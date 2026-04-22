# Supabase setup

This project uses Supabase as the backend layer for API, auth, storage, and Edge Functions. The Flutter app reads its runtime config from `--dart-define-from-file` and expects the following keys:

- `FLAVOR`
- `APP_API_DOMAIN`
- `APP_API_FUNCTIONS_DOMAIN`
- `APP_API_KEY`

## What to prepare locally

Create the `env/` folder at the repo root and add:

- `env/development.json`
- `env/staging.json`
- `env/production.json`

Example:

```json
{
  "FLAVOR": "development",
  "APP_API_DOMAIN": "https://your-project.supabase.co",
  "APP_API_FUNCTIONS_DOMAIN": "https://your-project.functions.supabase.co",
  "APP_API_KEY": "your-public-anon-key"
}
```

## Run with the correct flavor

Use the pinned Flutter SDK through FVM:

```bash
fvm flutter run --flavor development --dart-define-from-file=env/development.json
fvm flutter run --flavor staging --dart-define-from-file=env/staging.json
fvm flutter run --flavor production --dart-define-from-file=env/production.json
```

## Project structure

The repository already includes a `supabase/` folder with:

- `config.toml` for Supabase local configuration.
- `migrations/` for SQL migrations.
- `functions/` for Edge Functions.

## Supabase side features in this repo

From the current source layout, Supabase is used for:

- authentication flows,
- OTP and password reset functions,
- transaction and wallet data migrations,
- exchange rate support,
- helper functions for user lookup and other database operations.

## Working with migrations

When you add or change database schema:

1. Add a new SQL migration under `supabase/migrations/`.
2. Keep function names stable when the Flutter app already depends on them.
3. Prefer additive changes over breaking changes when possible.
4. Update the client docs if a new env variable or function endpoint is introduced.

## Working with Edge Functions

Edge Functions live under `supabase/functions/`. Common function folders in this repo include:

- `send_otp`
- `otp_verify`
- `send_otp_reset_password`
- `otp_verify_reset_password`
- `create_user`
- `reset_user_password`
- `cron_transactions_reminder`

Each function has its own `index.ts` entry file and local Deno config.

## How the Flutter app consumes Supabase config

The app reads values from Dart defines and builds request URLs from them. In practice:

- `APP_API_DOMAIN` becomes the base URL for auth, rest, and storage requests.
- `APP_API_FUNCTIONS_DOMAIN` becomes the base URL for Edge Functions.
- `APP_API_KEY` is used as the public API key.

## CI/CD note

`codemagic.yaml` installs FVM, pins Flutter to `3.29.3`, and generates env files from CI variables before build.

## Secrets and safety

- Never commit real keys to the repo.
- Keep `env/*.json` local or inject them from CI.
- If a value changes, update both the docs and the CI config.
