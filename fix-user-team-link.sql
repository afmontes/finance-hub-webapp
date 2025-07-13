-- Fix User Team Link
-- Update user.team_id to point to the created team

-- Update your user record to point to the team you just created
UPDATE public.users 
SET team_id = 'd865ac34-7e31-4b12-ad93-1d58af97e419'
WHERE id = '59c2d985-e917-43a6-854a-904d0dc55877';

-- Verify the update
SELECT 
    u.id,
    u.email,
    u.full_name,
    u.team_id,
    t.name as team_name
FROM public.users u
LEFT JOIN teams t ON t.id = u.team_id
WHERE u.id = '59c2d985-e917-43a6-854a-904d0dc55877';