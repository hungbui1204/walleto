-- P0/P1: OTP purpose, RPC owner checks, RLS, grants, trigger restore, stats dates, cron secret header.

-- ---------------------------------------------------------------------------
-- 1) otp_codes: purpose, failed_attempts, created_at; wipe plaintext leftovers
-- ---------------------------------------------------------------------------
ALTER TABLE public.otp_codes
  ADD COLUMN IF NOT EXISTS purpose text NOT NULL DEFAULT 'signup',
  ADD COLUMN IF NOT EXISTS failed_attempts integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now();

ALTER TABLE public.otp_codes DROP CONSTRAINT IF EXISTS otp_codes_purpose_check;
ALTER TABLE public.otp_codes
  ADD CONSTRAINT otp_codes_purpose_check CHECK (purpose IN ('signup', 'reset'));

DELETE FROM public.otp_codes;

CREATE INDEX IF NOT EXISTS otp_codes_email_purpose_created_at_idx
  ON public.otp_codes (email, purpose, created_at DESC);

REVOKE ALL ON TABLE public.otp_codes FROM PUBLIC;
REVOKE ALL ON TABLE public.otp_codes FROM anon;
REVOKE ALL ON TABLE public.otp_codes FROM authenticated;
GRANT ALL ON TABLE public.otp_codes TO postgres, service_role;
GRANT USAGE, SELECT ON SEQUENCE public.otp_codes_id_seq TO postgres, service_role;

-- ---------------------------------------------------------------------------
-- 2) exchange_rates RLS + write revoke
-- ---------------------------------------------------------------------------
ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS exchange_rates_select_authenticated ON public.exchange_rates;
CREATE POLICY exchange_rates_select_authenticated
  ON public.exchange_rates
  FOR SELECT
  TO authenticated
  USING (true);

REVOKE ALL ON TABLE public.exchange_rates FROM PUBLIC;
REVOKE ALL ON TABLE public.exchange_rates FROM anon;
REVOKE ALL ON TABLE public.exchange_rates FROM authenticated;
GRANT SELECT ON TABLE public.exchange_rates TO authenticated;
GRANT ALL ON TABLE public.exchange_rates TO postgres, service_role;

-- ---------------------------------------------------------------------------
-- 3) IDOR: get_transaction_by_id / update_transaction (+ sibling owner checks)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_transaction_by_id(p_id bigint)
 RETURNS TABLE(id bigint, created_at timestamp with time zone, user_id uuid, wallet_id bigint, category_id bigint, note text, amount double precision, type category_type, currency_code character, updated_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = public
AS $function$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.transactions t
    WHERE t.id = p_id
      AND t.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Transaction not found';
  END IF;

  RETURN QUERY
  SELECT
    t.id, t.created_at, t.user_id, t.wallet_id, t.category_id,
    t.note, t.amount, t.type, t.currency_code, t.updated_at
  FROM public.transactions t
  WHERE t.id = p_id
    AND t.user_id = auth.uid();
END;
$function$;

CREATE OR REPLACE FUNCTION public.update_transaction(
  p_id bigint,
  p_amount numeric DEFAULT NULL::numeric,
  p_currency_code character DEFAULT NULL::bpchar,
  p_category_id bigint DEFAULT NULL::bigint,
  p_note text DEFAULT NULL::text,
  p_transaction_date timestamp with time zone DEFAULT NULL::timestamp with time zone,
  p_wallet_id bigint DEFAULT NULL::bigint
)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = public
AS $function$
DECLARE
  updated_tx RECORD;
  new_type category_type;
BEGIN
  IF p_category_id IS NOT NULL THEN
    IF NOT EXISTS (SELECT 1 FROM public.categories WHERE id = p_category_id) THEN
      RAISE EXCEPTION 'Category % does not exist', p_category_id;
    END IF;

    SELECT c.type INTO new_type
    FROM public.categories c
    WHERE c.id = p_category_id;
  END IF;

  IF p_wallet_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.wallets w
      WHERE w.id = p_wallet_id AND w.user_id = auth.uid()
    ) THEN
      RAISE EXCEPTION 'Wallet not found';
    END IF;
  END IF;

  UPDATE public.transactions
  SET
    amount           = COALESCE(p_amount, amount),
    currency_code    = COALESCE(p_currency_code, currency_code),
    category_id      = COALESCE(p_category_id, category_id),
    note             = COALESCE(p_note, note),
    type             = COALESCE(new_type, type, 'expense'::category_type),
    transaction_date = COALESCE(p_transaction_date, transaction_date),
    wallet_id        = COALESCE(p_wallet_id, wallet_id),
    updated_at       = NOW()
  WHERE id = p_id
    AND user_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found';
  END IF;

  SELECT * INTO updated_tx
  FROM public.transactions
  WHERE id = p_id
    AND user_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found';
  END IF;

  RETURN row_to_json(updated_tx);
END;
$function$;

CREATE OR REPLACE FUNCTION public.duplicate_transaction(
  p_id bigint,
  p_new_transaction_date timestamp with time zone DEFAULT now()
)
 RETURNS json
 LANGUAGE plpgsql
 SET search_path = public
AS $function$
DECLARE
  src_tx RECORD;
  new_tx RECORD;
BEGIN
  SELECT *
  INTO src_tx
  FROM public.transactions
  WHERE id = p_id
    AND user_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found';
  END IF;

  IF src_tx.wallet_id IS NULL THEN
    RAISE EXCEPTION 'Source transaction % has null wallet_id', p_id;
  END IF;

  IF src_tx.user_id IS NULL THEN
    RAISE EXCEPTION 'Source transaction % has null user_id', p_id;
  END IF;

  IF src_tx.category_id IS NULL THEN
    RAISE EXCEPTION 'Source transaction % has null category_id', p_id;
  END IF;

  INSERT INTO public.transactions (
    created_at,
    user_id,
    wallet_id,
    category_id,
    note,
    amount,
    type,
    currency_code,
    transaction_date,
    updated_at
  )
  VALUES (
    NOW(),
    auth.uid(),
    src_tx.wallet_id,
    src_tx.category_id,
    src_tx.note,
    src_tx.amount,
    src_tx.type,
    src_tx.currency_code,
    p_new_transaction_date,
    NOW()
  )
  RETURNING * INTO new_tx;

  RETURN row_to_json(new_tx);
END;
$function$;

CREATE OR REPLACE FUNCTION public.update_wallet(
  p_wallet_id bigint,
  p_name text DEFAULT NULL::text,
  p_icon_url text DEFAULT NULL::text,
  p_new_amount double precision DEFAULT NULL::double precision
)
 RETURNS json
 LANGUAGE plpgsql
 SET search_path = public
AS $function$
DECLARE
  wallet_rec RECORD;
  old_amount DOUBLE PRECISION;
  diff DOUBLE PRECISION;
  adj_tx RECORD;
  adjustment_category_id BIGINT := 999;
BEGIN
  SELECT * INTO wallet_rec
  FROM public.wallets
  WHERE id = p_wallet_id
    AND user_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Wallet not found';
  END IF;

  UPDATE public.wallets
  SET
    name = COALESCE(p_name, name),
    icon_url = COALESCE(p_icon_url, icon_url),
    updated_at = NOW()
  WHERE id = p_wallet_id
    AND user_id = auth.uid();

  IF p_new_amount IS NOT NULL THEN
    old_amount := COALESCE(wallet_rec.amount, 0);
    diff := old_amount - p_new_amount;

    IF ABS(diff) > 0.01 THEN
      INSERT INTO public.transactions (
        created_at,
        user_id,
        wallet_id,
        category_id,
        note,
        amount,
        type,
        currency_code,
        transaction_date,
        updated_at
      )
      VALUES (
        NOW(),
        auth.uid(),
        p_wallet_id,
        adjustment_category_id,
        CONCAT('Wallet balance adjustment (Old: ', old_amount, ', New: ', p_new_amount, ')'),
        ABS(diff),
        CASE WHEN diff < 0 THEN 'income'::category_type ELSE 'expense'::category_type END,
        wallet_rec.currency_code,
        NOW(),
        NOW()
      )
      RETURNING * INTO adj_tx;
    END IF;
  END IF;

  SELECT * INTO wallet_rec
  FROM public.wallets
  WHERE id = p_wallet_id
    AND user_id = auth.uid();

  RETURN json_build_object(
    'wallet', row_to_json(wallet_rec),
    'adjustment_created', (p_new_amount IS NOT NULL AND ABS(diff) > 0.01),
    'adjustment_transaction', COALESCE(row_to_json(adj_tx), NULL::json),
    'old_amount', COALESCE(old_amount, wallet_rec.amount),
    'new_amount', p_new_amount,
    'diff', diff
  );
