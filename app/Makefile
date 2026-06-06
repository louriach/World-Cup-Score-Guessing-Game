# Run locally — reads SUPABASE_URL and SUPABASE_ANON_KEY from your shell environment.
# Set these in your shell profile (NOT in any file that gets committed):
#   export SUPABASE_URL=https://xxx.supabase.co
#   export SUPABASE_ANON_KEY=your_anon_key

run:
	flutter run \
		--dart-define=SUPABASE_URL=$(SUPABASE_URL) \
		--dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)

build-ios:
	flutter build ios \
		--dart-define=SUPABASE_URL=$(SUPABASE_URL) \
		--dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)

build-android:
	flutter build apk \
		--dart-define=SUPABASE_URL=$(SUPABASE_URL) \
		--dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)

gen:
	dart run build_runner build --delete-conflicting-outputs
