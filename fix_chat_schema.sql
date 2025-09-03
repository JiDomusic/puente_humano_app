-- ============================================
-- SCRIPT PARA CORREGIR SCHEMA DE CHAT
-- ============================================

-- 1. Crear nueva tabla chats con el schema correcto
DROP TABLE IF EXISTS chats_new CASCADE;

CREATE TABLE chats_new (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id TEXT NOT NULL,
    receiver_id TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Migrar datos existentes si los hay (la tabla original podría estar vacía)
INSERT INTO chats_new (sender_id, receiver_id, message, created_at)
SELECT sender_id::TEXT, 
       COALESCE(receiver_id::TEXT, 'unknown') as receiver_id,
       message, 
       created_at
FROM chats
WHERE sender_id IS NOT NULL;

-- 3. Eliminar tabla anterior y renombrar la nueva
DROP TABLE IF EXISTS chats CASCADE;
ALTER TABLE chats_new RENAME TO chats;

-- 4. Crear índices para mejor performance
CREATE INDEX idx_chats_sender ON chats(sender_id);
CREATE INDEX idx_chats_receiver ON chats(receiver_id);
CREATE INDEX idx_chats_conversation ON chats(sender_id, receiver_id);
CREATE INDEX idx_chats_created_at ON chats(created_at);

-- 5. Habilitar RLS
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- 6. Políticas de seguridad para chat
CREATE POLICY "Users can view their own conversations" ON chats
FOR SELECT USING (
  sender_id = auth.jwt() ->> 'sub' OR 
  receiver_id = auth.jwt() ->> 'sub'
);

CREATE POLICY "Users can send messages" ON chats
FOR INSERT WITH CHECK (
  sender_id = auth.jwt() ->> 'sub'
);

CREATE POLICY "Users can update their own messages" ON chats
FOR UPDATE USING (
  sender_id = auth.jwt() ->> 'sub' OR 
  receiver_id = auth.jwt() ->> 'sub'
);