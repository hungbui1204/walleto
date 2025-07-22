create or replace function public.get_daily_stats(month int, year int)
returns table (
  date date,
  total_income numeric,
  total_expense numeric
)
language sql
security definer
as $$
  select
    date(t.created_at) as date,
    sum(case when t.type = 'income' then t.amount else 0 end) as total_income,
    sum(case when t.type = 'expense' then t.amount else 0 end) as total_expense
  from public.transactions t
  where extract(month from t.created_at) = month
    and extract(year from t.created_at) = year
    and t.user_id = auth.uid()
  group by date(t.created_at)
  order by date(t.created_at)
$$;
