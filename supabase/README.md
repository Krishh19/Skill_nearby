# Supabase setup

This directory contains the Postgres/PostGIS, RLS, Realtime, Storage, and
conflict-gate migration for SkillNearby.

1. Install and authenticate the Supabase CLI.
2. Link the project and apply the migration:

```powershell
supabase link --project-ref <project-ref>
supabase db push
```

3. Run the Flutter app with only the publishable client key:

```powershell
flutter run --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

For the configured project ref, the repository also includes a local runner:

```powershell
.\tool\run_supabase.ps1 -PublishableKey '<publishable-key>'
```

Never put a `service_role` key in Flutter or commit credentials. Until these
defines are supplied, the app intentionally continues to use its local cache
and deterministic fallback transport.
