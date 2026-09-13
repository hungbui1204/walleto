import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";
import {
  isValidOtpCode,
  jsonResponse,
  normalizeEmail,
  peekValidOtp,
} from "../_shared/otp.ts";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

serve(async (req) => {
  try {
    const { email: rawEmail, code } = await req.json();
    const email = normalizeEmail(rawEmail);
    if (!email || !isValidOtpCode(code)) {
      return jsonResponse({
        msg: "Email and OTP code are required",
        code: 400,
        error_code: "missing_fields",
      }, 400);
    }

    const valid = await peekValidOtp(supabaseAdmin, email, code, "reset");
    if (!valid) {
      return jsonResponse({
        msg: "Invalid or expired OTP",
        code: 400,
        error_code: "invalid_or_expired_otp",
      }, 400);
    }

    return jsonResponse({
      msg: "Reset password OTP verified successfully",
      valid: true,
      code: 200,
    });
  } catch (err) {
    return jsonResponse({
      msg: err.message || "Internal server error",
      code: 500,
      error_code: "internal_error",
    }, 500);
  }
});
