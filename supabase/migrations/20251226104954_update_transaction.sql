
DROP FUNCTION IF EXISTS public.update_transaction(BIGINT, BIGINT, BPCHAR(3), BIGINT, TEXT, category_type) CASCADE;

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
  created_at TIMESTAMPTZ,
  user_id UUID,
  wallet_id BIGINT,
  category_id BIGINT,
  note TEXT,
  amount BIGINT,           
  type category_type,
  currency_code BPCHAR(3),
  updated_at TIMESTAMPTZ
) AS $$
DECLARE
  tx_record public.transactions%ROWTYPE;
BEGIN
  UPDATE public.transactions 
  SET
    amount        = COALESCE(p_amount, transactions.amount),
    currency_code = COALESCE(p_currency_code, transactions.currency_code),
    category_id   = COALESCE(p_category_id, transactions.category_id),
    note          = COALESCE(p_note, transactions.note),
    type          = COALESCE(p_type, transactions.type),
    updated_at    = NOW()
  WHERE transactions.id = p_id
  RETURNING * INTO tx_record;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transaction not found: %', p_id;
  END IF;

  RETURN QUERY SELECT tx_record.*;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.update_transaction(
  BIGINT, BIGINT, BPCHAR(3), BIGINT, TEXT, category_type
) TO authenticated, service_role;
