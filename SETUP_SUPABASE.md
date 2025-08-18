# 🔥 Configurar Supabase para PuenteHumano

## Paso 1: Crear las tablas en Supabase

1. **Ve a tu proyecto Supabase**: https://xolnejqgdkgyivbuithr.supabase.co
2. **Haz clic en "SQL Editor"** (lado izquierdo)
3. **Copia y pega TODO el contenido** del archivo `supabase_schema.sql`
4. **Haz clic en "RUN"** para ejecutar

Esto creará:
- ✅ 8 tablas (users, libraries, trips, donations, shipments, ratings, chats, notifications)
- ✅ Funciones automáticas (generar PIN, actualizar ratings)
- ✅ Políticas de seguridad (RLS)
- ✅ Datos de ejemplo (3 bibliotecas)

## Paso 2: Verificar que funciona

```bash
cd /home/jido/puente_humano_app

# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run -d chrome
```

## Paso 3: Probar la autenticación

En la app, ve a **"Registrarse"** y crea una cuenta con:
- **Email**: test@mail.com
- **Contraseña**: 123456
- **Rol**: Donante
- **Nombre**: Tu nombre
- **Ciudad/País**: Tu ubicación

Si todo funciona bien:
1. ✅ Se creará el usuario en Supabase
2. ✅ Te llevará al dashboard
3. ✅ Podrás ver tu perfil

## Paso 4: Verificar en Supabase

1. Ve a tu proyecto Supabase
2. Haz clic en **"Table Editor"**
3. Selecciona tabla **"users"**
4. ✅ Deberías ver tu usuario registrado

## Paso 5: Usuarios de prueba (si los necesitas)

Puedes crear usuarios de prueba manualmente o usar estos:

```sql
-- Ejecutar en SQL Editor de Supabase
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, confirmation_sent_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at) VALUES 
('00000000-0000-0000-0000-000000000000', '550e8400-e29b-41d4-a716-446655440001', 'authenticated', 'authenticated', 'donante1@mail.com', '$2a$10$yourhash', NOW(), NOW(), '', '', '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{}', FALSE, NOW(), NOW(), NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL);

-- Después crear el perfil
INSERT INTO users (id, email, full_name, role, language, phone, city, country, lat, lng) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'donante1@mail.com', 'Ana Pérez', 'donante', 'es', '+54 9 11 5555-1111', 'Buenos Aires', 'Argentina', -34.6037, -58.3816);
```

## 🚨 ¿Cómo saber si Supabase funciona?

### ✅ Funcionando correctamente:
- La app se abre sin errores
- Puedes registrarte/iniciar sesión
- Ves el dashboard después del login
- En Supabase Table Editor ves los datos

### ❌ No funciona:
- Error de conexión al ejecutar la app
- Error al registrarse
- No aparecen datos en Supabase

### 🔧 Solución a errores comunes:

1. **Error de conexión**: Verifica `app_config.dart` tenga la URL y API key correctas
2. **Error de RLS**: Ejecuta todo el `supabase_schema.sql` completo
3. **Error de autenticación**: Verifica que las políticas RLS estén creadas

## 🎯 Siguientes pasos

Una vez que funciona la autenticación:
1. ✅ Crear viajes (como Transportista)
2. ✅ Crear donaciones (como Donante)  
3. ✅ Ver bibliotecas en el mapa
4. ✅ Confirmar entregas con QR/PIN