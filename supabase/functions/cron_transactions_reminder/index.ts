import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { encode } from "https://deno.land/std@0.168.0/encoding/base64.ts";
import { crypto } from "https://deno.land/std@0.168.0/crypto/mod.ts";

const SERVICE_ACCOUNT = {
  private_key: Deno.env.get("GOOGLE_PRIVATE_KEY")!,
  client_email: Deno.env.get("GOOGLE_CLIENT_EMAIL")!,
  project_id: Deno.env.get("GOOGLE_PROJECT_ID")!,
};

const SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"];

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

function decodePrivateKey(pem: string): ArrayBuffer {
  const pemBody = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\n/g, "");
  const binary = atob(pemBody);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}


function dateTimePartsInZone(date: Date, timeZone: string) {
  const fmt = new Intl.DateTimeFormat("en-US", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hourCycle: "h23",
  });
  const parts = Object.fromEntries(
    fmt.formatToParts(date).map((p) => [p.type, p.value]),
  );
  return {
    year: Number(parts.year),
    month: Number(parts.month),
    day: Number(parts.day),
    hour: Number(parts.hour === "24" ? "0" : parts.hour),
    minute: Number(parts.minute),
    second: Number(parts.second),
  };
}

function calendarDateInZone(date: Date, timeZone: string): string {
  const p = dateTimePartsInZone(date, timeZone);
  const y = p.year.toString().padStart(4, "0");
  const m = p.month.toString().padStart(2, "0");
  const d = p.day.toString().padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function addOneCalendarDay(ymd: string): string {
  const [y, m, d] = ymd.split("-").map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d + 1));
  return dt.toISOString().slice(0, 10);
}

function zonedCivilToUtc(ymd: string, hms: string, timeZone: string): Date {
  const [y, month, d] = ymd.split("-").map(Number);
  const [hh, mm, ss] = hms.split(":").map(Number);
  let utc = Date.UTC(y, month - 1, d, hh, mm, ss);
  for (let i = 0; i < 3; i++) {
    const local = dateTimePartsInZone(new Date(utc), timeZone);
    const localMs = Date.UTC(
      local.year,
      local.month - 1,
      local.day,
      local.hour,
      local.minute,
      local.second,
    );
    const wanted = Date.UTC(y, month - 1, d, hh, mm, ss);
    const diff = wanted - localMs;
    utc += diff;
    if (diff === 0) break;
  }
  return new Date(utc);
}

serve(async (req) => {
  const provided = req.headers.get("x-cron-secret") ?? "";
  const { data: secretOk, error: secretError } = await supabase.rpc(
    "verify_cron_secret",
    { p_secret: provided },
  );
  if (secretError || secretOk !== true) {
    return new Response(JSON.stringify({ msg: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const now = new Date();

  const { data: profiles, error } = await supabase
    .from("profiles")
    .select("id, fcm_token, timezone")
    .not("fcm_token", "is", null)
    .not("timezone", "is", null);

  if (error) {
    console.error("Failed to get profiles:", error);
    return new Response("Error getting profiles", { status: 500 });
  }

  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 3600;

  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  const payload = {
    iss: SERVICE_ACCOUNT.client_email,
    scope: SCOPES.join(" "),
    aud: "https://oauth2.googleapis.com/token",
    exp,
    iat,
  };

  const base64Url = (obj: unknown) =>
    encode(new TextEncoder().encode(JSON.stringify(obj)))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

  const unsignedToken = `${base64Url(header)}.${base64Url(payload)}`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    decodePrivateKey(SERVICE_ACCOUNT.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedToken),
  );

  const signedJWT = `${unsignedToken}.${encode(new Uint8Array(signature))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "")}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: signedJWT,
    }),
  });

  const { access_token } = await tokenRes.json();

  const results = [];

  for (const profile of profiles) {
    const tzDate = calendarDateInZone(now, profile.timezone);
    const nextDate = addOneCalendarDay(tzDate);
    const startIso = zonedCivilToUtc(tzDate, "00:00:00", profile.timezone).toISOString();
    const endIso = zonedCivilToUtc(nextDate, "00:00:00", profile.timezone).toISOString();

    const { count, error: transError } = await supabase
      .from("transactions")
      .select("*", { count: "exact", head: true })
      .eq("user_id", profile.id)
      .gte("transaction_date", startIso)
      .lt("transaction_date", endIso);

    if (transError) {
      console.error("Transaction query failed for user:", profile.id, transError);
      continue;
    }

    if ((count ?? 0) === 0) {
      const fcmRes = await fetch(
        `https://fcm.googleapis.com/v1/projects/${SERVICE_ACCOUNT.project_id}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${access_token}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token: profile.fcm_token,
              notification: {
                title: "Walleto",
                body: "💰Did you forget to add transactions today?\n👉 Create new transactions now",
              },
            },
          }),
        },
      );
      const fcmResult = await fcmRes.json();
      results.push({ user_id: profile.id, status: fcmRes.status, fcmResult });
    }
  }

  return new Response(JSON.stringify({ sent: results.length, results }), {
    status: 200,
  });
});
