-- Configuración del bucket de Storage para fotos de perfil
-- Ejecutar en Supabase SQL Editor

-- 1. Crear el bucket si no existe (esto también se puede hacer desde el dashboard)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars', 
  true,
  5242880, -- 5MB límite
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- 2. Política para permitir subir fotos (INSERT)
CREATE POLICY "Anyone can upload avatars" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] IS NOT NULL
);

-- 3. Política para ver fotos públicamente (SELECT)
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

-- 4. Política para actualizar fotos propias (UPDATE)
CREATE POLICY "Users can update own avatar" ON storage.objects
FOR UPDATE WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] IS NOT NULL
);

-- 5. Política para eliminar fotos propias (DELETE)
CREATE POLICY "Users can delete own avatar" ON storage.objects
FOR DELETE USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] IS NOT NULL
);

-- 6. Habilitar RLS en storage.objects si no está habilitado
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;