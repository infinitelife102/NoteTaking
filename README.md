# NoteTaking

A simple, secure note-taking app built with Flutter. Works fully offline. Notes are stored locally and encrypted.

## Features

- **Offline-first** – No account required; all data stays on your device
- **Encrypted storage** – Notes are encrypted using Hive with a secure key
- **Light / dark theme** – Follows system theme or manual toggle
- **Rich notes** – Text and images (camera or gallery)
- **Trash** – Deleted notes can be restored from trash

## Supported platforms

- Android  
- iOS  
- macOS  
- Windows  
- Linux  
- Web  

## Requirements

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (stable channel, SDK ^3.7.2)
- For mobile: Android Studio / Xcode and device or emulator
- For desktop: platform-specific build tools (e.g. Visual Studio for Windows, Xcode for macOS)

## Getting started

### 1. Clone and open the project

```bash
git clone <repository-url>
cd <project-folder>
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
# Run on default device (phone/emulator/Chrome)
flutter run

# Run on a specific platform
flutter run -d chrome
flutter run -d windows
flutter run -d macos
```

### 4. Build for release

```bash
# Android APK
flutter build apk

# Android App Bundle (for Play Store)
flutter build appbundle

# iOS (requires macOS and Xcode)
flutter build ios

# Web
flutter build web

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Project structure

```
lib/
  main.dart           # App entry, theme, providers
  note_list_page.dart # Note list and FAB
  note_form_page.dart # Create/edit note screen
  note_tile.dart      # Note list item widget
  note_service.dart   # Hive box and CRUD
  theme.dart          # Theme data
  theme_provider.dart # Theme mode state
  models/
    note_item.dart    # Note model (Hive)
    note_item.g.dart  # Generated Hive adapter
```

## Regenerating code

After changing `lib/models/note_item.dart` (e.g. new fields), run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Changing the app icon

Source icon: `assets/app_icon.png` (1024×1024 recommended). Regenerate all platform icons with:

```bash
dart run flutter_launcher_icons
```

## Privacy

NoteTaking does not collect or send any personal data. All notes are stored only on your device. See [privacy.md](privacy.md).

## License

This project is licensed under the MIT License – see [LICENSE](LICENSE).
