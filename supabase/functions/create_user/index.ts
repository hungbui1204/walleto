import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  try {
    const { email, password } = await req.json();

    // Check if user exists
    const { data: exists, error: checkError } = await supabaseAdmin.rpc(
      "check_user_exists",
      { target_email: email }
    );

    if (checkError) {
      console.error("Error checking user:", checkError);
      throw checkError;
    }

    if (exists === true) {
      return new Response(
        JSON.stringify({ 
          msg: "User already exists",
          code: 400,
          error_code: "user_already_exists",
          
        }),
        { status: 400,
          headers: {
            "Content-Type": "application/json"
          }
        }
      );
    }

    // Create new user
    const { data: newUser, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true
    });

    if (error) throw error;

    return new Response(JSON.stringify({ msg: "User created successfully", user: newUser }), { 
      status: 200,
      headers: {
        "Content-Type": "application/json"
      }
    });
  } catch (err) {
    return new Response(JSON.stringify({ msg: err.message, code: 500 }), { 
      status: 500,
      headers: {
        "Content-Type": "application/json"
      }
    });
  }
});
