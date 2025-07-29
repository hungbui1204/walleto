import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { encode } from "https://deno.land/std@0.168.0/encoding/base64.ts";
import { crypto } from "https://deno.land/std@0.168.0/crypto/mod.ts";

const SERVICE_ACCOUNT = {
  private_key: Deno.env.get("GOOGLE_PRIVATE_KEY")!,
  client_email: Deno.env.get("GOOGLE_CLIENT_EMAIL")!,
  project_id: Deno.env.get("GOOGLE_PROJECT_ID")!,
};

const SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"];

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

function decodePrivateKey(pem: string): ArrayBuffer {
  const pemBody = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\n/g, "");
  const binary = atob(pemBody);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

serve(async () => {
  const now = new Date();
  const today = now.toISOString().split("T")[0];

  // 1. Get user profiles with fcm_token and timezone
  const { data: profiles, error } = await supabase
    .from("profiles")
    .select("id, fcm_token, timezone")
    .not("fcm_token", "is", null)
    .not("timezone", "is", null);

  if (error) {
    console.error("Failed to get profiles:", error);
    return new Response("Error getting profiles", { status: 500 });
  }

  // 2. Prepare Firebase token
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 3600;

  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  const payload = {
    iss: SERVICE_ACCOUNT.client_email,
    scope: SCOPES.join(" "),
    aud: "https://oauth2.googleapis.com/token",
    exp,
    iat,
  };

  const base64Url = (obj: unknown) =>
    encode(new TextEncoder().encode(JSON.stringify(obj)))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

  const unsignedToken = `${base64Url(header)}.${base64Url(payload)}`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    decodePrivateKey(SERVICE_ACCOUNT.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedToken)
  );

  const signedJWT = `${unsignedToken}.${encode(new Uint8Array(signature))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "")}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: signedJWT,
    }),
  });

  const { access_token } = await tokenRes.json();

  // 3. Check and send notification
  const results = [];

  for (const profile of profiles) {
    const tzNow = new Date(now.toLocaleString("en-US", { timeZone: profile.timezone }));
    const tzDate = tzNow.toISOString().split("T")[0];

    const { count, error: transError } = await supabase
      .from("transactions")
      .select("*", { count: "exact", head: true })
      .eq("user_id", profile.id)
      .gte("created_at", `${tzDate}T00:00:00`)
      .lte("created_at", `${tzDate}T23:59:59`);

    if (transError) {
      console.error("Transaction query failed for user:", profile.id, transError);
      continue;
    }

    if ((count ?? 0) === 0) {
      // Send FCM push
      const fcmRes = await fetch(
        `https://fcm.googleapis.com/v1/projects/${SERVICE_ACCOUNT.project_id}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${access_token}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token: profile.fcm_token,
              notification: {
                title: "Walleto",
                body: "💰Did you forget to add transactions today?\n👉 Create new transactions now",
              },
            },
          }),
        }
      );
      const fcmResult = await fcmRes.json();
      results.push({ user_id: profile.id, status: fcmRes.status, fcmResult });
    }
  }

  return new Response(JSON.stringify({ sent: results.length, results }), {
    status: 200,
  });
});
