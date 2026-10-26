# NetraOne Mobile v0.1.1 — Flutter analyzer hotfix

Fixes 21 reported analyzer findings from v0.1.0: MenuScreen syntax, unused intl import, DropdownButtonFormField initialValue, flutter_test dependency and default MyApp test.

## Applying to existing Flutter project
1. Back up project.
2. Copy `lib/main.dart` and `pubspec.yaml` from this archive into your Flutter project.
3. Replace `test/widget_test.dart` with archive version.
4. Run `flutter pub get`, `flutter analyze`, then `flutter test`.
5. Report any remaining analyzer or runtime errors with output.

`backend_patch/` is unchanged from v0.1.0. Do not reapply it if already installed. No API changes in this hotfix.

Flutter SDK is unavailable here, so this is a source correction, not a claimed compile-verified build.
