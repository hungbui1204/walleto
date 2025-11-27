create or replace function public.get_recent_transactions(
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
    ($1 is null or t.wallet_id = $1)
  )
  order by t.created_at desc
  limit 5;
$$;
