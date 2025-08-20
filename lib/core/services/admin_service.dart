import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Verificar si un usuario es administrador
  Future<bool> isAdmin(String email) async {
    try {
      final adminUser = await _supabase
          .from('admin_users')
          .select('is_active')
          .eq('email', email.toLowerCase())
          .maybeSingle();
      
      return adminUser != null && adminUser['is_active'] == true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verificando admin: $e');
      }
      return false;
    }
  }

  // Autenticar administrador
  Future<bool> authenticateAdmin(String email, String password) async {
    try {
      final adminUser = await _supabase
          .from('admin_users')
          .select('*')
          .eq('email', email.toLowerCase())
          .eq('is_active', true)
          .maybeSingle();
      
      if (adminUser != null) {
        // Por ahora, contraseña simplificada para testing
        // En producción deberías usar hash de contraseña
        if (password == 'admin123') {
          // Actualizar último login
          await _supabase
              .from('admin_users')
              .update({'last_login': DateTime.now().toIso8601String()})
              .eq('email', email.toLowerCase());
              
          if (kDebugMode) {
            debugPrint('Admin autenticado: ${adminUser['email']}');
          }
          return true;
        }
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error autenticando admin: $e');
      }
      return false;
    }
  }

  // Obtener información del admin
  Future<Map<String, dynamic>?> getAdminInfo(String email) async {
    try {
      final adminUser = await _supabase
          .from('admin_users')
          .select('*')
          .eq('email', email.toLowerCase())
          .eq('is_active', true)
          .maybeSingle();
      
      return adminUser;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error obteniendo info admin: $e');
      }
      return null;
    }
  }

  // Obtener estadísticas del admin
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final totalUsers = await _supabase
          .from('users')
          .select('id')
          .count();
      
      final donantes = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'donante')
          .count();
      
      final transportistas = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'transportista')
          .count();
      
      final bibliotecas = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'biblioteca')
          .count();

      return {
        'total_users': totalUsers,
        'donantes': donantes,
        'transportistas': transportistas,
        'bibliotecas': bibliotecas,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error obteniendo estadísticas: $e');
      }
      return {};
    }
  }

  // Obtener todos los usuarios
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final users = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(users);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error obteniendo usuarios: $e');
      }
      return [];
    }
  }

  // Desactivar usuario
  Future<bool> deactivateUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({'is_active': false})
          .eq('id', userId);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error desactivando usuario: $e');
      }
      return false;
    }
  }

  // Eliminar usuario
  Future<bool> deleteUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error eliminando usuario: $e');
      }
      return false;
    }
  }
}