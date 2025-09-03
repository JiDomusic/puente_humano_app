import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/user_profile.dart';
import '../core/services/auth_service.dart';
import '../core/services/analytics_service.dart';

class SimpleAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AnalyticsService _analytics = AnalyticsService();
  final SupabaseClient _supabase = Supabase.instance.client;

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _currentUser?.role.name == 'admin';

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // REGISTRO SIMPLIFICADO
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required String phone,
    required String city,
    required String country,
    int? age,
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
        age: age,
        lat: lat,
        lng: lng,
      );

      if (response['success'] == true) {
        print('✅ Usuario creado exitosamente en tabla users');
        
        // Cargar el perfil del usuario recién creado
        final userId = response['user']['id'];
        await _loadUserById(userId);
        
        if (_currentUser != null) {
          // Guardar sesión
          await _saveSession(userId);
          
          // Log exitoso
          await _analytics.logUserAction(
            action: 'user_registered',
            userId: _currentUser!.id,
            details: {
              'role': role.name,
              'city': city,
              'country': country,
              'registration_success': true,
            },
          );
          
          print('🎉 Registro exitoso para ${_currentUser!.fullName} (${_currentUser!.role.displayName})');
          return true;
        } else {
          _setError('Error cargando el perfil del usuario');
          return false;
        }
      } else {
        _setError('Error creando la cuenta');
        return false;
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      _setError('Error en registro: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // LOGIN SIMPLIFICADO
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

      if (response['success'] == true) {
        print('✅ Login exitoso');
        
        final userData = response['user'];
        _currentUser = UserProfile.fromJson(userData);
        
        // Sincronizar con AuthService
        _authService.setCurrentUserData(userData);
        
        // Guardar sesión
        await _saveSession(_currentUser!.id);
        
        // Log exitoso
        await _analytics.logUserAction(
          action: 'user_login',
          userId: _currentUser!.id,
          details: {'role': _currentUser!.role.name},
        );
        
        return true;
      } else {
        _setError('Credenciales incorrectas');
        return false;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      _setError('Error al iniciar sesión: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CARGAR USUARIO POR ID
  Future<void> _loadUserById(String userId) async {
    if (userId.isEmpty) {
      print('❌ userId is empty, cannot load user');
      return;
    }
    
    try {
      final userProfile = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();
      
      if (userProfile != null && userProfile.isNotEmpty) {
        _currentUser = UserProfile.fromJson(userProfile);
        
        // IMPORTANTE: Sincronizar con AuthService
        _authService.setCurrentUserData(userProfile);
        
        print('✅ Perfil cargado: ${_currentUser!.fullName}');
      } else {
        print('❌ Perfil vacío o nulo para userId: $userId');
        _currentUser = null;
        _authService.setCurrentUserData(null);
      }
    } catch (e) {
      print('❌ Error cargando perfil: $e');
      _currentUser = null;
      _authService.setCurrentUserData(null);
    }
  }

  // CERRAR SESIÓN
  Future<void> signOut() async {
    _currentUser = null;
    _authService.setCurrentUserData(null);
    await _clearSession();
    notifyListeners();
  }

  // GUARDAR SESIÓN
  Future<void> _saveSession(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
    } catch (e) {
      print('Error guardando sesión: $e');
    }
  }

  // CARGAR SESIÓN
  Future<void> loadSession() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null && userId.isNotEmpty && userId.trim().isNotEmpty) {
        await _loadUserById(userId);
      } else {
        print('No hay sesión guardada o userId es inválido');
      }
    } catch (e) {
      print('Error cargando sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  // LIMPIAR SESIÓN
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
    } catch (e) {
      print('Error limpiando sesión: $e');
    }
  }

  // RESETEAR CONTRASEÑA
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      print('❌ Error en resetPassword: $e');
      _setError('Error al resetear contraseña: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ACTUALIZAR FOTO DE PERFIL
  Future<bool> updateProfilePhoto(dynamic imageFile) async {
    _setLoading(true);
    _clearError();

    try {
      final newPhotoUrl = await _authService.updateProfilePhoto(imageFile);
      if (newPhotoUrl != null && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(photo: newPhotoUrl);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error en updateProfilePhoto: $e');
      _setError('Error actualizando foto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // REMOVER FOTO DE PERFIL
  Future<bool> removeProfilePhoto() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.removeProfilePhoto();
      if (success && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(photo: null);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error en removeProfilePhoto: $e');
      _setError('Error removiendo foto: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ACTUALIZAR PERFIL
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateProfile(updates);
      
      // Recargar el perfil del usuario
      if (_currentUser != null) {
        await _loadUserById(_currentUser!.id);
      }
      
      return true;
    } catch (e) {
      print('❌ Error en updateProfile: $e');
      _setError('Error actualizando perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}