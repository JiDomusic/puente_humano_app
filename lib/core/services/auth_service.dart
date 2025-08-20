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
  
  // Usuario actual almacenado localmente (sin Supabase Auth)
  Map<String, dynamic>? _currentUserData;
  
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

  Map<String, dynamic>? get currentUser => _currentUserData;
  bool get isLoggedIn => _currentUserData != null;

  // Registro sin email usando solo tabla users (sin Supabase Auth)
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
      print('🔄 Iniciando registro sin email auth...');
      
      // Generar ID único para el usuario
      final userId = _generateUserId();
      final hashedPassword = _hashPassword(password);
      
      // Crear perfil directamente en tabla users
      await _supabase.from('users').insert({
        'id': userId,
        'email': email.toLowerCase(),
        'password_hash': hashedPassword,
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

      print('✅ Usuario creado directamente en tabla users: $email');

      return {
        'success': true,
        'user': {
          'id': userId,
          'email': email,
          'full_name': fullName,
          'role': role.name,
        }
      };
    } catch (e) {
      print('❌ Error en registro: $e');
      throw Exception('Error al crear la cuenta: $e');
    }
  }

  // Inicio de sesión usando solo tabla users (sin Supabase Auth)
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Iniciando sesión con verificación directa...');
      
      // 1. Buscar usuario en tabla users
      final userProfile = await _supabase
          .from('users')
          .select('*')
          .eq('email', email.toLowerCase())
          .maybeSingle();

      if (userProfile == null) {
        throw Exception('Email o contraseña incorrectos');
      }

      // 2. Verificar contraseña
      final hashedPassword = _hashPassword(password);
      if (userProfile['password_hash'] != hashedPassword) {
        throw Exception('Email o contraseña incorrectos');
      }

      print('✅ Usuario autenticado: ${userProfile['full_name']}');

      // Almacenar usuario actual
      _currentUserData = userProfile;

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
    _currentUserData = null;
  }

  // Recuperar contraseña (deshabilitado - requiere email auth)
  Future<void> resetPassword(String email) async {
    throw Exception('Recuperación de contraseña no disponible sin autenticación por email');
  }


  // Obtener perfil de usuario con mejor manejo de errores
  Future<UserProfile?> getUserProfile([String? userId]) async {
    final id = userId ?? currentUser?['id'];
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
        .eq('id', currentUser!['id']);
  }

  // Actualizar foto de perfil
  Future<String?> updateProfilePhoto(File imageFile) async {
    if (currentUser == null) throw Exception('Usuario no autenticado');
    
    try {
      // Obtener perfil actual para eliminar foto anterior si existe
      final currentProfile = await getUserProfile();
      
      // Subir nueva foto
      final newPhotoUrl = await _storageService.uploadProfilePhoto(
        currentUser!['id'], 
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

  // Helper methods for user ID generation and password hashing
  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'user_${timestamp}_$random';
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode('${password}puente_humano_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

}