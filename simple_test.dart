import 'package:supabase/supabase.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

void main() async {
  print('🧪 TEST SIMPLE DE USUARIOS EN SUPABASE');
  print('=' * 50);
  
  // Configuración de Supabase (necesitas poner tus valores reales)
  const supabaseUrl = 'https://your-project.supabase.co';
  const supabaseKey = 'your-anon-key';
  
  // Nota: Necesitas poner las credenciales reales de tu proyecto
  print('⚠️  Para ejecutar este test, necesitas:');
  print('   1. Editar simple_test.dart');
  print('   2. Poner tu URL y clave de Supabase');
  print('   3. Ejecutar con: dart run simple_test.dart');
  print('');
  
  // Crear cliente de Supabase
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  
  try {
    print('📋 TEST 1: Verificar conexión a Supabase');
    print('-' * 30);
    
    // Test básico de conexión
    final response = await supabase
        .from('users')
        .select('count')
        .count(CountOption.exact);
    
    print('✅ Conexión exitosa a Supabase');
    print('📊 Total de usuarios en tabla: ${response.count}');
    
    print('\n📋 TEST 2: Crear usuario de prueba');
    print('-' * 30);
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testUserId = 'test_$timestamp';
    final testEmail = 'test_$timestamp@example.com';
    
    // Crear hash de contraseña
    const password = 'test123456';
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);
    
    print('📝 Creando usuario: $testEmail');
    
    await supabase.from('users').insert({
      'id': testUserId,
      'email': testEmail,
      'full_name': 'Usuario Test $timestamp',
      'role': 'donante',
      'phone': '1234567890',
      'city': 'Ciudad Test',
      'country': 'País Test',
      'age': 25,
      'password_hash': passwordHash,
      'language': 'es',
      'created_at': DateTime.now().toIso8601String(),
    });
    
    print('✅ Usuario creado exitosamente!');
    
    print('\n📋 TEST 3: Verificar usuario en DB');
    print('-' * 30);
    
    final createdUser = await supabase
        .from('users')
        .select('*')
        .eq('id', testUserId)
        .single();
    
    print('✅ Usuario verificado en base de datos:');
    print('   ID: ${createdUser['id']}');
    print('   Email: ${createdUser['email']}');
    print('   Nombre: ${createdUser['full_name']}');
    print('   Rol: ${createdUser['role']}');
    print('   Teléfono: ${createdUser['phone']}');
    print('   Ciudad: ${createdUser['city']}');
    print('   País: ${createdUser['country']}');
    print('   Edad: ${createdUser['age']}');
    print('   Hash contraseña: ${createdUser['password_hash']?.substring(0, 20)}...');
    
    print('\n📋 TEST 4: Limpiar usuario de prueba');
    print('-' * 30);
    
    await supabase
        .from('users')
        .delete()
        .eq('id', testUserId);
    
    print('🗑️ Usuario de prueba eliminado');
    
    print('\n🎉 TODOS LOS TESTS EXITOSOS!');
    print('✅ La tabla users funciona correctamente');
    print('✅ Se pueden crear usuarios');
    print('✅ Se pueden consultar usuarios');
    print('✅ Se pueden eliminar usuarios');
    
  } catch (e) {
    print('❌ ERROR EN TEST: $e');
    print('');
    print('🔧 Posibles soluciones:');
    print('   1. Verificar credenciales de Supabase');
    print('   2. Verificar que existe la tabla users');
    print('   3. Verificar permisos RLS en Supabase');
    print('   4. Crear políticas de acceso público');
  }
  
  print('\n${'=' * 50}');
}

String _generateSalt() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
}

String _hashPassword(String password, String salt) {
  final bytes = utf8.encode(password + salt);
  final digest = sha256.convert(bytes);
  return '$salt:${digest.toString()}';
}