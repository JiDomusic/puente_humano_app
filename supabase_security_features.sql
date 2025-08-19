-- ============================================
-- CARACTERÍSTICAS DE SEGURIDAD AVANZADAS
-- ============================================

-- 1. TABLA PARA CÓDIGOS DE VERIFICACIÓN 2FA
CREATE TABLE IF NOT EXISTS verification_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL,
    purpose TEXT NOT NULL CHECK (purpose IN ('login', 'password_reset', 'email_verification', 'account_recovery')),
    code_hash TEXT NOT NULL,
    salt TEXT NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    attempts INTEGER DEFAULT 0 CHECK (attempts >= 0 AND attempts <= 10),
    is_used BOOLEAN DEFAULT FALSE,
    is_locked BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP WITH TIME ZONE,
    locked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABLA PARA CÓDIGOS DE RESPALDO
CREATE TABLE IF NOT EXISTS backup_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    code_hash TEXT NOT NULL,
    salt TEXT NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TABLA PARA LOGS DE SEGURIDAD
CREATE TABLE IF NOT EXISTS security_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    email TEXT,
    event_type TEXT NOT NULL CHECK (event_type IN (
        'login_success', 'login_failed', 'password_change', 'email_change',
        'two_factor_enabled', 'two_factor_disabled', 'backup_codes_generated',
        'suspicious_activity', 'account_locked', 'password_reset_requested'
    )),
    ip_address TEXT,
    user_agent TEXT,
    location TEXT,
    details JSONB,
    severity TEXT DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TABLA PARA INTENTOS DE LOGIN FALLIDOS
CREATE TABLE IF NOT EXISTS failed_login_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL,
    ip_address TEXT,
    user_agent TEXT,
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. TABLA PARA SESIONES ACTIVAS
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_token TEXT UNIQUE NOT NULL,
    ip_address TEXT,
    user_agent TEXT,
    device_info JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. AGREGAR COLUMNAS DE SEGURIDAD A TABLA USERS
ALTER TABLE users ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE users ADD COLUMN IF NOT EXISTS account_locked BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS account_locked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS failed_login_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_ip TEXT;

-- 7. FUNCIÓN PARA LIMPIAR CÓDIGOS EXPIRADOS
CREATE OR REPLACE FUNCTION cleanup_expired_codes()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM verification_codes 
    WHERE expires_at < NOW() OR (is_used = TRUE AND created_at < NOW() - INTERVAL '7 days');
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- También limpiar intentos de login antiguos (más de 30 días)
    DELETE FROM failed_login_attempts 
    WHERE created_at < NOW() - INTERVAL '30 days';
    
    -- Limpiar logs de seguridad antiguos (más de 90 días)
    DELETE FROM security_logs 
    WHERE created_at < NOW() - INTERVAL '90 days' AND severity != 'critical';
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 8. FUNCIÓN PARA REGISTRAR EVENTOS DE SEGURIDAD
CREATE OR REPLACE FUNCTION log_security_event(
    p_user_id UUID,
    p_email TEXT,
    p_event_type TEXT,
    p_ip_address TEXT DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_details JSONB DEFAULT NULL,
    p_severity TEXT DEFAULT 'info'
)
RETURNS UUID AS $$
DECLARE
    log_id UUID;
BEGIN
    INSERT INTO security_logs (
        user_id, email, event_type, ip_address, user_agent, details, severity
    ) VALUES (
        p_user_id, p_email, p_event_type, p_ip_address, p_user_agent, p_details, p_severity
    ) RETURNING id INTO log_id;
    
    RETURN log_id;
END;
$$ LANGUAGE plpgsql;

