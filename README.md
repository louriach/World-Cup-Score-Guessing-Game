# Golden Goals

Predict every World Cup 2026 score. Beat your mates.

Golden Goals is a free score prediction game for the FIFA World Cup 2026. Predict match scores before kick-off, earn points, and compete in private leagues with friends.

## How scoring works

| Result | Points |
|--------|--------|
| Exact score | 3 pts |
| Correct result (win/draw/loss) | 1 pt |
| Correct penalty outcome (knockouts) | +1 pt bonus |
| Wrong result | 0 pts |

Predictions lock 15 minutes before kick-off.

## Features

- Sign in with Apple (iOS) or magic link email (web)
- Predict scores for all 72 group stage matches
- Private leagues — create or join with an 8-digit code + phrase
- Push notifications for match reminders and results
- Progressive Web App — installable from any browser

## Tech stack

| Layer | Technology |
|-------|-----------|
| App | Flutter (iOS + Web) |
| Backend | Supabase (PostgreSQL, Auth, Storage, Edge Functions) |
| Push notifications | Firebase Cloud Messaging v1 |
| Match data | football-data.org |
| Hosting | GitHub Pages (PWA + docs) |

## Project structure

```
├── app/                        # Flutter app
│   ├── lib/
│   │   ├── core/               # Theme, router, notifications
│   │   ├── features/           # Auth, home, scores, leagues, profile
│   │   └── shared/             # Models, widgets
│   └── ios/                    # iOS-specific config
├── supabase/
│   ├── schema.sql              # Full database schema + RLS policies
│   └── functions/              # Edge Functions
│       ├── sync-fixtures/      # Fetches WC fixtures from football-data.org
│       ├── settle-results/     # Scores guesses after matches finish
│       ├── schedule-reminders/ # Triggers 24h/1h push reminders
│       └── send-notifications/ # Sends FCM push notifications
└── docs/                       # GitHub Pages (PWA + privacy/terms)
```

## Running locally

```bash
cd app
flutter run --dart-define=SUPABASE_URL=your_url \
            --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## Web / PWA

Live at: https://louriach.github.io/World-Cup-Score-Guessing-Game/app/

## Legal

- [Privacy Policy](https://louriach.github.io/World-Cup-Score-Guessing-Game/privacy.html)
- [Terms of Service](https://louriach.github.io/World-Cup-Score-Guessing-Game/terms.html)

## Author

Luis Ouriach
