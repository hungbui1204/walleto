create or replace function public.get_parent_category_stats(
  target_month int,
  target_year int,
  target_type category_type  -- enum: 'income' | 'expense'
)
returns setof json
language sql
security definer
as $$
  select json_build_object(
    'category_id', parent.id,
    'category_name', parent.name,
    'category_icon_url', parent.icon_url,
    'total_amount', sum(t.amount)
  )
  from public.transactions t
  join public.categories c on t.category_id = c.id
  join public.categories parent on 
    (c.parent_id is not null and parent.id = c.parent_id)
    or (c.parent_id is null and parent.id = c.id)
  where t.user_id = auth.uid()
    and t.type = target_type
    and extract(month from t.created_at) = target_month
    and extract(year from t.created_at) = target_year
  group by parent.id, parent.name, parent.icon_url
  order by sum(t.amount) desc;
$$;