-- 9. FUNCIÓN PARA DETECTAR ACTIVIDAD SOSPECHOSA
CREATE OR REPLACE FUNCTION detect_suspicious_activity()
RETURNS TABLE(
    email TEXT,
    suspicious_score INTEGER,
    reasons TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    WITH suspicious_activity AS (
        SELECT 
            u.email,
            CASE 
                WHEN u.failed_login_count > 5 THEN 10
                ELSE 0
            END +
            CASE 
                WHEN EXISTS(
                    SELECT 1 FROM failed_login_attempts fla 
                    WHERE fla.email = u.email 
                    AND fla.created_at > NOW() - INTERVAL '1 hour'
                    GROUP BY fla.email
                    HAVING COUNT(*) > 5
                ) THEN 15
                ELSE 0
            END +
            CASE 
                WHEN EXISTS(
                    SELECT 1 FROM security_logs sl 
                    WHERE sl.email = u.email 
                    AND sl.event_type = 'login_success'
                    AND sl.created_at > NOW() - INTERVAL '1 hour'
                    GROUP BY sl.ip_address
                    HAVING COUNT(DISTINCT sl.ip_address) > 3
                ) THEN 20
                ELSE 0
            END AS suspicious_score,
            
            ARRAY_REMOVE(ARRAY[
                CASE WHEN u.failed_login_count > 5 THEN 'Múltiples intentos fallidos' END,
                CASE WHEN EXISTS(
                    SELECT 1 FROM failed_login_attempts fla 
                    WHERE fla.email = u.email 
                    AND fla.created_at > NOW() - INTERVAL '1 hour'
                    GROUP BY fla.email
                    HAVING COUNT(*) > 5
                ) THEN 'Ataques de fuerza bruta' END,
                CASE WHEN EXISTS(
                    SELECT 1 FROM security_logs sl 
                    WHERE sl.email = u.email 
                    AND sl.event_type = 'login_success'
                    AND sl.created_at > NOW() - INTERVAL '1 hour'
                    GROUP BY sl.ip_address
                    HAVING COUNT(DISTINCT sl.ip_address) > 3
                ) THEN 'Múltiples ubicaciones simultáneas' END
            ], NULL) AS reasons
        FROM users u
    )
    SELECT 
        sa.email,
        sa.suspicious_score,
        sa.reasons
    FROM suspicious_activity sa
    WHERE sa.suspicious_score > 0
    ORDER BY sa.suspicious_score DESC;
END;
$$ LANGUAGE plpgsql;

-- 10. FUNCIÓN PARA BLOQUEAR CUENTA AUTOMÁTICAMENTE
CREATE OR REPLACE FUNCTION auto_lock_account()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se exceden 10 intentos fallidos, bloquear cuenta
    IF NEW.failed_login_count >= 10 THEN
        NEW.account_locked = TRUE;
        NEW.account_locked_at = NOW();
        
        -- Registrar evento de seguridad
        PERFORM log_security_event(
            NEW.id,
            NEW.email,
            'account_locked',
            NULL,
            NULL,
            jsonb_build_object('reason', 'too_many_failed_attempts', 'count', NEW.failed_login_count),
            'critical'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 11. TRIGGER PARA BLOQUEO AUTOMÁTICO
DROP TRIGGER IF EXISTS trigger_auto_lock_account ON users;
CREATE TRIGGER trigger_auto_lock_account
    BEFORE UPDATE ON users
    FOR EACH ROW
    WHEN (OLD.failed_login_count IS DISTINCT FROM NEW.failed_login_count)
    EXECUTE FUNCTION auto_lock_account();

-- 12. FUNCIÓN PARA VALIDAR FUERZA DE CONTRASEÑA
CREATE OR REPLACE FUNCTION validate_password_strength(password TEXT)
RETURNS TABLE(
    is_valid BOOLEAN,
    score INTEGER,
    issues TEXT[]
) AS $$
DECLARE
    pwd_issues TEXT[] := '{}';
    pwd_score INTEGER := 0;
BEGIN
    -- Longitud
    IF LENGTH(password) < 8 THEN
        pwd_issues := array_append(pwd_issues, 'Debe tener al menos 8 caracteres');
    ELSE
        pwd_score := pwd_score + 1;
    END IF;
    
    -- Minúsculas
    IF password !~ '[a-z]' THEN
        pwd_issues := array_append(pwd_issues, 'Debe incluir letras minúsculas');
    ELSE
        pwd_score := pwd_score + 1;
    END IF;
    
    -- Mayúsculas
    IF password !~ '[A-Z]' THEN
        pwd_issues := array_append(pwd_issues, 'Debe incluir letras mayúsculas');
    ELSE
        pwd_score := pwd_score + 1;
    END IF;
    
    -- Números
    IF password !~ '[0-9]' THEN
        pwd_issues := array_append(pwd_issues, 'Debe incluir números');
    ELSE
        pwd_score := pwd_score + 1;
    END IF;
    
    -- Caracteres especiales
    IF password !~ '[!@#$%^&*(),.?":{}|<>]' THEN
        pwd_issues := array_append(pwd_issues, 'Debe incluir caracteres especiales');
    ELSE
        pwd_score := pwd_score + 2;
    END IF;
    
    -- Patrones comunes
    IF LOWER(password) ~ '(password|123456|qwerty|admin)' THEN
        pwd_issues := array_append(pwd_issues, 'No debe contener patrones comunes');
        pwd_score := pwd_score - 2;
    END IF;
    
    RETURN QUERY SELECT 
        (array_length(pwd_issues, 1) IS NULL OR array_length(pwd_issues, 1) = 0),
        GREATEST(pwd_score, 0),
        COALESCE(pwd_issues, '{}');
END;
$$ LANGUAGE plpgsql;

-- 13. POLÍTICAS RLS PARA TABLAS DE SEGURIDAD
ALTER TABLE verification_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE backup_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE failed_login_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- Política: Solo admins pueden ver logs de seguridad completos
CREATE POLICY "Admins can view all security logs" ON security_logs
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND email IN ('equiz.rec@gmail.com', 'bibliowalsh25@gmail.com')
        )
    );

