DROP POLICY IF EXISTS "Allow authenticated users to insert user_logs" ON user_logs;
DROP POLICY IF EXISTS "Allow admins to view user_logs" ON user_logs;
DROP POLICY IF EXISTS "Allow authenticated users to access user_logs" ON user_logs;

CREATE POLICY "Allow all access to user_logs" ON user_logs
FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow public read access to user_logs" ON user_logs
FOR SELECT USING (true);