END;
$function$;

-- ---------------------------------------------------------------------------
-- 4) Stats: filter by transaction_date
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_user_transactions(
  target_month integer DEFAULT NULL::integer,
  target_year integer DEFAULT NULL::integer,
  from_date date DEFAULT NULL::date,
  to_date date DEFAULT NULL::date,
  wallet_id integer DEFAULT NULL::integer
)
 RETURNS SETOF json
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path = public
AS $function$
select json_build_object(
    'id', t.id,
    'amount', t.amount,
    'note', t.note,
    'created_at', t.created_at,
    'type', t.type,
    'currency_code', t.currency_code,
    'transaction_date', t.transaction_date,
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
    (target_month is null or extract(month from t.transaction_date) = target_month)
    and (target_year is null or extract(year from t.transaction_date) = target_year)
  )
  and (
    (from_date is null or t.transaction_date::date >= from_date)
    and (to_date is null or t.transaction_date::date <= to_date)
  )
  and (
    ($5 is null or t.wallet_id = $5)
  );
$function$;

CREATE OR REPLACE FUNCTION public.get_daily_stats(month integer, year integer)
 RETURNS TABLE(date date, total_income numeric, total_expense numeric)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path = public
AS $function$
  select
    date(t.transaction_date) as date,
    sum(case when t.type = 'income' then t.amount else 0 end) as total_income,
    sum(case when t.type = 'expense' then t.amount else 0 end) as total_expense
  from public.transactions t
  where extract(month from t.transaction_date) = month
    and extract(year from t.transaction_date) = year
    and t.user_id = auth.uid()
  group by date(t.transaction_date)
  order by date(t.transaction_date)
$function$;

CREATE OR REPLACE FUNCTION public.get_monthly_summary(base_currency character)
 RETURNS SETOF jsonb
 LANGUAGE sql
 STABLE
 SET search_path = public
AS $function$
WITH periods AS (
  SELECT
    date_trunc('month', now())::date AS month_date, 'this_month'::text AS label
  UNION ALL
  SELECT
    date_trunc('month', now() - interval '1 month')::date, 'last_month'::text
),
converted AS (
  SELECT
    p.label, p.month_date,
    COALESCE(er.rate, 1::numeric) AS conversion_rate,
    SUM(CASE WHEN t.type = 'income' THEN t.amount * COALESCE(er.rate, 1::numeric) ELSE 0 END) AS total_income,
    SUM(CASE WHEN t.type = 'expense' THEN t.amount * COALESCE(er.rate, 1::numeric) ELSE 0 END) AS total_expense
  FROM periods p
  LEFT JOIN public.transactions t
    ON date_trunc('month', t.transaction_date)::date = p.month_date
    AND t.user_id = auth.uid()
  LEFT JOIN public.exchange_rates er
    ON er.from_currency = t.currency_code
    AND er.to_currency = base_currency
    AND date_trunc('month', er.created_at)::date = p.month_date
    AND er.is_active = true
  GROUP BY p.label, p.month_date, er.rate
)
SELECT json_build_object(
  'target_month', label,
  'base_currency', base_currency,
  'total_income', COALESCE(total_income, 0),
  'total_expense', COALESCE(total_expense, 0),
  'net_change', COALESCE(total_income - total_expense, 0)
)
FROM converted
ORDER BY month_date DESC;
$function$;

