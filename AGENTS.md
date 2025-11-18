# Repository Guidelines
This repository hosts the federated Flutter Secure Storage plugin. Each directory hosts a platform-specific package, so changes must keep the shared API stable across implementations.

## Project Structure & Module Organization
- `flutter_secure_storage/`: main cross-platform package consumed by apps; holds the public Dart API plus the showcase `example/`.
- `flutter_secure_storage_<platform>/`: platform implementations (linux, macos, windows, web, ohos) that export a plugin class under `lib/`.
- `flutter_secure_storage_platform_interface/`: shared method-channel contracts; update this first when adding API surface.
- Tests live beside packages in their respective `test/` folders, while integration flows sit in `flutter_secure_storage/example/test_driver/`.

## Build, Test, and Development Commands
- `flutter pub get` (run per package) installs dependencies after editing `pubspec.yaml`.
- `flutter analyze` in `flutter_secure_storage/` and `dart analyze` in pure-Dart packages enforce lint rules.
- `dart format .` (or `flutter format .`) keeps sources consistent before review.
- `cd flutter_secure_storage && flutter test` executes unit tests for the primary package; repeat for each platform package you touch.
- `cd flutter_secure_storage/example && flutter drive --target=test_driver/app.dart` runs the encrypted-storage integration suite.

## Coding Style & Naming Conventions
Linting is configured through `analysis_options.yaml`, which includes `package:lint/analysis_options_package.yaml`. Follow Dart’s two-space indentation, `lower_snake_case` for files and private members, and `PascalCase` for classes/options. Prefer const constructors, avoid `print`, and keep channel/method names descriptive (e.g., `FlutterSecureStorageAndroidPlugin`).

## Testing Guidelines
Add or update `*_test.dart` files next to the code they cover. Mock platform channels through the platform interface when possible and guard new behaviors with regression tests. Run `flutter test` (or `dart test`) on each package you modify and re-run the integration test when changing shared APIs or encryption behavior. Cover both success and failure paths that handle stored secrets.

## Commit & Pull Request Guidelines
Craft commits in the style already used (`docs: update README`, `fix(linux): handle keyring failure`). Keep them focused, reference related issues, and update the relevant `CHANGELOG.md`. Pull requests need a clear summary, testing evidence (commands run, logs, or screenshots), and platform callouts (e.g., “verified on macOS 13”). Link issues or feature requests so reviewers can trace intent, and confirm CI-facing commands pass locally.

## Security & Configuration Tips
Never check real credentials into `example/` or tests. Call `WidgetsFlutterBinding.ensureInitialized()` before interacting with secure storage, use `IOSOptions`/`AndroidOptions` that follow the README guidance, require `minSdkVersion 18` for Android, and serve the web implementation only over HTTPS or localhost.
