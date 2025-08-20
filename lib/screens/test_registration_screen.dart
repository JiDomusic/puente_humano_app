import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_simple.dart';
import '../core/models/user_profile.dart';
import '../core/services/debug_service.dart';

class TestRegistrationScreen extends StatefulWidget {
  const TestRegistrationScreen({super.key});

  @override
  State<TestRegistrationScreen> createState() => _TestRegistrationScreenState();
}

class _TestRegistrationScreenState extends State<TestRegistrationScreen> {
  final DebugService _debugService = DebugService();
  bool _isLoading = false;
  String? _result;

  Future<void> _runDatabaseTest() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      print('🧪 Iniciando test de base de datos...');
      await _debugService.testUserTableInsertion();
      await _debugService.checkUserTableStructure();
      
      setState(() {
        _result = '✅ Test de base de datos EXITOSO!\nLa tabla users funciona correctamente.';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Test de base de datos FALLÓ:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFullRegistration() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final authProvider = context.read<SimpleAuthProvider>();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      print('🧪 Iniciando test de registro completo...');
      
      final success = await authProvider.signUp(
        email: 'test_$timestamp@example.com',
        password: 'test123456',
        fullName: 'Usuario Test $timestamp',
        role: UserRole.donante,
        phone: '1234567890',
        city: 'Ciudad Test',
        country: 'País Test',
        age: 25,
      );

      if (success) {
        setState(() {
          _result = '✅ REGISTRO EXITOSO!\n\n'
                   'Usuario creado: ${authProvider.currentUser?.fullName}\n'
                   'Email: ${authProvider.currentUser?.email}\n'
                   'Rol: ${authProvider.currentUser?.role.displayName}\n'
                   'ID: ${authProvider.currentUser?.id}';
        });
        
        // Cerrar sesión después del test
        await Future.delayed(const Duration(seconds: 2));
        await authProvider.signOut();
      } else {
        setState(() {
          _result = '❌ REGISTRO FALLÓ:\n${authProvider.error}';
        });
      }
    } catch (e) {
      setState(() {
        _result = '❌ ERROR EN REGISTRO:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Registro'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.bug_report,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Test del Sistema de Registro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Verificar que el registro funciona correctamente',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runDatabaseTest,
              icon: const Icon(Icons.storage),
              label: const Text('Test de Base de Datos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testFullRegistration,
              icon: const Icon(Icons.person_add),
              label: const Text('Test de Registro Completo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (_isLoading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Ejecutando test...'),
                  ],
                ),
              ),
            ],
            
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!.contains('✅') ? Colors.green[50] : Colors.red[50],
                  border: Border.all(
                    color: _result!.contains('✅') ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultado del Test:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _result!.contains('✅') ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}