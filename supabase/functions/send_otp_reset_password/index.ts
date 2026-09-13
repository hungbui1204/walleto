import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";
import {
  cleanupExpiredOtps,
  issueOtpIfAllowed,
  jsonResponse,
  normalizeEmail,
  OTP_SENT_MSG,
} from "../_shared/otp.ts";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

async function sendEmail(email: string, otp: string) {
  const res = await fetch("https://api.brevo.com/v3/smtp/email", {
    method: "POST",
    headers: {
      "api-key": Deno.env.get("BREVO_API_KEY")!,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      sender: { name: "Walleto", email: "noreply.walleto@gmail.com" },
      to: [{ email }],
      subject: "Reset Password OTP Code",
      htmlContent: `
        <h1>Reset Password OTP Code</h1>
        <p>Your OTP code: <strong>${otp}</strong></p>
        <p>Expires in 10 minutes</p>
        <p>If you didn't request this, please ignore this email.</p>
      `,
    }),
  });

  if (!res.ok) {
    throw new Error("Failed to send reset password email");
  }
}

serve(async (req) => {
  try {
    const { email: rawEmail } = await req.json();
    const email = normalizeEmail(rawEmail);
    if (!email) {
      return jsonResponse({ msg: "Email is required", code: 400, error_code: "missing_email" }, 400);
    }

    await cleanupExpiredOtps(supabaseAdmin);

    const { data: exists, error: sqlError } = await supabaseAdmin.rpc("check_user_exists", {
      target_email: email,
    });
    if (sqlError) throw sqlError;

    if (exists === true) {
      await issueOtpIfAllowed(supabaseAdmin, email, "reset", (otp) => sendEmail(email, otp));
    }

    return jsonResponse({ msg: OTP_SENT_MSG });
  } catch (err) {
    return jsonResponse({
      msg: err.message || "Internal server error",
      code: 500,
    }, 500);
  }
});
