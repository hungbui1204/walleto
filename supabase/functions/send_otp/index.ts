import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

// Supabase Admin client
const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

// Create 6-digit OTP function
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Function to send email via Brevo
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
      subject: "Your sign up OTP code",
      htmlContent: `<h1>Your OTP code: ${otp}</h1><p>Expires in 10 minutes</p>`,
    }),
  });

  if (!res.ok) {
    throw new Error("Failed to send email");
  }
}

// Edge function
serve(async (req) => {
  try {
    const { email } = await req.json();

    // Check if email already exists
    const { data: exists, error: sqlError } = await supabaseAdmin.rpc("check_user_exists", {
      target_email: email
    });

    if (sqlError) throw sqlError;

    if (exists === true) {
      return new Response(JSON.stringify({ message: "Email already exists" }), { status: 400 });
    }

    // Create OTP
    const otp = generateOtp();
    const expires_at = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Save OTP to table
    const { error: dbError } = await supabaseAdmin
      .from("otp_codes")
      .insert([{ email, code: otp, expires_at }]);

    if (dbError) throw dbError;

    // Send email
    await sendEmail(email, otp);

    return new Response(JSON.stringify({ message: "OTP sent" }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ message: err.message }), { status: 500 });
  }
});
