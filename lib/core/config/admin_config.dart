// ============================================
// CONFIGURACIÓN DE ADMINISTRADORES
// ============================================

class AdminConfig {
  // EMAILS AUTORIZADOS COMO ADMINISTRADORES
  // ⚠️ IMPORTANTE: Solo estos 2 emails pueden ser admins
  static const List<String> authorizedAdminEmails = [
    'equiz.rec@gmail.com',
    'bibliowalsh25@gmail.com',
  ];

  // CONTRASEÑA DE ADMIN (temporal - cambiar por sistema más seguro)
  static const String adminPassword = 'admin123';

  // VERIFICACIÓN RÁPIDA DE ADMIN
  static bool isAuthorizedAdmin(String email) {
    return authorizedAdminEmails.contains(email.toLowerCase());
  }

  // OBTENER EMAILS COMO SET PARA BÚSQUEDAS RÁPIDAS
  static Set<String> get adminEmailsSet => authorizedAdminEmails.toSet();

  // VALIDAR QUE UN EMAIL NO ES ADMIN (para registro de usuarios)
  static bool canRegisterAsUser(String email) {
    return !isAuthorizedAdmin(email);
  }

  // MENSAJE DE ERROR ESTÁNDAR PARA ADMINS
  static const String adminBlockMessage = 
      '❌ Email de administrador detectado.\n\n'
      'Los administradores NO se registran como usuarios.\n'
      'Use el panel de administración.';

  // MENSAJE DE ERROR PARA LOGIN ADMIN COMO USER
  static const String adminLoginBlockMessage = 
      '❌ Los administradores deben usar el panel de administración.\n\n'
      'Este sistema es solo para usuarios regulares.';

  // CONFIGURACIÓN PARA LOGS
  static const bool enableAdminLogs = true;
  static const String adminLogTable = 'admin_auth_logs';
}