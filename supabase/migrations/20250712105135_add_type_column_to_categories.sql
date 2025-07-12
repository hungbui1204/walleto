-- Create new enum
DO $$ BEGIN
  CREATE TYPE category_type AS ENUM ('expense', 'income');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 2. Add type column into categories table
ALTER TABLE categories
ADD COLUMN type category_type NOT NULL DEFAULT 'expense';
