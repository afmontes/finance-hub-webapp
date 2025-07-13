-- Manual User Creation Fix
-- This manually creates the user record for the current authenticated user

-- Get the current user's details from the JWT token and create their record
DO $$
DECLARE
    current_user_id uuid;
    current_email text;
    current_name text;
    current_avatar text;
BEGIN
    -- Try to get current user info from auth context
    -- If this doesn't work, we'll insert manually with known details
    
    -- Insert the specific user we know exists (from the JWT token in the network request)
    INSERT INTO public.users (
        id, 
        email, 
        full_name, 
        avatar_url,
        created_at
    )
    VALUES (
        '59c2d985-e917-43a6-854a-904d0dc55877'::uuid,  -- User ID from JWT
        'afmontesg@icloud.com',                          -- Email from JWT
        'Andrés',                                        -- Name from JWT
        'https://avatars.githubusercontent.com/u/132019298?v=4',  -- Avatar from JWT
        now()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        avatar_url = EXCLUDED.avatar_url;
    
    RAISE NOTICE 'User created/updated successfully for ID: 59c2d985-e917-43a6-854a-904d0dc55877';
END $$;

-- Verify the user was created
SELECT 
    id, 
    email, 
    full_name, 
    created_at 
FROM public.users 
WHERE id = '59c2d985-e917-43a6-854a-904d0dc55877';