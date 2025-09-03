import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _avatarsBucket = 'avatars';

  // Subir foto de perfil
  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      print('🔄 Iniciando subida de foto para usuario: $userId');
      
      // Verificar que el archivo existe y es válido
      if (!await imageFile.exists()) {
        print('❌ El archivo de imagen no existe');
        return null;
      }
      
      final fileSize = await imageFile.length();
      print('📁 Tamaño del archivo: ${fileSize} bytes');
      
      // Verificar límite de tamaño (20MB)
      if (fileSize > 20 * 1024 * 1024) {
        print('❌ Archivo demasiado grande: ${fileSize} bytes');
        return null;
      }
      
      // Obtener la extensión del archivo original
      final originalPath = imageFile.path;
      final extension = originalPath.split('.').last.toLowerCase();
      
      // Validar tipo de archivo
      if (!['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension)) {
        print('❌ Tipo de archivo no soportado: $extension');
        return null;
      }
      
      // Generar nombre único para la imagen conservando la extensión
      const uuid = Uuid();
      final fileName = '${userId}_${uuid.v4()}.$extension';
      final filePath = '$userId/$fileName';
      
      print('📤 Subiendo archivo: $filePath');

      // Subir archivo a Supabase Storage
      try {
        await _supabase.storage
            .from(_avatarsBucket)
            .upload(filePath, imageFile);
        
        print('✅ Archivo subido exitosamente');
      } catch (uploadError) {
        print('❌ Error específico de upload: $uploadError');
        if (uploadError is StorageException) {
          if (uploadError.statusCode == '409') {
            // Archivo ya existe, intentar con otro nombre
            print('🔄 Archivo existe, intentando con nuevo nombre...');
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final newFileName = '${userId}_${uuid.v4()}_$timestamp.$extension';
            final newFilePath = '$userId/$newFileName';
            
            await _supabase.storage
                .from(_avatarsBucket)
                .upload(newFilePath, imageFile);
            
            final publicUrl = _supabase.storage
                .from(_avatarsBucket)
                .getPublicUrl(newFilePath);
            
            print('🔗 URL pública generada: $publicUrl');
            return publicUrl;
          }
        }
        rethrow;
      }

      // Obtener URL pública
      final String publicUrl = _supabase.storage
          .from(_avatarsBucket)
          .getPublicUrl(filePath);
      
      print('🔗 URL pública generada: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Error uploading profile photo: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
      if (e is StorageException) {
        print('❌ Código de error Storage: ${e.statusCode}');
        print('❌ Mensaje de error Storage: ${e.message}');
        
        // Dar mensajes de error más específicos
        if (e.statusCode == '403') {
          print('❌ Permisos insuficientes - verificar políticas RLS');
        } else if (e.statusCode == '404') {
          print('❌ Bucket no encontrado');
        }
      }
      return null;
    }
  }

  // Eliminar foto de perfil anterior
  Future<bool> deleteProfilePhoto(String photoUrl) async {
    try {
      // Extraer path del URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 3) {
        final filePath = pathSegments.sublist(2).join('/');
        
        await _supabase.storage
            .from(_avatarsBucket)
            .remove([filePath]);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting profile photo: $e');
      return false;
    }
  }

  // Verificar si el bucket existe (solo verificación, no creación)
  Future<bool> bucketExists() async {
    try {
      print('🔍 Verificando existencia del bucket: $_avatarsBucket');
      
      // Intentar listar archivos del bucket como test
      await _supabase.storage.from(_avatarsBucket).list();
      
      print('✅ Bucket existe y es accesible: $_avatarsBucket');
      return true;
    } catch (e) {
      print('❌ Bucket no accesible: $e');
      if (e is StorageException) {
        print('❌ Código de error: ${e.statusCode}');
        print('❌ Mensaje: ${e.message}');
      }
      return false;
    }
  }
}