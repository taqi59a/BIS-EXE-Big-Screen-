# BIS Display — Android Digital Signage App

**School:** The British International School of Lubumbashi  
**Platform:** Android (portrait tablet / TV)  
**Stack:** Flutter 3.24.5 · Dart 3.5.4 · Java 21 · SQLite (sqflite)  
**APK:** `build/app/outputs/flutter-apk/app-release.apk` (~36 MB)

> **For agents/developers:** Read [ARCHITECTURE.md](ARCHITECTURE.md) for a full technical map of every file, pattern, and gotcha before making changes.

---

## What It Does

Full-screen kiosk display that rotates through content slides:

| Slide | Content |
|---|---|
| Clock | Live time, date, current school period |
| Quote | Inspirational quote (rotates every 3 min) |
| Fact | Did-you-know fact (rotates every 45 s) |
| Word of the Day | Word + phonetic + definition (changes daily) |
| Today in History | Historical event matching today's date |
| Next Event | Next upcoming school event + countdown |
| Upcoming Events | Next 5 school events listed |

Background: animated gradient (8 themes) + floating particle overlay + looping background music.

---

## Admin Panel

Tap the screen **5 times in 3 seconds** → password prompt → full CRUD for all content.

**Password:** defined in `AppConstants.adminPassword` in `lib/constants.dart`

Sections: Quotes · Facts · Words · History Events · School Events · Periods · Music · Settings

---

## Build

```bash
# Java 21 required — Java 25 will break the build
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

flutter build apk --release
```

---

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── constants.dart               # All colours, fonts, school strings, timing constants
├── models/models.dart           # Data classes: Quote, Fact, Word, HistoryEvent, SchoolEvent, Period
├── database/database_helper.dart # SQLite CRUD singleton
├── database/seed_data.dart      # Default content seeded on first install
├── providers/display_provider.dart # Central state + slideshow engine (ChangeNotifier)
├── services/music_service.dart  # Background music — LoopMode.one, volume 0.7
├── screens/display_screen.dart  # All slide widgets + header/footer/dots
├── screens/admin_screen.dart    # Admin CRUD panel
└── widgets/particle_overlay.dart # Animated particle canvas
```

---

## Key Technical Facts

- **Orientation:** Portrait only, immersive sticky (no system UI)
- **Screen always on:** `wakelock_plus`
- **State management:** `provider` (single `DisplayProvider`)
- **Database:** SQLite via `sqflite`, db version `3` in `AppConstants.dbVersion`
- **Fonts:** Cinzel (headings), Orbitron (clock), Lato (body) — all bundled in `assets/fonts/`
- **Music:** Bundled MP3 in `assets/music/` + optional external `/sdcard/BISL_Display/music/`
- **Glass card:** `BackdropFilter` blur 20 + `Colors.black.withOpacity(0.52)` — ensures text is always visible
- **Dynamic text:** `_dynamicFontSize()` in `display_screen.dart` scales font by text length
- **Slide navigation:** Swipe left/right or auto-advance every `slideSeconds` (default 10 s, configurable in Admin)

---

## Dependencies

| Package | Version | Use |
|---|---|---|
| `sqflite` | ^2.3.3 | Local database |
| `provider` | ^6.1.2 | State management |
| `just_audio` | ^0.9.40 | Music playback |
| `flutter_animate` | ^4.5.0 | Slide/widget animations |
| `shared_preferences` | ^2.3.2 | Persist settings |
| `intl` | ^0.19.0 | Date formatting |
| `wakelock_plus` | 1.2.8 (pinned) | Keep screen on |
| `permission_handler` | ^11.3.1 | Storage access |

`package_info_plus` and `wakelock_plus` are pinned via `dependency_overrides` in `pubspec.yaml` to avoid a Kotlin 2.2.0 requirement.

---

## Known Gotchas

- **Java 25 breaks the build** — always set `JAVA_HOME` to Java 21 before building
- **Logo removed** — the asset file has a corrupt name (`'BIS LOGO with font.png bb.png'`); logo references were deleted
- **Music asset filename has double spaces** — do not rename the MP3 file or the asset manifest path will break
- **DB upgrade drops all data** — bump `AppConstants.dbVersion` to reset and reseed the database
