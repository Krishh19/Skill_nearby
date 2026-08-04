**Full PRD + Tech Stack**  
**App: SkillNearby** (recommended name)

**Alternative name options:**  
- SwapLocal  
- NeighborSkill  
- SkillRadius  
- BarterBlock  
- LocalHand  

**Primary recommendation: SkillNearby** — clear, friendly, memorable, and App Store friendly.

---

### 1. Product Requirements Document (PRD)

#### 1.1 Overview
**SkillNearby** is an offline-first mobile app that enables people within walking or short driving distance to trade skills and favors without money. Users build local reputation through completed swaps. The app prioritizes trust, safety, and reliable offline functionality.

**Core Value Proposition**  
“Trade skills with people near you — even when you’re offline.”

**Platform**  
- iOS + Android (Flutter)  
- Primary focus: Mobile-first, one-handed use

**Success Metrics (Year 1)**  
- 10k+ total users  
- 1,200+ paying subscribers  
- $10k+ MRR  
- Average 3.5+ completed swaps per active user per month  
- <6% monthly churn on premium

---

#### 1.2 Full Tech Stack (Flutter)

**Frontend**
- Flutter 3.24+ (stable)
- Dart 3.5+
- State management: Riverpod 2.5+ (or Bloc if team prefers)
- Routing: go_router
- Local storage: Hive + flutter_secure_storage
- Offline sync: PowerSync or custom sync engine with Drift (SQLite)
- Maps: mapbox_maps_flutter or google_maps_flutter + flutter_map for offline tiles
- UI: Custom design system + flutter_screenutil + gap
- Icons: phosphor_flutter or custom SVG
- Image/video: cached_network_image, video_player, image_picker, video_compress
- Push notifications: firebase_messaging + flutter_local_notifications
- Connectivity: connectivity_plus + internet_connection_checker_plus
- Location: geolocator + geocoding
- Permissions: permission_handler

**Backend**
- Supabase (recommended for speed) or custom Node.js/Go + PostgreSQL
- Auth: Supabase Auth (email + Apple + Google)
- Database: PostgreSQL + PostGIS (for geo queries)
- Real-time: Supabase Realtime
- Storage: Supabase Storage or Cloudflare R2
- Edge functions: Supabase Edge Functions (TypeScript)
- Offline sync layer: PowerSync (best Flutter integration) or ElectricSQL

**Infrastructure & Services**
- Hosting: Supabase + Cloudflare
- Analytics: Mixpanel or PostHog
- Crash reporting: Sentry
- CI/CD: Codemagic or GitHub Actions
- App distribution: TestFlight + Google Play Internal Testing
- Maps tiles: Mapbox (offline pack support)

**AI (Phase 2 – optional)**
- On-device: TensorFlow Lite or MediaPipe for basic skill tagging
- Cloud: Optional OpenAI/Claude for skill matching suggestions (never core)

**Dev Tools**
- IDE: VS Code / Cursor / Android Studio
- Design handoff: Figma
- API: Supabase client + freezed + json_serializable
- Testing: flutter_test + mockito + integration_test

---

#### 1.3 Core Workflows (Detailed)

**A. New User Onboarding**
1. Splash → Welcome
2. Location permission (with clear benefit copy)
3. Create profile (photo, display name, short bio)
4. Add skills offered (search + custom + optional 15s video)
5. Add skills wanted
6. Set default radius (0.5 / 1 / 2 / 5 km)
7. Optional verification prompt
8. Land on Nearby feed

**B. Discover & Request**
1. Nearby feed (list + optional map)
2. Filter by skill / radius / availability
3. Open profile → view skills, rating, distance, videos
4. Tap Request Swap
5. Select skill wanted + skill offered + message + times
6. Send (queued if offline)
7. Confirmation + safety tips

**C. Accept → Schedule → Complete**
1. Incoming request notification
2. Accept / Counter / Decline
3. Agree on time & meeting point
4. Day-of: optional live location share
5. Both mark Complete
6. Mutual rating + optional note
7. Reputation update

