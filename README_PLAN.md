# README Plan — clipboard_project

Analysis based on repository inspection (August 2026). All items below are derived from source files, configuration, and test runs.

---

## Project Summary

| Field | Value |
| ----- | ----- |
| **Package name** | `clipboard_project` |
| **Display name** | Clipboard Manager (`MaterialApp.title` in `lib/main.dart`) |
| **One-line description** | A macOS menu bar clipboard manager with local history, search, and a global keyboard shortcut. |
| **Detailed description** | Flutter/Dart application with native macOS integration. It runs as a menu bar utility (`LSUIElement`), monitors the system clipboard, stores history in a local SQLite database (Drift), and presents a floating glass panel to browse, search, filter, pin, and re-copy items. |
| **Problem solved** | Gives quick access to recently copied text and images without leaving the current app. |
| **Target users** | macOS users who want a lightweight clipboard history utility. |
| **Platform(s)** | **macOS** — fully implemented with native Swift integration. Other Flutter platform folders (Android, iOS, Linux, Windows, Web) exist as scaffold but have no clipboard-specific native implementation. |
| **Status** | Active development. `pubspec.yaml` version `1.0.0+1`. Default `README.md` is still the Flutter template. No `LICENSE`, CI workflows, or contribution docs found. |

---

## Feature List

### Implemented features

**Core**

- Automatic clipboard monitoring (text and images) via native `ClipboardMonitor` (0.5s polling)
- Local persistence with Drift/SQLite (`clipboard_db`)
- Content classification on capture (image, URL, email, phone, color, code, plain text)
- SHA-256 content hashing for duplicate detection; duplicates update `lastUsedAt` instead of creating new rows
- History cap of 1,000 non-favorite items (`ClipboardHistoryPolicy`)
- Select an item to copy it back to the clipboard and hide the panel
- Image clipboard support (saved to cache as PNG, path stored in DB)

**Search & filter**

- Debounced text search (250 ms) against stored content
- Date filters: All dates, Today, Yesterday, Last 7 days, Pick a date
- Category filter chips: All, Text, URL, Email, Code, Color, Image
- Combined empty-state messaging for active filters

**History & organization**

- Pinned (favorite) section at top
- Recent items grouped by day with item counts
- Pin/unpin and delete via card actions and context menu
- Clear history from panel footer
- Source app name captured when available

**Smart / type-specific behavior**

- URL items: Open and Copy quick actions
- Email items: Email (`mailto:`) and Copy quick actions
- Phone and code items: Copy quick action
- Color items: grid/swatch layout (hex and `rgb()`/`rgba()` detection)
- Image items: grid layout

**macOS integration**

- Menu bar icon and menu (Open, Pause/Resume monitoring, Clear history, Quit)
- Floating panel window (`NSPanel`, 450×600) with transparent title bar
- App hides on window close; keeps running in background
- Global shortcut **⌘⇧V** via Carbon `RegisterEventHotKey`, CGEvent tap (when Accessibility granted), and `NSEvent` global monitor fallback
- Launch at login via `SMAppService` (`LaunchAtLogin.swift`)
- Accessibility permission prompt and settings deep-link from in-app Settings
- `flutter_acrylic` HUD window effect on macOS

**UI / UX**

- Dark-themed glass panel UI
- Keyboard navigation: ↑/↓ to move selection, Enter to paste, Esc to close/hide
- Settings screen: Launch at login toggle, shortcut status, Accessibility guidance with bundle path
- Relative-timestamp display on cards
- Item count in footer

### Partially implemented / limited

| Item | Notes |
| ---- | ----- |
| **Phone category** | Detected by `PhoneDetector` but no category filter chip in the UI mapper |
| **Monitoring toggle in Flutter UI** | `ClipboardMonitoringToggled` exists in the BLoC; pause/resume is only exposed via the native status bar menu, not the Settings panel |
| **Status bar “Clear History”** | `AppDelegate.statusBarDidRequestClearHistory` sends `["type": "clear_history"]` but `ClipboardBloc` listens for `event == 'clear_history'` — likely does not trigger Flutter-side clear |
| **Legacy page** | `clipboard_history_page.dart` exists but is not referenced anywhere |
| **Non-macOS platforms** | `ClipboardPlatformImpl` returns stubs for non-macOS; `main.dart` only applies window effects on macOS |

### Planned features

None explicitly documented in the repository (no roadmap, issues template, or TODO file found).

---

## Tech Stack

