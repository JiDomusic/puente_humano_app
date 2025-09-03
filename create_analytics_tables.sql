-- Crear tablas para Analytics Service
-- Ejecutar en Supabase SQL Editor

-- Tabla para logs de acciones de usuarios
CREATE TABLE IF NOT EXISTS user_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  action TEXT NOT NULL,
  details JSONB,
  ip_address TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_user_logs_user_id ON user_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_user_logs_action ON user_logs(action);
CREATE INDEX IF NOT EXISTS idx_user_logs_timestamp ON user_logs(timestamp);

-- Tabla para logs de errores
CREATE TABLE IF NOT EXISTS error_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT,
  error TEXT NOT NULL,
  context TEXT NOT NULL,
  details JSONB,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_error_logs_user_id ON error_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_error_logs_context ON error_logs(context);
CREATE INDEX IF NOT EXISTS idx_error_logs_timestamp ON error_logs(timestamp);

-- RLS (Row Level Security) - Opcional, por seguridad
ALTER TABLE user_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

-- Políticas básicas (permitir a todos los usuarios autenticados)
CREATE POLICY "Allow authenticated users to insert user_logs" ON user_logs
FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated users to insert error_logs" ON error_logs
FOR INSERT TO authenticated WITH CHECK (true);

-- Solo administradores pueden ver los logs
CREATE POLICY "Allow admins to view user_logs" ON user_logs
FOR SELECT TO authenticated USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.jwt() ->> 'sub' 
    AND users.role = 'admin'
  )
);

CREATE POLICY "Allow admins to view error_logs" ON error_logs
FOR SELECT TO authenticated USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.jwt() ->> 'sub' 
    AND users.role = 'admin'
  )
);