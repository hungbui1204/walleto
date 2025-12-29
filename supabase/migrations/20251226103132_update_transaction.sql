DROP FUNCTION IF EXISTS public.update_transaction(BIGINT, BIGINT, BPCHAR(3), BIGINT, TEXT, category_type);

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
  old_tx_record public.transactions%ROWTYPE;
  new_tx_record public.transactions%ROWTYPE;
BEGIN
  -- Lấy transaction cũ
  SELECT * INTO old_tx_record 
  FROM public.transactions 
  WHERE transactions.id = p_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found: %', p_id;
  END IF;

  -- Update transaction (trigger sẽ tự update wallet)
  UPDATE public.transactions 
  SET
    amount        = COALESCE(p_amount, transactions.amount),
    currency_code = COALESCE(p_currency_code, transactions.currency_code),
    category_id   = COALESCE(p_category_id, transactions.category_id),
    note          = COALESCE(p_note, transactions.note),
    type          = COALESCE(p_type, transactions.type),
    updated_at    = NOW()
  WHERE transactions.id = p_id
  RETURNING * INTO new_tx_record;

  -- Trả về transaction mới
  RETURN QUERY
  SELECT 
    new_tx_record.id,
    new_tx_record.amount,
    new_tx_record.currency_code,
    new_tx_record.category_id,
    new_tx_record.note,
    new_tx_record.type,
    new_tx_record.wallet_id,
    new_tx_record.updated_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Cấp quyền
GRANT EXECUTE ON FUNCTION public.update_transaction(
  BIGINT, BIGINT, BPCHAR(3), BIGINT, TEXT, category_type
) TO authenticated, service_role;
