import { createClient } from "jsr:@supabase/supabase-js@2";

// Secrets are injected by Supabase at runtime — never hard-coded
const FOOTBALL_API_KEY = Deno.env.get("FOOTBALL_DATA_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SERVICE_ROLE_KEY")!;

const COMPETITION_CODE = "WC"; // football-data.org code for FIFA World Cup
const API_BASE = "https://api.football-data.org/v4";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

Deno.serve(async (req) => {
  // Only allow POST requests from authenticated Supabase cron or admin calls
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const res = await fetch(`${API_BASE}/competitions/${COMPETITION_CODE}/matches`, {
      headers: { "X-Auth-Token": FOOTBALL_API_KEY },
    });

    if (!res.ok) {
      throw new Error(`football-data.org error: ${res.status}`);
    }

    const data = await res.json();
    const matches = data.matches as FootballMatch[];

    // Skip fixtures where teams aren't determined yet (knockout placeholders)
    const knownMatches = matches.filter((m) => m.homeTeam.name && m.awayTeam.name && m.matchday !== null);

    const fixtures = knownMatches.map((m) => {
      const kickoff = new Date(m.utcDate);
      const lockTime = new Date(kickoff.getTime() - 15 * 60 * 1000); // minus 15 min

      return {
        external_id: String(m.id),
        matchday: m.matchday,
        stage: normaliseStage(m.stage),
        home_team: m.homeTeam.name,
        away_team: m.awayTeam.name,
        home_crest_url: m.homeTeam.crest ?? null,
        away_crest_url: m.awayTeam.crest ?? null,
        kickoff_time: kickoff.toISOString(),
        guess_lock_time: lockTime.toISOString(),
        status: normaliseStatus(m.status),
        home_score: m.score?.fullTime?.home ?? null,
        away_score: m.score?.fullTime?.away ?? null,
      };
    });

    // Upsert — safe to run repeatedly; updates existing rows, inserts new ones
    const { error } = await supabase
      .from("fixtures")
      .upsert(fixtures, { onConflict: "external_id" });

    if (error) throw error;

    return new Response(
      JSON.stringify({ synced: fixtures.length, skipped: matches.length - knownMatches.length }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("sync-fixtures error:", err);
    // Never expose internal error details to the caller
    return new Response(JSON.stringify({ error: "Sync failed" }), { status: 500 });
  }
});

function normaliseStage(stage: string): string {
  const map: Record<string, string> = {
    "GROUP_STAGE": "group",
    "ROUND_OF_16": "round_of_16",
    "QUARTER_FINALS": "quarter_final",
    "SEMI_FINALS": "semi_final",
    "FINAL": "final",
  };
  return map[stage] ?? stage.toLowerCase();
}

function normaliseStatus(status: string): string {
  const map: Record<string, string> = {
    "SCHEDULED": "scheduled",
    "TIMED": "scheduled",
    "IN_PLAY": "live",
    "PAUSED": "live",
    "FINISHED": "completed",
    "POSTPONED": "postponed",
    "CANCELLED": "postponed",
  };
  return map[status] ?? "scheduled";
}

interface FootballMatch {
  id: number;
  matchday: number;
  stage: string;
  status: string;
  utcDate: string;
  homeTeam: { name: string; crest?: string };
  awayTeam: { name: string; crest?: string };
  score: {
    fullTime: { home: number | null; away: number | null };
  };
}
