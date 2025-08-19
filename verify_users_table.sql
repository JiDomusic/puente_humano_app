-- VERIFICAR Y CREAR TABLA USERS CON ESTRUCTURA CORRECTA

-- Verificar si la tabla existe
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE  table_schema = 'public'
   AND    table_name   = 'users'
);

-- Si no existe, crearla
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('donante', 'transportista', 'biblioteca', 'admin')),
    phone TEXT,
    city TEXT,
    country TEXT,
    language TEXT DEFAULT 'es',
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    photo TEXT,
    average_rating DECIMAL(3, 2) DEFAULT 0,
    ratings_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Deshabilitar RLS para testing
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_city ON users(city);

-- Verificar estructura de la tabla
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- Verificar usuarios existentes
SELECT 
    id, 
    email, 
    full_name, 
    role, 
    created_at 
FROM users 
ORDER BY created_at DESC 
LIMIT 10;