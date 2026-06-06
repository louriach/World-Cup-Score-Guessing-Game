# Golden Goals – Pre-Launch Checklist

Manual steps that cannot be done in code. Complete all of these before submitting to the App Store.

---

## Xcode / Apple Developer

- [ ] **Sign in with Apple capability** — Xcode → target → Signing & Capabilities → add "Sign in with Apple"
- [ ] **Push Notifications capability** — Xcode → target → Signing & Capabilities → add "Push Notifications"
- [ ] **Background Modes capability** — enable "Remote notifications" under Background Modes
- [ ] **APNs key** — generate an APNs Auth Key (.p8) in Apple Developer portal → Certificates, Identifiers & Profiles → Keys. Upload to Firebase Console → Project Settings → Cloud Messaging
- [ ] **Bundle ID** — register your app's Bundle ID in Apple Developer portal before first build
- [ ] **Provisioning profile** — create a distribution provisioning profile for App Store submission

## Firebase

- [ ] **Create Firebase project** — console.firebase.google.com
- [ ] **Add iOS app** — use your Bundle ID, download `GoogleService-Info.plist`, place in `app/ios/Runner/`
- [ ] **`GoogleService-Info.plist` is gitignored** — verify it never gets committed (contains API keys)
- [ ] **Add Android app** (when ready) — download `google-services.json`, place in `app/android/app/`
- [ ] **FCM Service Account** — Google Cloud Console → IAM & Admin → Service Accounts → firebase-adminsdk → Keys → Create JSON key. Set via `supabase secrets set FCM_SERVICE_ACCOUNT_JSON='<paste full JSON as one line>'`
- [ ] **APNs key uploaded to Firebase** — Firebase Console → Project Settings → Cloud Messaging → Apple app configuration → upload your `.p8` APNs Auth Key with your Team ID and Key ID
- [ ] **Deploy `schedule-reminders` Edge Function** — `supabase functions deploy schedule-reminders`
- [ ] **Add reminder cron job** — run the full cron SQL from `supabase/functions/settle-results/cron.md` (includes the new 30-min reminder schedule)

## Supabase

- [ ] **Create Supabase project** — supabase.com
- [ ] **Run schema.sql** — paste into SQL Editor and execute
- [ ] **Enable Storage extension** — Dashboard → Storage (creates the avatars bucket via schema)
- [ ] **Enable pg_cron and pg_net extensions** — Dashboard → Database → Extensions
- [ ] **Set secrets** — `supabase secrets set FOOTBALL_DATA_API_KEY=... SUPABASE_SERVICE_ROLE_KEY=...`
- [ ] **Deploy Edge Functions** — `supabase functions deploy sync-fixtures && supabase functions deploy settle-results`
- [ ] **Run cron jobs SQL** — paste from `supabase/functions/settle-results/cron.md` into SQL Editor
- [ ] **Trigger first fixture sync** — invoke `sync-fixtures` manually to seed all World Cup fixtures
- [ ] **Enable Apple auth provider** — Dashboard → Authentication → Providers → Apple. Requires your Apple Services ID and private key from Apple Developer portal

## Environment / secrets (local dev)

- [ ] **Set shell env vars** — add to `~/.zshrc` (never commit these):
  ```
  export SUPABASE_URL=https://xxx.supabase.co
  export SUPABASE_ANON_KEY=your_anon_key
  ```
- [ ] **Verify `.gitignore`** — run `git status` before first commit and confirm no `.env`, `*.plist` with secrets, or `*.p8` files are staged

## iOS permissions (Info.plist)

- [ ] **Photo library access** — add `NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist` with a clear reason string (e.g. "Choose a profile photo")
- [ ] **Camera access** (if you enable camera capture later) — `NSCameraUsageDescription`

## Football data API

- [ ] **Register at football-data.org** — free tier, get API key
- [ ] **Confirm World Cup competition code** — should be `WC` for FIFA World Cup 2026; verify against their `/competitions` endpoint before seeding

## App Store

- [ ] **Privacy Policy URL** — required before submission; host a simple page and add URL to App Store Connect
- [ ] **Terms of Service URL** — same requirement
- [ ] **App Store screenshots** — required: 6.7" (iPhone 15 Pro Max) and 6.1" sizes minimum
- [ ] **App icon** — 1024×1024px PNG, no alpha channel, required for submission
- [ ] **Age rating** — complete the questionnaire in App Store Connect (likely 4+)
- [ ] **Submit for review at least 7 days before launch** — allow buffer for rejection and resubmission

---

*Updated throughout the build. Check this file before any release.*
