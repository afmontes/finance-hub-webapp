-- Fix Teams Table Schema
-- Add missing country_code column that tRPC team.create expects

-- Add the missing country_code column to teams table
ALTER TABLE public.teams 
ADD COLUMN IF NOT EXISTS country_code text;

-- Also check if we need any other missing columns that might be expected
-- Let's make sure we have all the columns the tRPC expects

-- Verify the teams table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'teams'
ORDER BY ordinal_position;