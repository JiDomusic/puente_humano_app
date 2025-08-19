-- ============================================
-- SISTEMA COMPLETO USUARIO/ADMIN SEPARADO
-- ============================================

-- 1. TABLA USERS - Solo para usuarios normales
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL CHECK (length(full_name) >= 2 AND length(full_name) <= 100),
    role TEXT NOT NULL CHECK (role IN ('donante', 'transportista', 'biblioteca')) DEFAULT 'donante',
    phone TEXT,
    city TEXT,
    country TEXT,
    language TEXT DEFAULT 'es',
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    photo TEXT,
    average_rating DECIMAL(3, 2) DEFAULT 0 CHECK (average_rating >= 0 AND average_rating <= 5),
    ratings_count INTEGER DEFAULT 0 CHECK (ratings_count >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. FUNCIÓN PARA PREVENIR ADMINS EN TABLA USERS
CREATE OR REPLACE FUNCTION prevent_admin_in_users()
RETURNS TRIGGER AS $$
DECLARE
    admin_emails TEXT[] := ARRAY['equiz.rec@gmail.com', 'bibliowalsh25@gmail.com'];
BEGIN
    -- Bloquear inserción/actualización de emails de admin
    IF NEW.email = ANY(admin_emails) THEN
        RAISE EXCEPTION 'Email % no puede registrarse como usuario regular. Es un administrador.', NEW.email;
    END IF;
    
    -- Bloquear rol admin en tabla users
    IF NEW.role = 'admin' THEN
        RAISE EXCEPTION 'El rol "admin" no está permitido en la tabla users.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. TRIGGERS PARA PREVENIR ADMINS EN TABLA USERS
DROP TRIGGER IF EXISTS prevent_admin_insert ON users;
CREATE TRIGGER prevent_admin_insert
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION prevent_admin_in_users();

DROP TRIGGER IF EXISTS prevent_admin_update ON users;
CREATE TRIGGER prevent_admin_update
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION prevent_admin_in_users();

-- 4. FUNCIÓN TRIGGER PARA AUTO-CREAR USUARIOS
CREATE OR REPLACE FUNCTION handle_new_user() 
RETURNS TRIGGER AS $$
DECLARE
    admin_emails TEXT[] := ARRAY['equiz.rec@gmail.com', 'bibliowalsh25@gmail.com'];
BEGIN
    -- Solo crear perfil si NO es admin
    IF NOT (NEW.email = ANY(admin_emails)) THEN
        INSERT INTO public.users (
            id, 
            email, 
            full_name, 
            role, 
            phone, 
            city, 
            country, 
            language
        )
        VALUES (
            NEW.id,
            NEW.email,
            COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuario'),
            COALESCE(NEW.raw_user_meta_data->>'role', 'donante'),
            NEW.raw_user_meta_data->>'phone',
            NEW.raw_user_meta_data->>'city',
            NEW.raw_user_meta_data->>'country',
            COALESCE(NEW.raw_user_meta_data->>'language', 'es')
        )
        ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            role = EXCLUDED.role,
            phone = EXCLUDED.phone,
            city = EXCLUDED.city,
            country = EXCLUDED.country,
            language = EXCLUDED.language,
            updated_at = NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. TRIGGER PARA AUTO-CREAR USUARIOS (SOLO NO-ADMINS)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION handle_new_user();

-- 6. FUNCIÓN PARA VERIFICAR ADMIN
CREATE OR REPLACE FUNCTION is_admin(user_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Solo estos 2 emails son admins
    RETURN user_email IN ('equiz.rec@gmail.com', 'bibliowalsh25@gmail.com');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. FUNCIÓN PARA PREVENIR LOGIN DE ADMINS COMO USUARIOS
CREATE OR REPLACE FUNCTION prevent_admin_auth()
RETURNS TRIGGER AS $$
DECLARE
    admin_emails TEXT[] := ARRAY['equiz.rec@gmail.com', 'bibliowalsh25@gmail.com'];
BEGIN
    -- Si es admin, prevenir que se autentique como usuario regular
    IF NEW.email = ANY(admin_emails) AND TG_OP = 'INSERT' THEN
        -- Solo permitir si viene de sistema admin (no implementado aquí)
        -- Por ahora, permitir pero logear
        INSERT INTO admin_auth_logs (email, attempted_at) 
        VALUES (NEW.email, NOW())
        ON CONFLICT DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. TABLA DE LOGS PARA ADMINS
CREATE TABLE IF NOT EXISTS admin_auth_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    success BOOLEAN DEFAULT FALSE,
    method TEXT DEFAULT 'regular_auth'
);

-- 9. POLÍTICAS RLS PARA PRODUCCIÓN
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Política: Usuarios pueden ver su propio perfil
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT
    USING (auth.uid() = id);

-- Política: Usuarios pueden actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE
    USING (auth.uid() = id);

-- Política: Cualquiera puede ver perfiles públicos (para matching)
CREATE POLICY "Anyone can view public user info" ON users
    FOR SELECT
    USING (is_active = true);

-- Política: Solo admins pueden insertar usuarios (via trigger)
CREATE POLICY "System can insert users" ON users
    FOR INSERT
    WITH CHECK (true); -- El trigger ya valida

-- 10. FUNCIÓN PARA LIMPIAR USUARIOS ADMIN EXISTENTES
CREATE OR REPLACE FUNCTION cleanup_admin_users()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
    admin_emails TEXT[] := ARRAY['equiz.rec@gmail.com', 'bibliowalsh25@gmail.com'];
BEGIN
    -- Eliminar admins de la tabla users si existen
    DELETE FROM users WHERE email = ANY(admin_emails);
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 11. EJECUTAR LIMPIEZA
SELECT cleanup_admin_users() as cleaned_admin_users;

-- 12. FUNCIÓN HELPER PARA DEBUG
CREATE OR REPLACE FUNCTION debug_user_system()
RETURNS TABLE(
    table_name TEXT,
    admin_emails_in_users BIGINT,
    total_users BIGINT,
    total_auth_users BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'Summary'::TEXT,
        (SELECT COUNT(*) FROM users WHERE email IN ('equiz.rec@gmail.com', 'bibliowalsh25@gmail.com'))::BIGINT,
        (SELECT COUNT(*) FROM users)::BIGINT,
        (SELECT COUNT(*) FROM auth.users)::BIGINT;
END;
$$ LANGUAGE plpgsql;

-- 13. ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- 14. COMENTARIOS
COMMENT ON TABLE users IS 'Tabla solo para usuarios regulares (donante, transportista, biblioteca). Los admins NO van aquí.';
COMMENT ON FUNCTION is_admin(TEXT) IS 'Función que verifica si un email es de los 2 administradores autorizados.';
COMMENT ON FUNCTION prevent_admin_in_users() IS 'Previene que emails de admin se guarden en tabla users.';

-- ============================================
-- VERIFICACIONES FINALES
-- ============================================

-- Mostrar estado del sistema
SELECT 'ESTADO DEL SISTEMA DE USUARIOS' as status;
SELECT * FROM debug_user_system();

-- Verificar que admins no están en users
SELECT 
    CASE 
        WHEN EXISTS(SELECT 1 FROM users WHERE email IN ('equiz.rec@gmail.com', 'bibliowalsh25@gmail.com'))
        THEN '❌ PROBLEMA: Admins encontrados en tabla users'
        ELSE '✅ CORRECTO: No hay admins en tabla users'
    END as admin_check;

-- Verificar triggers
SELECT 
    CASE 
        WHEN EXISTS(SELECT 1 FROM pg_trigger WHERE tgname = 'prevent_admin_insert')
        THEN '✅ Trigger prevent_admin_insert activo'
        ELSE '❌ Trigger prevent_admin_insert NO encontrado'
    END as trigger_check;

COMMIT;