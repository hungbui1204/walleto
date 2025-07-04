create or replace function public.get_user_transactions()
returns setof json
language sql
security definer
as $$
  select json_build_object(
    'id', t.id,
    'amount', t.amount,
    'note', t.note,
    'created_at', t.created_at,
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
  where t.user_id = auth.uid();
$$;
