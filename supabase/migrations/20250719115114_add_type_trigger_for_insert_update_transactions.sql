-- Create function to auto set transactions.type
create or replace function public.set_transaction_type_from_category()
returns trigger as $$
begin
  select type into new.type
  from public.categories
  where id = new.category_id;

  return new;
end;
$$ language plpgsql security definer;

-- Create trigger that runs BEFORE INSERT or UPDATE ON category_id
drop trigger if exists trg_set_transaction_type on public.transactions;

create trigger trg_set_transaction_type
before insert or update of category_id
on public.transactions
for each row
execute function public.set_transaction_type_from_category();
