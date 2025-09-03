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
      await _storageService.bucketExists();
    } catch (e) {
      // Silenciar errores de storage para no afectar la funcionalidad principal
      print('Storage initialization failed silently: $e');
    }
  }

  Map<String, dynamic>? get currentUser => _currentUserData;
  bool get isLoggedIn => _currentUserData != null;
  
  // Método para sincronizar estado desde el provider
  void setCurrentUserData(Map<String, dynamic>? userData) {
    _currentUserData = userData != null ? Map<String, dynamic>.from(userData) : null;
  }

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
      final userData = <String, dynamic>{
        'id': userId,
        'email': email.toLowerCase(),
        'password_hash': hashedPassword,
        'full_name': fullName,
        'role': role.name,
        'phone': phone,
        'city': city,
        'country': country,
        'language': 'es',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Solo añadir campos opcionales si no son null
      if (age != null) userData['age'] = age;
      if (lat != null) userData['lat'] = lat;
      if (lng != null) userData['lng'] = lng;
      
      await _supabase.from('users').insert(userData);

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
      _currentUserData = Map<String, dynamic>.from(userProfile);

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
    
    // Filtrar valores null para evitar el error "Cannot send Null"
    final filteredUpdates = <String, dynamic>{};
    for (final entry in updates.entries) {
      if (entry.value != null) {
        filteredUpdates[entry.key] = entry.value;
      }
    }
    
    if (filteredUpdates.isNotEmpty) {
      await _supabase
          .from('users')
          .update(filteredUpdates)
          .eq('id', currentUser!['id']);
    }
    
    // Actualizar el estado local _currentUserData
    _currentUserData = {
      ..._currentUserData!,
      ...updates,
    };
  }

  // Actualizar foto de perfil
  Future<String?> updateProfilePhoto(File imageFile) async {
    if (currentUser == null) {
      print('❌ Usuario no autenticado para upload');
      return null;
    }
    
    try {
      print('🔄 Iniciando actualización de foto de perfil...');
      
      // Verificar si el archivo es válido
      if (!await imageFile.exists()) {
        print('❌ Archivo de imagen no existe');
        return null;
      }
      
      final userId = currentUser!['id'];
      if (userId == null) {
        print('❌ ID de usuario es null');
        return null;
      }
      
      // Subir nueva foto
      print('📤 Subiendo nueva foto...');
      final newPhotoUrl = await _storageService.uploadProfilePhoto(
        userId.toString(), 
        imageFile
      );
      
      if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
        print('✅ Foto subida exitosamente: $newPhotoUrl');
        
        try {
          // Actualizar URL en la base de datos
          await updateProfile({'photo': newPhotoUrl});
          
          // Actualizar el estado local _currentUserData
          _currentUserData = {
            ..._currentUserData!,
            'photo': newPhotoUrl,
          };
          
          print('✅ Perfil actualizado en BD');
          
          // Eliminar foto anterior si existe (pero no bloquear si falla)
          try {
            final currentProfile = await getUserProfile();
            if (currentProfile?.photo != null && currentProfile!.photo!.isNotEmpty) {
              await _storageService.deleteProfilePhoto(currentProfile.photo!);
              print('🗑️ Foto anterior eliminada');
            }
          } catch (deleteError) {
            print('⚠️ No se pudo eliminar foto anterior: $deleteError');
            // No fallar por esto
          }
          
          return newPhotoUrl;
        } catch (dbError) {
          print('❌ Error actualizando BD: $dbError');
          return null;
        }
      } else {
        print('❌ Upload falló - URL es null o vacía');
        return null;
      }
    } catch (e) {
      print('❌ Error general en updateProfilePhoto: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
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