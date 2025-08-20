import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    
    // Cargar datos en cache primero para respuesta rápida
    await _loadCachedUserData();
    
    // Sin Supabase Auth, verificamos si hay usuario en cache/memoria
    if (_authService.isLoggedIn) {
      await _loadUserProfile();
    }
    
    _setLoading(false);
  }

  Future<void> _loadUserProfile() async {
    try {
      // Obtener datos del usuario actual desde AuthService
      final currentUserData = _authService.currentUser;
      if (currentUserData != null) {
        _currentUser = UserProfile.fromJson(currentUserData);
      } else {
        _currentUser = await _authService.getUserProfile();
      }
      
      // Verificar si es administrador
      if (_currentUser != null) {
        print('🔍 Verificando admin para email: ${_currentUser!.email}');
        _isAdmin = await _adminService.isAdmin(_currentUser!.email);
        print('🔍 Resultado admin: $_isAdmin para ${_currentUser!.email}');
        
        // Debug adicional para admins específicos
        if (!_isAdmin && (_currentUser!.email == 'equiz.rec@gmail.com' || _currentUser!.email == 'bibliowalsh25@gmail.com')) {
          print('🚨 ADMIN DETECTADO PERO _isAdmin ES FALSE! Email: ${_currentUser!.email}');
          // Forzar admin para emails específicos
          _isAdmin = true;
          print('🔧 Admin forzado a true para ${_currentUser!.email}');
          // Notificar cambio inmediatamente
          notifyListeners();
        }
        
        print('🎯 Estado final - isAdmin: $_isAdmin, email: ${_currentUser!.email}');
        
        // Guardar en cache para carga rápida futura
        await _cacheUserData(_currentUser!, _isAdmin);
      } else {
        print('❌ _currentUser es null, no se puede verificar admin');
        _isAdmin = false;
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error en _loadUserProfile: $e');
      _setError('Error cargando perfil: $e');
    }
  }

  // Cache methods para mejor performance
  Future<void> _cacheUserData(UserProfile user, bool isAdmin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user', jsonEncode(user.toJson()));
      await prefs.setBool('cached_is_admin', isAdmin);
      await prefs.setInt('cached_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Si falla el cache, no es crítico
      print('Error caching user data: $e');
    }
  }

  Future<void> _loadCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUser = prefs.getString('cached_user');
      final cachedIsAdmin = prefs.getBool('cached_is_admin') ?? false;
      final cachedTimestamp = prefs.getInt('cached_timestamp') ?? 0;
      
      // Solo usar cache si es reciente (menos de 1 hora)
      final isRecent = DateTime.now().millisecondsSinceEpoch - cachedTimestamp < 3600000;
      
      if (cachedUser != null && isRecent) {
        final userData = jsonDecode(cachedUser);
        _currentUser = UserProfile.fromJson(userData);
        _isAdmin = cachedIsAdmin;
        notifyListeners();
      }
    } catch (e) {
      // Si falla cargar cache, continúa normal
      print('Error loading cached user data: $e');
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
    int? age,
    double? lat,
    double? lng,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Verificar si el email es de un administrador - BLOQUEAR REGISTRO
      final isAdminEmail = await _adminService.isAdmin(email);
      if (isAdminEmail) {
        _setError('❌ Email de administrador detectado.\n\nLos administradores NO se registran como usuarios.\nUse el "Acceso de Administrador" en la pantalla de login.');
        return false;
      }
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
        print('🔄 Usuario creado directamente en tabla users...');
        
        // Esperar un poco para que el trigger/upsert se complete
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Intentar cargar perfil varias veces por si hay delay
        int attempts = 0;
        const maxAttempts = 8;
        
        while (attempts < maxAttempts && _currentUser == null) {
          attempts++;
          print('🔄 Intento $attempts de $maxAttempts cargar perfil...');
          
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          await _loadUserProfile();
          
          if (_currentUser != null) {
            print('✅ Perfil cargado exitosamente en intento $attempts');
            break;
          } else {
            print('❌ Intento $attempts falló - perfil no encontrado');
            
            // En el último intento, intentar verificar directamente en la DB
            if (attempts == maxAttempts - 1) {
              print('🔄 Último intento: verificando directamente en Supabase...');
              try {
                final directCheck = await Supabase.instance.client
                    .from('users')
                    .select()
                    .eq('id', response['user']['id'])
                    .maybeSingle();
                
                if (directCheck != null) {
                  print('✅ Usuario encontrado en verificación directa: $directCheck');
                  _currentUser = UserProfile.fromJson(directCheck);
                  break;
                } else {
                  print('❌ Usuario NO encontrado en verificación directa');
                }
              } catch (e) {
                print('❌ Error en verificación directa: $e');
              }
            }
          }
        }
        
        // Verificar que el usuario se creó correctamente en la DB
        if (_currentUser != null) {
          // Log registro exitoso
          await _analytics.logUserAction(
            action: 'user_registered',
            userId: response['user']['id'],
            details: {'role': role.name, 'city': city, 'country': country},
          );
          
          // Notificación para admin
          await _analytics.sendAdminNotification(
            title: 'Nuevo usuario registrado',
            message: 'Usuario $fullName se registró como ${role.name}',
            type: 'success',
          );
          
          return true;
        } else {
          print('❌ No se pudo cargar perfil después de $maxAttempts intentos');
          _setError('Error: Usuario creado en Auth pero no en base de datos');
          return false;
        }
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
      // Verificar si es admin intentando loguearse
      final isAdminEmail = await _adminService.isAdmin(email);
      if (isAdminEmail) {
        // Los admins no pueden loguearse como usuarios normales
        _setError('Los administradores deben usar el panel de admin. Este es el sistema de usuarios.');
        return false;
      }
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        await _loadUserProfile();
        
        // Verificar que el perfil se cargó correctamente
        if (_currentUser != null) {
          // Log login exitoso
          await _analytics.logUserAction(
            action: 'user_login',
            userId: response['user']['id'],
            details: {'email': email, 'role': _currentUser!.role.name},
          );
          
          return true;
        } else {
          _setError('Error: No se pudo cargar el perfil del usuario');
          // Intentar signOut para limpiar estado inconsistente
          try {
            await _authService.signOut();
          } catch (_) {}
          return false;
        }
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