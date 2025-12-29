DROP FUNCTION IF EXISTS public.update_transaction(BIGINT, NUMERIC, BPCHAR(3), BIGINT, TEXT, category_type) CASCADE;
DROP FUNCTION IF EXISTS public.update_transaction(integer, numeric, character, integer, unknown, unknown) CASCADE;

CREATE OR REPLACE FUNCTION public.update_transaction(
  p_id BIGINT,
  p_amount NUMERIC DEFAULT NULL,
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
  amount DOUBLE PRECISION,
  type category_type,
  currency_code BPCHAR(3),
  updated_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  UPDATE public.transactions 
  SET
    amount = COALESCE(p_amount, transactions.amount),
    currency_code = COALESCE(p_currency_code, transactions.currency_code),
    category_id = COALESCE(p_category_id::BIGINT, transactions.category_id),
    note = COALESCE(p_note, transactions.note),
    type = COALESCE(p_type::category_type, transactions.type),
    updated_at = NOW()
  WHERE transactions.id = p_id
  RETURNING 
    transactions.id, transactions.created_at, transactions.user_id, 
    transactions.wallet_id, transactions.category_id, transactions.note,
    transactions.amount, transactions.type, transactions.currency_code,
    transactions.updated_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.update_transaction(
  BIGINT, NUMERIC, BPCHAR(3), BIGINT, TEXT, category_type
) TO authenticated, service_role;
