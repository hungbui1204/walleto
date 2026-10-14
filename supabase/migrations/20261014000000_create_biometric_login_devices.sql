create table if not exists public.biometric_login_devices (
  user_id uuid not null references auth.users (id) on delete cascade,
  installation_id uuid not null,
  enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, installation_id)
);

alter table public.biometric_login_devices enable row level security;

revoke all on table public.biometric_login_devices from anon, authenticated;
grant select, insert, update, delete on table public.biometric_login_devices to authenticated;

drop policy if exists biometric_login_devices_select_own
  on public.biometric_login_devices;
create policy biometric_login_devices_select_own
  on public.biometric_login_devices
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists biometric_login_devices_insert_own
  on public.biometric_login_devices;
create policy biometric_login_devices_insert_own
  on public.biometric_login_devices
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists biometric_login_devices_update_own
  on public.biometric_login_devices;
create policy biometric_login_devices_update_own
  on public.biometric_login_devices
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists biometric_login_devices_delete_own
  on public.biometric_login_devices;
create policy biometric_login_devices_delete_own
  on public.biometric_login_devices
  for delete
  to authenticated
  using (auth.uid() = user_id);
