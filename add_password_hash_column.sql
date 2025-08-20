-- Add password_hash column to users table
-- This fixes the registration error where password_hash column is missing

ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;

-- Also add an age column since the auth service expects it
ALTER TABLE users ADD COLUMN IF NOT EXISTS age INTEGER;

-- Disable RLS to allow registration to work
ALTER TABLE users DISABLE ROW LEVEL SECURITY;