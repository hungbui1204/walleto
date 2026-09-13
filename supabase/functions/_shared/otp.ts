export type OtpPurpose = "signup" | "reset";

// deno-lint-ignore no-explicit-any
export type AdminClient = any;

export const OTP_TTL_MS = 10 * 60 * 1000;
export const OTP_RESEND_COOLDOWN_MS = 60 * 1000;
export const OTP_MAX_FAILED_ATTEMPTS = 5;
export const OTP_SENT_MSG = "OTP sent";

const recentSends = new Map<string, number>();

export function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export function normalizeEmail(email: unknown): string {
  return typeof email === "string" ? email.trim().toLowerCase() : "";
}

export function isValidOtpCode(code: unknown): code is string {
  return typeof code === "string" && /^\d{6}$/.test(code);
}

export function generateOtp(): string {
  const buf = new Uint32Array(1);
  const max = 4294000000;
  let n: number;
  do {
    crypto.getRandomValues(buf);
    n = buf[0] % 1_000_000;
  } while (buf[0] >= max);
  return n.toString().padStart(6, "0");
}

export async function hashOtp(code: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(code),
  );
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function memoryKey(email: string, purpose: OtpPurpose): string {
  return `${purpose}:${email}`;
}

export function isMemoryRateLimited(email: string, purpose: OtpPurpose): boolean {
  const last = recentSends.get(memoryKey(email, purpose)) ?? 0;
  return Date.now() - last < OTP_RESEND_COOLDOWN_MS;
}

export function markMemorySent(email: string, purpose: OtpPurpose): void {
  recentSends.set(memoryKey(email, purpose), Date.now());
}

export async function cleanupExpiredOtps(admin: AdminClient): Promise<void> {
  await admin.from("otp_codes").delete().lt("expires_at", new Date().toISOString());
}

export async function isDbRateLimited(
  admin: AdminClient,
  email: string,
  purpose: OtpPurpose,
): Promise<boolean> {
  const since = new Date(Date.now() - OTP_RESEND_COOLDOWN_MS).toISOString();
  const { data, error } = await admin
    .from("otp_codes")
    .select("id")
    .eq("email", email)
    .eq("purpose", purpose)
    .gte("created_at", since)
    .limit(1);
  if (error) throw error;
  return (data?.length ?? 0) > 0;
}

export async function insertHashedOtp(
  admin: AdminClient,
  email: string,
  purpose: OtpPurpose,
  codeHash: string,
): Promise<void> {
  const { error } = await admin.from("otp_codes").insert([{
    email,
    code: codeHash,
    purpose,
    used: false,
    failed_attempts: 0,
    expires_at: new Date(Date.now() + OTP_TTL_MS).toISOString(),
  }]);
  if (error) throw error;
}

type OtpRow = { id: number; failed_attempts: number };

async function findMatchingOtp(
  admin: AdminClient,
  email: string,
  codeHash: string,
  purpose: OtpPurpose,
): Promise<OtpRow | null> {
  const { data, error } = await admin
    .from("otp_codes")
    .select("id, failed_attempts")
    .eq("email", email)
    .eq("code", codeHash)
    .eq("purpose", purpose)
    .eq("used", false)
    .gt("expires_at", new Date().toISOString())
    .order("id", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (error) throw error;
  if (!data) return null;
  if ((data.failed_attempts ?? 0) >= OTP_MAX_FAILED_ATTEMPTS) return null;
  return data as OtpRow;
}

export async function recordFailedAttempt(
  admin: AdminClient,
  email: string,
  purpose: OtpPurpose,
): Promise<void> {
  const { data, error } = await admin
    .from("otp_codes")
    .select("id, failed_attempts")
    .eq("email", email)
    .eq("purpose", purpose)
    .eq("used", false)
    .gt("expires_at", new Date().toISOString())
    .order("id", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (error) throw error;
  if (!data) return;
  const next = (data.failed_attempts ?? 0) + 1;
  const patch: Record<string, unknown> = { failed_attempts: next };
  if (next >= OTP_MAX_FAILED_ATTEMPTS) patch.used = true;
  const { error: updateError } = await admin.from("otp_codes").update(patch).eq("id", data.id);
  if (updateError) throw updateError;
}

export async function peekValidOtp(
  admin: AdminClient,
  email: string,
  code: string,
  purpose: OtpPurpose,
): Promise<boolean> {
  const codeHash = await hashOtp(code);
  const row = await findMatchingOtp(admin, email, codeHash, purpose);
  if (!row) {
    await recordFailedAttempt(admin, email, purpose);
    return false;
  }
  return true;
}

export async function consumeValidOtp(
  admin: AdminClient,
  email: string,
  code: string,
  purpose: OtpPurpose,
): Promise<boolean> {
  const codeHash = await hashOtp(code);
  const row = await findMatchingOtp(admin, email, codeHash, purpose);
  if (!row) {
    await recordFailedAttempt(admin, email, purpose);
    return false;
  }
  const { data, error } = await admin
    .from("otp_codes")
    .update({ used: true })
    .eq("id", row.id)
    .eq("used", false)
    .select("id")
    .maybeSingle();
  if (error) throw error;
  return !!data;
}

export async function issueOtpIfAllowed(
  admin: AdminClient,
  email: string,
  purpose: OtpPurpose,
  sendEmail: (otp: string) => Promise<void>,
): Promise<void> {
  if (isMemoryRateLimited(email, purpose)) return;
  if (await isDbRateLimited(admin, email, purpose)) return;

  const otp = generateOtp();
  await insertHashedOtp(admin, email, purpose, await hashOtp(otp));
  await sendEmail(otp);
  markMemorySent(email, purpose);
}
