import { createClient } from "jsr:@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SERVICE_ROLE_KEY")!;

// Service account JSON stored as a single secret — never in code or git
const FCM_SERVICE_ACCOUNT = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT_JSON")!);

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

type NotificationType = "reminder_24h" | "reminder_1h" | "result";

interface NotifyRequest {
  type: NotificationType;
  fixture_id: string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  let body: NotifyRequest;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), { status: 400 });
  }

  const { type, fixture_id } = body;
  if (!type || !fixture_id) {
    return new Response(JSON.stringify({ error: "Missing type or fixture_id" }), { status: 400 });
  }

  try {
    const { data: fixture, error: fixtureError } = await supabase
      .from("fixtures")
      .select("*")
      .eq("id", fixture_id)
      .single();

    if (fixtureError || !fixture) throw new Error(`Fixture not found: ${fixture_id}`);

    const { title, body: notifBody, data } = buildNotification(type, fixture);

    const { data: targets, error: targetsError } = await supabase
      .rpc("get_notification_targets", { p_fixture_id: fixture_id, p_type: type });

    if (targetsError) throw targetsError;
    if (!targets || targets.length === 0) {
      return new Response(JSON.stringify({ sent: 0 }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const accessToken = await getFcmAccessToken();
    const projectId = FCM_SERVICE_ACCOUNT.project_id;
    let sent = 0;

    // FCM v1 sends one message per token (no batch endpoint)
    // For <100 users this is fine; parallelise with Promise.allSettled
    const results = await Promise.allSettled(
      targets.map((t: { token: string }) =>
        sendFcmV1(accessToken, projectId, t.token, title, notifBody, data)
      ),
    );

    sent = results.filter((r) => r.status === "fulfilled").length;

    // Log to prevent duplicates
    await supabase.from("notifications_log").insert(
      targets.map((t: { user_id: string }) => ({
        user_id: t.user_id,
        fixture_id,
        type,
      })),
    );

    return new Response(JSON.stringify({ sent }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("send-notifications error:", err);
    return new Response(JSON.stringify({ error: "Failed to send" }), { status: 500 });
  }
});

// ── FCM v1 helpers ────────────────────────────────────────────────────────────

async function getFcmAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToBuffer(FCM_SERVICE_ACCOUNT.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: FCM_SERVICE_ACCOUNT.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: getNumericDate(0),
      exp: getNumericDate(3600),
    },
    privateKey,
  );

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const json = await res.json();
  return json.access_token as string;
}

async function sendFcmV1(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, unknown>,
): Promise<void> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: Object.fromEntries(
            Object.entries(data).map(([k, v]) => [k, String(v)]),
          ),
          apns: {
            payload: {
              aps: { alert: { title, body }, sound: "default", badge: 1 },
            },
          },
        },
      }),
    },
  );

  if (!res.ok) {
    throw new Error(`FCM send failed: ${res.status} ${await res.text()}`);
  }
}

function pemToBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");
  const binary = atob(b64);
  const buffer = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) buffer[i] = binary.charCodeAt(i);
  return buffer.buffer;
}

// ── Notification content ──────────────────────────────────────────────────────

function buildNotification(type: NotificationType, fixture: Record<string, unknown>) {
  const home = fixture.home_team as string;
  const away = fixture.away_team as string;
  const matchLabel = `${home} vs ${away}`;
  const baseData = { type, fixture_id: fixture.id as string };

  switch (type) {
    case "reminder_24h":
      return {
        title: "⚽ Prediction due tomorrow",
        body: `Don't forget to predict ${matchLabel}`,
        data: baseData,
      };
    case "reminder_1h":
      return {
        title: "⏰ Last chance to predict",
        body: `${matchLabel} locks in 45 minutes`,
        data: baseData,
      };
    case "result": {
      const homeScore = fixture.home_score as number;
      const awayScore = fixture.away_score as number;
      return {
        title: "📊 Result in",
        body: `${home} ${homeScore}–${awayScore} ${away} · See how you scored`,
        data: { ...baseData, home_score: homeScore, away_score: awayScore },
      };
    }
  }
}
