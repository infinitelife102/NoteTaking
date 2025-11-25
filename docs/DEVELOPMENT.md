# NoteTaking – Development guide

## Environment

- **Flutter**: Stable channel, SDK constraint `^3.7.2` (see `pubspec.yaml`)
- **Dart**: 3.7.2 or compatible
- **IDE**: VS Code or Android Studio with Flutter/Dart plugins

## Dependencies (main)

| Package            | Purpose                    |
|--------------------|----------------------------|
| hive / hive_flutter | Local encrypted storage    |
| provider            | State management           |
| flutter_secure_storage | Key storage for Hive   |
| image_picker        | Camera and gallery images  |
| google_fonts        | Fonts                      |
| intl                | Date/time formatting      |
| uuid                | Note IDs                   |

## Code generation

- **Hive adapters**: `lib/models/note_item.dart` uses `@HiveType()` / `@HiveField()`. After changing the model, run:

  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- **App icons**: Edit `assets/app_icon.png` (1024×1024), then:

  ```bash
  dart run flutter_launcher_icons
  ```

## App identity (for forks)

If you fork and publish under a new name:

1. **Display name**: Update `NoteTaking` in:
   - `lib/main.dart` (`MaterialApp.title`)
   - `android/app/src/main/AndroidManifest.xml` (`android:label`)
   - `ios/Runner/Info.plist` (`CFBundleDisplayName`, `CFBundleName`)
   - `macos/Runner/Configs/AppInfo.xcconfig` (`PRODUCT_NAME`)
   - `web/index.html` (title, meta)
   - `web/manifest.json` (name, short_name)
   - `windows/runner/Runner.rc` (ProductName, FileDescription, etc.)
   - `linux/CMakeLists.txt` (`BINARY_NAME`)

2. **Bundle / package ID**: Change `com.notetaking.app` in:
   - `android/app/build.gradle.kts` (`namespace`, `applicationId`)
   - `android/app/src/main/kotlin/com/notetaking/app/MainActivity.kt` (package)
   - `ios/Runner.xcodeproj/project.pbxproj` (PRODUCT_BUNDLE_IDENTIFIER)
   - `macos/Runner/Configs/AppInfo.xcconfig` (PRODUCT_BUNDLE_IDENTIFIER)
   - `linux/CMakeLists.txt` (APPLICATION_ID)

3. **Pub package name**: In `pubspec.yaml`, set `name:` to your desired Dart package name (e.g. `my_note_app`). Use lowercase with underscores.

## Running tests

```bash
flutter test
```

## Building for store / distribution

- **Android**: Configure signing in `android/app/build.gradle.kts` (e.g. `key.properties`, `signingConfigs`). Use `flutter build appbundle` for Play Store.
- **iOS**: Open `ios/Runner.xcworkspace` in Xcode, set team and signing, then archive and upload.
- **Web**: `flutter build web`; deploy the `build/web` output to any static host.

## Troubleshooting

- **Hive “box not found”**: Ensure `main()` runs `Hive.initFlutter()`, registers adapters, and opens the box before any screen that reads notes.
- **Icons not updating**: Clean and regenerate: `flutter clean`, then `dart run flutter_launcher_icons` and rebuild.
- **Old package ID on device**: After changing `applicationId` or bundle ID, uninstall the app from the device/emulator and reinstall.
