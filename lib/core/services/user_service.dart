import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import '../models/user_profile.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener perfil público de usuario por ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error obteniendo perfil de usuario: $e');
      return null;
    }
  }

  // Obtener lista de usuarios por rol
  Future<List<UserProfile>> getUsersByRole(UserRole role) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('role', role.name)
          .order('created_at', ascending: false);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo usuarios por rol: $e');
      return [];
    }
  }

  // Obtener usuarios cercanos a una ubicación
  Future<List<UserProfile>> getNearbyUsers(double lat, double lng, {double radiusKm = 50}) async {
    try {
      // Query básico sin filtro de distancia (Supabase PostGIS sería ideal)
      final response = await _supabase
          .from('users')
          .select('*')
          .not('lat', 'is', null)
          .not('lng', 'is', null)
          .order('created_at', ascending: false);

      final users = response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();

      // Filtrar por distancia en el cliente (para demo)
      return users.where((user) {
        if (user.lat == null || user.lng == null) return false;
        final distance = _calculateDistance(lat, lng, user.lat!, user.lng!);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error obteniendo usuarios cercanos: $e');
      return [];
    }
  }

  // Buscar usuarios por ciudad
  Future<List<UserProfile>> getUsersByCity(String city) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .ilike('city', '%$city%')
          .order('created_at', ascending: false);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      print('Error buscando usuarios por ciudad: $e');
      return [];
    }
  }

  // Actualizar perfil público (campos específicos)
  Future<bool> updatePublicProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? city,
    String? country,
    int? age,
    double? lat,
    double? lng,
    String? photo,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (city != null) updateData['city'] = city;
      if (country != null) updateData['country'] = country;
      if (age != null) updateData['age'] = age;
      if (lat != null) updateData['lat'] = lat;
      if (lng != null) updateData['lng'] = lng;
      if (photo != null) updateData['photo'] = photo;

      if (updateData.isEmpty) return true;

      await _supabase
          .from('users')
          .update(updateData)
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error actualizando perfil público: $e');
      return false;
    }
  }

  // Calcular distancia entre dos puntos (fórmula de Haversine)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Radio de la Tierra en km
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Obtener usuario por ID
  Future<UserProfile?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error obteniendo usuario por ID: $e');
      return null;
    }
  }

  // Calificar usuario
  Future<bool> rateUser({
    required String ratedUserId,
    required String raterUserId,
    required double rating,
    String? comment,
    String? interactionType,
    String? interactionId,
  }) async {
    try {
      // Insertar o actualizar calificación
      final ratingData = {
        'rated_user_id': ratedUserId,
        'rater_user_id': raterUserId,
        'rating': rating,
        'comment': comment,
        'interaction_type': interactionType,
        'interaction_id': interactionId,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('user_ratings')
          .upsert(ratingData, onConflict: 'rated_user_id,rater_user_id');

      // Actualizar estadísticas del usuario calificado
      await _updateUserRatingStats(ratedUserId);

      return true;
    } catch (e) {
      print('Error calificando usuario: $e');
      return false;
    }
  }

  // Actualizar estadísticas de calificación
  Future<void> _updateUserRatingStats(String userId) async {
    try {
      final response = await _supabase
          .from('user_ratings')
          .select('rating')
          .eq('rated_user_id', userId);

      if (response.isNotEmpty) {
        final ratings = response.map<double>((r) => r['rating'].toDouble()).toList();
        final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
        final ratingsCount = ratings.length;

        await _supabase
            .from('users')
            .update({
              'average_rating': averageRating,
              'ratings_count': ratingsCount,
            })
            .eq('id', userId);
      }
    } catch (e) {
      print('Error actualizando estadísticas de calificación: $e');
    }
  }

  // Obtener calificaciones de un usuario
  Future<List<Map<String, dynamic>>> getUserRatings(String userId) async {
    try {
      final response = await _supabase
          .from('user_ratings')
          .select('*, rater:users!rater_user_id(full_name, photo)')
          .eq('rated_user_id', userId)
          .order('created_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error obteniendo calificaciones: $e');
      return [];
    }
  }
}