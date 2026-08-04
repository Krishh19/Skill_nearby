# SkillNearby — Implementation Status

## What has been completed

### Project foundation

- Scaffolded a Flutter application named `skill_nearby`.
- Added the feature-first structure for app routing, design system, data, domain models, and feature screens.
- Added the supplied onboarding illustration at `assets/gettingstarted.png`.
- Configured Android and iOS location permission descriptions.

### Design system and reusable UI

- Added centralized `AppColors` and theme tokens.
- Implemented the required palette:
  - Primary: `#0F766E`
  - Accent: `#F97066`
  - Background: `#FAF9F6`
- Added reusable buttons, cards, inputs, skill chips, status pills, profile cards, empty states, skeletons, and offline banners.
- Added warm spacing, rounded cards, soft shadows, accessible touch targets, and a light-only theme.

### Navigation and screens

- Added `go_router` navigation with guarded onboarding routes.
- Added shell navigation for:
  - Nearby
  - Requests
  - Messages
  - Profile
- Implemented the supplied prototype flows:
  - Welcome and onboarding
  - Location permission and denied-location fallback
  - Profile creation, skill selection, radius, and availability
  - Nearby cached feed and search UI
  - Profile detail
  - Request creation, review, and sent states
  - Requests/activity views
  - Chat
  - Completion and rating
  - Standing offers
  - Safety
  - Offline-data settings
  - Honest unavailable Map state

### Offline-first data layer

- Added Drift-backed local tables for profiles, skills, requests, messages, ratings, and the outbox.
- Added Hive-backed preferences for onboarding state, radius, availability, and lightweight settings.
- Added typed domain models for profiles, skills, requests, messages, ratings-related flows, preferences, connection state, and queued operations.
- Implemented optimistic local mutations that enqueue pending operations.
- Added a FIFO `SyncCoordinator` flow through a mock remote transport.
- Added connectivity monitoring and visible pending/offline UI states.
- Seeded local sample profiles, skills, requests, messages, and ratings data for the prototype.

### Tests and verification

- Added an offline queue unit test covering optimistic request creation and later synchronization.
- Added an offline banner widget test.
- `flutter pub get` completed successfully.
- `dart analyze` completed successfully with informational lint findings only.
- `flutter test` completed successfully: all tests passed.

## Current prototype limitations

These are intentional for this milestone or still need production hardening:

- The remote transport is a mock; there is no Supabase backend or authentication yet.
- Startup currently seeds fixture data rather than fully hydrating every cached record from Drift.
- Some mutation paths, including completion and ratings, need more complete local state updates and persistence coverage.
- There are no real map tiles, media uploads, push notifications, payments, or production location-based discovery.
- The app has not yet been validated on a physical Android/iOS device in this workspace.
- Analyzer output still contains style-level informational lints that can be cleaned up.

## What to do next

## Backend milestone added

- Added a Supabase Flutter adapter selected through `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` dart-defines.
- Added Supabase auth, Storage media upload, Realtime subscription, PostGIS nearby query, and conflict-aware sync service seams.
- Added a Supabase migration with profiles, skills, swaps, messages, ratings, reports, verification requests, RLS policies, Storage policies, Realtime publication, and nearby geo RPC.
- Added local offline map-pack metadata storage and a device integration-test scaffold.

The migration's `apply_sync_operation` function is deliberately a safe idempotency/conflict gate. The next backend pass must map each operation kind to its concrete table mutation and return the winning server row for local reconciliation.

### 1. Run and visually verify the app

From the project directory:

```powershell
cd C:\mobile\SkillNearby
flutter run
```

Walk through onboarding, nearby discovery, request creation, chat, completion, rating, and the offline-data screen. Check both narrow phone layouts and larger screens.

### 2. Finish durable local hydration

- Read profiles, requests, messages, ratings, and outbox records from Drift during repository startup.
- Rebuild in-memory streams from the persisted cache before showing the first screen.
- Persist all optimistic state transitions, including completion, ratings, and message status changes.
- Add migrations and schema versioning before changing local tables further.

### 3. Harden synchronization

- Add operation deduplication/idempotency keys.
- Persist retry count, next retry time, and failure reason.
- Add exponential backoff and a user-visible failed-operation state.
- Verify FIFO ordering and recovery across app restarts.
- Add tests for retry, permanent failure, reconnect-triggered sync, and restart recovery.

### 4. Replace the mock transport

- Define the production repository adapter boundary.
- Add authentication and a Supabase implementation when the backend is available.
- Add authorization policies for profiles, requests, messages, ratings, and user-owned data.
- Keep Drift as the local source of truth and preserve optimistic UI behavior.

### 5. Complete device behavior

- Test location permission flows on Android and iOS, including denied-forever behavior.
- Add real device connectivity transitions and verify the banner/sync behavior.
- Add accessibility checks, scalable text checks, keyboard handling, and screen-reader labels.
- Validate minimum 48dp interactive targets and offline usability on every major screen.

### 6. Expand automated coverage

- Add widget tests for onboarding guards, request pending states, chat pending messages, empty states, and denied location.
- Add an integration flow for onboarding → cached nearby profile → offline request/message → reconnect → completion → rating.
- Add golden or screenshot checks for the key reference screens if visual regression testing is desired.

### 7. Clean up for release readiness

- Resolve remaining informational analyzer lints.
- Add app icon, splash screen, package metadata, and environment configuration.
- Add logging and crash reporting hooks without leaking private user data.
- Document build, test, release, and backend configuration steps.

## Definition of done for the next milestone

The next milestone is complete when the app can restart without network access, restore its cached records and pending operations from Drift/Hive, allow request and message actions offline, drain those operations reliably after reconnecting, and pass the end-to-end integration flow on a real device or emulator.
