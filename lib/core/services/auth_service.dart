import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../models/user_profile.dart';
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

  // Registro usando Supabase Auth + tabla users con referencia
  Future<Map<String, dynamic>> signUp({
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
    try {
      print('🔄 Iniciando registro con Supabase Auth...');
      
      // 1. Crear usuario en Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email.toLowerCase(),
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error creando usuario en Auth');
      }

      final authUser = authResponse.user!;
      print('✅ Usuario creado en Auth: ${authUser.id}');

      // 2. Crear perfil en tabla users (referencia a auth.users)
      await _supabase.from('users').insert({
        'id': authUser.id, // Usar el ID de auth.users
        'email': email.toLowerCase(),
        'full_name': fullName,
        'role': role.name,
        'phone': phone,
        'city': city,
        'country': country,
        'age': age,
        'lat': lat,
        'lng': lng,
        'language': 'es',
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Perfil creado en tabla users: $email');

      return {
        'success': true,
        'user': {
          'id': authUser.id,
          'email': email,
          'full_name': fullName,
          'role': role.name,
        }
      };
    } catch (e) {
      print('❌ Error en registro: $e');
      
      // Si falló la creación del perfil pero el usuario auth existe, limpiarlo
      if (currentUser != null) {
        try {
          await _supabase.auth.signOut();
        } catch (_) {}
      }
      
      throw Exception('Error al crear la cuenta: $e');
    }
  }

  // Inicio de sesión usando Supabase Auth
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Iniciando sesión con Supabase Auth...');
      
      // 1. Autenticar con Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email.toLowerCase(),
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Email o contraseña incorrectos');
      }

      final authUser = authResponse.user!;
      print('✅ Usuario autenticado: ${authUser.id}');

      // 2. Obtener perfil de tabla users
      final userProfile = await _supabase
          .from('users')
          .select('*')
          .eq('id', authUser.id)
          .maybeSingle();

      if (userProfile == null) {
        throw Exception('Perfil de usuario no encontrado');
      }

      print('✅ Perfil cargado: ${userProfile['full_name']}');

      return {
        'success': true,
        'user': userProfile,
      };
    } catch (e) {
      print('❌ Error en login: $e');
      throw Exception('Error al iniciar sesión: $e');
    }
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