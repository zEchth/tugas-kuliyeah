import { serve } from "https://deno.land/std/http/server.ts";
import { encodeBase64Url } from "https://deno.land/std@0.224.0/encoding/base64url.ts";
import { crypto } from "https://deno.land/std/crypto/mod.ts";

const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
if (!raw) throw new Error("ENV FIREBASE_SERVICE_ACCOUNT KOSONG");
const SA = JSON.parse(raw);

let cachedToken = "";
let tokenExp = 0;


async function createJWT() {
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: SA.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const enc = (obj: object) =>
    encodeBase64Url(new TextEncoder().encode(JSON.stringify(obj)));


  const data = `${enc(header)}.${enc(payload)}`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToBuf(SA.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(data)
  );

  return `${data}.${encodeBase64Url(new Uint8Array(signature))}`;
}

function pemToBuf(pem: string) {
  const b64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s+/g, "");

  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);

  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes.buffer;
}


async function getAccessToken() {
  if (cachedToken && Date.now() < tokenExp) return cachedToken;

  const jwt = await createJWT();
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const data = await res.json();
  cachedToken = data.access_token;
  tokenExp = Date.now() + 55 * 60 * 1000;
  return cachedToken;
}


serve(async (req: { json: () => PromiseLike<{ token: any; title: any; body: any; }> | { token: any; title: any; body: any; }; }) => {
  try {
    const { token, title, body } = await req.json();
    const accessToken = await getAccessToken();

    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${SA.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: { token, notification: { title, body } },
        }),
      }
    );

    return new Response(await res.text(), { status: res.status });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: e.message }),
      { status: 500 }
    );
  }
});