// ============================================
// CONFIGURACIÓN DE ADMINISTRADORES
// ============================================

class AdminConfig {
  // Configuración básica sin emails hardcodeados
  
  // VERIFICACIÓN DE ADMIN (basada en campo role en base de datos)
  static bool isAuthorizedAdmin(String email) {
    // Ya no verificamos emails hardcodeados
    return false;
  }

  // VALIDAR QUE UN EMAIL PUEDE REGISTRARSE
  static bool canRegisterAsUser(String email) {
    // Permitir registro de cualquier email
    return true;
  }

  // CONFIGURACIÓN PARA LOGS
  static const bool enableAdminLogs = true;
  static const String adminLogTable = 'admin_auth_logs';
}