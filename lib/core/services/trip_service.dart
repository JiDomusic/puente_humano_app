import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip.dart';

class TripService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Crear nuevo viaje
  Future<Trip> createTrip({
    required String travelerId,
    required String originCity,
    required String originCountry,
    required double originLat,
    required double originLng,
    required String destCity,
    required String destCountry,
    required double destLat,
    required double destLng,
    required DateTime departDate,
    required DateTime arriveDate,
    required double capacityKg,
    String? notes,
  }) async {
    try {
      // Generar código único para el viaje
      final tripCode = await _generateTripCode();
      
      final tripData = {
        'trip_code': tripCode,
        'traveler_id': travelerId,
        'origin_city': originCity,
        'origin_country': originCountry,
        'origin_lat': originLat,
        'origin_lng': originLng,
        'dest_city': destCity,
        'dest_country': destCountry,
        'dest_lat': destLat,
        'dest_lng': destLng,
        'depart_date': departDate.toIso8601String().split('T')[0],
        'arrive_date': arriveDate.toIso8601String().split('T')[0],
        'capacity_kg': capacityKg,
        'notes': notes,
        'status': 'activo',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('trips')
          .insert(tripData)
          .select()
          .single();

      return Trip.fromJson(response);
    } catch (e) {
      throw Exception('Error creando viaje: $e');
    }
  }

  // Obtener viajes del usuario
  Future<List<Trip>> getUserTrips(String userId) async {
    try {
      final response = await _supabase
          .from('trips')
          .select('''
            *,
            traveler:users!traveler_id(*)
          ''')
          .eq('traveler_id', userId)
          .order('depart_date', ascending: false);

      return response.map((data) => Trip.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Error obteniendo viajes: $e');
    }
  }

  // Obtener viajes activos con capacidad disponible
  Future<List<Trip>> getAvailableTrips({
    String? originCity,
    String? destCity,
    DateTime? fromDate,
    DateTime? toDate,
    double? minCapacity,
  }) async {
    try {
      var query = _supabase
          .from('trips')
          .select('''
            *,
            traveler:users!traveler_id(*)
          ''')
          .eq('status', 'activo')
          .gte('depart_date', DateTime.now().toIso8601String().split('T')[0]);

      if (originCity != null) {
        query = query.ilike('origin_city', '%$originCity%');
      }

      if (destCity != null) {
        query = query.ilike('dest_city', '%$destCity%');
      }

      if (fromDate != null) {
        query = query.gte('depart_date', fromDate.toIso8601String().split('T')[0]);
      }

      if (toDate != null) {
        query = query.lte('arrive_date', toDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('depart_date', ascending: true);

      var trips = response.map((data) => Trip.fromJson(data)).toList();

      // Filtrar por capacidad disponible si se especifica
      if (minCapacity != null) {
        trips = trips.where((trip) => trip.availableKg >= minCapacity).toList();
      }

      return trips;
    } catch (e) {
      throw Exception('Error obteniendo viajes disponibles: $e');
    }
  }

  // Actualizar capacidad usada del viaje
  Future<void> updateTripUsedCapacity(String tripId, double newUsedKg) async {
    try {
      await _supabase
          .from('trips')
          .update({'used_kg': newUsedKg})
          .eq('id', tripId);
    } catch (e) {
      throw Exception('Error actualizando capacidad: $e');
    }
  }

  // Actualizar estado del viaje
  Future<void> updateTripStatus(String tripId, String newStatus) async {
    try {
      await _supabase
          .from('trips')
          .update({'status': newStatus})
          .eq('id', tripId);
    } catch (e) {
      throw Exception('Error actualizando estado: $e');
    }
  }

  // Obtener viaje por ID
  Future<Trip?> getTripById(String tripId) async {
    try {
      final response = await _supabase
          .from('trips')
          .select('''
            *,
            traveler:users!traveler_id(*)
          ''')
          .eq('id', tripId)
          .maybeSingle();

      if (response == null) return null;
      return Trip.fromJson(response);
    } catch (e) {
      throw Exception('Error obteniendo viaje: $e');
    }
  }

  // Obtener estadísticas de viajes
  Future<Map<String, dynamic>> getTripStats() async {
    try {
      final totalResponse = await _supabase
          .from('trips')
          .select('id')
          .count();

      final activeResponse = await _supabase
          .from('trips')
          .select('id')
          .eq('status', 'activo')
          .count();

      final completedResponse = await _supabase
          .from('trips')
          .select('id')
          .eq('status', 'completado')
          .count();

      final totalCapacityResponse = await _supabase
          .rpc('get_total_capacity_trips');

      return {
        'total_trips': totalResponse.count,
        'active_trips': activeResponse.count,
        'completed_trips': completedResponse.count,
        'total_capacity_kg': totalCapacityResponse ?? 0.0,
      };
    } catch (e) {
      throw Exception('Error obteniendo estadísticas: $e');
    }
  }

  // Buscar viajes por ruta
  Future<List<Trip>> searchTripsByRoute({
    required String originCity,
    required String destCity,
    DateTime? departDate,
  }) async {
    try {
      var query = _supabase
          .from('trips')
          .select('''
            *,
            traveler:users!traveler_id(*)
          ''')
          .eq('status', 'activo')
          .ilike('origin_city', '%$originCity%')
          .ilike('dest_city', '%$destCity%');

      if (departDate != null) {
        query = query.gte('depart_date', departDate.toIso8601String().split('T')[0]);
      }

      final response = await query
          .order('depart_date', ascending: true)
          .limit(20);

      return response.map((data) => Trip.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Error buscando viajes: $e');
    }
  }

  // Generar código único para viaje
  Future<String> _generateTripCode() async {
    const prefix = 'TRP';
    var attempts = 0;
    const maxAttempts = 10;

    while (attempts < maxAttempts) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final code = '$prefix-${timestamp.toString().substring(7)}';

      // Verificar que el código no existe
      final existing = await _supabase
          .from('trips')
          .select('id')
          .eq('trip_code', code)
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