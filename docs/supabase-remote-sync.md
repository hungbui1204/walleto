# Supabase remote sync

Project: `xfcsqktcewhwykqrpbor`

## Remote project
- Name: `Walleto`
- Region: `ap-southeast-1`
- Status: `ACTIVE_HEALTHY`
- DB version: `17.4.1.043`

## Local Supabase functions in repo
- `create_user`
- `cron_transactions_reminder`
- `otp_verify`
- `otp_verify_reset_password`
- `reset_user_password`
- `send_otp`
- `send_otp_reset_password`

## Remote function API probe
- `/functions`: HTTP 200
- `/edge-functions`: HTTP 404

## Plan
This PR is the sync workspace for comparing remote Supabase state against GitHub source. Each function update should be committed separately.
