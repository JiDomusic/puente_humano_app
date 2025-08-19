-- CREAR USUARIOS DE PRUEBA DIRECTAMENTE EN LA BASE DE DATOS

-- Primero verificar que la tabla users existe y tiene la estructura correcta
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
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

-- INSERTAR USUARIOS DE PRUEBA

-- Donantes
INSERT INTO users (id, email, full_name, role, phone, city, country, language, created_at) VALUES
(gen_random_uuid(), 'donante1@mail.com', 'María González', 'donante', '+54911234567', 'Buenos Aires', 'Argentina', 'es', NOW()),
(gen_random_uuid(), 'donante2@mail.com', 'Carlos López', 'donante', '+54911234568', 'Rosario', 'Argentina', 'es', NOW()),
(gen_random_uuid(), 'donante3@mail.com', 'Ana Martínez', 'donante', '+54911234569', 'Córdoba', 'Argentina', 'es', NOW())
ON CONFLICT (email) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- Transportistas
INSERT INTO users (id, email, full_name, role, phone, city, country, language, created_at) VALUES
(gen_random_uuid(), 'viajero1@mail.com', 'Pedro Ramírez', 'transportista', '+54911234570', 'La Plata', 'Argentina', 'es', NOW()),
(gen_random_uuid(), 'viajero2@mail.com', 'Laura Fernández', 'transportista', '+54911234571', 'Mendoza', 'Argentina', 'es', NOW()),
(gen_random_uuid(), 'transportista3@mail.com', 'Diego Silva', 'transportista', '+54911234572', 'Tucumán', 'Argentina', 'es', NOW())
ON CONFLICT (email) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- Bibliotecas
INSERT INTO users (id, email, full_name, role, phone, city, country, language, created_at) VALUES
(gen_random_uuid(), 'biblio1@mail.com', 'Biblioteca Comunal Norte', 'biblioteca', '+54911234573', 'Salta', 'Argentina', 'es', NOW()),
(gen_random_uuid(), 'biblioteca2@mail.com', 'Centro de Lectura Sur', 'biblioteca', '+54911234574', 'Neuquén', 'Argentina', 'es', NOW()),
(gen_random_uuid(), 'biblioteca3@mail.com', 'Espacio Cultural Villa María', 'biblioteca', '+54911234575', 'Villa María', 'Argentina', 'es', NOW())
ON CONFLICT (email) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- Usuarios adicionales con diferentes ubicaciones
INSERT INTO users (id, email, full_name, role, phone, city, country, language, lat, lng, created_at) VALUES
(gen_random_uuid(), 'juan.perez@example.com', 'Juan Pérez', 'donante', '+54911111111', 'CABA', 'Argentina', 'es', -34.6118, -58.3960, NOW()),
(gen_random_uuid(), 'sofia.rodriguez@example.com', 'Sofía Rodríguez', 'transportista', '+54922222222', 'Mar del Plata', 'Argentina', 'es', -38.0055, -57.5426, NOW()),
(gen_random_uuid(), 'biblioteca.central@example.com', 'Biblioteca Central', 'biblioteca', '+54933333333', 'San Miguel de Tucumán', 'Argentina', 'es', -26.8083, -65.2176, NOW()),
(gen_random_uuid(), 'martin.gomez@example.com', 'Martín Gómez', 'donante', '+54944444444', 'Santa Fe', 'Argentina', 'es', -31.6333, -60.7000, NOW()),
(gen_random_uuid(), 'camila.torres@example.com', 'Camila Torres', 'transportista', '+54955555555', 'Bahía Blanca', 'Argentina', 'es', -38.7183, -62.2669, NOW())
ON CONFLICT (email) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- Verificar usuarios creados
SELECT 
    email, 
    full_name, 
    role, 
    city, 
    country,
    created_at 
FROM users 
ORDER BY created_at DESC;

-- Contar usuarios por rol
SELECT 
    role, 
    COUNT(*) as cantidad 
FROM users 
GROUP BY role 
ORDER BY cantidad DESC;