**D. Offline Behavior**
- Browse last-synced nearby profiles
- Compose requests & messages (queued)
- View own profile, past swaps, reputation
- Clear visual offline banner
- Auto-sync when connection returns

**E. Premium Upsell Triggers**
- After 3 completed swaps
- When trying to expand radius
- When adding standing offers
- When accessing advanced filters

---

#### 1.4 UI Library & Design System Implementation

**Recommended Approach**
- Build a custom design system in Flutter (do not use heavy third-party UI kits)
- Core package structure:
  ```
  lib/
    design_system/
      colors.dart
      typography.dart
      spacing.dart
      radii.dart
      shadows.dart
      components/
        buttons.dart
        cards.dart
        chips.dart
        badges.dart
        inputs.dart
        offline_banner.dart
  ```

**Key Components to Build**
- AppButton (primary, secondary, ghost, destructive)
- ProfileCard
- SkillChip
- ReputationBadge
- OfflineBanner (persistent)
- StatusPill
- EmptyState
- LoadingSkeleton
- BottomNav

**UI Libraries (lightweight only)**
- flutter_screenutil (responsive)
- gap or sizedbox equivalents
- shimmer (skeletons)
- modal_bottom_sheet
- pull_to_refresh

Avoid: GetWidget, Huge UI kits, or anything that fights the custom warm aesthetic.

---

#### 1.5 UI Flow (Screen Map)

1. Onboarding (4–5 screens)
2. Main Tab Bar
   - Nearby (default)
   - Requests (Incoming / Outgoing / History)
   - Messages
   - Profile
3. Profile Detail (other user)
4. Request Swap Modal / Screen
5. Chat Screen
6. Rating Bottom Sheet
7. Own Profile & Settings
8. Standing Offers Management
9. Safety & Verification Center
10. Premium Paywall

---

#### 1.6 AI Guide – How to Avoid AI Slop

**Rules for any AI-generated design or code:**

1. **Never accept generic “SaaS blue” or Inter-only safe designs**  
   Force the warm teal + coral + off-white palette every time.

2. **Reject these common AI failures**
   - Too much white space with no personality
   - Generic rounded cards with heavy shadows
   - Perfect but soulless empty states
   - Overly complex onboarding
   - Dark mode as default
   - Stock “happy people shaking hands” illustrations

3. **Prompting rules when using AI**
   - Always paste the full design system colors + principles first
   - Add: “Make it feel like a trusted neighborhood tool, not a startup dashboard”
   - Add: “Prioritize offline clarity and safety visibility”
   - Add: “Use large touch targets and calm density”
   - Reject and regenerate if it looks like every other AI app

4. **Human review checklist**
   - Does it feel warm and local?
   - Is offline state impossible to miss?
   - Are safety actions easy to find?
   - Would a 45-year-old non-tech person understand it in 10 seconds?

5. **Code generation rule**
   - AI may generate components, but final design tokens and spacing must be manually verified against the design system.

---

#### 1.7 AI IDE Prompt Guide (Cursor / Windsurf / etc.)

**Master Prompt Template** (paste this at the start of every chat):

```
You are a senior Flutter engineer building SkillNearby — an offline-first local skill swap marketplace.

Strict rules:
- Follow the design system exactly: Primary #0F766E, Accent #F97066, Background #FAF9F6
- Offline-first architecture is non-negotiable
- Use Riverpod + go_router + Hive/Drift
- Write clean, production-ready, well-commented Dart code
- Prefer composition over huge widgets
- Every screen must handle offline state gracefully
- No generic AI-looking UI. Warm, human, trustworthy neighborhood feel.
- Large touch targets, calm spacing, clear hierarchy

Current design system summary:
[Paste colors, typography, spacing here]

When generating UI:
- Use the custom design system components
- Never hardcode colors — always use AppColors
- Always include offline banner logic where relevant

When generating logic:
- Optimistic UI + queue for offline actions
- Clear error and empty states
```

**Good follow-up prompts**
- “Create the ProfileCard widget following the design system”
- “Implement offline request queue with Hive”
- “Build the Nearby feed with pull-to-refresh and offline cache”
- “Add the persistent OfflineBanner that shows connection status”



---

