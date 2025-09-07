create or replace function public.check_user_exists(target_email text)
returns boolean
language sql
security definer
as $$
  select exists(
    select 1 from auth.users u 
    where lower(u.email) = lower(target_email)
  );
$$;