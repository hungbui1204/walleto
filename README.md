# walleto

A Flutter money manager app with flavors, environment-driven config, and CI support via Codemagic.

## Project requirements

- Flutter **3.29.3** managed with **FVM**.
- Dart SDK **^3.7.2**.
- Android Studio / Android SDK for Android development.
- Xcode and CocoaPods for iOS development.
- Java 17 for Android builds.

## Repository setup

### 1) Clone the repo

```bash
git clone https://github.com/hungbui1204/walleto.git
cd walleto
git checkout develop
```

### 2) Install and use the pinned Flutter version

```bash
fvm install
fvm use 3.29.3
```

If you want to run commands through the pinned SDK, use `fvm flutter` instead of `flutter`.

### 3) Install dependencies

```bash
fvm flutter pub get
```

### 4) Create environment files

The app expects environment values through `--dart-define-from-file` and the following keys:

- `FLAVOR`
- `APP_API_DOMAIN`
- `APP_API_FUNCTIONS_DOMAIN`
- `APP_API_KEY`

Create these files under `env/`:

- `env/development.json`
- `env/staging.json`
- `env/production.json`

Example:

```json
{
  "FLAVOR": "development",
  "APP_API_DOMAIN": "https://your-project.supabase.co",
  "APP_API_FUNCTIONS_DOMAIN": "https://your-project.functions.supabase.co",
  "APP_API_KEY": "your-anon-or-public-api-key"
}
```

> Do not commit real secrets to the repository.

## Run the app

### Development

```bash
fvm flutter run   --flavor development   --dart-define-from-file=env/development.json
```

### Staging

```bash
fvm flutter run   --flavor staging   --dart-define-from-file=env/staging.json
```

### Production

```bash
fvm flutter run   --flavor production   --dart-define-from-file=env/production.json
```

## IDE setup

### Visual Studio Code

The repository already includes launch configurations for:

- `Debug Develop`
- `Debug Production`
- `Profile Develop`
- `Profile Production`
- `Release Develop`
- `Release Production`

These configs use `--flavor` and `--dart-define-from-file` so you can run the project without typing the full command every time.

### Android Studio

The project includes a helper under `tools/gen_env` that reads the flavor env files and generates IDE run configuration support. If you change env files or flavor settings, regenerate the config.

## iOS setup

The iOS target uses deployment target **13.0**.

```bash
cd ios
pod install
cd ..
```

Then run:

```bash
fvm flutter run --flavor development --dart-define-from-file=env/development.json
```

## Android setup

Android is configured with:

- `compileSdk 35`
- `minSdk 24`
- Java 17
- Google Services plugin support

If you change native config, run a clean build:

```bash
fvm flutter clean
fvm flutter pub get
```

## Environment flow

The app reads runtime config from Dart defines. Internally, `EnvConstants` expects:

- `FLAVOR` for flavor selection
- `APP_API_DOMAIN` for API base URL
- `APP_API_FUNCTIONS_DOMAIN` for Supabase functions URL
- `APP_API_KEY` for the public API key

The `tools/gen_env` utility also supports these flavors:

- development
- staging
- production

## CI/CD notes

Codemagic is configured to:

- install FVM
- pin Flutter to **3.29.3**
- generate env config files from CI variables
- run the Flutter build with the pinned SDK

## Useful commands

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter clean
```

## Troubleshooting

- If Flutter commands behave inconsistently, confirm you are using `fvm flutter`.
- If iOS pods fail, rerun `pod install` inside `ios/`.
- If flavor launch fails, verify the correct env JSON file exists in `env/`.
- If build config changes do not appear in Android Studio, regenerate the run configs using the helper in `tools/gen_env`.
