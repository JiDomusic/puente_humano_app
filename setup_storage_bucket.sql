-- Configuración CORRECTA del bucket de Storage para fotos de perfil
-- Ejecutar en Supabase SQL Editor

-- 1. Primero eliminar políticas existentes que puedan causar conflicto
DROP POLICY IF EXISTS "Anyone can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Usuarios solo suben a su carpeta" ON storage.objects;

-- 2. Crear el bucket si no existe
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars', 
  true,
  20971520, -- 20MB límite
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- 3. POLÍTICA SIMPLE para subir fotos (cualquier usuario autenticado)
CREATE POLICY "Authenticated users can upload avatars" ON storage.objects
FOR INSERT 
TO authenticated
WITH CHECK (bucket_id = 'avatars');

-- 4. POLÍTICA para ver fotos públicamente (cualquiera puede ver)
CREATE POLICY "Public avatar access" ON storage.objects
FOR SELECT 
USING (bucket_id = 'avatars');

-- 5. POLÍTICA para actualizar fotos (cualquier usuario autenticado)
CREATE POLICY "Authenticated users can update avatars" ON storage.objects
FOR UPDATE 
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');

-- 6. POLÍTICA para eliminar fotos (cualquier usuario autenticado)
CREATE POLICY "Authenticated users can delete avatars" ON storage.objects
FOR DELETE 
TO authenticated
USING (bucket_id = 'avatars');

-- 7. Habilitar RLS en storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;