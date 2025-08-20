import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/config/app_config.dart';
import 'lib/core/services/debug_service.dart';
import 'lib/core/services/auth_service.dart';
import 'lib/core/models/user_profile.dart';

void main() async {
  print('🧪 INICIANDO TEST DE USUARIOS');
  print('=' * 50);
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  final debugService = DebugService();
  final authService = AuthService();
  
  print('\n📋 TEST 1: Verificar tabla users');
  print('-' * 30);
  
  try {
    await debugService.checkUserTableStructure();
    await debugService.testUserTableInsertion();
    print('✅ Test de tabla users: EXITOSO');
  } catch (e) {
    print('❌ Test de tabla users: FALLÓ - $e');
    return;
  }
  
  print('\n📋 TEST 2: Crear usuario con AuthService');
  print('-' * 30);
  
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'test_$timestamp@example.com';
    
    print('📝 Creando usuario: $testEmail');
    
    final result = await authService.signUp(
      email: testEmail,
      password: 'test123456',
      fullName: 'Usuario Test $timestamp',
      role: UserRole.donante,
      phone: '1234567890',
      city: 'Ciudad Test',
      country: 'País Test',
      age: 25,
    );
    
    if (result['success'] == true) {
      print('✅ Usuario creado exitosamente!');
      print('   ID: ${result['user']['id']}');
      print('   Email: ${result['user']['email']}');
      print('   Nombre: ${result['user']['full_name']}');
      print('   Rol: ${result['user']['role']}');
      
      // Verificar que el usuario existe en la DB
      final supabase = Supabase.instance.client;
      final userCheck = await supabase
          .from('users')
          .select('*')
          .eq('email', testEmail)
          .single();
      
      print('✅ Usuario verificado en base de datos:');
      print('   Todos los campos: ${userCheck.keys.join(', ')}');
      
      // Limpiar usuario de prueba
      await supabase
          .from('users')
          .delete()
          .eq('id', result['user']['id']);
      
      print('🗑️ Usuario de prueba eliminado');
      
    } else {
      print('❌ Error creando usuario: $result');
    }
    
  } catch (e) {
    print('❌ Test de AuthService: FALLÓ - $e');
  }
  
  print('\n📋 TEST 3: Verificar estructura final');
  print('-' * 30);
  
  try {
    final supabase = Supabase.instance.client;
    
    // Contar usuarios existentes
    final count = await supabase
        .from('users')
        .select('id')
        .count();
    
    print('📊 Total de usuarios en la tabla: $count');
    
    // Mostrar algunos usuarios ejemplo (sin passwords)
    final sampleUsers = await supabase
        .from('users')
        .select('id, email, full_name, role, created_at')
        .limit(3);
    
    if (sampleUsers.isNotEmpty) {
      print('👥 Usuarios ejemplo:');
      for (final user in sampleUsers) {
        print('   • ${user['full_name']} (${user['role']}) - ${user['email']}');
      }
    } else {
      print('ℹ️  No hay usuarios en la tabla aún');
    }
    
  } catch (e) {
    print('❌ Error verificando estructura: $e');
  }
  
  print('\n🎉 TEST COMPLETADO');
  print('=' * 50);
}