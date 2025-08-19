import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../config/admin_config.dart';
import 'storage_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();
  
  // Inicializar storage de forma silenciosa
  AuthService() {
    _initializeStorageSilently();
  }
  
  Future<void> _initializeStorageSilently() async {
    // Inicializar storage sin bloquear la app si falla
    try {
      await _storageService.createAvatarsBucketIfNotExists();
    } catch (e) {
      // Silenciar errores de storage para no afectar la funcionalidad principal
      // print('Storage initialization failed silently: $e');
    }
  }

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Registro con email/password - SOLO USUARIOS REGULARES
  Future<AuthResponse> signUp({
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
    // BLOQUEAR REGISTRO DE ADMINS
    if (!AdminConfig.canRegisterAsUser(email)) {
      throw Exception(AdminConfig.adminBlockMessage);
    }

    // VALIDAR QUE EL ROL NO SEA ADMIN
    if (role.name == 'admin') {
      throw Exception('❌ El rol "admin" no está permitido para usuarios regulares.');
    }

    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.name,
        'phone': phone,
        'city': city,
        'country': country,
        'age': age,
        'lat': lat,
        'lng': lng,
        'language': 'es',
      },
    );

    // El trigger automático se encarga de crear el perfil en la tabla users
    if (response.user != null) {
      print('✅ Usuario registrado exitosamente: ${response.user!.email}');
      print('🔄 El trigger automático creará el perfil en la tabla users');
    }

    return response;
  }

  // Inicio de sesión - SOLO USUARIOS REGULARES
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    // BLOQUEAR LOGIN DE ADMINS COMO USUARIOS REGULARES
    if (AdminConfig.isAuthorizedAdmin(email)) {
      throw Exception(AdminConfig.adminLoginBlockMessage);
    }

    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }


  // Cerrar sesión
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Recuperar contraseña
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }


  // Obtener perfil de usuario con mejor manejo de errores
  Future<UserProfile?> getUserProfile([String? userId]) async {
    final id = userId ?? currentUser?.id;
    if (id == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle(); // Usa maybeSingle en lugar de single para evitar excepciones

      if (response == null) {
        print('No se encontró perfil para usuario: $id');
        return null;
      }

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error obteniendo perfil de usuario: $e');
      // Si es un error de red, podríamos implementar retry aquí
      rethrow;
    }
  }

  // Actualizar perfil
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (currentUser == null) throw Exception('Usuario no autenticado');
    
    await _supabase
        .from('users')
        .update(updates)
        .eq('id', currentUser!.id);
  }

  // Actualizar foto de perfil
  Future<String?> updateProfilePhoto(File imageFile) async {
    if (currentUser == null) throw Exception('Usuario no autenticado');
    
    try {
      // Obtener perfil actual para eliminar foto anterior si existe
      final currentProfile = await getUserProfile();
      
      // Subir nueva foto
      final newPhotoUrl = await _storageService.uploadProfilePhoto(
        currentUser!.id, 
        imageFile
      );
      
      if (newPhotoUrl != null) {
        // Actualizar URL en la base de datos
        await updateProfile({'photo': newPhotoUrl});
        
        // Eliminar foto anterior si existe
        if (currentProfile?.photo != null) {
          await _storageService.deleteProfilePhoto(currentProfile!.photo!);
        }
        
        return newPhotoUrl;
      }
      
      return null;
    } catch (e) {
      print('Error en updateProfilePhoto: $e');
      // Devolver null en lugar de lanzar excepción
      return null;
    }
  }

  // Eliminar foto de perfil
  Future<bool> removeProfilePhoto() async {
    if (currentUser == null) throw Exception('Usuario no autenticado');
    
    try {
      final currentProfile = await getUserProfile();
      
      if (currentProfile?.photo != null) {
        // Eliminar de Storage
        final deleted = await _storageService.deleteProfilePhoto(currentProfile!.photo!);
        
        if (deleted) {
          // Actualizar base de datos
          await updateProfile({'photo': null});
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error en removeProfilePhoto: $e');
      return false;
    }
  }
}