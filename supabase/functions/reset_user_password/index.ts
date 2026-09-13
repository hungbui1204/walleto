import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";
import {
  consumeValidOtp,
  isValidOtpCode,
  jsonResponse,
  normalizeEmail,
} from "../_shared/otp.ts";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

serve(async (req) => {
  try {
    const { email: rawEmail, password, code } = await req.json();
    const email = normalizeEmail(rawEmail);

    if (!email || typeof password !== "string" || !password || !isValidOtpCode(code)) {
      return jsonResponse({
        msg: "Invalid or expired OTP",
        code: 400,
        error_code: "invalid_or_expired_otp",
      }, 400);
    }

    const consumed = await consumeValidOtp(supabaseAdmin, email, code, "reset");
    if (!consumed) {
      return jsonResponse({
        msg: "Invalid or expired OTP",
        code: 400,
        error_code: "invalid_or_expired_otp",
      }, 400);
    }

    const { data: userId, error: idError } = await supabaseAdmin.rpc(
      "get_user_id_by_email",
      { p_email: email },
    );
    if (idError || !userId) {
      return jsonResponse({
        msg: "Unable to reset password",
        code: 400,
        error_code: "unable_to_reset_password",
      }, 400);
    }

    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
      userId,
      { password },
    );
    if (updateError) throw updateError;

    return jsonResponse({ msg: "Password reset successfully" });
  } catch (err) {
    return jsonResponse({ msg: err.message, code: 500 }, 500);
  }
});
