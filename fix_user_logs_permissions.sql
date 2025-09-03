-- Fix user_logs table permissions
-- Run this in your Supabase SQL Editor

-- Drop any conflicting policies
DROP POLICY IF EXISTS "Allow authenticated users to insert user_logs" ON user_logs;
DROP POLICY IF EXISTS "Allow admins to view user_logs" ON user_logs;
DROP POLICY IF EXISTS "Allow authenticated users to access user_logs" ON user_logs;

-- Create simple policy to allow all access for authenticated users
CREATE POLICY "Allow all access to user_logs" ON user_logs
FOR ALL TO authenticated USING (true);

-- Also allow public access for SELECT to match your app's current usage
CREATE POLICY "Allow public read access to user_logs" ON user_logs
FOR SELECT USING (true);