CREATE OR REPLACE FUNCTION public.get_top_wallet_stats(
  target_month integer,
  target_year integer,
  target_type category_type
)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path = public
AS $function$
WITH category_totals AS (
  SELECT
    w.id AS wallet_id,
    w.name AS wallet_name,
    COALESCE(w.currency_code, t.currency_code) AS currency_code,
    parent.id AS parent_category_id,
    parent.name AS parent_category_name,
    parent.icon_url AS parent_category_icon_url,
    SUM(t.amount) AS total_amount
  FROM public.transactions t
  JOIN public.categories c ON t.category_id = c.id
  JOIN public.categories parent ON
         (c.parent_id IS NOT NULL AND parent.id = c.parent_id)
      OR (c.parent_id IS NULL     AND parent.id = c.id)
  JOIN public.wallets w ON w.id = t.wallet_id
  WHERE
    t.user_id = auth.uid()
    AND t.type = target_type
    AND EXTRACT(MONTH FROM t.transaction_date) = target_month
    AND EXTRACT(YEAR  FROM t.transaction_date) = target_year
  GROUP BY
    w.id, w.name, w.currency_code, t.currency_code,
    parent.id, parent.name, parent.icon_url
),
wallet_totals AS (
  SELECT
    wallet_id,
    wallet_name,
    currency_code,
    SUM(total_amount) AS total_amount
  FROM category_totals
  GROUP BY wallet_id, wallet_name, currency_code
)
SELECT jsonb_build_object(
  'wallet_id', wt.wallet_id,
  'wallet_name', wt.wallet_name,
  'currency_code', wt.currency_code,
  'total_amount', wt.total_amount,
  'categories', COALESCE(
    (SELECT jsonb_agg(
      jsonb_build_object(
        'category_id', ct.parent_category_id,
        'category_name', ct.parent_category_name,
        'category_icon_url', ct.parent_category_icon_url,
        'total_amount', ct.total_amount
      ) ORDER BY ct.total_amount DESC
    )
    FROM category_totals ct
    WHERE ct.wallet_id = wt.wallet_id),
    '[]'::jsonb
  )
)
FROM wallet_totals wt
ORDER BY wt.total_amount DESC
LIMIT 1;
$function$;

-- ---------------------------------------------------------------------------
-- 5) Move trigger functions off PostgREST (private schema) and restore type trigger
-- ---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;
REVOKE ALL ON SCHEMA private FROM anon;
GRANT USAGE ON SCHEMA private TO postgres, authenticated, service_role;

DROP TRIGGER IF EXISTS trg_update_wallet_balance ON public.transactions;
DROP TRIGGER IF EXISTS trg_set_base_currency ON public.wallets;
DROP TRIGGER IF EXISTS trg_set_transaction_type ON public.transactions;

CREATE OR REPLACE FUNCTION private.update_wallet_balance()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path = public
AS $function$
declare
  delta numeric;
begin
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

  elsif tg_op = 'UPDATE' then
    if old.type = 'income' then
      delta := -old.amount;
    else
      delta := old.amount;
    end if;

    update public.wallets
    set amount = amount + delta
    where id = old.wallet_id;

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
$function$;

CREATE OR REPLACE FUNCTION private.set_user_base_currency()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path = public
AS $function$
DECLARE
  wallet_count INTEGER;
BEGIN
  IF NEW.user_id IS NOT NULL AND (SELECT base_currency FROM public.profiles WHERE id = NEW.user_id) IS NULL THEN
    SELECT COUNT(*) INTO wallet_count
    FROM public.wallets w
    WHERE w.user_id = NEW.user_id;

    IF wallet_count = 0 THEN
      UPDATE public.profiles
      SET base_currency = NEW.currency_code
      WHERE id = NEW.user_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION private.set_transaction_type_from_category()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = public
AS $function$
DECLARE
  category_type category_type;
BEGIN
  IF new.category_id IS NOT NULL THEN
    SELECT c.type INTO category_type
    FROM public.categories c
    WHERE c.id = new.category_id;

    IF category_type IS NOT NULL THEN
      new.type := category_type;
    ELSE
      new.type := COALESCE(new.type, 'expense'::category_type);
    END IF;
  ELSE
    IF new.type IS NULL THEN
      new.type := 'expense'::category_type;
    END IF;
  END IF;

  RETURN new;
END;
$function$;

DROP FUNCTION IF EXISTS public.update_wallet_balance();
DROP FUNCTION IF EXISTS public.set_user_base_currency();
DROP FUNCTION IF EXISTS public.set_transaction_type_from_category();

CREATE TRIGGER trg_update_wallet_balance
  AFTER INSERT OR DELETE OR UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION private.update_wallet_balance();

CREATE TRIGGER trg_set_base_currency
  AFTER INSERT ON public.wallets
  FOR EACH ROW
  EXECUTE FUNCTION private.set_user_base_currency();

CREATE TRIGGER trg_set_transaction_type
  BEFORE INSERT OR UPDATE OF category_id ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION private.set_transaction_type_from_category();

