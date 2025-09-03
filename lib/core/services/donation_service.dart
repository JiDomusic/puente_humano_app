import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donation.dart';

class DonationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Crear nueva donación
  Future<Donation> createDonation({
    required String donorId,
    required String title,
    required String author,
    required double weightKg,
    required String targetLibraryId,
    String? notes,
  }) async {
    try {
      // Generar código único para la donación
      final donationCode = await _generateDonationCode();
      
      final donationData = {
        'donation_code': donationCode,
        'donor_id': donorId,
        'title': title,
        'author': author,
        'weight_kg': weightKg,
        'target_library_id': targetLibraryId,
        'notes': notes,
        'status': 'pendiente',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('donations')
          .insert(donationData)
          .select()
          .single();

      return Donation.fromJson(response);
    } catch (e) {
      throw Exception('Error creando donación: $e');
    }
  }

  // Obtener todas las donaciones
  Future<List<Donation>> getAllDonations() async {
    try {
      final response = await _supabase
          .from('donations')
          .select('''
            *,
            donor:users(*),
            target_library:libraries(*)
          ''')
          .order('created_at', ascending: false);

      return response.map((data) => Donation.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Error obteniendo donaciones: $e');
    }
  }

  // Obtener donaciones del usuario
  Future<List<Donation>> getUserDonations(String userId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select('''
            *,
            donor:users(*),
            target_library:libraries(*)
          ''')
          .eq('donor_id', userId)
          .order('created_at', ascending: false);

      return response.map((data) => Donation.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Error obteniendo donaciones: $e');
    }
  }

  // Obtener todas las donaciones con filtros
  Future<List<Donation>> getDonations({
    String? status,
    String? targetLibraryId,
    int? limit,
  }) async {
    try {
      var query = _supabase
          .from('donations')
          .select('''
            *,
            donor:users(*),
            target_library:libraries(*)
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (targetLibraryId != null) {
        query = query.eq('target_library_id', targetLibraryId);
      }

      // Build
      // the final query with order and optional limit
      final finalQuery = query.order('created_at', ascending: false);
      final response = await (limit != null 
          ? finalQuery.limit(limit)
          : finalQuery);

      return response.map((data) => Donation.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Error obteniendo donaciones: $e');
    }
  }

  // Actualizar estado de donación
  Future<void> updateDonationStatus(String donationId, String newStatus) async {
    try {
      await _supabase
          .from('donations')
          .update({'status': newStatus})
          .eq('id', donationId);
    } catch (e) {
      throw Exception('Error actualizando estado: $e');
    }
  }

  // Obtener donación por ID
  Future<Donation?> getDonationById(String donationId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select('''
            *,
            donor:users(*),
            target_library:libraries(*)
          ''')
          .eq('id', donationId)
          .maybeSingle();

      if (response == null) return null;
      return Donation.fromJson(response);
    } catch (e) {
      throw Exception('Error obteniendo donación: $e');
    }
  }

  // Obtener estadísticas de donaciones
  Future<Map<String, dynamic>> getDonationStats() async {
    try {
      final totalResponse = await _supabase
          .from('donations')
          .select('id')
          .count();

      final deliveredResponse = await _supabase
          .from('donations')
          .select('id')
          .eq('status', 'entregado')
          .count();

      final pendingResponse = await _supabase
          .from('donations')
          .select('id')
          .eq('status', 'pendiente')
          .count();

      final totalWeightResponse = await _supabase
          .rpc('get_total_weight_donations');

      return {
        'total_donations': totalResponse.count,
        'delivered_donations': deliveredResponse.count,
        'pending_donations': pendingResponse.count,
        'total_weight_kg': totalWeightResponse ?? 0.0,
      };
    } catch (e) {
      throw Exception('Error obteniendo estadísticas: $e');
    }
  }

  // Generar código único para donación
  Future<String> _generateDonationCode() async {
    const prefix = 'DON';
    var attempts = 0;
    const maxAttempts = 10;

    while (attempts < maxAttempts) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final code = '$prefix-${timestamp.toString().substring(7)}';

      // Verificar que el código no existe
      final existing = await _supabase
          .from('donations')
          .select('id')
          .eq('donation_code', code)
          .maybeSingle();

      if (existing == null) {
        return code;
      }

      attempts++;
      await Future.delayed(const Duration(milliseconds: 10));
    }

    throw Exception('No se pudo generar código único');
  }
}