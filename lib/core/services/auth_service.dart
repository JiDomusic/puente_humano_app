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
    try {
      await _storageService.createAvatarsBucketIfNotExists();
    } catch (e) {
      print('Warning: Could not create avatars bucket: $e');
      // No lanzar error, continuar sin storage de avatars
    }
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
      try {
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
        print('✅ Perfil creado exitosamente en AuthService');
      } catch (e) {
        print('❌ Error creando perfil en AuthService: $e');
        // Importante: NO lanzar error aquí, ya que el usuario ya está en Auth
      }
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

  // Crear perfil de usuario con manejo mejorado de errores y triggers
  Future<void> _createUserProfile(User user, Map<String, dynamic> profileData) async {
    print('🔄 Creando/actualizando perfil para usuario: ${user.email} con ID: ${user.id}');
    
    try {
      // Esperar un poco para que el trigger de auth.users se ejecute
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verificar si el usuario ya existe en la tabla (trigger automático)
      final existingUser = await _supabase
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      
      if (existingUser != null) {
        print('✅ Usuario ya existe en tabla users (creado por trigger)');
        
        // Solo actualizar los campos que no están en el trigger
        final updateData = <String, dynamic>{};
        if (profileData['lat'] != null) updateData['lat'] = profileData['lat'];
        if (profileData['lng'] != null) updateData['lng'] = profileData['lng'];
        
        if (updateData.isNotEmpty) {
          await _supabase
              .from('users')
              .update(updateData)
              .eq('id', user.id);
          print('✅ Datos adicionales actualizados (lat/lng)');
        }
        return;
      }
      
      // Si no existe, crear manualmente (fallback)
      print('⚠️ Usuario no creado por trigger, creando manualmente...');
      final dataToInsert = {
        'id': user.id,
        'email': user.email,
        'created_at': DateTime.now().toIso8601String(),
        ...profileData,
      };
      
      final result = await _supabase
          .from('users')
          .upsert(dataToInsert, onConflict: 'id')
          .select();
      
      print('✅ Perfil creado manualmente: $result');
      
    } catch (e) {
      print('❌ Error en _createUserProfile: $e');
      
      // Intentar una vez más con datos mínimos
      try {
        print('🔄 Reintentando con datos mínimos...');
        await _supabase
            .from('users')
            .upsert({
              'id': user.id,
              'email': user.email ?? '',
              'full_name': profileData['full_name'] ?? '',
              'role': profileData['role'] ?? 'donante',
              'phone': profileData['phone'] ?? '',
              'city': profileData['city'] ?? '',
              'country': profileData['country'] ?? '',
              'language': 'es',
            }, onConflict: 'id');
        
        print('✅ Perfil creado con datos mínimos en segundo intento');
      } catch (retryError) {
        print('❌ Error en segundo intento: $retryError');
        throw Exception('Error guardando perfil después de reintentos: $retryError');
      }
    }
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