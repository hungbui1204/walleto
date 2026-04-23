# Supabase function content check

## What the API exposes

Remote Supabase function metadata is available, including: name, slug, version, status, verify_jwt, entrypoint_path, import_map_path, and timestamps.

## What could be compared now

- `create_user`: local `index.ts` exists in GitHub source. Remote metadata reports version `9` and status `ACTIVE`.
- `cron_transactions_reminder`: local `index.ts` exists in GitHub source. Remote metadata reports version `19` and status `ACTIVE`.
- `otp_verify`: local `index.ts` exists in GitHub source. Remote metadata reports version `9` and status `ACTIVE`.
- `otp_verify_reset_password`: local `index.ts` exists in GitHub source. Remote metadata reports version `1` and status `ACTIVE`.
- `reset_user_password`: local `index.ts` exists in GitHub source. Remote metadata reports version `4` and status `ACTIVE`.
- `send_otp`: local `index.ts` exists in GitHub source. Remote metadata reports version `13` and status `ACTIVE`.
- `send_otp_reset_password`: local `index.ts` exists in GitHub source. Remote metadata reports version `1` and status `ACTIVE`.

## Limitation

The currently available Management API response does not expose the deployed source body for each Edge Function, so exact line-by-line content comparison cannot be completed from this API response alone.

## Result

Function names match between remote Supabase and GitHub repo, and remote function metadata is present, but source-body equality still needs either a deploy artifact/source fetch or a CLI-based pull from the remote project.
