# Scheduled Jobs

Set these up in the Supabase dashboard under Database → Extensions → pg_cron,
or via the SQL editor:

```sql
-- Sync fixtures once a day (picks up any kickoff time changes)
select cron.schedule(
  'sync-fixtures-daily',
  '0 6 * * *',  -- 06:00 UTC daily
  $$
    select net.http_post(
      url := current_setting('app.supabase_url') || '/functions/v1/sync-fixtures',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key')
      ),
      body := '{}'::jsonb
    );
  $$
);

-- Settle results every 5 minutes during the tournament
select cron.schedule(
  'settle-results-every-5min',
  '*/5 * * * *',
  $$
    select net.http_post(
      url := current_setting('app.supabase_url') || '/functions/v1/settle-results',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key')
      ),
      body := '{}'::jsonb
    );
  $$
);

-- Check for 24h and 1h reminders every 30 minutes
select cron.schedule(
  'schedule-reminders-every-30min',
  '*/30 * * * *',
  $$
    select net.http_post(
      url := current_setting('app.supabase_url') || '/functions/v1/schedule-reminders',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key')
      ),
      body := '{}'::jsonb
    );
  $$
);
```
