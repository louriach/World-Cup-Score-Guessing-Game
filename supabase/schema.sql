-- ============================================================
-- Golden Goals – Supabase Schema
-- ============================================================

-- Extensions
create extension if not exists "uuid-ossp";

-- ============================================================
-- STORAGE
-- Run after enabling the Storage extension in your Supabase project.
-- ============================================================
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict do nothing;

-- Anyone can view avatars (public bucket)
create policy "avatars_select" on storage.objects
  for select using (bucket_id = 'avatars');

-- Users can upload/update only their own avatar (path must start with their user id)
create policy "avatars_insert" on storage.objects
  for insert with check (
    bucket_id = 'avatars' and
    (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars_update" on storage.objects
  for update using (
    bucket_id = 'avatars' and
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- ============================================================
-- USERS
-- Extends Supabase auth.users with public profile data
-- ============================================================
create table public.users (
  id            uuid primary key references auth.users(id) on delete cascade,
  username      text not null unique,
  avatar_url    text,
  is_banned     boolean not null default false,
  created_at    timestamptz not null default now()
);

-- ============================================================
-- FIXTURES
-- Populated and updated via football-data.org API
-- ============================================================
create table public.fixtures (
  id              uuid primary key default uuid_generate_v4(),
  external_id     text not null unique,          -- football-data.org match id
  matchday        int not null,
  stage           text not null,                 -- 'group', 'round_of_16', 'quarter_final', 'semi_final', 'final'
  home_team       text not null,
  away_team       text not null,
  home_crest_url  text,
  away_crest_url  text,
  kickoff_time    timestamptz not null,
  guess_lock_time timestamptz not null,          -- kickoff_time - 15 minutes, set on insert
  status          text not null default 'scheduled', -- 'scheduled', 'live', 'completed', 'postponed'
  home_score      int,                           -- null until completed
  away_score      int,                           -- null until completed
  went_to_penalties boolean,                     -- knockout rounds only
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ============================================================
-- GUESSES
-- One row per user per fixture
-- ============================================================
create table public.guesses (
  id                    uuid primary key default uuid_generate_v4(),
  user_id               uuid not null references public.users(id) on delete cascade,
  fixture_id            uuid not null references public.fixtures(id) on delete cascade,
  home_score_guess      int not null,
  away_score_guess      int not null,
  predicts_penalties    boolean not null default false, -- knockout rounds only
  points_earned         int,                            -- null until result settled
  submitted_at          timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique(user_id, fixture_id)
);

-- ============================================================
-- LEAGUES
-- Private leagues created by users
-- ============================================================
create table public.leagues (
  id            uuid primary key default uuid_generate_v4(),
  name          text not null,
  join_code     char(8) not null unique,          -- 8-digit numeric string e.g. '00293847'
  join_phrase   text not null,                    -- 4-word hyphenated e.g. 'golden-tiger-bends-spoon'
  admin_user_id uuid not null references public.users(id) on delete restrict,
  created_at    timestamptz not null default now()
);

-- ============================================================
-- LEAGUE MEMBERS
-- ============================================================
create table public.league_members (
  id            uuid primary key default uuid_generate_v4(),
  league_id     uuid not null references public.leagues(id) on delete cascade,
  user_id       uuid not null references public.users(id) on delete cascade,
  total_points  int not null default 0,           -- cached, updated when results settle
  games_guessed int not null default 0,           -- cached count of guesses made
  joined_at     timestamptz not null default now(),
  unique(league_id, user_id)
);

-- ============================================================
-- NOTIFICATIONS LOG
-- Tracks which notifications have been sent to avoid duplicates
-- ============================================================
create table public.notifications_log (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references public.users(id) on delete cascade,
  fixture_id    uuid not null references public.fixtures(id) on delete cascade,
  type          text not null,                    -- 'reminder_24h', 'reminder_1h', 'result'
  sent_at       timestamptz not null default now(),
  unique(user_id, fixture_id, type)
);

-- ============================================================
-- NOTIFICATION PREFERENCES
-- Per-user opt in/out per notification type
-- ============================================================
create table public.notification_preferences (
  user_id             uuid primary key references public.users(id) on delete cascade,
  reminder_24h        boolean not null default true,
  reminder_1h         boolean not null default true,
  result_notification boolean not null default true,
  updated_at          timestamptz not null default now()
);

-- ============================================================
-- PUSH TOKENS
-- FCM/APNs tokens per user — used by Edge Functions to send notifications.
-- One token per user (upsert on conflict). Never read by the client.
-- ============================================================
create table public.push_tokens (
  user_id     uuid primary key references public.users(id) on delete cascade,
  token       text not null,
  updated_at  timestamptz not null default now()
);

-- RLS: users can write their own token, nobody can read them (server only via service role)
alter table public.push_tokens enable row level security;
create policy "push_tokens_insert" on public.push_tokens for insert with check (auth.uid() = user_id);
create policy "push_tokens_update" on public.push_tokens for update using (auth.uid() = user_id);

-- ============================================================
-- INDEXES
-- ============================================================
create index on public.fixtures(kickoff_time);
create index on public.fixtures(status);
create index on public.guesses(user_id);
create index on public.guesses(fixture_id);
create index on public.league_members(league_id, total_points desc);
create index on public.notifications_log(fixture_id, type);

-- ============================================================
-- NOTIFICATION TARGETING FUNCTION
-- Returns user_id + token for users who:
--   1. Have a push token registered
--   2. Haven't already received this notification type for this fixture
--   3. Have the notification type enabled in their preferences
-- Called by the send-notifications Edge Function (service role only).
-- ============================================================
create or replace function get_notification_targets(
  p_fixture_id uuid,
  p_type text
)
returns table(user_id uuid, token text)
language sql
security definer
as $$
  select pt.user_id, pt.token
  from public.push_tokens pt
  -- Preference check — default true if no preference row exists
  left join public.notification_preferences np on np.user_id = pt.user_id
  -- Exclude already-sent
  where not exists (
    select 1 from public.notifications_log nl
    where nl.user_id = pt.user_id
      and nl.fixture_id = p_fixture_id
      and nl.type = p_type
  )
  -- Respect opt-outs
  and case p_type
    when 'reminder_24h'  then coalesce(np.reminder_24h, true)
    when 'reminder_1h'   then coalesce(np.reminder_1h, true)
    when 'result'        then coalesce(np.result_notification, true)
    else true
  end;
$$;

-- ============================================================
-- SCORING FUNCTION
-- Called after a fixture result is confirmed
-- 3pts = exact score, 1pt = correct result, 1pt = penalties bonus
-- ============================================================
create or replace function settle_fixture_guesses(p_fixture_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  v_home_score      int;
  v_away_score      int;
  v_went_to_penalties boolean;
  v_actual_result   text; -- 'home', 'draw', 'away'
begin
  select home_score, away_score, went_to_penalties
  into v_home_score, v_away_score, v_went_to_penalties
  from public.fixtures
  where id = p_fixture_id and status = 'completed';

  if not found then
    raise exception 'Fixture % not found or not completed', p_fixture_id;
  end if;

  v_actual_result := case
    when v_home_score > v_away_score then 'home'
    when v_home_score < v_away_score then 'away'
    else 'draw'
  end;

  -- Score each guess
  update public.guesses
  set points_earned = (
    -- Exact score: 3 points
    case when home_score_guess = v_home_score and away_score_guess = v_away_score then 3
    -- Correct result: 1 point
    when (
      (home_score_guess > away_score_guess and v_actual_result = 'home') or
      (home_score_guess < away_score_guess and v_actual_result = 'away') or
      (home_score_guess = away_score_guess and v_actual_result = 'draw')
    ) then 1
    else 0 end
    +
    -- Penalties bonus: 1 point (knockout only)
    case when predicts_penalties = true and v_went_to_penalties = true then 1 else 0 end
  ),
  updated_at = now()
  where fixture_id = p_fixture_id;

  -- Update cached totals on league_members
  update public.league_members lm
  set
    total_points = total_points + coalesce((
      select points_earned
      from public.guesses
      where fixture_id = p_fixture_id and user_id = lm.user_id
    ), 0),
    games_guessed = games_guessed + (
      select count(*) from public.guesses
      where fixture_id = p_fixture_id and user_id = lm.user_id
    );

end;
$$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table public.users enable row level security;
alter table public.fixtures enable row level security;
alter table public.guesses enable row level security;
alter table public.leagues enable row level security;
alter table public.league_members enable row level security;
alter table public.notifications_log enable row level security;
alter table public.notification_preferences enable row level security;

-- Users: anyone can read profiles, only owner can update
create policy "users_select" on public.users for select using (true);
create policy "users_insert" on public.users for insert with check (auth.uid() = id);
create policy "users_update" on public.users for update using (auth.uid() = id);

-- Fixtures: public read, no client writes (server only)
create policy "fixtures_select" on public.fixtures for select using (true);

-- Guesses: users see only their own; insert/update only before lock time
create policy "guesses_select" on public.guesses for select using (auth.uid() = user_id);
create policy "guesses_insert" on public.guesses for insert with check (
  auth.uid() = user_id and
  (select guess_lock_time from public.fixtures where id = fixture_id) > now()
);
create policy "guesses_update" on public.guesses for update using (
  auth.uid() = user_id and
  (select guess_lock_time from public.fixtures where id = fixture_id) > now()
);

-- Leagues: members can read their leagues
create policy "leagues_select" on public.leagues for select using (
  exists (
    select 1 from public.league_members
    where league_id = id and user_id = auth.uid()
  )
);
create policy "leagues_insert" on public.leagues for insert with check (auth.uid() = admin_user_id);

-- League members: visible to other members of same league
create policy "league_members_select" on public.league_members for select using (
  exists (
    select 1 from public.league_members lm2
    where lm2.league_id = league_id and lm2.user_id = auth.uid()
  )
);
create policy "league_members_insert" on public.league_members for insert with check (auth.uid() = user_id);

-- Notification preferences: owner only
create policy "notif_prefs_select" on public.notification_preferences for select using (auth.uid() = user_id);
create policy "notif_prefs_insert" on public.notification_preferences for insert with check (auth.uid() = user_id);
create policy "notif_prefs_update" on public.notification_preferences for update using (auth.uid() = user_id);

-- Notifications log: owner only
create policy "notif_log_select" on public.notifications_log for select using (auth.uid() = user_id);
