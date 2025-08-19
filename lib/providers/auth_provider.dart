import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/auth_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/admin_service.dart';
import '../core/models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final AnalyticsService _analytics = AnalyticsService();
  final AdminService _adminService = AdminService();
  
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;

  AuthProvider(this._authService) {
    _initializeAuth();
  }

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _isAdmin;

  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    // Escuchar cambios de autenticación
    _authService.authStateChanges.listen((AuthState state) async {
      if (state.event == AuthChangeEvent.signedIn) {
        await _loadUserProfile();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });

    // Cargar usuario actual si ya está autenticado
    if (_authService.isLoggedIn) {
      await _loadUserProfile();
    }
    
    _setLoading(false);
  }

  Future<void> _loadUserProfile() async {
    try {
      _currentUser = await _authService.getUserProfile();
      
      // Verificar si es administrador
      if (_currentUser != null) {
        _isAdmin = await _adminService.isAdmin(_currentUser!.email);
      } else {
        _isAdmin = false;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Error cargando perfil: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required String phone,
    required String city,
    required String country,
    double? lat,
    double? lng,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        city: city,
        country: country,
        lat: lat,
        lng: lng,
      );

      if (response.user != null) {
        await _loadUserProfile();
        
        // Log registro exitoso
        await _analytics.logUserAction(
          action: 'user_registered',
          userId: response.user!.id,
          details: {'role': role.name, 'city': city, 'country': country},
        );
        
        // Notificación para admin
        await _analytics.sendAdminNotification(
          title: 'Nuevo usuario registrado',
          message: 'Usuario $fullName se registró como ${role.name}',
          type: 'success',
        );
        
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error en registro: $e');
      
      // Log error de registro
      await _analytics.logError(
        error: e.toString(),
        context: 'user_registration',
        details: {'email': email, 'role': role.name},
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile();
        
        // Log login exitoso
        await _analytics.logUserAction(
          action: 'user_login',
          userId: response.user!.id,
          details: {'email': email},
        );
        
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error en inicio de sesión: $e');
      
      // Log error de login
      await _analytics.logError(
        error: e.toString(),
        context: 'user_login',
        details: {'email': email},
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signInWithGoogle();

      if (response?.user != null) {
        await _loadUserProfile();
        
        // Log login exitoso con Google
        await _analytics.logUserAction(
          action: 'user_login_google',
          userId: response!.user!.id,
          details: {'provider': 'google'},
        );
        
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error en inicio de sesión con Google: $e');
      
      // Log error de login con Google
      await _analytics.logError(
        error: e.toString(),
        context: 'user_login_google',
        details: {},
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _setError('Error cerrando sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError('Error enviando recuperación: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateProfile(updates);
      await _loadUserProfile();
      return true;
    } catch (e) {
      _setError('Error actualizando perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Actualizar foto de perfil
  Future<bool> updateProfilePhoto(File imageFile) async {
    _setLoading(true);
    _clearError();

    try {
      final photoUrl = await _authService.updateProfilePhoto(imageFile);
      if (photoUrl != null) {
        await _loadUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error actualizando foto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar foto de perfil
  Future<bool> removeProfilePhoto() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.removeProfilePhoto();
      if (success) {
        await _loadUserProfile();
      }
      return success;
    } catch (e) {
      _setError('Error eliminando foto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}