| Technology | Purpose |
| ---------- | ------- |
| Flutter 3.48+ (main channel, per `.metadata`) | UI framework |
| Dart ^3.13.0-158.0.dev (`pubspec.yaml`) | Application language |
| flutter_bloc ^9.1.0 + equatable | State management |
| drift ^2.34.0 + drift_flutter ^0.3.0 | SQLite persistence |
| drift_dev + build_runner | Drift code generation (`database.g.dart`) |
| crypto ^3.0.0 | SHA-256 content hashing |
| url_launcher ^6.3.1 | Open URLs and `mailto:` links |
| intl ^0.20.2 | Date/time formatting |
| flutter_acrylic ^1.1.4 | macOS translucent window effect |
| cupertino_icons ^1.0.8 | UI icons |
| path_provider ^2.1.0 | Platform paths (dependency) |
| flutter_lints ^6.0.0 | Lint rules (`analysis_options.yaml`) |
| bloc_test + mocktail | BLoC and repository tests |
| Swift (macOS Runner) | Clipboard monitor, global shortcut, status bar, launch at login |
| Cocoa / Carbon / ApplicationServices | Native macOS APIs |

---

## Architecture Summary

**Feature-based layout** with a **clipboard** feature split into **data**, **domain**, and **presentation** layers, plus a small **core** module.

- **Domain**: entities (`ClipboardItem`, `ContentCategory`, `ClipboardDateFilter`), repository interface, use case (`AddClipboardItemUseCase`), content detection pipeline (`ContentClassifier` + detectors), quick actions, history policy.
- **Data**: `ClipboardRepositoryImpl` using Drift (`AppDatabase`).
- **Presentation**: `ClipboardBloc` (events/states), UI mappers, modern glass-panel widgets, `ClipboardModernPanelPage`.
- **Core**: `ClipboardPlatform` abstraction, method/event channels (`com.clipboard/methods`, `com.clipboard/events`), Drift database setup.
- **DI**: Manual wiring in `main.dart` via `RepositoryProvider` and `BlocProvider` (no injectable/get_it).
- **Native**: Flutter method/event channels bridge to Swift (`AppDelegate`, `ClipboardMonitor`, `GlobalShortcut`, `StatusBarController`, `LaunchAtLogin`, `MainFlutterWindow`).

This is a pragmatic layered architecture with BLoC and repository/use-case patterns. It is **not** a full Clean Architecture setup (no separate injectable service locator, limited use-case surface).

---

## Setup Requirements

| Requirement | Source |
| ----------- | ------ |
| macOS 13.0+ | `MACOSX_DEPLOYMENT_TARGET = 13.0` in Xcode project |
| Flutter SDK compatible with Dart ^3.13.0-158.0.dev | `pubspec.yaml`, `.metadata` |
| Xcode (for macOS builds) | Standard Flutter macOS requirement |
| No `.env`, API keys, or external services | Not found in repository |

---

## Installation

```bash
git clone <repository-url>
cd clipboard_project
flutter pub get
```

`lib/core/database/database.g.dart` is committed. Regenerate only if the Drift schema changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Running

```bash
flutter run -d macos
```

The app starts hidden (menu bar only). Open the panel with **⌘⇧V** or the menu bar item **Open Clipboard History**.

---

## Building

```bash
# Debug (sandbox enabled via DebugProfile.entitlements)
flutter build macos

# Release
flutter build macos --release
```

**Artifact:** `build/macos/Build/Products/Release/clipboard_project.app`

Release builds use `macos/Runner/Release.entitlements` (empty dict — App Sandbox disabled). Debug/profile builds use sandbox entitlements.

Signing: `CODE_SIGN_IDENTITY = "-"` (ad-hoc) in `project.pbxproj`. No notarization or distribution scripts in the repo.

---

## Testing

```bash
flutter test
```

**Current result:** 41 tests, all passing.

Coverage includes: date filters, content classifiers/detectors, repository, BLoC, UI mapper, timestamp formatter, quick action resolver, add-item use case, hasher, and widget tests for the modern panel page.

```bash
flutter analyze
```

---

## Repository Structure

```text
clipboard_project/
├── lib/
│   ├── main.dart                          # App entry, DI wiring
│   ├── core/
│   │   ├── database/                      # Drift schema + generated code
│   │   └── platform/                      # Method/event channels, platform API
│   └── features/clipboard/
│       ├── data/repositories/             # ClipboardRepositoryImpl
│       ├── domain/
│       │   ├── actions/                   # Quick actions
│       │   ├── detection/                 # Content classifiers & detectors
│       │   ├── entities/
│       │   ├── hashing/
│       │   ├── repositories/              # Repository interface
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── mappers/
│           ├── models/
│           ├── pages/
│           ├── theme/
│           ├── utils/
│           └── widgets/modern/            # Glass panel UI
├── macos/Runner/
│   ├── AppDelegate.swift
│   ├── ClipboardMonitor.swift
│   ├── GlobalShortcut.swift
│   ├── LaunchAtLogin.swift
│   ├── MainFlutterWindow.swift
│   ├── StatusBarController.swift
│   ├── DebugProfile.entitlements
│   └── Release.entitlements
├── test/features/clipboard/               # Unit, bloc, widget tests
├── pubspec.yaml
└── analysis_options.yaml
```

---
