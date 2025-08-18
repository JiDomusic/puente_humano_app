-- TABLAS PARA SISTEMA DE ADMINISTRACIÓN

-- Tabla de logs de acciones de usuarios
CREATE TABLE user_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    details JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address VARCHAR(45)
);

-- Tabla de logs de errores
CREATE TABLE error_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    error TEXT NOT NULL,
    context VARCHAR(255) NOT NULL,
    details JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved BOOLEAN DEFAULT FALSE
);

-- Tabla de notificaciones para admin
CREATE TABLE admin_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read BOOLEAN DEFAULT FALSE
);

-- Tabla de configuración de la app
CREATE TABLE app_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by UUID REFERENCES users(id)
);

-- Tabla de reportes de usuarios
CREATE TABLE user_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reported_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID REFERENCES users(id)
);

-- Índices para optimizar consultas
CREATE INDEX idx_user_logs_user_id ON user_logs(user_id);
CREATE INDEX idx_user_logs_timestamp ON user_logs(timestamp DESC);
CREATE INDEX idx_error_logs_timestamp ON error_logs(timestamp DESC);
CREATE INDEX idx_admin_notifications_read ON admin_notifications(read, timestamp DESC);

-- RLS para tablas de admin (solo admins pueden acceder)
ALTER TABLE user_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_reports ENABLE ROW LEVEL SECURITY;

-- Políticas más permisivas para desarrollo
CREATE POLICY "Allow all for now" ON user_logs FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON error_logs FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON admin_notifications FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON app_config FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON user_reports FOR ALL USING (true);

-- Datos iniciales de configuración
INSERT INTO app_config (key, value, description) VALUES
('maintenance_mode', 'false', 'Activar modo mantenimiento'),
('max_file_size', '5MB', 'Tamaño máximo de archivos'),
('allowed_languages', 'es,en', 'Idiomas soportados'),
('email_notifications', 'true', 'Enviar notificaciones por email'),
('app_version', '1.0.0', 'Versión actual de la aplicación');