REVOKE ALL ON FUNCTION private.update_wallet_balance() FROM PUBLIC;
REVOKE ALL ON FUNCTION private.update_wallet_balance() FROM anon;
GRANT EXECUTE ON FUNCTION private.update_wallet_balance() TO postgres, authenticated, service_role;

REVOKE ALL ON FUNCTION private.set_user_base_currency() FROM PUBLIC;
REVOKE ALL ON FUNCTION private.set_user_base_currency() FROM anon;
GRANT EXECUTE ON FUNCTION private.set_user_base_currency() TO postgres, authenticated, service_role;

REVOKE ALL ON FUNCTION private.set_transaction_type_from_category() FROM PUBLIC;
REVOKE ALL ON FUNCTION private.set_transaction_type_from_category() FROM anon;
GRANT EXECUTE ON FUNCTION private.set_transaction_type_from_category() TO postgres, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6) search_path + REVOKE/GRANT for public RPCs
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT n.nspname AS schema, p.proname, pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname IN ('public', 'private')
      AND p.prokind = 'f'
  LOOP
    EXECUTE format('ALTER FUNCTION %I.%I(%s) SET search_path = public', r.schema, r.proname, r.args);
    EXECUTE format('REVOKE ALL ON FUNCTION %I.%I(%s) FROM PUBLIC', r.schema, r.proname, r.args);
    EXECUTE format('REVOKE ALL ON FUNCTION %I.%I(%s) FROM anon', r.schema, r.proname, r.args);
    EXECUTE format('REVOKE ALL ON FUNCTION %I.%I(%s) FROM authenticated', r.schema, r.proname, r.args);
  END LOOP;
END $$;

DO $$
DECLARE
  r record;
  service_only constant text[] := ARRAY['check_user_exists', 'get_user_id_by_email', 'verify_cron_secret'];
BEGIN
  FOR r IN
    SELECT n.nspname AS schema, p.proname, pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prokind = 'f'
  LOOP
    IF r.proname = ANY (service_only) THEN
      EXECUTE format(
        'GRANT EXECUTE ON FUNCTION %I.%I(%s) TO service_role',
        r.schema, r.proname, r.args
      );
    ELSE
      EXECUTE format(
        'GRANT EXECUTE ON FUNCTION %I.%I(%s) TO authenticated, service_role',
        r.schema, r.proname, r.args
      );
    END IF;
  END LOOP;

  FOR r IN
    SELECT n.nspname AS schema, p.proname, pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'private'
      AND p.prokind = 'f'
  LOOP
    EXECUTE format(
      'GRANT EXECUTE ON FUNCTION %I.%I(%s) TO postgres, authenticated, service_role',
      r.schema, r.proname, r.args
    );
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- 7) cron job: x-cron-secret from vault (create secret if missing)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.verify_cron_secret(p_secret text)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path = public
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM vault.decrypted_secrets s
    WHERE s.name = 'cron_secret'
      AND p_secret IS NOT NULL
      AND p_secret <> ''
      AND s.decrypted_secret = p_secret
  );
$function$;

REVOKE ALL ON FUNCTION public.verify_cron_secret(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.verify_cron_secret(text) FROM anon;
REVOKE ALL ON FUNCTION public.verify_cron_secret(text) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.verify_cron_secret(text) TO service_role;

DO $$
DECLARE
  jid bigint;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM vault.secrets WHERE name = 'cron_secret') THEN
    PERFORM vault.create_secret(
      encode(gen_random_bytes(32), 'hex'),
      'cron_secret',
      'Shared secret for cron_transactions_reminder'
    );
  END IF;

  SELECT jobid INTO jid
  FROM cron.job
  WHERE command ILIKE '%cron_transactions_reminder%'
     OR jobname = 'invoke-function-every-hour'
  LIMIT 1;

  IF jid IS NOT NULL THEN
    PERFORM cron.alter_job(
      jid,
      '0 * * * *',
      $cmd$
    select
      net.http_post(
          url:= (select decrypted_secret from vault.decrypted_secrets where name = 'project_url') || '/functions/v1/cron_transactions_reminder',
          headers:=jsonb_build_object(
            'Content-type', 'application/json',
            'x-cron-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret')
          ),
          body:=concat('{"time": "', now(), '"}')::jsonb
      ) as request_id;
      $cmd$
    );
  END IF;
END $$;

NOTIFY pgrst, 'reload schema';
