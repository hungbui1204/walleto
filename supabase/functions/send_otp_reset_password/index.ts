import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

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
    const { email } = await req.json();

    if (!email) {
      return new Response(JSON.stringify({ 
        msg: "Email is required",
        code: 400,
        error_code: "missing_email"
      }), {
        status: 400,
        headers: { "Content-Type": "application/json" }
      });
    }

    // Check user exists (PHẢI tồn tại cho reset password)
    const { data: exists, error: sqlError } = await supabaseAdmin.rpc("check_user_exists", {
      target_email: email
    });

    if (sqlError) throw sqlError;
    if (exists !== true) {
      return new Response(JSON.stringify({ 
        msg: "User not found",
        code: 404,
        error_code: "user_not_found"
      }), {
        status: 404,
        headers: { "Content-Type": "application/json" }
      });
    }

    // Tạo OTP mới
    const otp = generateOtp();
    const expires_at = new Date(Date.now() + 10 * 60 * 1000);

    // Lưu OTP vào otp_codes table 
    const { error: dbError } = await supabaseAdmin
      .from("otp_codes")
      .insert([{ 
        email, 
        code: otp, 
        expires_at 
      }]);

    if (dbError) throw dbError;

    // Gửi email
    await sendEmail(email, otp);

    return new Response(JSON.stringify({ 
      msg: "Reset password OTP sent successfully"
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });

  } catch (err) {
    console.error("Send reset OTP error:", err);
    return new Response(JSON.stringify({ 
      msg: err.message || "Internal server error",
      code: 500
    }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
});
