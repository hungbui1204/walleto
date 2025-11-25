-- Drop the old function first
DROP FUNCTION IF EXISTS get_exchange_rate(CHAR, CHAR) CASCADE;

-- Create the new function with json return type
CREATE FUNCTION get_exchange_rate(
  p_from_currency CHAR(3),
  p_to_currency CHAR(3)
)
RETURNS json AS $$
DECLARE
  result json;
BEGIN
  SELECT json_build_object(
    'id', er.id,
    'from_currency', er.from_currency,
    'to_currency', er.to_currency,
    'rate', er.rate,
    'source', er.source,
    'created_at', er.created_at,
    'is_active', er.is_active
  ) INTO result
  FROM exchange_rates er
  WHERE er.from_currency = p_from_currency 
    AND er.to_currency = p_to_currency 
    AND er.is_active = TRUE
  ORDER BY er.created_at DESC
  LIMIT 1;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_exchange_rate(CHAR, CHAR) TO authenticated;
