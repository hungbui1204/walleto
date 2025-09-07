create or replace function auth.check_user_exists(target_email text)
returns boolean
language sql
security definer
as $$
  select exists(
    select 1 from auth.users u where u.email = target_email
  );
$$;
