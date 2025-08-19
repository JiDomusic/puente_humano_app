-- TEST SCRIPT TO VERIFY USER REGISTRATION AND ADMIN FUNCTIONALITY
-- Run this in your Supabase SQL editor after applying COMPREHENSIVE_FIX.sql

-- 1. Verify table structures are correct
SELECT 'Tables exist:' as check_name;
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'admin_users')
ORDER BY table_name;

-- 2. Verify users table has correct foreign key to auth.users
SELECT 'Users table constraints:' as check_name;
SELECT 
    constraint_name,
    constraint_type,
    table_name,
    column_name,
    foreign_table_name,
    foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.referential_constraints rc ON tc.constraint_name = rc.constraint_name
LEFT JOIN information_schema.key_column_usage fkcu ON rc.unique_constraint_name = fkcu.constraint_name
WHERE tc.table_name = 'users' AND tc.constraint_type = 'FOREIGN KEY';

-- 3. Check that trigger function exists
SELECT 'Trigger function exists:' as check_name;
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';

-- 4. Check that trigger exists on auth.users
SELECT 'Trigger exists on auth.users:' as check_name;
SELECT trigger_name, event_manipulation, action_timing, event_object_table
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- 5. Verify admin users are properly configured
SELECT 'Admin users configured:' as check_name;
SELECT email, name, is_active, is_super_admin, created_at 
FROM admin_users 
ORDER BY created_at;

-- 6. Check RLS status (should be disabled for development)
SELECT 'RLS status:' as check_name;
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('users', 'admin_users', 'libraries', 'trips', 'donations') 
AND schemaname = 'public'
ORDER BY tablename;

-- 7. Test the is_admin function
SELECT 'Testing is_admin function:' as check_name;
SELECT 
    'equiz.rec@gmail.com' as email,
    is_admin('equiz.rec@gmail.com') as is_admin_result
UNION ALL
SELECT 
    'bibliowalsh25@gmail.com' as email,
    is_admin('bibliowalsh25@gmail.com') as is_admin_result
UNION ALL
SELECT 
    'notadmin@test.com' as email,
    is_admin('notadmin@test.com') as is_admin_result;

-- 8. Check if there are any existing users in the users table
SELECT 'Existing users count:' as check_name;
SELECT COUNT(*) as user_count FROM users;

-- 9. Show sample libraries for context
SELECT 'Sample libraries:' as check_name;
SELECT library_code, name, city, country 
FROM libraries 
LIMIT 3;

-- 10. Verify the handle_new_user function syntax
SELECT 'Function definition check:' as check_name;
SELECT routine_definition 
FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';

SELECT '=== ALL CHECKS COMPLETED ===' as final_status;