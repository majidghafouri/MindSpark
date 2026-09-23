# NeverMindSpark

![Flutter](https://img.shields.io/badge/Flutter-3.47-blue?logo=flutter) ![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart) ![Platform Android](https://img.shields.io/badge/platform-Android-green)

**A fresh set of quick brain challenges every day.**

NeverMindSpark is a daily brain-training app: every day you get a deterministic set of five short challenges across three categories — number sequences, logic (odd-one-out), and attention — with streaks, badges, and an optional daily reminder.

---

## Features

- **Daily 5-question run** — a new set is generated deterministically from the date, so every day offers the same set to everyone who plays it.
- **3 challenge categories**, each rendered with a purpose-built widget:
  - **Number Sequence** — find the next term of an arithmetic or Fibonacci pattern.
  - **Logic (odd-one-out)** — pick the item that doesn't fit.
  - **Attention** — count occurrences of a target digit in a large number.
- **3 difficulty tiers** (Easy / Medium / Hard) — harder questions are worth more points.
- **Scoring** — normalized 0–100 score with difficulty-weighted, partial credit for wrong answers and time-bonus-free (timer is visual only, never punishing).
- **Streaks & badges** — current/longest consecutive-day streaks and milestone badges at 1, 7, 30, and 100 days.
- **Stats screen** — all-time history, per-category breakdowns, and streaks.
- **AdMob** — adaptive banner on the results screen and an optional rewarded ad to claim a small score bonus (skippable, graceful fallback when ads are unavailable).
- **Daily reminder** — local push notification at a chosen time (runtime permission, safe to deny).
- **Onboarding** — first-run introduction and preferences, never shown again on restart.
- **Persistence** — Hive-backed storage: progress, history, badges, and settings survive restarts.
- **Light & dark themes** with system-follow.

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.47 (`flutter doctor` should pass for the Android toolchain)
- Android SDK with an emulator or a physical device

### Run

```sh
flutter pub get
flutter run
```

Current app/package metadata live in `pubspec.yaml` (`name: nevermindspark`,
`version: 1.0.0+1`).

> **Note for this machine:** `dl.google.com` and `pub.dev` are blocked on the
> dev network. Pub uses a mirror and Android Gradle resolves via a Tencent Nexus
> mirror; see the **Build environment** section below and
> [`STORE_SUBMISSION.md`](STORE_SUBMISSION.md).

## Test

```sh
flutter analyze       # must report: No issues found!
flutter test          # 37 tests across unit + widget suites
```

Tests cover: deterministic daily sets, every generator (valid, solvable,
seed-stable), streak semantics, scoring/partial credit, persistence round-trips,
and a full end-to-end widget flow (onboarding → 5-question run → results).

## Architecture

The app is organized in a lightweight layered layout under `lib/`:

```
lib/
├── main.dart                  # Bootstrap: Hive init, notification/ads init
├── app.dart                   # Root MaterialApp, routing, onboarding gate
├── domain/                    # Pure Dart: no Flutter UI, no I/O
│   ├── models/                # Challenge, DailyChallengeSet, enums, difficulty
│   ├── generators/            # Sequence / Logic / Attention challenge engines
│   └── services/              # DailyChallengeService, deterministic seed
├── data/                      # Persistence & value objects
│   ├── models/                # DayResult, StreakInfo, Badge, ProgressSnapshot, AppSettings
│   └── repositories/          # ProgressRepository over a pluggable ProgressStore
├── services/                  # AdMob (AdsService/AdConfig) and notifications
└── presentation/              # Flutter UI
    ├── state/                 # AppState + GameSession (ChangeNotifier)
    ├── screens/               # Home, Challenge, Results, Stats, Settings, Onboarding
    ├── widgets/               # Question views, AnswerOption, QuestionTimer, BannerAdView
    └── theme/                 # AppTheme (light/dark)
```

### Design decisions

- **Deterministic content**: `DailyChallengeService` produces the identical
  challenge set for a given date (seeded by date). Rotating generator picker
  guarantees all three categories appear every day. Same seed ⇒ same challenge,
  so answers stay fair and reproducible.
- **UI owns nothing permanent**: gameplay state lives in `GameSession`
  (a `ChangeNotifier`), shared app state lives in `AppState`, and persistent
  data flows through `ProgressRepository`. Screens are dumb renderers.
- **Storage is pluggable**: `ProgressStore` has a `HiveProgressStore` (production)
  and a `MemoryProgressStore` (tests), so persistence logic is exercised without
  a device.
- **Ads degrade gracefully**: if the SDK is unavailable or a network fails, the
  app simply hides the banner and disables the reward instead of crashing.
- **Non-punitive timer**: the per-question clock is a light visual nudge; running
  out never auto-fails you.

## Domain model cheat-sheet

| Concept | Detail |
|---|---|
| `ChallengeType` | `sequence`, `oddOneOut`, `attention` |
| `ChallengeDifficulty` | Easy (15 pts, 20 s), Medium (18 pts, 30 s), Hard (20 pts, 45 s) |
| Scoring | difficulty-weighted points → 0–100 normalized daily score |
| Streaks | missed day resets `current`, keeps `longest` + history |
| `Badge` | 1 day *Beginner*, 7 *Trainee*, 30 *Master*, 100 *Elite* |

## Store submission

Before shipping, you must replace AdMob test IDs, configure release signing,
and prepare store assets/privacy text. That full checklist lives in
[`STORE_SUBMISSION.md`](STORE_SUBMISSION.md).

## Build environment (this machine)

This network blocks Google's and pub.dev's hosts. The repo copes as follows:

- Pub dependency resolution uses the Flutter-io.cn mirror.
- `android/settings.gradle.kts` and `android/build.gradle.kts` use the Tencent
  Nexus Maven mirror in place of `google()`.
- `android/app/build.gradle.kts` pins `ndkVersion = "27.1.12297006"` because
  Flutter's preferred NDK can't be downloaded here.
- Several plugin `android/build.gradle` files in the pub-cache were patched in
  place to use the mirror — those patches are local and lost on cache flush.

## License

Not yet licensed. Intent privately distributed, direct-to-store.