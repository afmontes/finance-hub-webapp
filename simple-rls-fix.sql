-- SIMPLE Row Level Security Fix for Finance Hub
-- This version works with the current database schema

-- 1. Create private schema if needed
CREATE SCHEMA IF NOT EXISTS private;

-- 2. First, let's check if users_on_team exists and create a simple version if not
CREATE TABLE IF NOT EXISTS users_on_team (
    user_id uuid NOT NULL,
    team_id uuid NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    role text DEFAULT 'owner',
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT users_on_team_pkey PRIMARY KEY(user_id, team_id, id)
);

-- Enable RLS on users_on_team if not already enabled
ALTER TABLE users_on_team ENABLE ROW LEVEL SECURITY;

-- 3. Create simple team membership function
CREATE OR REPLACE FUNCTION private.get_teams_for_authenticated_user()
RETURNS TABLE(team_id uuid)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  -- Check if users_on_team exists and has data, otherwise fall back to users.team_id
  SELECT DISTINCT 
    CASE 
      WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users_on_team')
      THEN (SELECT uot.team_id FROM users_on_team uot WHERE uot.user_id = auth.uid())
      ELSE (SELECT u.team_id FROM users u WHERE u.id = auth.uid())
    END as team_id
  WHERE team_id IS NOT NULL
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
      -- Always allow if user has no teams yet
      WHEN NOT EXISTS (
        SELECT 1 FROM users_on_team WHERE user_id = auth.uid()
        UNION ALL
        SELECT 1 FROM users WHERE id = auth.uid() AND team_id IS NOT NULL
      ) THEN true
      -- Allow owners to create up to 3 teams
      WHEN (
        SELECT COUNT(*) FROM users_on_team 
        WHERE user_id = auth.uid() AND role = 'owner'
      ) < 3 THEN true
      ELSE false
    END
$$;

-- 5. Drop existing policies
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON teams;
DROP POLICY IF EXISTS "Teams can be selected by a member of the team" ON teams;
DROP POLICY IF EXISTS "Teams can be updated by a member of the team" ON teams;
DROP POLICY IF EXISTS "Teams can be deleted by a member of the team" ON teams;
DROP POLICY IF EXISTS "Invited users can select team if they are invited." ON teams;

-- 6. Create SIMPLE but SECURE team policies

-- SECURE team creation - only authenticated users who can create teams
CREATE POLICY "secure_team_creation" ON teams
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() IS NOT NULL 
    AND 
    private.can_user_create_team()
  );

-- SECURE team selection - users can see teams they belong to
CREATE POLICY "team_members_can_select" ON teams
  FOR SELECT TO authenticated
  USING (
    -- Either they're in users_on_team or users.team_id points to this team
    id IN (SELECT team_id FROM private.get_teams_for_authenticated_user())
    OR 
    id = (SELECT team_id FROM users WHERE id = auth.uid())
  );

-- SECURE team updates - only owners can update
CREATE POLICY "team_owners_can_update" ON teams
  FOR UPDATE TO authenticated
  USING (
    id IN (
      SELECT team_id FROM users_on_team 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
    OR
    (id = (SELECT team_id FROM users WHERE id = auth.uid()) AND 
     NOT EXISTS (SELECT 1 FROM users_on_team WHERE team_id = id))
  );

-- SECURE team deletion - only owners can delete
CREATE POLICY "team_owners_can_delete" ON teams
  FOR DELETE TO authenticated
  USING (
    id IN (
      SELECT team_id FROM users_on_team 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
    OR
    (id = (SELECT team_id FROM users WHERE id = auth.uid()) AND 
     NOT EXISTS (SELECT 1 FROM users_on_team WHERE team_id = id))
  );

-- 7. Create basic policies for users_on_team table
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON users_on_team;
DROP POLICY IF EXISTS "Select for current user teams" ON users_on_team;
DROP POLICY IF EXISTS "Enable updates for users on team" ON users_on_team;
DROP POLICY IF EXISTS "Users on team can be deleted by a member of the team" ON users_on_team;

CREATE POLICY "users_can_manage_team_membership" ON users_on_team
  FOR ALL TO authenticated
  USING (
    user_id = auth.uid() -- Users can manage their own membership
    OR 
    team_id IN ( -- Or owners can manage team membership
      SELECT team_id FROM users_on_team 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- 8. Create basic audit logging (optional, simpler version)
CREATE TABLE IF NOT EXISTS team_audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id uuid,
  user_id uuid,
  action text,
  details jsonb,
  created_at timestamp with time zone DEFAULT now()
);

ALTER TABLE team_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_can_see_own_team_audit" ON team_audit_log
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR 
    team_id IN (SELECT team_id FROM private.get_teams_for_authenticated_user())
  );