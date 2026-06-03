# UI Theming & Animation Design

> **Created**: 2026-06-03
> **Status**: Color system ✅ | Jelly animations ✅ | Remaining: Hero + blur ✅ | Open Q's recorded ✅

---

## Overview

Color theming is bound to the NSFW filter, giving each mode a distinct visual identity.
Animation strategy complements the color system with purposeful, non-intrusive motion.

---

## Color System

### Design Philosophy

Each NSFW filter mode has a distinct emotional intent:

| Mode | Intent | Visual Character |
|------|--------|------------------|
| **No** (SFW only) | Open, rational, tech-forward | Bright, clean, blue-gray — like VS Code / Linear |
| **Yes** (NSFW only) | Private, immersive, sensual | Dark, purple-pink — like late-night Discord |
| **All** | Unified, content-agnostic | Bridge palette — warm-gray base, blue-violet primary |

### All Mode: Bridge Palette Rationale

Choosing **slate-violet + deep cyan** as the bridge:

- Dark enough to be comfortable for NSFW content, but not so dark it feels "hidden"
- Blue-violet primary straddles SFW tech-blue and NSFW purple-pink
- Single consistent shell — content thumbnails provide their own color context
- Simpler to implement than dual-track approaches

---

### Color Tokens

#### SFW — `NsfwFilter.no`

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#F5F7FA` | Scaffold background |
| `surface` | `#FFFFFF` | Cards, dialogs |
| `surfaceVariant` | `#E8ECF1` | Chips, filter bars, subtle dividers |
| `primary` | `#4A90D9` | FAB, main CTA, selected states |
| `primaryContainer` | `#D6E8FB` | Highlighted rows, badges |
| `secondary` | `#6B7D8E` | Subtitle text, icons |
| `onBackground` | `#1A1D22` | Body text |
| `onSurface` | `#1A1D22` | Card text |
| `border` | `#D1D7E0` | Card borders, dividers |
| `accent` | `#34C759` | Success, download complete, positive indicators |

#### NSFW — `NsfwFilter.yes`

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#0D0A14` | Scaffold background |
| `surface` | `#1A1424` | Cards, dialogs |
| `surfaceVariant` | `#251D33` | Chips, filter bars |
| `primary` | `#B44D8F` | FAB, main CTA, selected states |
| `primaryContainer` | `#3D1B3D` | Highlighted rows, badges |
| `secondary` | `#E85D75` | Accent text, emphasis icons |
| `onBackground` | `#EDE4F2` | Body text |
| `onSurface` | `#EDE4F2` | Card text |
| `border` | `#302540` | Card borders, dividers |
| `accent` | `#FF6B9D` | Success, download complete, positive indicators |

#### All — `NsfwFilter.all`

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#1E1B24` | Scaffold background |
| `surface` | `#282432` | Cards, dialogs |
| `surfaceVariant` | `#332E40` | Chips, filter bars |
| `primary` | `#5B6ABF` | FAB, main CTA, selected states |
| `primaryContainer` | `#2A2A5A` | Highlighted rows, badges |
| `secondary` | `#C88A9E` | Accent text, emphasis icons |
| `onBackground` | `#E8E2F0` | Body text |
| `onSurface` | `#E8E2F0` | Card text |
| `border` | `#3A3448` | Card borders, dividers |
| `accent` | `#7B93D4` | Success, download complete, positive indicators |

---

### Semantic Token Mapping

| Semantic Role | SFW | NSFW | All |
|---------------|-----|------|-----|
| `error` | `#DC3545` | `#FF4D6A` | `#E0455B` |
| `warning` | `#F0A030` | `#F5B042` | `#F2A838` |
| `info` | `#4A90D9` | `#7B5EA7` | `#5B6ABF` |
| `nsfwBadge` | — | `#E85D75` | `#C44D8F` |
| `downloadProgress` | `#4A90D9` | `#B44D8F` | `#5B6ABF` |
| `downloadComplete` | `#34C759` | `#FF6B9D` | `#7B93D4` |
| `skeletonBase` | `#E8ECF1` | `#251D33` | `#332E40` |
| `skeletonShimmer` | `#F5F7FA` | `#302540` | `#3A3448` |

---

## Animation Strategy

### Design Philosophy — "Jelly"

Animations should feel **soft, rhythmic, and sensual** — like a dancer's controlled sway.
Motion language: slow build, soft landing, a gentle 2-3 cycle decay wobble before resting.

| Trait | Technical Expression |
|-------|---------------------|
| **Soft** | Low stiffness spring — yields under pressure, rebounds gently |
| **Rhythmic** | Asymmetric curve — slow acceleration, gentle deceleration with overshoot |
| **Subtle** | Small amplitude (±5-10%) — never jarring |
| **Flowing** | Stagger delays make elements ripple in like a wave |

### Spring vs Cubic — Decision

| Approach | Character | Verdict |
|----------|-----------|---------|
| `Cubic` (e.g. `easeOutBack`) | Single overshoot, no decay — feels like a bouncy ball | Not "jelly" enough |
| **Spring physics** ✅ | Multi-cycle decay oscillation — soft wobble before rest | True jelly feel |

**Chosen spring constants:**

| Token | mass | stiffness | damping | Duration | Feels Like |
|-------|------|-----------|---------|----------|------------|
| `jellyMicro` | 1.0 | 150 | 14 | ~200ms | Fingertip tap — quick settle |
| `jellyQuick` | 1.0 | 100 | 15 | ~350ms | Card pop-in — one visible wobble |
| `jellyStandard` | 1.0 | 120 | 12 | ~450ms | Page/modal — two visible wobbles |
| `jellySlow` | 1.0 | 80 | 10 | ~600ms | Hero reveal — slow bloom, lingering sway |

```dart
const jellyMicro    = SpringDescription(mass: 1.0, stiffness: 150, damping: 14);
const jellyQuick    = SpringDescription(mass: 1.0, stiffness: 100, damping: 15);
const jellyStandard = SpringDescription(mass: 1.0, stiffness: 120, damping: 12);
const jellySlow     = SpringDescription(mass: 1.0, stiffness: 80,  damping: 10);
```

### Reduced Motion

When `MediaQuery.of(context).disableAnimations` is true:

- All durations → 0ms
- Spring → instant snap
- Scale/stagger disabled entirely
- Progress bars retain width animation (functional, not decorative)
- Shimmer skeletons disabled — show static placeholder

---

### Specific Animations

#### ✅ Suited for Jelly

| Element | Animation | Spring | Notes |
|---------|-----------|--------|-------|
| Card appear (grid) | `scale(0.92→1.03→1.0)` + `fade` | `jellyQuick` | Stagger 60ms per card — wave-like |
| Chip toggle | `scale(1→0.94→1.02→1.0)` | `jellyMicro` | Gentle bounce on selection |
| Modal / bottom sheet | `scale(0.9→1.03→1.0)` + `fade` | `jellyStandard` | Soft entrance |
| Page transition | `fade` + `slide(8px, Curves.easeOut)` | 300ms | Slide first, fade overlays |
| NSFW blur reveal | Animated `ImageFiltered.blur(10→0)` | `jellySlow` | Slow unveil, 300ms |
| Download complete icon | `scale(0→1.2→1.0)` draw | `jellyQuick` | Bounce-in checkmark |
| Empty state | `translateY(12→0)` + `fade` | `jellySlow` | Drift in, 200ms delay |
| Shimmer skeleton | Linear gradient sweep | 1500ms loop | `surfaceVariant` → shimmer highlight |

#### ❌ Not Suited for Jelly

| Element | Why | Use Instead |
|---------|-----|-------------|
| Download progress bar | Needs precise reading | Linear tween, no spring |
| Text input focus | Distracting | Instant border color shift |
| Error banner / snackbar | Needs seriousness | Simple `fade` 200ms |
| Infinite loops (except shimmer) | Violates reduced-motion, annoys | Never |

---

## Implementation Approach

### Jelly Spring Helpers

```dart
/// Curves that approximate spring motion for use with [AnimatedContainer],
/// [AnimatedScale], etc. where only [Curve] is accepted.
const jellyCurve = Cubic(0.25, 1.3, 0.55, 1.0);     // ≈ jellyQuick
const jellyCurveGentle = Cubic(0.34, 1.4, 0.64, 1.0); // ≈ jellyStandard

/// Extension for triggering jelly spring animations on any widget.
extension JellyWidgetX on Widget {
  /// Wraps in an [AnimatedScale] with jelly spring feel.
  Widget jellyTap({VoidCallback? onTap}) => /* ... */;
}
```

### `ThemeData` per Mode

Three `ThemeData` instances with explicit `ColorScheme`:

```dart
final sfwTheme  = ThemeData(colorScheme: _sfwColorScheme,  useMaterial3: true);
final nsfwTheme = ThemeData(colorScheme: _nsfwColorScheme, useMaterial3: true);
final allTheme  = ThemeData(colorScheme: _allColorScheme,  useMaterial3: true);
```

### Mode Switching

```dart
final nsfwMode = NsfwSettings.instance.mode;
final theme = themeForMode(nsfwMode);
```

Theme crossfades over 400ms via `AnimatedTheme` in `main.dart`.

---

## Open Design Questions

### Card Shape

| Option | Corner Radius | Feel |
|--------|---------------|------|
| A | 12px | Subtle, professional — like Material 3 default |
| B | 16px | Softer, more playful — matches jelly animation feel |

**Recommendation:** B (16px). Our jelly animations lean playful. 16px corners complement the soft landing.

---

### Typography

| Option | Font | Feel |
|--------|------|------|
| A | Material 3 default (Roboto) | Familiar, zero cost |
| B | SFW: Inter / NSFW: custom softer font | More character, maintenance cost |

**Recommendation:** A for now. Custom typography is high-effort, low-ROI at this stage. Revisit when we have a design system.

---

### App Bar Style

| Option | Style | Feel |
|--------|-------|------|
| A | Standard Material 3 | Clean, predictable |
| B | Glassmorphism (NSFW/All modes) | Translucent blur — immersive, premium |

**Recommendation:** A for now. Glassmorphism requires `BackdropFilter` which has performance implications on scroll. Worth exploring later.

---

### Tab Indicator

| Option | Style | Feel |
|--------|-------|------|
| A | Underline (M3 default) | Minimal, standard |
| B | Pill shape | Softer, iOS-like |

**Recommendation:** B (pill). Pill indicators + jelly bounce on tab switch = cohesive motion language.

---

---

## Implementation Log

### 2026-06-03 — Color System Infrastructure ✅

**Files created:**

- `lib/settings/nsfw_settings.dart` — Global `NsfwSettings` ChangeNotifier, persisted to SharedPreferences
- `lib/ui/theme.dart` — Three `ColorScheme` constants (`_sfwColorScheme`, `_nsfwColorScheme`, `_allColorScheme`) + `themeForMode()` helper

**Files modified:**

- `lib/main.dart` — `MyApp` → `StatefulWidget`, wraps `AnimatedTheme` with `ListenableBuilder` listening to `NsfwSettings`
- `lib/ui/local_models/filter_panel.dart` — NSFW `ChoiceChip` selection updates global `NsfwSettings.instance.mode`; removed `nsfw` from `ModelFilters` output
- `lib/ui/local_models/local_models_page.dart` — `_fetch()` reads NSFW filter from `NsfwSettings.instance.mode`; listens for NSFW changes to re-query

**Behavior:**

- Changing NSFW mode in FilterPanel → theme crossfades (400ms) + model list re-queries
- Mode persists across app restarts via SharedPreferences key `nsfw_filter`
- Default: `NsfwFilter.all` (show everything, bridge palette)

### 2026-06-03 — Color Cleanup ✅

All hardcoded `Colors.xxx` migrated to `ColorScheme`:

| File | Before | After |
|------|--------|-------|
| `stats_page.dart` | 8 hardcoded chart colors + `Colors.green/red/grey` | `_generateColors(scheme)` from `ColorScheme` tones |
| `model_card.dart` | `Colors.blue/purple/teal/...` per type | `_typeColor(type, scheme)` mapping |
| `download_task_tile.dart` | `Colors.green/red/grey` icons | `theme.colorScheme.error/tertiary/onSurface` |

### 2026-06-03 — Skeleton + Progress + Page Transition ✅

| Widget | File | Effect |
|--------|------|--------|
| `ShimmerCard` + `ShimmerGrid` | `animation.dart` | Replaces `CircularProgressIndicator` with shimmer skeleton grid |
| `JellyProgressBar` | `animation.dart` | Gradient-filled progress bar replacing `LinearProgressIndicator` |
| `JellyPageRoute` | `animation.dart` | fade + slide-up page transition, 350ms |

### 2026-06-03 — NSFW Blur + Hero Transition ✅

| Widget | File | Effect |
|--------|------|--------|
| `NsfwBlurReveal` | `animation.dart` | Blurs child (sigma 20), tap to deblur over 300ms with eye icon overlay |
| `Hero` wrappers | `model_card.dart` + `model_detail_page.dart` | Image animates from grid tile to detail header on navigation |

**Design decisions recorded:**

- Card corners: **16px** (matches jelly aesthetic)
- Typography: **M3 default** for now
- App bar: **standard Material** for now
- Tab indicator: **pill shape** preferred

**Card widget replaced:** `_CardEntrance` → `_AnimatedModelCard`

| Feature | Implementation | Detail |
|---------|---------------|--------|
| **Scroll-proof** | `AutomaticKeepAliveClientMixin` | Cards survive GridView recycling — entrance animation plays only once |
| **Floating** | `AnimationController` repeat reverse, phase-shifted per index | Each card bobs ±3px at a slightly different rhythm (2.2-2.8s cycle) |
| **Hover tilt** | `MouseRegion` + `Matrix4` perspective + `rotateX`/`rotateY` | ±6° tilt following cursor, 1.04x scale lift on hover |
| **Tilt return** | `AnimationController` + `jellyCurve` spring-back | On mouse exit, tilt springs back to neutral over 400ms |
| **Reduced motion** | `MediaQuery.disableAnimations` gate | All effects disabled; returns plain `widget.child` |

**Files created:**

- `lib/ui/animation.dart` — Spring constants (`jellyMicro/Quick/Standard/Slow`), cubic approximations, helper widgets (`JellyStaggerList`, `JellyTap`, `JellyScale`, `JellyDriftIn`)

**Animations applied:**

| Location | Animation | Spring/Curve | Effect |
|----------|-----------|--------------|--------|
| `local_models_page.dart` | `_CardEntrance` | `jellyCurve`, stagger 60ms | Grid cards ripple in like a wave |
| `local_models_page.dart` | `JellyDriftIn` | `jellyCurveGentle`, 500ms | Empty state text drifts up + fades in |
| `download_task_tile.dart` | `_JellyCompleteIcon` | `jellyCurve`, 400ms | Checkmark pops in 0→1.3→1.0 on download complete |
