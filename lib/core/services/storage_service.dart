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
      
      // Asegurar que el bucket existe
      await createAvatarsBucketIfNotExists();
      
      // Generar nombre único para la imagen
      const uuid = Uuid();
      final fileName = '${userId}_${uuid.v4()}.jpg';
      final filePath = '$userId/$fileName';
      
      print('📤 Subiendo archivo: $filePath');

      // Subir archivo a Supabase Storage
      final response = await _supabase.storage
          .from(_avatarsBucket)
          .upload(filePath, imageFile);
      
      print('✅ Archivo subido exitosamente');

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

  // Crear bucket si no existe
  Future<void> createAvatarsBucketIfNotExists() async {
    try {
      print('🔍 Verificando existencia del bucket: $_avatarsBucket');
      
      // Intentar obtener la lista de buckets primero
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == _avatarsBucket);
      
      if (!bucketExists) {
        print('📦 Bucket no existe, creando: $_avatarsBucket');
        // Solo crear si no existe
        await _supabase.storage.createBucket(
          _avatarsBucket,
          const BucketOptions(
            public: true,
            allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
            fileSizeLimit: '5MB',
          ),
        );
        print('✅ Bucket creado exitosamente: $_avatarsBucket');
      } else {
        print('✅ Bucket ya existe: $_avatarsBucket');
      }
    } catch (e) {
      print('❌ Error al crear/verificar bucket: $e');
      if (e is StorageException) {
        print('❌ Código de error bucket: ${e.statusCode}');
        print('❌ Mensaje de error bucket: ${e.message}');
      }
      rethrow; // Re-lanzar para que el upload sepa que falló
    }
  }
}