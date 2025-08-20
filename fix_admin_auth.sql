-- ============================================
-- SCRIPT PARA ARREGLAR AUTENTICACIÓN DE ADMIN
-- ============================================

-- 1. Desactivar temporalmente RLS para hacer cambios
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- 2. Crear/actualizar función para hash de contraseñas que coincida con el código Dart
CREATE OR REPLACE FUNCTION hash_password(password TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Mismo salt que usa el código Dart: 'puente_humano_salt'
    RETURN encode(digest(password || 'puente_humano_salt', 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql;

-- 3. Verificar si el admin ya existe y eliminarlo si está mal configurado
DELETE FROM users WHERE email = 'equiz.rec@gmail.com';

-- 4. Crear usuario admin con la contraseña correcta
INSERT INTO users (
    id,
    email,
    password_hash,
    full_name,
    role,
    phone,
    city,
    country,
    language,
    created_at
) VALUES (
    'admin_equiz_rec_gmail_com',
    'equiz.rec@gmail.com',
    hash_password('admin123'),
    'Administrador Principal',
    'admin',
    '+1234567890',
    'Admin City',
    'Admin Country',
    'es',
    NOW()
);

-- 5. Crear el segundo admin: bibliowalsh25@gmail.com
INSERT INTO users (
    id,
    email,
    password_hash,
    full_name,
    role,
    phone,
    city,
    country,
    language,
    created_at
) VALUES (
    'admin_biblio_walsh_gmail_com',
    'bibliowalsh25@gmail.com',
    hash_password('admin123'),
    'Administrador Biblioteca',
    'admin',
    '+1234567891',
    'Library City',
    'Library Country',
    'es',
    NOW()
);

-- 6. Verificar que ambos admins fueron creados correctamente
SELECT 
    id,
    email,
    full_name,
    role,
    created_at,
    CASE 
        WHEN password_hash = hash_password('admin123') 
        THEN '✅ Contraseña correcta'
        ELSE '❌ Contraseña incorrecta'
    END as password_check
FROM users 
WHERE email IN ('equiz.rec@gmail.com', 'bibliowalsh25@gmail.com')
ORDER BY email;

-- 7. Reactivar RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 8. Crear política especial para admins si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'users' 
        AND policyname = 'Admin access policy'
    ) THEN
        EXECUTE 'CREATE POLICY "Admin access policy" ON users FOR ALL USING (role = ''admin'')';
    END IF;
END $$;

-- 9. Mostrar estado final
SELECT 'VERIFICACIÓN FINAL DEL SISTEMA ADMIN' as status;
SELECT COUNT(*) as total_admins FROM users WHERE role = 'admin';
SELECT email, full_name, role FROM users WHERE role = 'admin';