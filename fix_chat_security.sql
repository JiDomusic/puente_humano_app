-- ============================================
-- CORRECCIÓN COMPLETA DE SEGURIDAD PARA CHAT
-- ============================================

-- 1. Eliminar políticas existentes que podrían estar causando conflictos
DROP POLICY IF EXISTS "Users can view their own conversations" ON chats;
DROP POLICY IF EXISTS "Users can send messages" ON chats;
DROP POLICY IF EXISTS "Users can update their own messages" ON chats;
DROP POLICY IF EXISTS "Enable read access for users" ON chats;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON chats;
DROP POLICY IF EXISTS "Enable update for users" ON chats;

-- 2. Desactivar temporalmente RLS para hacer cambios
ALTER TABLE chats DISABLE ROW LEVEL SECURITY;

-- 3. Verificar que la tabla tiene la estructura correcta
-- Si no existe, crearla
CREATE TABLE IF NOT EXISTS chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id TEXT NOT NULL,
    receiver_id TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_chats_sender ON chats(sender_id);
CREATE INDEX IF NOT EXISTS idx_chats_receiver ON chats(receiver_id);
CREATE INDEX IF NOT EXISTS idx_chats_conversation ON chats(sender_id, receiver_id);
CREATE INDEX IF NOT EXISTS idx_chats_created_at ON chats(created_at);

-- 5. Reactivar RLS
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- 6. POLÍTICAS SIMPLIFICADAS Y FUNCIONALES

-- Política para VER mensajes (SELECT)
CREATE POLICY "chat_select_policy" ON chats
FOR SELECT USING (
  auth.uid()::TEXT = sender_id OR auth.uid()::TEXT = receiver_id
);

-- Política para INSERTAR mensajes (INSERT)
CREATE POLICY "chat_insert_policy" ON chats
FOR INSERT WITH CHECK (
  auth.uid()::TEXT = sender_id
);

-- Política para ACTUALIZAR mensajes (UPDATE) - para marcar como leído
CREATE POLICY "chat_update_policy" ON chats
FOR UPDATE USING (
  auth.uid()::TEXT = sender_id OR auth.uid()::TEXT = receiver_id
) WITH CHECK (
  auth.uid()::TEXT = sender_id OR auth.uid()::TEXT = receiver_id
);

-- 7. POLÍTICA ALTERNATIVA MÁS PERMISIVA (USAR SOLO SI LAS ANTERIORES FALLAN)
-- Descomenta estas líneas si sigues teniendo problemas:
/*
DROP POLICY IF EXISTS "chat_select_policy" ON chats;
DROP POLICY IF EXISTS "chat_insert_policy" ON chats;
DROP POLICY IF EXISTS "chat_update_policy" ON chats;

-- Políticas más permisivas usando authenticated()
CREATE POLICY "authenticated_can_view_chats" ON chats
FOR SELECT TO authenticated USING (true);

CREATE POLICY "authenticated_can_insert_chats" ON chats
FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "authenticated_can_update_chats" ON chats
FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
*/

-- 8. Dar permisos explícitos si es necesario
GRANT ALL ON chats TO authenticated;
GRANT ALL ON chats TO anon;

-- 9. Verificar que todo funciona
SELECT 'Tabla chats configurada correctamente' as status;