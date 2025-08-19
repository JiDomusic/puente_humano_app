-- REGLAS DE SEGURIDAD COMPLETAMENTE ABIERTAS PARA TESTING
-- ¡IMPORTANTE! Solo usar en desarrollo/testing, NUNCA en producción

-- Desactivar RLS en todas las tablas principales
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE donations DISABLE ROW LEVEL SECURITY;
ALTER TABLE libraries DISABLE ROW LEVEL SECURITY;
ALTER TABLE trips DISABLE ROW LEVEL SECURITY;
ALTER TABLE shipments DISABLE ROW LEVEL SECURITY;

-- Eliminar todas las políticas existentes
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Anyone can view public user info" ON users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON users;
DROP POLICY IF EXISTS "Enable select for users based on user_id" ON users;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON users;

-- Políticas completamente permisivas (opcional, ya que RLS está desactivado)
CREATE POLICY "Allow all operations" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON donations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON libraries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON trips FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON shipments FOR ALL USING (true) WITH CHECK (true);

-- Para admin_users si existe
DROP POLICY IF EXISTS "Admin users can do everything" ON admin_users;
ALTER TABLE admin_users DISABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations" ON admin_users FOR ALL USING (true) WITH CHECK (true);