import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _avatarsBucket = 'avatars';

  // Subir foto de perfil
  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      // Generar nombre único para la imagen
      final uuid = const Uuid();
      final fileName = '${userId}_${uuid.v4()}.jpg';
      final filePath = '$userId/$fileName';

      // Subir archivo a Supabase Storage
      final String path = await _supabase.storage
          .from(_avatarsBucket)
          .upload(filePath, imageFile);

      // Obtener URL pública
      final String publicUrl = _supabase.storage
          .from(_avatarsBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
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
      // Intentar crear el bucket
      await _supabase.storage.createBucket(
        _avatarsBucket,
        const BucketOptions(
          public: true,
          allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
          fileSizeLimit: '5MB',
        ),
      );
    } catch (e) {
      // El bucket ya existe o hay otro error
      print('Avatars bucket might already exist: $e');
    }
  }
}