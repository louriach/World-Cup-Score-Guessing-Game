import { createClient } from "jsr:@supabase/supabase-js@2";

const FOOTBALL_API_KEY = Deno.env.get("FOOTBALL_DATA_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SERVICE_ROLE_KEY")!;

const API_BASE = "https://api.football-data.org/v4";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Run periodically (every 5 min during tournament) via Supabase cron
// Finds fixtures that have finished but aren't yet settled, fetches results, scores guesses
Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    // Find fixtures that kicked off over 100 minutes ago and are still not completed
    const cutoff = new Date(Date.now() - 100 * 60 * 1000).toISOString();

    const { data: pending, error: fetchError } = await supabase
      .from("fixtures")
      .select("id, external_id")
      .eq("status", "scheduled")
      .lt("kickoff_time", cutoff);

    if (fetchError) throw fetchError;
    if (!pending || pending.length === 0) {
      return new Response(JSON.stringify({ settled: 0 }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    let settled = 0;

    for (const fixture of pending) {
      const res = await fetch(`${API_BASE}/matches/${fixture.external_id}`, {
        headers: { "X-Auth-Token": FOOTBALL_API_KEY },
      });

      if (!res.ok) continue;

      const { match } = await res.json();

      if (match.status !== "FINISHED") continue;

      const homeScore = match.score?.fullTime?.home;
      const awayScore = match.score?.fullTime?.away;

      if (homeScore === null || awayScore === null) continue;

      // Detect penalties: football-data.org sets score.penalties when applicable
      const wentToPenalties = !!match.score?.penalties;

      // Mark fixture as completed with result
      const { error: updateError } = await supabase
        .from("fixtures")
        .update({
          status: "completed",
          home_score: homeScore,
          away_score: awayScore,
          went_to_penalties: wentToPenalties,
          updated_at: new Date().toISOString(),
        })
        .eq("id", fixture.id);

      if (updateError) {
        console.error(`Failed to update fixture ${fixture.id}:`, updateError);
        continue;
      }

      // Score all guesses for this fixture atomically
      const { error: settleError } = await supabase.rpc("settle_fixture_guesses", {
        p_fixture_id: fixture.id,
      });

      if (settleError) {
        console.error(`Failed to settle guesses for ${fixture.id}:`, settleError);
        continue;
      }

      // Fire result notifications — best-effort, don't fail settlement if this errors
      fetch(`${SUPABASE_URL}/functions/v1/send-notifications`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        },
        body: JSON.stringify({ type: "result", fixture_id: fixture.id }),
      }).catch((e) => console.error("Failed to trigger result notification:", e));

      settled++;
    }

    return new Response(JSON.stringify({ settled }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("settle-results error:", err);
    return new Response(JSON.stringify({ error: "Settlement failed" }), { status: 500 });
  }
});
