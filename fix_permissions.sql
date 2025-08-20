-- Arreglar permisos para permitir registro de usuarios
-- Ejecutar en Supabase SQL Editor

-- Desactivar RLS para la tabla users
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- O si prefieres mantener RLS, usar esta política:
-- CREATE POLICY "Allow public user registration" 
-- ON users FOR INSERT 
-- WITH CHECK (true);