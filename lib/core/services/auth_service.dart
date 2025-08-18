import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();
  
  // Inicializar storage al crear la instancia
  AuthService() {
    _initializeStorage();
  }
  
  Future<void> _initializeStorage() async {
    await _storageService.createAvatarsBucketIfNotExists();
  }

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Registro con email/password
  Future<AuthResponse> signUp({
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
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.name,
        'phone': phone,
        'city': city,
        'country': country,
        'lat': lat,
        'lng': lng,
      },
    );

    if (response.user != null) {
      // Crear perfil en la tabla users
      await _createUserProfile(response.user!, {
        'full_name': fullName,
        'role': role.name,
        'phone': phone,
        'city': city,
        'country': country,
        'lat': lat,
        'lng': lng,
        'language': 'es',
      });
    }

    return response;
  }

  // Inicio de sesión
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
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

  // Crear perfil de usuario
  Future<void> _createUserProfile(User user, Map<String, dynamic> profileData) async {
    await _supabase.from('users').insert({
      'id': user.id,
      'email': user.email,
      'created_at': DateTime.now().toIso8601String(),
      ...profileData,
    });
  }

  // Obtener perfil de usuario
  Future<UserProfile?> getUserProfile([String? userId]) async {
    final id = userId ?? currentUser?.id;
    if (id == null) return null;

    final response = await _supabase
        .from('users')
        .select()
        .eq('id', id)
        .single();

    return UserProfile.fromJson(response);
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
  }

  // Eliminar foto de perfil
  Future<bool> removeProfilePhoto() async {
    if (currentUser == null) throw Exception('Usuario no autenticado');
    
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
  }
}