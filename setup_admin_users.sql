-- CONFIGURAR ADMINS ESPECÍFICOS
-- Emails: equiz.rec@gmail.com y bibliowalsh2025@gmail.com

-- Primero, aplicar reglas de seguridad abiertas
ALTER TABLE admin_users DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "Admin users can do everything" ON admin_users;
DROP POLICY IF EXISTS "Allow all operations" ON admin_users;

-- Crear política permisiva para admin_users
CREATE POLICY "Allow all operations" ON admin_users FOR ALL USING (true) WITH CHECK (true);

-- Insertar admins específicos (con contraseñas por defecto)
-- IMPORTANTE: Cambiar estas contraseñas después del primer login

-- Admin 1: equiz.rec@gmail.com
INSERT INTO admin_users (email, password_hash, is_super_admin, created_at)
VALUES (
  'equiz.rec@gmail.com',
  crypt('admin123', gen_salt('bf')),
  true,
  NOW()
) ON CONFLICT (email) DO UPDATE SET
  password_hash = crypt('admin123', gen_salt('bf')),
  is_super_admin = true,
  updated_at = NOW();

-- Admin 2: bibliowalsh25@gmail.com  
INSERT INTO admin_users (email, password_hash, is_super_admin, created_at)
VALUES (
  'bibliowalsh25@gmail.com',
  crypt('admin123', gen_salt('bf')), 
  true,
  NOW()
) ON CONFLICT (email) DO UPDATE SET
  password_hash = crypt('admin123', gen_salt('bf')),
  is_super_admin = true,
  updated_at = NOW();

-- Crear usuarios regulares en la tabla users si no existen
-- (Para que puedan hacer login normal también)

INSERT INTO users (
  id, 
  email, 
  full_name, 
  role, 
  phone, 
  city, 
  country, 
  language,
  created_at
) VALUES (
  gen_random_uuid(),
  'equiz.rec@gmail.com',
  'Administrador Principal',
  'admin',
  '',
  '',
  '',
  'es',
  NOW()
) ON CONFLICT (email) DO UPDATE SET
  role = 'admin',
  updated_at = NOW();

INSERT INTO users (
  id,
  email,
  full_name, 
  role,
  phone,
  city,
  country,
  language,
  created_at
) VALUES (
  gen_random_uuid(),
  'bibliowalsh25@gmail.com',
  'Biblioteca Walsh Admin',
  'admin', 
  '',
  '',
  '',
  'es',
  NOW()
) ON CONFLICT (email) DO UPDATE SET
  role = 'admin',
  updated_at = NOW();

-- Verificar que se crearon correctamente
SELECT email, is_super_admin, created_at FROM admin_users 
WHERE email IN ('equiz.rec@gmail.com', 'bibliowalsh25@gmail.com');

SELECT email, role, full_name FROM users 
WHERE email IN ('equiz.rec@gmail.com', 'bibliowalsh25@gmail.com');