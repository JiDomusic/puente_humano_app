-- ============================================
-- SCRIPT PARA LIMPIAR DATOS DE PRUEBA
-- ============================================

-- 1. ELIMINAR USUARIOS DE PRUEBA
-- (Mantener solo usuarios reales - revisar antes de ejecutar)

DELETE FROM users WHERE 
    email ILIKE '%test%' OR 
    email ILIKE '%prueba%' OR 
    full_name ILIKE '%test%' OR
    full_name ILIKE '%prueba%' OR
    full_name = 'Usuario Demo';

-- 2. ELIMINAR BIBLIOTECAS DE PRUEBA
-- (Mantener solo bibliotecas reales)

DELETE FROM libraries WHERE 
    name ILIKE '%test%' OR 
    name ILIKE '%prueba%' OR
    name ILIKE '%demo%' OR
    library_code ILIKE 'TEST-%' OR
    contact_email ILIKE '%test%' OR
    contact_email ILIKE '%demo%';

-- 3. LIMPIAR DONATIONS HUÉRFANAS
-- (Eliminar donaciones de usuarios/bibliotecas eliminados)

DELETE FROM donations WHERE 
    donor_id NOT IN (SELECT id FROM users) OR
    target_library_id NOT IN (SELECT id FROM libraries);

-- 4. LIMPIAR TRIPS HUÉRFANOS
-- (Eliminar viajes de usuarios eliminados)

DELETE FROM trips WHERE 
    traveler_id NOT IN (SELECT id FROM users);

-- 5. LIMPIAR SHIPMENTS HUÉRFANOS
-- (Eliminar envíos con referencias inválidas)

DELETE FROM shipments WHERE 
    donor_id NOT IN (SELECT id FROM users) OR
    traveler_id NOT IN (SELECT id FROM users) OR
    target_library_id NOT IN (SELECT id FROM libraries) OR
    donation_id NOT IN (SELECT id FROM donations) OR
    trip_id NOT IN (SELECT id FROM trips);

-- 6. LIMPIAR RATINGS HUÉRFANOS

DELETE FROM ratings WHERE 
    about_user_id NOT IN (SELECT id FROM users) OR
    by_user_id NOT IN (SELECT id FROM users);

-- 7. LIMPIAR NOTIFICATIONS HUÉRFANAS

DELETE FROM notifications WHERE 
    user_id NOT IN (SELECT id FROM users);

-- 8. LIMPIAR CHATS HUÉRFANOS

DELETE FROM chats WHERE 
    sender_id NOT IN (SELECT id::TEXT FROM users) OR
    receiver_id NOT IN (SELECT id::TEXT FROM users);

-- 9. RESETEAR CONTADORES
-- Actualizar contadores después de limpiar datos

UPDATE users SET 
    ratings_count = COALESCE((
        SELECT COUNT(*) 
        FROM ratings 
        WHERE about_user_id = users.id
    ), 0),
    average_rating = COALESCE((
        SELECT AVG(stars) 
        FROM ratings 
        WHERE about_user_id = users.id
    ), 0);

UPDATE libraries SET 
    received_count = COALESCE((
        SELECT COUNT(*) 
        FROM shipments 
        WHERE target_library_id = libraries.id 
        AND status = 'entregado'
    ), 0);

-- 10. VERIFICACIÓN POST-LIMPIEZA
-- Mostrar resumen de datos limpios

SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'libraries', COUNT(*) FROM libraries
UNION ALL
SELECT 'donations', COUNT(*) FROM donations
UNION ALL
SELECT 'trips', COUNT(*) FROM trips
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'chats', COUNT(*) FROM chats;