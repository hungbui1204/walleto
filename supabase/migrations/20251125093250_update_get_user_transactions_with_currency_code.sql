create or replace function public.get_user_transactions(
  target_month int default null,
  target_year int default null,
  from_date date default null,
  to_date date default null,
  wallet_id int default null
)
returns setof json
language sql
security definer
as $$
  select json_build_object(
    'id', t.id,
    'amount', t.amount,
    'note', t.note,
    'created_at', t.created_at,
    'type', t.type,
    'currency_code', t.currency_code,
    'wallet', json_build_object(
      'id', w.id,
      'name', w.name,
      'icon_url', w.icon_url
    ),
    'category', json_build_object(
      'id', c.id,
      'name', c.name,
      'icon_url', c.icon_url
    )
  )
  from public.transactions t
  join public.wallets w on t.wallet_id = w.id
  join public.categories c on t.category_id = c.id
  where t.user_id = auth.uid()
  and (
    (target_month is null or extract(month from t.created_at) = target_month)
    and (target_year is null or extract(year from t.created_at) = target_year)
  )
  and (
    (from_date is null or t.created_at >= from_date)
    and (to_date is null or t.created_at <= to_date)
  )
  -- wallet_id filter
  and (
    ($5 is null or t.wallet_id = $5)
  );
$$;
