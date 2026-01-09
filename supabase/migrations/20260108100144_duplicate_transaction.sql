DROP FUNCTION IF EXISTS public.duplicate_transaction(BIGINT, TIMESTAMPTZ) CASCADE;

CREATE OR REPLACE FUNCTION public.duplicate_transaction(
  p_id BIGINT,
  p_new_created_at TIMESTAMPTZ DEFAULT NOW()
)
RETURNS JSON AS $$
DECLARE
  src_tx RECORD;
  new_tx RECORD;
BEGIN
  SELECT *
  INTO src_tx
  FROM public.transactions
  WHERE id = p_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction % not found', p_id;
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
    updated_at
  )
  VALUES (
    p_new_created_at,             
    src_tx.user_id,
    src_tx.wallet_id,
    src_tx.category_id,
    src_tx.note,
    src_tx.amount,
    src_tx.type,
    src_tx.currency_code,
    NOW()                         
  )
  RETURNING * INTO new_tx;

  RETURN row_to_json(new_tx);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.duplicate_transaction(BIGINT, TIMESTAMPTZ)
TO authenticated, service_role;
