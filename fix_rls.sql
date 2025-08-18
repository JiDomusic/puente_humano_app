-- TEMPORAL: Desactivar RLS para permitir registro de usuarios
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- O si prefieres mantener RLS, ejecuta estas políticas corregidas:
-- DROP POLICY IF EXISTS "Users can view own profile" ON users;
-- DROP POLICY IF EXISTS "Users can update own profile" ON users; 
-- DROP POLICY IF EXISTS "Anyone can view public user info" ON users;

-- Nuevas políticas más permisivas para registro
-- CREATE POLICY "Enable insert for authenticated users only" ON users FOR INSERT WITH CHECK (true);
-- CREATE POLICY "Enable select for users based on user_id" ON users FOR SELECT USING (true);
-- CREATE POLICY "Enable update for users based on user_id" ON users FOR UPDATE USING (auth.uid() = id);