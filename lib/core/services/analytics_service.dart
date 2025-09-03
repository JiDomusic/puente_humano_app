import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _tablesExist = true; // Flag para evitar logs repetitivos
  
  // Log de acciones de usuarios
  Future<void> logUserAction({
    required String action,
    required String userId,
    Map<String, dynamic>? details,
  }) async {
    if (!_tablesExist) return; // Skip si ya sabemos que no existen las tablas
    
    try {
      await _supabase.from('user_logs').insert({
        'user_id': userId,
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
        'ip_address': 'web', // En web no se puede obtener IP fácilmente
      });
    } catch (e) {
      if (e.toString().contains('PGRST205') || e.toString().contains('404')) {
        _tablesExist = false;
        // Silenciar mensaje para producción - las tablas de analytics son opcionales
      } else {
        print('Error logging user action: $e');
      }
    }
  }
  
  // Log de errores
  Future<void> logError({
    required String error,
    required String context,
    String? userId,
    Map<String, dynamic>? details,
  }) async {
    if (!_tablesExist) return; // Skip si ya sabemos que no existen las tablas
    
    try {
      await _supabase.from('error_logs').insert({
        'user_id': userId,
        'error': error,
        'context': context,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (e.toString().contains('PGRST205') || e.toString().contains('404')) {
        _tablesExist = false;
        // Silenciar mensaje para producción - las tablas de analytics son opcionales
      } else {
        print('Error logging error: $e');
      }
    }
  }
  
  // Estadísticas de uso
  Future<Map<String, dynamic>> getUsageStats() async {
    try {
      // Usuarios por día
      final usersToday = await _supabase
          .from('users')
          .select('id')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 1)).toIso8601String())
          .count();
      
      // Usuarios por rol
      final usersByRole = await _supabase
          .from('users')
          .select('role');
      
      // Acciones recientes (solo si existen las tablas)
      List<Map<String, dynamic>> recentActions = [];
      try {
        recentActions = await _supabase
            .from('user_logs')
            .select('action, timestamp')
            .order('timestamp', ascending: false)
            .limit(100);
      } catch (e) {
        print('User logs table might not exist yet: $e');
      }
      
      return {
        'users_today': usersToday.count,
        'total_users': usersByRole.length,
        'users_by_role': _groupByRole(usersByRole),
        'recent_actions': recentActions,
      };
    } catch (e) {
      print('Error getting usage stats: $e');
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
  
  // Notificaciones para admin
  Future<void> sendAdminNotification({
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      await _supabase.from('admin_notifications').insert({
        'title': title,
        'message': message,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      });
    } catch (e) {
      print('Error sending admin notification: $e');
    }
  }
}