-- Política: Usuarios pueden ver sus propios logs
CREATE POLICY "Users can view own security logs" ON security_logs
    FOR SELECT
    USING (user_id = auth.uid());

-- Política: Solo el sistema puede insertar logs
CREATE POLICY "System can insert security logs" ON security_logs
    FOR INSERT
    WITH CHECK (true);

-- Política: Usuarios pueden ver sus propios códigos de respaldo
CREATE POLICY "Users can view own backup codes" ON backup_codes
    FOR SELECT
    USING (user_id = auth.uid());

-- Política: Solo el sistema puede gestionar códigos de verificación
CREATE POLICY "System manages verification codes" ON verification_codes
    FOR ALL
    USING (true);

-- 14. ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_verification_codes_email_purpose ON verification_codes(email, purpose);
CREATE INDEX IF NOT EXISTS idx_verification_codes_expires_at ON verification_codes(expires_at);
CREATE INDEX IF NOT EXISTS idx_security_logs_user_id ON security_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_security_logs_email ON security_logs(email);
CREATE INDEX IF NOT EXISTS idx_security_logs_event_type ON security_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_security_logs_created_at ON security_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_failed_login_attempts_email ON failed_login_attempts(email);
CREATE INDEX IF NOT EXISTS idx_failed_login_attempts_ip ON failed_login_attempts(ip_address);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_users_email_verified ON users(email_verified);
CREATE INDEX IF NOT EXISTS idx_users_account_locked ON users(account_locked);

-- 15. JOB PARA LIMPIEZA AUTOMÁTICA (ejecutar diariamente)
-- Nota: Esto requiere pg_cron extension
-- SELECT cron.schedule('cleanup-expired-codes', '0 2 * * *', 'SELECT cleanup_expired_codes();');

-- 16. VISTAS PARA MONITOREO
CREATE OR REPLACE VIEW security_dashboard AS
SELECT
    'users_total' as metric,
    COUNT(*)::TEXT as value,
    'Total de usuarios registrados' as description
FROM users
UNION ALL
SELECT
    'users_verified' as metric,
    COUNT(*)::TEXT as value,
    'Usuarios con email verificado' as description
FROM users WHERE email_verified = TRUE
UNION ALL
SELECT
    'users_2fa_enabled' as metric,
    COUNT(*)::TEXT as value,
    'Usuarios con 2FA habilitado' as description
FROM users WHERE two_factor_enabled = TRUE
UNION ALL
SELECT
    'accounts_locked' as metric,
    COUNT(*)::TEXT as value,
    'Cuentas bloqueadas' as description
FROM users WHERE account_locked = TRUE
UNION ALL
SELECT
    'failed_logins_today' as metric,
    COUNT(*)::TEXT as value,
    'Intentos fallidos hoy' as description
FROM failed_login_attempts 
WHERE created_at >= CURRENT_DATE
UNION ALL
SELECT
    'suspicious_activity' as metric,
    COUNT(*)::TEXT as value,
    'Actividades sospechosas detectadas' as description
FROM (SELECT * FROM detect_suspicious_activity() WHERE suspicious_score > 10) sa;

-- 17. FUNCIÓN PARA ESTADÍSTICAS DE SEGURIDAD
CREATE OR REPLACE FUNCTION get_security_stats()
RETURNS JSONB AS $$
DECLARE
    stats JSONB;
BEGIN
    SELECT jsonb_object_agg(metric, jsonb_build_object('value', value, 'description', description))
    INTO stats
    FROM security_dashboard;
    
    RETURN stats;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VERIFICACIONES FINALES
-- ============================================

-- Verificar que las tablas se crearon correctamente
SELECT 
    CASE 
        WHEN EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'verification_codes')
        THEN '✅ Tabla verification_codes creada'
        ELSE '❌ Error: tabla verification_codes no existe'
    END as verification_codes_check,
    
    CASE 
        WHEN EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'backup_codes')
        THEN '✅ Tabla backup_codes creada'
        ELSE '❌ Error: tabla backup_codes no existe'
    END as backup_codes_check,
    
    CASE 
        WHEN EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'security_logs')
        THEN '✅ Tabla security_logs creada'
        ELSE '❌ Error: tabla security_logs no existe'
    END as security_logs_check;

-- Mostrar estadísticas iniciales
SELECT 'ESTADÍSTICAS DE SEGURIDAD INICIAL' as status;
SELECT * FROM get_security_stats();

COMMIT;