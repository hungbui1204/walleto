import { serve } from "https://deno.land/std@0.178.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  try {
    const { email, password } = await req.json();

    // 1. Validate + check user exists (RPC của bạn)
    const { data: exists } = await supabaseAdmin.rpc("check_user_exists", { target_email: email });
    if (exists !== true) {
      return new Response(JSON.stringify({ 
        msg: "User not found", 
        code: 404 
      }), { status: 404 });
    }

    // 2. Lấy user ID siêu nhanh (1 query)
    const { data: userId, error: idError } = await supabaseAdmin.rpc(
      "get_user_id_by_email", 
      { p_email: email }
    );

    if (idError || !userId) throw new Error("User ID not found");

    // 3. Update password (1 query)
    const { data: updatedUser, error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
      userId, 
      { password }
    );

    if (updateError) throw updateError;

    return new Response(JSON.stringify({ 
      msg: "Password reset successfully", 
      user_id: updatedUser.user.id 
    }), { status: 200 });

  } catch (err) {
    return new Response(JSON.stringify({ 
      msg: err.message, 
      code: 500 
    }), { status: 500 });
  }
});

