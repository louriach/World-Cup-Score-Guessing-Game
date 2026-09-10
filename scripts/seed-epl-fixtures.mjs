/**
 * Seed EPL fixtures from football-data.org into Supabase.
 *
 * Usage:
 *   FOOTBALL_DATA_API_KEY=your_key SUPABASE_URL=https://xxx.supabase.co SUPABASE_SERVICE_ROLE_KEY=your_key node scripts/seed-epl-fixtures.mjs
 */

const FOOTBALL_DATA_BASE = 'https://api.football-data.org/v4';
const EPL_COMPETITION = 'PL'; // Premier League code

const { FOOTBALL_DATA_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY } = process.env;

if (!FOOTBALL_DATA_API_KEY || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing required environment variables: FOOTBALL_DATA_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

async function fetchFixtures() {
  const res = await fetch(`${FOOTBALL_DATA_BASE}/competitions/${EPL_COMPETITION}/matches?season=2026`, {
    headers: { 'X-Auth-Token': FOOTBALL_DATA_API_KEY },
  });

  if (!res.ok) {
    throw new Error(`football-data.org error: ${res.status} ${await res.text()}`);
  }

  const data = await res.json();
  return data.matches;
}

function mapStatus(match) {
  switch (match.status) {
    case 'FINISHED': return 'completed';
    case 'IN_PLAY':
    case 'PAUSED': return 'live';
    case 'POSTPONED':
    case 'CANCELLED':
    case 'SUSPENDED': return 'postponed';
    default: return 'scheduled';
  }
}

function toRow(match) {
  const kickoff = new Date(match.utcDate);
  const lockTime = new Date(kickoff.getTime() - 15 * 60 * 1000); // 15 min before kickoff

  const status = mapStatus(match);
  const isCompleted = status === 'completed';

  return {
    external_id: String(match.id),
    matchday: match.matchday ?? 0,
    stage: match.stage?.toLowerCase() ?? 'regular_season',
    home_team: match.homeTeam.shortName ?? match.homeTeam.name,
    away_team: match.awayTeam.shortName ?? match.awayTeam.name,
    home_crest_url: match.homeTeam.crest ?? null,
    away_crest_url: match.awayTeam.crest ?? null,
    kickoff_time: kickoff.toISOString(),
    guess_lock_time: lockTime.toISOString(),
    status,
    home_score: isCompleted ? (match.score.fullTime.home ?? null) : null,
    away_score: isCompleted ? (match.score.fullTime.away ?? null) : null,
    went_to_penalties: null, // EPL has no penalties (league format)
  };
}

async function upsertFixtures(rows) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/fixtures`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_SERVICE_ROLE_KEY,
      'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'Prefer': 'resolution=merge-duplicates',
    },
    body: JSON.stringify(rows),
  });

  if (!res.ok) {
    throw new Error(`Supabase upsert error: ${res.status} ${await res.text()}`);
  }
}

async function main() {
  console.log('Fetching EPL fixtures from football-data.org...');
  const matches = await fetchFixtures();
  console.log(`Fetched ${matches.length} matches.`);

  const rows = matches.map(toRow);

  console.log('Upserting into Supabase...');
  await upsertFixtures(rows);
  console.log('Done.');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
