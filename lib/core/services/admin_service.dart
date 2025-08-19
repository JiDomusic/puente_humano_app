import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Lista de emails de administradores autorizados (hardcoded como backup)
  static const List<String> _authorizedAdmins = [
    'equiz.rec@gmail.com',
    'bibliowalsh25@gmail.com',
  ];
  
  // Verificar si un usuario es administrador
  Future<bool> isAdmin(String email) async {
    final emailLower = email.toLowerCase();
    print('🔍 AdminService.isAdmin() verificando: $emailLower');
    
    try {
      // Primero verificar en la lista hardcoded (más rápido y confiable)
      if (_authorizedAdmins.contains(emailLower)) {
        print('✅ Usuario encontrado en lista hardcoded de admins');
        
        // Intentar actualizar último login en la DB si existe
        try {
          await _updateLastLogin(email);
        } catch (e) {
          print('⚠️ No se pudo actualizar último login: $e');
        }
        
        return true;
      }
      
      // Verificar en la base de datos como backup
      print('🔍 Verificando en base de datos admin_users...');
      final result = await _supabase
          .from('admin_users')
          .select('id, is_active')
          .eq('email', emailLower)
          .maybeSingle();
      
      print('🔍 Resultado de DB admin_users: $result');
      
      if (result != null && result['is_active'] == true) {
        print('✅ Usuario encontrado como admin en DB');
        await _updateLastLogin(email);
        return true;
      }
      
      print('❌ Usuario NO es admin - no encontrado en lista ni DB');
      return false;
      
    } catch (e) {
      print('❌ Error verificando admin en DB: $e');
      // En caso de error de DB, usar lista hardcoded como fallback final
      final isAdminFallback = _authorizedAdmins.contains(emailLower);
      print('🔄 Fallback a lista hardcoded: $isAdminFallback');
      return isAdminFallback;
    }
  }
  
  // Actualizar último login del admin
  Future<void> _updateLastLogin(String email) async {
    try {
      await _supabase
          .from('admin_users')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('email', email.toLowerCase());
    } catch (e) {
      print('Error actualizando último login: $e');
    }
  }
  
  // Obtener estadísticas completas para administradores
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      // Usuarios totales
      final totalUsers = await _supabase
          .from('users')
          .select('id')
          .count();
      
      // Usuarios por día (últimos 7 días)
      final usersThisWeek = await _supabase
          .from('users')
          .select('created_at')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String());
      
      // Usuarios por rol
      final usersByRole = await _supabase
          .from('users')
          .select('role');
      
      // Actividad reciente (si existe la tabla)
      List<Map<String, dynamic>> recentActivity = [];
      try {
        recentActivity = await _supabase
            .from('user_logs')
            .select('action, timestamp, user_id, details')
            .order('timestamp', ascending: false)
            .limit(50);
      } catch (e) {
        print('Tabla user_logs no existe aún: $e');
      }
      
      // Errores recientes
      List<Map<String, dynamic>> recentErrors = [];
      try {
        recentErrors = await _supabase
            .from('error_logs')
            .select('error, context, timestamp, resolved')
            .eq('resolved', false)
            .order('timestamp', ascending: false)
            .limit(20);
      } catch (e) {
        print('Tabla error_logs no existe aún: $e');
      }
      
      return {
        'total_users': totalUsers,
        'users_this_week': usersThisWeek.length,
        'users_by_role': _groupByRole(usersByRole),
        'recent_activity': recentActivity,
        'recent_errors': recentErrors,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error obteniendo estadísticas de admin: $e');
      return {};
    }
  }
  
  Map<String, int> _groupByRole(List<Map<String, dynamic>> users) {
    final Map<String, int> roleCount = {
      'donante': 0,
      'transportista': 0,
      'biblioteca': 0,
    };
    
    for (final user in users) {
      final role = user['role'] as String?;
      if (role != null && roleCount.containsKey(role)) {
        roleCount[role] = roleCount[role]! + 1;
      }
    }
    
    return roleCount;
  }
  
  // Eliminar usuario (solo para administradores)
  Future<bool> deleteUser(String userId) async {
    try {
      // Eliminar de auth de Supabase
      await _supabase.auth.admin.deleteUser(userId);
      
      // La eliminación en cascade debería eliminar de la tabla users también
      return true;
    } catch (e) {
      print('Error eliminando usuario: $e');
      return false;
    }
  }
  
  // Desactivar usuario temporalmente
  Future<bool> deactivateUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({'is_active': false})
          .eq('id', userId);
      
      return true;
    } catch (e) {
      print('Error desactivando usuario: $e');
      return false;
    }
  }
  
  // Obtener lista de usuarios para administración
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return await _supabase
          .from('users')
          .select('id, email, full_name, role, city, country, created_at, average_rating')
          .order('created_at', ascending: false);
    } catch (e) {
      print('Error obteniendo usuarios: $e');
      return [];
    }
  }
}