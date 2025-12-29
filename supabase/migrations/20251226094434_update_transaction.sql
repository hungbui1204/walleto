CREATE OR REPLACE FUNCTION public.update_transaction(
  p_id BIGINT,
  p_amount BIGINT DEFAULT NULL,
  p_currency_code BPCHAR(3) DEFAULT NULL,
  p_category_id BIGINT DEFAULT NULL,
  p_note TEXT DEFAULT NULL,
  p_type category_type DEFAULT NULL
)
RETURNS TABLE (
  id BIGINT,
  amount BIGINT,
  currency_code BPCHAR(3),
  category_id BIGINT,
  note TEXT,
  type category_type,
  wallet_id BIGINT,
  updated_at TIMESTAMPTZ
) AS $$
DECLARE
  old_tx public.transactions%ROWTYPE;
  new_tx public.transactions%ROWTYPE;
BEGIN
  -- Get existing transaction
  SELECT * INTO old_tx 
  FROM public.transactions 
  WHERE id = p_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found: %', p_id;
  END IF;

  -- Update transaction fields if new values are provided
  UPDATE public.transactions 
  SET
    amount        = COALESCE(p_amount, amount),
    currency_code = COALESCE(p_currency_code, currency_code),
    category_id   = COALESCE(p_category_id, category_id),
    note          = COALESCE(p_note, note),
    type          = COALESCE(p_type, type),
    updated_at    = NOW()
  WHERE id = p_id
  RETURNING * INTO new_tx;

  RETURN QUERY
  SELECT 
    new_tx.id,
    new_tx.amount,
    new_tx.currency_code,
    new_tx.category_id,
    new_tx.note,
    new_tx.type,
    new_tx.wallet_id,
    new_tx.updated_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.update_transaction(
  BIGINT, BIGINT, BPCHAR(3), BIGINT, TEXT, category_type
) TO authenticated, service_role;
