CREATE OR REPLACE FUNCTION get_exchange_rate(
  p_from_currency CHAR(3),
  p_to_currency CHAR(3)
)
RETURNS TABLE (
  id BIGINT,
  from_currency CHAR(3),
  to_currency CHAR(3),
  rate NUMERIC,
  source VARCHAR,
  created_at TIMESTAMPTZ,
  is_active BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    er.id,
    er.from_currency,
    er.to_currency,
    er.rate,
    er.source,
    er.created_at,
    er.is_active
  FROM exchange_rates er
  WHERE er.from_currency = p_from_currency 
    AND er.to_currency = p_to_currency 
    AND er.is_active = TRUE
  ORDER BY er.created_at DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;
