# 🚀 GUÍA COMPLETA: Implementar SQL en Supabase

## 📋 **ARCHIVOS SQL CREADOS**

Hemos creado 2 archivos SQL principales:

1. **`supabase_user_admin_fix.sql`** - Sistema de usuarios/admin separado
2. **`supabase_security_features.sql`** - Características de seguridad avanzadas

## 🔧 **CÓMO IMPLEMENTAR EN SUPABASE**

### **Método 1: SQL Editor (MÁS FÁCIL)**

#### **Paso 1: Acceder a Supabase**
1. Ve a https://supabase.com/dashboard
2. Busca tu proyecto "PuenteHumano" 
3. Haz clic para entrar

#### **Paso 2: Ir al SQL Editor**
1. En el menú lateral izquierdo, busca el icono de base de datos 🗄️
2. Haz clic en **"SQL Editor"**
3. Verás una pantalla con un editor de código

#### **Paso 3: Ejecutar Primer Archivo**
1. Haz clic en **"New query"** (nueva consulta)
2. Abre el archivo `supabase_user_admin_fix.sql`
3. **Copia TODO el contenido** (Ctrl+A, Ctrl+C)
4. **Pega en el SQL Editor** de Supabase (Ctrl+V)
5. Haz clic en **"Run"** (botón verde) o presiona **Ctrl+Enter**
6. ✅ Debería aparecer "Success" y mensajes de verificación

#### **Paso 4: Ejecutar Segundo Archivo**
1. Haz clic en **"New query"** nuevamente
2. Abre el archivo `supabase_security_features.sql`  
3. **Copia TODO el contenido**
4. **Pega en el SQL Editor** de Supabase
5. Haz clic en **"Run"** o presiona **Ctrl+Enter**
6. ✅ Debería aparecer "Success" y estadísticas

---

### **Método 2: Por Secciones (Si hay errores)**

Si el archivo es muy grande o hay errores, ejecuta por partes:

#### **Para `supabase_user_admin_fix.sql`:**
```sql
-- SECCIÓN 1: Crear tabla users
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    -- ... (copiar solo hasta la sección de triggers)
);

-- SECCIÓN 2: Triggers
CREATE OR REPLACE FUNCTION prevent_admin_in_users()
-- ... (continuar paso a paso)
```

#### **Para `supabase_security_features.sql`:**
```sql
-- SECCIÓN 1: Crear tablas de seguridad
CREATE TABLE IF NOT EXISTS verification_codes (
    -- ... (ejecutar tabla por tabla)
);

-- SECCIÓN 2: Funciones
CREATE OR REPLACE FUNCTION cleanup_expired_codes()
-- ... (función por función)
```

---

## 🔍 **VERIFICAR QUE FUNCIONÓ**

### **Después de ejecutar los scripts:**

1. **Ve a "Table Editor"** en Supabase
2. **Deberías ver estas tablas:**
   - ✅ `users` (mejorada)
   - ✅ `verification_codes` (nueva)
   - ✅ `backup_codes` (nueva)
   - ✅ `security_logs` (nueva)
   - ✅ `failed_login_attempts` (nueva)
   - ✅ `user_sessions` (nueva)

3. **Ejecutar verificación:**
```sql
-- Copiar y ejecutar esto en SQL Editor para verificar
SELECT 'VERIFICACIÓN DEL SISTEMA' as status;

-- Verificar tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'verification_codes', 'backup_codes', 'security_logs');

-- Verificar funciones
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('is_admin', 'cleanup_expired_codes', 'log_security_event');

-- Estado del sistema
SELECT * FROM debug_user_system();
```

---

## 🚨 **POSIBLES ERRORES Y SOLUCIONES**

### **Error: "permission denied"**
**Solución:** Asegúrate de que eres propietario del proyecto Supabase

### **Error: "function uuid_generate_v4() does not exist"**
**Solución:** Ejecuta primero:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### **Error: "relation already exists"**
**Solución:** Las tablas ya existen, continúa con el siguiente script

### **Error de memoria/timeout**
**Solución:** Ejecuta el script por secciones más pequeñas

---

## 📊 **FUNCIONES ÚTILES DESPUÉS DE IMPLEMENTAR**

### **Ver estadísticas de seguridad:**
```sql
SELECT * FROM get_security_stats();
```

### **Detectar actividad sospechosa:**
```sql
SELECT * FROM detect_suspicious_activity();
```

### **Limpiar códigos expirados:**
```sql
SELECT cleanup_expired_codes();
```

### **Verificar que admins no están en users:**
```sql
SELECT email FROM users 
WHERE email IN ('equiz.rec@gmail.com', 'bibliowalsh25@gmail.com');
-- Debe retornar 0 resultados
```

---

## 🎯 **ORDEN DE EJECUCIÓN RECOMENDADO**

1. **PRIMERO:** `supabase_user_admin_fix.sql`
   - ✅ Configura sistema usuario/admin
   - ✅ Previene conflictos de permisos

2. **SEGUNDO:** `supabase_security_features.sql`  
   - ✅ Agrega características de seguridad
   - ✅ Crea tablas de logs y 2FA

3. **TERCERO:** Verificar con las consultas de arriba

---

## 💡 **CONSEJOS IMPORTANTES**

- ⚠️ **Haz backup** de tu base de datos antes (Supabase > Settings > Database > Backups)
- 📝 **Lee los mensajes** de éxito/error en el SQL Editor
- 🔄 **Si algo falla**, puedes ejecutar solo esa sección otra vez
- 📞 **Contacta si hay problemas** - puedo ayudarte a debuggear errores específicos

---

## ✅ **DESPUÉS DE IMPLEMENTAR**

Tu base de datos tendrá:
- 🔐 **Sistema de permisos robusto** (users vs admins)
- 🛡️ **Autenticación de dos factores**
- 📊 **Logs de seguridad completos**
- 🚨 **Detección de actividad sospechosa**
- 🔒 **Validaciones de contraseña avanzadas**
- 📧 **Sistema de verificación por email**

¡Y tu app Flutter ya está preparada para usar todo esto!