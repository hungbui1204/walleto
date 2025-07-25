create or replace function public.get_monthly_summary()
returns setof json
language sql
security definer
as $$
  select json_build_object(
    'target_month', 'this_month',
    'total_income', coalesce(sum(case when t.type = 'income' then t.amount else 0 end), 0),
    'total_expense', coalesce(sum(case when t.type = 'expense' then t.amount else 0 end), 0)
  )
  from public.transactions t
  where t.user_id = auth.uid()
    and date_trunc('month', t.created_at) = date_trunc('month', now())

  union all

  select json_build_object(
    'target_month', 'last_month',
    'total_income', coalesce(sum(case when t.type = 'income' then t.amount else 0 end), 0),
    'total_expense', coalesce(sum(case when t.type = 'expense' then t.amount else 0 end), 0)
  )
  from public.transactions t
  where t.user_id = auth.uid()
    and date_trunc('month', t.created_at) = date_trunc('month', now() - interval '1 month');
$$;
