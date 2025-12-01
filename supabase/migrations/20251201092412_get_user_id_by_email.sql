-- Tạo function lấy user id theo email
CREATE OR REPLACE FUNCTION public.get_user_id_by_email(p_email TEXT)
RETURNS UUID AS $$
DECLARE
  user_id UUID;
BEGIN
  SELECT id INTO user_id 
  FROM auth.users 
  WHERE email = p_email 
  LIMIT 1;

  RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Cấp quyền EXECUTE cho role service_role (hoặc authenticated nếu cần)
GRANT EXECUTE ON FUNCTION public.get_user_id_by_email(TEXT) TO service_role;
