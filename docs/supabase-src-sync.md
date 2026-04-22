# Supabase source sync

This PR aligns Supabase functions and backend-related docs with the current Flutter source.

## Function mapping

- `send_otp` — Creates and emails a sign-up OTP after checking whether the email already exists.
- `otp_verify` — Verifies OTP for sign-up flow.
- `send_otp_reset_password` — Creates and emails an OTP for password reset flow.
- `otp_verify_reset_password` — Verifies OTP for password reset flow.
- `create_user` — Creates a user record / related auth bootstrap after signup.
- `reset_user_password` — Resets the user password after OTP verification.


## Change policy

When a Supabase function changes, keep the review path small:

- one function = one commit
- one migration = one commit
- keep the branch open for review only
- do not merge until the source and Supabase implementation match

## Notes

This branch is intended to compare Supabase source against Flutter usage and update the related implementation files as needed.
