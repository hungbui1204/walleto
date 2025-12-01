import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  try {
    const { email, code } = await req.json();

    // Validate input
    if (!email || !code) {
      return new Response(JSON.stringify({ 
        msg: "Email and OTP code are required",
        code: 400,
        error_code: "missing_fields"
      }), { 
        status: 400,
        headers: { "Content-Type": "application/json" }
      });
    }

    console.log("Verifying reset password OTP for:", email, code);

    // Get unused and unexpired OTP (dùng table otp_codes hiện tại)
    const { data: otpRow, error } = await supabaseAdmin
      .from("otp_codes")
      .select("*")
      .eq("email", email)
      .eq("code", code)
      .eq("used", false)
      .gte("expires_at", new Date().toISOString())
      .maybeSingle();

    if (error) {
      console.error("Supabase error:", error);
      return new Response(JSON.stringify({ 
        msg: "Database error",
        code: 500,
        error_code: "database_error"
      }), { 
        status: 500,
        headers: { "Content-Type": "application/json" }
      });
    }

    if (!otpRow) {
      console.log("Invalid or expired OTP for:", email);
      return new Response(JSON.stringify({ 
        msg: "Invalid or expired OTP",
        code: 400,
        error_code: "invalid_or_expired_otp"
      }), { 
        status: 400,
        headers: { "Content-Type": "application/json" }
      });
    }

    // Mark OTP as used
    const { error: updateError } = await supabaseAdmin
      .from("otp_codes")
      .update({ used: true })
      .eq("id", otpRow.id);

    if (updateError) {
      console.error("Error marking OTP as used:", updateError);
      return new Response(JSON.stringify({ 
        msg: "OTP validation failed",
        code: 500,
        error_code: "otp_update_failed"
      }), { 
        status: 500,
        headers: { "Content-Type": "application/json" }
      });
    }

    console.log("Reset password OTP verified successfully for:", email);

    return new Response(JSON.stringify({ 
      msg: "Reset password OTP verified successfully",
      valid: true,
      code: 200
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });

  } catch (err) {
    console.error("OTP verify error:", err);
    return new Response(JSON.stringify({ 
      msg: err.message || "Internal server error",
      code: 500,
      error_code: "internal_error"
    }), { 
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
});
