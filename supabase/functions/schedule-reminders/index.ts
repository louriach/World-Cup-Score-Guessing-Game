import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Runs every 30 minutes via cron.
// Finds fixtures whose 24h or 1h reminder window is now due and fires them.
Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const now = new Date();

  // 24h window: kickoff is between 23h55m and 24h05m from now
  const window24hStart = new Date(now.getTime() + 23 * 60 * 60 * 1000 + 55 * 60 * 1000);
  const window24hEnd   = new Date(now.getTime() + 24 * 60 * 60 * 1000 + 5  * 60 * 1000);

  // 1h window: kickoff is between 55m and 65m from now
  const window1hStart  = new Date(now.getTime() + 55 * 60 * 1000);
  const window1hEnd    = new Date(now.getTime() + 65 * 60 * 1000);

  const { data: fixtures24h } = await supabase
    .from("fixtures")
    .select("id")
    .eq("status", "scheduled")
    .gte("kickoff_time", window24hStart.toISOString())
    .lte("kickoff_time", window24hEnd.toISOString());

  const { data: fixtures1h } = await supabase
    .from("fixtures")
    .select("id")
    .eq("status", "scheduled")
    .gte("kickoff_time", window1hStart.toISOString())
    .lte("kickoff_time", window1hEnd.toISOString());

  const tasks: Promise<void>[] = [];

  for (const f of fixtures24h ?? []) {
    tasks.push(triggerNotification("reminder_24h", f.id));
  }
  for (const f of fixtures1h ?? []) {
    tasks.push(triggerNotification("reminder_1h", f.id));
  }

  await Promise.allSettled(tasks);

  return new Response(
    JSON.stringify({
      triggered_24h: fixtures24h?.length ?? 0,
      triggered_1h: fixtures1h?.length ?? 0,
    }),
    { headers: { "Content-Type": "application/json" } },
  );
});

async function triggerNotification(
  type: string,
  fixtureId: string,
): Promise<void> {
  await fetch(`${SUPABASE_URL}/functions/v1/send-notifications`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
    },
    body: JSON.stringify({ type, fixture_id: fixtureId }),
  });
}
