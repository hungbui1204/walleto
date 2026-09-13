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

    const consumed = await consumeValidOtp(supabaseAdmin, email, code, "signup");
    if (!consumed) {
      return jsonResponse({
        msg: "Invalid or expired OTP",
        code: 400,
        error_code: "invalid_or_expired_otp",
      }, 400);
    }

    const { data: exists, error: checkError } = await supabaseAdmin.rpc(
      "check_user_exists",
      { target_email: email },
    );
    if (checkError) throw checkError;

    if (exists === true) {
      return jsonResponse({
        msg: "Unable to create user",
        code: 400,
        error_code: "unable_to_create_user",
      }, 400);
    }

    const { data: newUser, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });
    if (error) throw error;

    const { error: profileError } = await supabaseAdmin.from("profiles").insert({
      id: newUser.user.id,
      email,
      created_at: new Date().toISOString(),
    });

    if (profileError) {
      await supabaseAdmin.auth.admin.deleteUser(newUser.user.id);
      throw profileError;
    }

    return jsonResponse({ msg: "User created successfully" });
  } catch (err) {
    return jsonResponse({ msg: err.message, code: 500 }, 500);
  }
});
