import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  try {
    const { email, code } = await req.json();

    // Get unused and unexpired OTP
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
    }

      console.log("Verifying OTP for:", email, code);


    if (!otpRow) return new Response(JSON.stringify({ 
      msg: "Invalid or expired OTP",
      code: 400,
      error_code: "invalid_or_expired_otp",
    }), { 
      status: 400,
      headers: {
          "Content-Type": "application/json"
        }
    });

    // Mark OTP as used
    await supabaseAdmin
      .from("otp_codes")
      .update({ used: true })
      .eq("id", otpRow.id);

    return new Response(JSON.stringify({ 
      msg: "Email confirmed successfully"
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json"
      }
    });

  } catch (err) {
    return new Response(JSON.stringify({ 
      msg: err.message,
      code: 500,
    }), { 
      status: 500,
      headers: {
        "Content-Type": "application/json"
      }
    });
  }
});
