-- Fix for User Creation in API Database
-- This creates users in the API database when they sign up via Supabase Auth

-- 1. First, let's check if users table exists and has the right structure
-- The users table should match the auth.users structure

-- 2. Create or update the users table to match auth requirements
CREATE TABLE IF NOT EXISTS public.users (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email text,
    full_name text,
    avatar_url text,
    team_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    locale text DEFAULT 'en',
    week_starts_on_monday boolean DEFAULT false,
    timezone text,
    time_format numeric DEFAULT 24,
    date_format text
);

-- Enable RLS on users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for users table
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;

CREATE POLICY "Users can view own profile" ON users
    FOR SELECT TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE TO authenticated
    USING (auth.uid() = id);

-- 3. Create function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (
    id, 
    email, 
    full_name, 
    avatar_url,
    created_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.created_at
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Create trigger on auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Create the current authenticated user if they don't exist yet
-- This fixes the immediate issue for the current user
INSERT INTO public.users (
  id, 
  email, 
  full_name, 
  avatar_url,
  created_at
)
SELECT 
  auth.uid(),
  auth.email(),
  COALESCE(
    (auth.jwt() ->> 'user_metadata')::jsonb ->> 'full_name',
    (auth.jwt() ->> 'user_metadata')::jsonb ->> 'name'
  ),
  (auth.jwt() ->> 'user_metadata')::jsonb ->> 'avatar_url',
  now()
WHERE auth.uid() IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid());