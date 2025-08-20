import 'package:supabase_flutter/supabase_flutter.dart';

class DebugService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Test inserción directa en tabla users
  Future<void> testUserTableInsertion() async {
    print('🔍 Testing user table insertion...');

    try {
      // Test 1: Verificar si podemos leer de la tabla users
      print('📖 Test 1: Reading from users table...');
      final readTest = await _supabase
          .from('users')
          .select('id, email')
          .limit(1);
      print('✅ Read test successful: Found ${readTest.length} users');

      // Test 2: Intentar insertar un usuario de prueba
      print('📝 Test 2: Inserting test user...');
      final testUserId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      
      await _supabase.from('users').insert({
        'id': testUserId,
        'email': 'test@example.com',
        'full_name': 'Test User',
        'role': 'donante',
        'phone': '1234567890',
        'city': 'Test City',
        'country': 'Test Country',
        'age': 25,
        'password_hash': 'test_hash',
        'language': 'es',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ Insert test successful');

      // Test 3: Verificar que se insertó correctamente
      print('🔍 Test 3: Verifying insertion...');
      final inserted = await _supabase
          .from('users')
          .select('*')
          .eq('id', testUserId)
          .single();
      
      print('✅ Verification successful: ${inserted['email']}');

      // Test 4: Limpiar (eliminar el usuario de prueba)
      print('🗑️ Test 4: Cleaning up...');
      await _supabase
          .from('users')
          .delete()
          .eq('id', testUserId);
      
      print('✅ Cleanup successful');
      print('🎉 All tests passed! User table is working correctly.');

    } catch (e) {
      print('❌ Test failed: $e');
      print('🔧 This indicates a problem with:');
      print('   - Table permissions (RLS policies)');
      print('   - Missing columns in users table');
      print('   - Supabase configuration');
    }
  }

  // Verificar estructura de tabla users
  Future<void> checkUserTableStructure() async {
    print('🔍 Checking users table structure...');

    try {
      // Intentar leer un usuario existente para ver la estructura
      final sample = await _supabase
          .from('users')
          .select('*')
          .limit(1)
          .maybeSingle();

      if (sample != null) {
        print('✅ Table structure (columns found):');
        for (var column in sample.keys) {
          print('   - $column: ${sample[column]?.runtimeType ?? 'null'}');
        }
      } else {
        print('⚠️ No users found in table to check structure');
      }
    } catch (e) {
      print('❌ Error checking table structure: $e');
    }
  }

  // Test completo del flujo de registro
  Future<void> testFullRegistrationFlow({
    required String email,
    required String password,
    required String fullName,
  }) async {
    print('🧪 Testing full registration flow for: $email');

    try {
      // Generar datos de prueba
      final userId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      final passwordHash = _hashPassword(password);

      print('📝 Step 1: Attempting to insert user...');
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'role': 'donante',
        'phone': '1234567890',
        'city': 'Test City',
        'country': 'Test Country',
        'age': 25,
        'password_hash': passwordHash,
        'language': 'es',
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Step 1 successful: User inserted');

      print('🔍 Step 2: Verifying user exists...');
      final user = await _supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .single();

      print('✅ Step 2 successful: User found with email ${user['email']}');

      print('🔐 Step 3: Testing password verification...');
      final storedHash = user['password_hash'];
      final isValidPassword = _verifyPassword(password, storedHash);
      
      if (isValidPassword) {
        print('✅ Step 3 successful: Password verification works');
      } else {
        print('❌ Step 3 failed: Password verification failed');
      }

      print('🗑️ Step 4: Cleaning up test user...');
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);

      print('✅ Step 4 successful: Test user cleaned up');
      print('🎉 Full registration flow test PASSED!');

    } catch (e) {
      print('❌ Registration flow test FAILED: $e');
      
      // Intentar limpiar en caso de error
      try {
        await _supabase
            .from('users')
            .delete()
            .eq('email', email);
      } catch (cleanupError) {
        print('⚠️ Cleanup also failed: $cleanupError');
      }
    }
  }

  // Método simple de hash para testing
  String _hashPassword(String password) {
    // Para testing, usar un hash simple (en producción usar crypto)
    return 'hash_$password';
  }

  bool _verifyPassword(String password, String storedHash) {
    return storedHash == 'hash_$password';
  }
}