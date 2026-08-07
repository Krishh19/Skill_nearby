# Swap — Dark Theme System v1

A parallel token set for dark mode — not an inverted filter, but re-tuned color, contrast, and elevation so the app still feels warm and legible at night.

---

## Why not just invert

Flipping cream → black and keeping the same teal/coral values fails on two counts: the light-mode teal (`#0F5C52`) is too dark to read on a black background, and pure black backgrounds kill the warm, human feel of the light theme. Every color below is re-picked for dark, not inverted.

**Three rules carried over from light mode:**
- Teal still means primary action
- Coral still means "needs your attention" — and only that
- The exchange glyph (crossing arrows) stays the one signature mark

What changes is *value* — teal and coral both get lighter/brighter so they hold contrast on dark surfaces, and every background gets a warm, slightly green-black tint instead of true black.

---

## Palette

Three background layers create depth without borders doing all the work: **base → raised → surface**.

| Token | Hex | Usage |
|---|---|---|
| `--d-bg` (Base) | `#0F1513` | App background |
| `--d-bg-raised` (Raised) | `#171F1C` | Nav bar, headers, phone chrome |
| `--d-surface` (Surface) | `#1D2622` | Cards |
| `--d-surface-2` (Surface 2) | `#23302A` | Chips, secondary buttons, nested elements |
| `--d-teal` (Teal, bright) | `#4FC3AE` | Primary actions, links, active states |
| `--d-teal-deep` | `#3AA890` | Secondary button borders |
| `--d-teal-tint` | `#1D3B34` | "Completed" pill background |
| `--d-coral` (Coral, bright) | `#F2895F` | Pending/attention states only |
| `--d-coral-tint` | `#3B2620` | "Pending" pill background |
| `--d-ink` (Text primary) | `#F1EEE3` | Headlines, primary text |
| `--d-stone` (Text secondary) | `#9BA6A0` | Body copy, metadata |
| `--d-stone-dim` | `#6C7874` | Labels, timestamps, disabled text |
| `--d-line` (Border) | `#2B3733` | Card borders, dividers |

> Note: body text uses a warm grey (`#9BA6A0`), not white at reduced opacity — white-at-opacity reads as muddy on OLED screens.

---

## Typography

Same system as light mode: **Fraunces** (display/headlines), **Inter** (body/UI), **IBM Plex Mono** (labels, data, timestamps).

| Role | Font | Weight | Size | Color |
|---|---|---|---|---|
| Display XL | Fraunces | 600 | 48px | `--d-ink` |
| Display LG | Fraunces | 600 | 32px | `--d-ink` |
| Display MD | Fraunces | 500 | 24px | `--d-ink` |
| Body — Large | Inter | 500 | 17px | `--d-ink` |
| Body | Inter | 400 | 15px | `--d-stone` |
| Mono Label | IBM Plex Mono | 500 | 12px, uppercase, +0.08em tracking | `--d-teal` |

---

## Buttons

One shape language (full pill), re-tuned contrast for dark surfaces.

| Style | Background | Text | Border | Shadow |
|---|---|---|---|---|
| Primary | `--d-teal` (`#4FC3AE`) | `#0B1B17` (dark, not white) | none | `0 8px 20px -8px rgba(79,195,174,.35)` |
| Secondary | transparent | `--d-teal` | 1.5px `--d-teal-deep` | none |
| Coral (attention only) | `--d-coral` (`#F2895F`) | `#2A150D` (dark) | none | `0 8px 20px -8px rgba(242,137,95,.35)` |
| Ghost | `--d-surface-2` | `--d-ink` | none | none |

> Primary and coral buttons use **dark text on a bright fill** — this holds a better contrast ratio on dark UIs than white text on saturated color, and avoids a neon look.

Radius: full pill (`100px`). Padding: `15px 28px`. Font: Inter, 600, 15px.

---

## Cards

Cards separate from the base background using a lighter surface fill **plus** a 1px hairline border — shadows alone barely read on dark backgrounds.

- Background: `--d-surface` (`#1D2622`)
- Border: 1px solid `--d-line` (`#2B3733`)
- Radius: `22px` (`--radius-lg`)
- Padding: `26px`
- Shadow: `0 1px 0 rgba(255,255,255,.03) inset, 0 12px 28px -14px rgba(0,0,0,.6)`

**Status pills:**
| State | Background | Text |
|---|---|---|
| Pending | `--d-coral-tint` (`#3B2620`) | `--d-coral` (`#F2895F`) |
| Completed | `--d-teal-tint` (`#1D3B34`) | `--d-teal` (`#4FC3AE`) |

**Exchange strip** (the "Skill A ↔ Skill B" row inside a card):
- Background: `--d-surface-2` (`#23302A`)
- Radius: `10px`
- Padding: `14px 16px`
- Icon color: `--d-coral`
- Text: `--d-ink`, 14px, weight 500

**Avatar:**
- 48px circle, gradient fill `linear-gradient(155deg, #4FC3AE, #7FD8C4)`
- Initials in `#0B1B17` (dark), IBM Plex Mono, 14px

---

## Radius scale

| Token | Value | Usage |
|---|---|---|
| `--radius-sm` | 10px | Exchange strip, small elements |
| `--radius-md` | 16px | Chips, mini-cards |
| `--radius-lg` | 22px | Main cards |
| Button radius | 100px (full pill) | All buttons |

---

## Component mapping (light → dark, by role)

Implement dark mode as a variable swap by **role**, not a hardcoded hex-per-screen rebuild:

| Role token | Light value | Dark value |
|---|---|---|
| `--bg` | `#FBF8F1` | `#0F1513` |
| `--bg-raised` | `#F3EEE2` | `#171F1C` |
| `--surface` (cards) | `#FFFFFF` | `#1D2622` |
| `--surface-2` (chips) | `#E3EEE7` | `#23302A` |
| `--accent-primary` (teal) | `#0F5C52` | `#4FC3AE` |
| `--accent-attention` (coral) | `#E2643A` | `#F2895F` |
| `--text-primary` | `#1B2430` | `#F1EEE3` |
| `--text-secondary` | `#7C8580` | `#9BA6A0` |
| `--border` | `#E7E1D3` | `#2B3733` |

Define these once as CSS custom properties per role, then toggle the whole theme by swapping the value set — no per-screen dark-mode overrides needed.

---

## Applied reference screens

**"Request sent" confirmation**
- Background: `--d-bg-raised`
- Success icon: exchange glyph, `--d-teal` on `--d-teal-tint` circle, 76px
- Headline: Fraunces 600, 22px
- Body copy: `--d-stone`, 13.5px
- Primary CTA: full-width pill, `--d-teal` fill
- Secondary link: `--d-teal` text, no button chrome

**"Great job!" completion screen**
- Mini summary card using standard card tokens (surface + border + exchange strip)
- Same success-icon treatment as above
- Primary CTA: "Confirm completion," full-width pill

---

*Swap · Dark Theme System v1 · Tokens for handoff*
