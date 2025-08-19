import 'package:flutter/foundation.dart';
import '../core/services/admin_service.dart';

class AdminAuthProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  String? _currentAdminEmail;
  
  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentAdminEmail => _currentAdminEmail;
  
  // Login para administradores (completamente separado del sistema de usuarios)
  Future<bool> adminLogin({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Verificar si es admin autorizado
      final isAdmin = await _adminService.isAdmin(email);
      if (!isAdmin) {
        _setError('Email no autorizado como administrador');
        return false;
      }
      
      // Verificar contraseña (simplificado para demo)
      if (password == 'admin123') {
        _currentAdminEmail = email;
        _isLoggedIn = true;
        
        print('✅ Admin login exitoso: $email');
        notifyListeners();
        return true;
      } else {
        _setError('Contraseña incorrecta');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Logout admin
  Future<void> adminLogout() async {
    _isLoggedIn = false;
    _currentAdminEmail = null;
    _clearError();
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}