# Supabase setup

This project uses Supabase for backend APIs, auth, storage, edge functions, and database workflows. The app reads runtime configuration from Dart defines, so each environment must provide the same required keys.

## Required env keys

- `FLAVOR`
- `APP_API_DOMAIN`
- `APP_API_FUNCTIONS_DOMAIN`
- `APP_API_KEY`

Example:

```json
{
  "FLAVOR": "development",
  "APP_API_DOMAIN": "https://your-project.supabase.co",
  "APP_API_FUNCTIONS_DOMAIN": "https://your-project.functions.supabase.co",
  "APP_API_KEY": "your-public-anon-key"
}
```

## What the source shows

The repo already contains:

- `supabase/config.toml` for local Supabase configuration.
- `supabase/migrations/` for SQL migrations.
- `supabase/functions/` for Edge Functions.
- `lib/shared/constants/env_constants.dart` and `lib/shared/constants/url_constants.dart` for runtime config consumption.
- `codemagic.yaml` that pins Flutter with FVM and generates env files in CI.

## Current Supabase usage in this repo

From the source, Supabase is used for:

- OTP signup and password reset flows.
- User existence checks.
- Transaction creation, update, duplication, and wallet balance logic.
- Exchange rate lookups.
- Notification / cron-style backend tasks.

## Functions found in the source

### Edge Functions

- `create_user`
- `cron_transactions_reminder`
- `otp_verify`
- `otp_verify_reset_password`
- `reset_user_password`
- `send_otp`
- `send_otp_reset_password`

### Database functions and migrations

Notable SQL migration files include transaction, exchange-rate, and auth-related functions such as:

- user existence checks
- exchange rate lookup RPCs
- transaction update/duplicate RPCs
- wallet balance trigger logic

## Suggested commit strategy for Supabase changes

When a Supabase function differs from the Flutter source and needs updates, keep changes isolated:

1. One function or one SQL concern per commit.
2. One migration file per logical change.
3. One PR can contain multiple commits, but each commit should be easy to review.
4. Update README or docs only when the public setup flow changes.

That keeps history readable when you later inspect function changes in GitHub.

## Migrations

Keep schema changes in `supabase/migrations/`.

Recommended workflow:

1. Add a new migration file.
2. Prefer additive changes over breaking changes.
3. Keep RPC names stable when the Flutter app already depends on them.
4. Update this doc when new env keys or function endpoints are added.

## Edge Functions

Functions currently live under `supabase/functions/` and each function has its own `index.ts` and Deno config.

Common function folders in this repo include:

- `send_otp`
- `otp_verify`
- `send_otp_reset_password`
- `otp_verify_reset_password`
- `create_user`
- `reset_user_password`
- `cron_transactions_reminder`

## Local run flow

Use the pinned Flutter version through FVM:

```bash
fvm install
fvm use 3.29.3
fvm flutter pub get
fvm flutter run --flavor development --dart-define-from-file=env/development.json
```

## Safety notes

- Never commit real Supabase secrets.
- Keep env JSON files local or inject them from CI.
- If your Supabase project URL or anon key changes, update both the env files and CI config.
