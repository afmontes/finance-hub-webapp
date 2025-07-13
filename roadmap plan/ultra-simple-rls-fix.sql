-- ULTRA-SIMPLE Row Level Security Fix for Finance Hub
-- Works with basic Supabase setup - just the teams table

-- 1. Create private schema if needed
CREATE SCHEMA IF NOT EXISTS private;

-- 2. Create basic users_on_team table (essential for team management)
CREATE TABLE IF NOT EXISTS users_on_team (
    user_id uuid NOT NULL,
    team_id uuid NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    role text DEFAULT 'owner',
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT users_on_team_pkey PRIMARY KEY(user_id, team_id, id)
);

-- Enable RLS on users_on_team
ALTER TABLE users_on_team ENABLE ROW LEVEL SECURITY;

-- 3. Simple function - just use users_on_team table
CREATE OR REPLACE FUNCTION private.get_teams_for_authenticated_user()
RETURNS TABLE(team_id uuid)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT DISTINCT uot.team_id 
  FROM users_on_team uot
  WHERE uot.user_id = auth.uid()
$$;

-- 4. Simple function to check if user can create teams
CREATE OR REPLACE FUNCTION private.can_user_create_team()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT 
    CASE 
      -- Allow if user has no teams yet (first team creation)
      WHEN NOT EXISTS (SELECT 1 FROM users_on_team WHERE user_id = auth.uid()) THEN true
      -- Allow if user is owner and has less than 3 teams
      WHEN (SELECT COUNT(*) FROM users_on_team WHERE user_id = auth.uid() AND role = 'owner') < 3 THEN true
      ELSE false
    END
$$;

-- 5. Drop ALL existing team policies (clean slate)
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON teams;
DROP POLICY IF EXISTS "Teams can be selected by a member of the team" ON teams;
DROP POLICY IF EXISTS "Teams can be updated by a member of the team" ON teams;
DROP POLICY IF EXISTS "Teams can be deleted by a member of the team" ON teams;
DROP POLICY IF EXISTS "Invited users can select team if they are invited." ON teams;
DROP POLICY IF EXISTS "secure_team_creation" ON teams;
DROP POLICY IF EXISTS "team_members_can_select" ON teams;
DROP POLICY IF EXISTS "team_owners_can_update" ON teams;
DROP POLICY IF EXISTS "team_owners_can_delete" ON teams;

-- 6. Create SIMPLE team policies

-- Allow authenticated users to create teams (with limits)
CREATE POLICY "allow_team_creation" ON teams
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() IS NOT NULL 
    AND 
    private.can_user_create_team()
  );

-- Allow users to see teams they're members of
CREATE POLICY "allow_team_select" ON teams
  FOR SELECT TO authenticated
  USING (
    id IN (SELECT team_id FROM private.get_teams_for_authenticated_user())
  );

-- Allow team owners to update teams
CREATE POLICY "allow_team_update" ON teams
  FOR UPDATE TO authenticated
  USING (
    id IN (
      SELECT team_id FROM users_on_team 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- Allow team owners to delete teams
CREATE POLICY "allow_team_delete" ON teams
  FOR DELETE TO authenticated
  USING (
    id IN (
      SELECT team_id FROM users_on_team 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- 7. Create policies for users_on_team table
DROP POLICY IF EXISTS "users_can_manage_team_membership" ON users_on_team;

-- Allow users to see team memberships for their teams
CREATE POLICY "allow_team_membership_select" ON users_on_team
  FOR SELECT TO authenticated
  USING (
    team_id IN (SELECT team_id FROM private.get_teams_for_authenticated_user())
  );

-- Allow inserting team membership (for team creation)
CREATE POLICY "allow_team_membership_insert" ON users_on_team
  FOR INSERT TO authenticated
  WITH CHECK (
    user_id = auth.uid() -- Users can add themselves to teams
    OR 
    team_id IN ( -- Or owners can add others
      SELECT team_id FROM users_on_team 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- Allow users to leave teams, owners to remove members
CREATE POLICY "allow_team_membership_delete" ON users_on_team
  FOR DELETE TO authenticated
  USING (
    user_id = auth.uid() -- Users can remove themselves
    OR 
    team_id IN ( -- Or owners can remove anyone
      SELECT team_id FROM users_on_team 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );