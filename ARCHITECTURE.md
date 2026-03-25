# BIS Display — App Architecture

> **Purpose of this file:** Give any future agent or developer a complete mental map of the app so they can make changes without reading every source file first. Read this + `README.md` before touching any code.

---

## 1. What the App Does

A Flutter Android kiosk/digital-signage app for **The British International School of Lubumbashi**. It runs full-screen on a portrait TV/tablet, rotating through content slides with ambient background music. An admin panel (hidden behind a 5-tap gesture) lets staff manage all content.

---

## 2. Project Layout

```
lib/
├── main.dart                    # Entry point, Provider setup, wakelock, orientation lock
├── constants.dart               # ALL magic values — colours, fonts, school strings, timing
│
├── models/
│   └── models.dart              # Pure Dart data classes (no logic, just toMap/fromMap)
│
├── database/
│   ├── database_helper.dart     # Singleton SQLite wrapper — all CRUD
│   ├── seed_data.dart           # Default quotes/facts/words/history seeded on first install
│   └── education_history_data.dart  # Additional history event seeds
│
├── providers/
│   └── display_provider.dart    # Central ChangeNotifier — slideshow engine, timers, state
│
├── services/
│   └── music_service.dart       # Singleton audio player — LoopMode.one, 0.7 volume
│
├── screens/
│   ├── display_screen.dart      # Main display — all slide widgets live here
│   └── admin_screen.dart        # Password-protected CRUD panel
│
└── widgets/
    ├── particle_overlay.dart    # Animated floating-particle + shooting-star canvas
    ├── clock_widget.dart        # (Legacy) Clock widget — may be unused
    ├── content_cards.dart       # (Legacy) Card widgets — may be unused
    └── glass_card.dart          # (Legacy) Glass card shell — may be unused

android/                         # Standard Flutter Android project
assets/
├── fonts/                       # Orbitron (clock), Cinzel (heading), Lato (body)
├── images/                      # Static images (logo removed — corrupt filename)
└── music/                       # Bundled MP3 (long filename with double spaces — do not rename)
```

---

## 3. Data Flow

```
SQLite (bisl_display.db)
        │
        ▼
DatabaseHelper.instance   ← singleton, all async CRUD
        │
        ▼
DisplayProvider (ChangeNotifier)
  • Loads all content on init()
  • Rotates current quote/fact/word/history on timers
  • Advances slide index on a periodic Timer
  • Writes settings to SharedPreferences
        │
        ▼ notifyListeners()
DisplayScreen (Consumer<DisplayProvider>)
  • Reads dp.currentSlideType → picks the right slide widget
  • Passes the whole `dp` object down to each slide widget
  • AnimatedSwitcher handles slide transitions
        │
        ▼
Slide Widgets (_ClockSlide, _QuoteSlide, _FactSlide, …)
  • Stateless widgets — read data from dp, render, done
```

---

## 4. Slide System

### Slide types (enum `SlideType`)
| Value | Widget | Accent colour | Data source |
|---|---|---|---|
| `clock` | `_ClockSlide` | gold | `dp.now`, `dp.currentPeriod` |
| `quote` | `_QuoteSlide` | electric (purple) | `dp.currentQuote` |
| `fact` | `_FactSlide` | cyan | `dp.currentFact` |
| `word` | `_WordSlide` | lavender | `dp.currentWord` |
| `history` | `_HistorySlide` | emerald | `dp.currentHistoryEvent` |
| `nextEvent` | `_NextEventSlide` | coral / neonPink | `dp.nextEvent` |
| `upcomingEvents` | `_UpcomingSlide` | teal | `dp.upcomingEvents` |

A slide is only added to `activeSlides` if its data is non-null/non-empty — so if there are no school events the event slides simply disappear.

### Slide layout pattern (NEW — all content slides)
Every slide uses this exact layout. **Do not use `Center → Column(min)` — it leaves dead space.**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const _SchoolNameBanner(),          // fixed height banner at top
    Expanded(
      child: _GlassBox(
        accentColor: VividColors.xxx,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ /* content */ ],
        ),
      ),
    ),
  ],
)
```

### The clock slide is the exception
The clock slide uses `Center → Column(min)` because it has a different visual structure (large time display, not a card).

---

## 5. Key Widgets in `display_screen.dart`

### `_GlassBox`
The frosted-glass card used on every content slide.
- `BackdropFilter(ImageFilter.blur(sigmaX: 20, sigmaY: 20))`
- Background: `Colors.black.withOpacity(0.52)` — high opacity ensures text is always readable
- Border: `Colors.white.withOpacity(0.55)`
- All text inside should be `Colors.white` with `Shadow(Colors.black, opacity 0.8, blurRadius 4)`

### `_SchoolNameBanner`
Displays school name and motto above every content slide card. Gold shimmer animation.

### `_dynamicFontSize()`
Free function (not a widget) that scales font size by text length:
```dart
double _dynamicFontSize(String text, {
  double maxSize = 24,
  double midSize = 20,
  double minSize = 16,
  int midThreshold = 120,   // chars where scaling starts
  int minThreshold = 220,   // chars where minimum kicks in
})
```
**Use this whenever displaying user-entered text (quotes, facts, event titles).**

### `_buildHeader()`
Top bar: school name (left), time + date (right). Always visible above slides.

### `_buildFooter()`
Bottom bar: website (gold, 13px) | credits (white70, 11px). No music track name.

### `_buildDots()`
Navigation dots between footer and content area.

---

## 6. Background

The full app background is an `AnimatedContainer` with a `LinearGradient` that transitions between 8 themes in `SlideGradients.themes`. The gradient index equals the current slide index. `ParticleOverlay` (35 particles + 1 shooting star) sits above the gradient on a `Positioned.fill` layer.

---

## 7. Music Service

**File:** `lib/services/music_service.dart`  
**Pattern:** Singleton (`MusicService.instance`)

Key facts:
- Uses `just_audio` `AudioPlayer` — **single player, no crossfade**
- `LoopMode.one` — track loops forever without any callback needed
- Volume set directly to `0.7` — **no fade-in**, it was removed because `_fadeIn()` was once not awaited, keeping volume at 0
- Discovers tracks from two sources in order:
  1. Bundled assets (`assets/music/*.mp3`)
  2. External storage at `[sdcard]/BISL_Display/music/`
- The bundled asset filename has double spaces — `Inspiring Background Music  Cinematic Epic Music  ROYALTY FREE Music by MUSIC4VIDEO.mp3` — **do not rename it**, the path in `AssetManifest.json` must match exactly

To add music via external storage: copy MP3s to `/sdcard/BISL_Display/music/` on the device and use the Admin → Music → Rescan button.

---

## 8. Database

**File:** `lib/database/database_helper.dart`  
**Engine:** `sqflite` — local SQLite, stored in app private storage  
**DB name:** `bisl_display.db`  **Version:** `3`

### Tables
| Table | Key columns | Notes |
|---|---|---|
| `quotes` | `text`, `author`, `is_active` | Random rotation every 3 min |
| `facts` | `text`, `category` (`global`/`drc`), `is_active` | Random rotation every 45 s |
| `words` | `word`, `phonetic`, `definition`, `example`, `is_active` | One per day (seeded by date) |
| `history_events` | `month`, `day`, `year`, `event`, `is_active` | Filtered to today's month+day |
| `school_events` | `title`, `event_date` (ISO string), `is_active` | Future events only |
| `periods` | `name`, `start_hour/minute`, `end_hour/minute`, `sort_order` | School timetable |

`onUpgrade` **drops all tables and re-creates** — bump `dbVersion` in `constants.dart` to wipe and reseed on next launch.

---

## 9. Provider (`DisplayProvider`)

**File:** `lib/providers/display_provider.dart`  
Extends `ChangeNotifier`. Initialised once via `create: (_) => DisplayProvider()..init()` in `main.dart`.

### Timers running after `init()`
| Timer | Interval | Action |
|---|---|---|
| `_clockTimer` | 1 s | Updates `_now`, triggers daily event refresh |
| `_quoteTimer` | 180 s | Picks new random quote |
| `_factTimer` | 45 s | Picks new random fact |
| `_historyTimer` | 30 s | Cycles to next today-in-history event |
| `_slideTimer` | `slideSeconds` (default 10 s) | Advances `_currentSlide` |

### Important getters
- `dp.nextEvent` — first upcoming `SchoolEvent` (used for Next Event slide)
- `dp.upcomingEvents` — all future school events sorted ascending
- `dp.currentPeriod` — active `Period` if within period time, else null
- `dp.activeSlides` — computed list; only includes slide types with data

---

## 10. Admin Screen

**Access:** Tap the display 5 times within 3 seconds  
**Password:** defined in `AppConstants.adminPassword`  
**Sections:** Quotes, Facts, Words, History Events, School Events, Periods, Music, Settings (slide speed)

The admin screen uses `BISLColors` (legacy dark-navy palette) — different from the vivid display palette.

---

## 11. Constants Quick Reference

All in `lib/constants.dart`. **Never hardcode these values elsewhere.**

| Class | Purpose |
|---|---|
| `VividColors` | Display UI colours (accent colours per slide type) |
| `SlideGradients` | 8 background gradient themes |
| `BISLColors` | Admin screen legacy palette |
| `AppConstants` | School name, motto, website, passwords, DB config, timing |
| `AppFonts` | Font family names: `heading=Cinzel`, `clock=Orbitron`, `body=Lato` |

---

## 12. Build Instructions

```bash
# Requires Java 21 — Java 25 breaks Kotlin/Gradle
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

cd /workspaces/Android-Display-Screen-BIS
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (~36 MB)
```

**Java 25 incompatibility note:** `IllegalArgumentException: 25.0.1` from Kotlin compiler. Always set `JAVA_HOME` to Java 21 before building.

---

## 13. Known Issues / Gotchas

| Issue | Status | Notes |
|---|---|---|
| Logo asset | Removed | File on disk: `'BIS LOGO with font.png bb.png'` (extra `bb` suffix). All logo references deleted. |
| Music asset filename | Working | Double spaces in filename — `AssetManifest.json` stores the exact path. Do not rename. |
| `withOpacity()` deprecation warning | Info only | Flutter 3.24 warns; use `Color.fromRGBO()` if needed. Won't break build. |
| `package_info_plus` & `wakelock_plus` pinned via `dependency_overrides` | Working | Avoids Kotlin 2.2.0 requirement from newer versions. |
| `_UpcomingSlide` skips first event | By design | `events.skip(1)` — first event is assumed to be shown in `_NextEventSlide`. |

---

## 14. Adding a New Slide Type

1. Add a value to the `SlideType` enum in `display_provider.dart`
2. Add the slide to `activeSlides` getter (with a null-guard if needed)
3. Add a `case SlideType.xxx:` in `_buildSlide()` in `display_screen.dart`
4. Write a new `class _XxxSlide extends StatelessWidget` using the **Expanded layout pattern** from §4
5. Pick an accent colour from `VividColors` and a gradient index from `SlideGradients`
