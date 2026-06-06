# Supabase Setup

## 1. Create your Supabase project
Go to supabase.com, create a new project. Save the project URL and keys somewhere safe (a password manager, not a text file).

## 2. Run the schema
In the Supabase dashboard → SQL Editor, paste and run the contents of `schema.sql`.

## 3. Set secrets (never put these in code or git)
Install the Supabase CLI, then run:

```bash
supabase secrets set FOOTBALL_DATA_API_KEY=your_key_here
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
supabase secrets set FCM_SERVER_KEY=your_fcm_server_key_here
```

SUPABASE_URL is automatically available in Edge Functions — no need to set it.

## 4. Deploy Edge Functions

```bash
supabase functions deploy sync-fixtures
supabase functions deploy settle-results
```

## 5. Set up cron jobs
Run the SQL in `functions/settle-results/cron.md` in the SQL Editor.
First enable the pg_cron and pg_net extensions under Database → Extensions.

## 6. Seed fixtures
Trigger the first sync manually from the Supabase dashboard →
Functions → sync-fixtures → Invoke. All World Cup fixtures will populate the fixtures table.

## Keys you will have — store in a password manager only:
- Supabase project URL
- Supabase anon key (safe for Flutter app — restricted by RLS)
- Supabase service role key (never in app — server only)
- football-data.org API key (never in app — server only)
