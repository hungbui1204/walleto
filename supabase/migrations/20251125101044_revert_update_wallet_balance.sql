-- Update wallet amount function depeding on action
create or replace function public.update_wallet_balance()
returns trigger as $$
declare
  delta numeric;
begin
  -- DELETE
  if tg_op = 'DELETE' then
    if old.type = 'income' then
      delta := -old.amount;
    else
      delta := old.amount;
    end if;

    update public.wallets
    set amount = amount + delta
    where id = old.wallet_id;

    return old;

  -- INSERT
  elsif tg_op = 'INSERT' then
    if new.type = 'income' then
      delta := new.amount;
    else
      delta := -new.amount;
    end if;

    update public.wallets
    set amount = amount + delta
    where id = new.wallet_id;

    return new;

  -- UPDATE
  elsif tg_op = 'UPDATE' then
    -- Subtract old transaction
    if old.type = 'income' then
      delta := -old.amount;
    else
      delta := old.amount;
    end if;

    update public.wallets
    set amount = amount + delta
    where id = old.wallet_id;

    -- Add new transaction
    if new.type = 'income' then
      delta := new.amount;
    else
      delta := -new.amount;
    end if;

    update public.wallets
    set amount = amount + delta
    where id = new.wallet_id;

    return new;
  end if;

  return null;
end;
$$ language plpgsql;

-- Drop and create trigger for updating wallet balance
drop trigger if exists trg_update_wallet_balance on public.transactions;

create trigger trg_update_wallet_balance
after insert or update or delete
on public.transactions
for each row
execute function public.update_wallet_balance();
