import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/library.dart';
import '../models/trip.dart';
import '../models/donation.dart';
import '../models/shipment.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== USERS ====================
  
  Future<List<UserProfile>> getUsers() async {
    final response = await _supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => UserProfile.fromJson(json))
        .toList();
  }

  Future<UserProfile?> getUserById(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile.fromJson(response);
  }

  // ==================== LIBRARIES ====================
  
  Future<List<Library>> getLibraries() async {
    final response = await _supabase
        .from('libraries')
        .select()
        .order('name');

    return (response as List)
        .map((json) => Library.fromJson(json))
        .toList();
  }

  Future<Library?> getLibraryById(String libraryId) async {
    final response = await _supabase
        .from('libraries')
        .select()
        .eq('id', libraryId)
        .single();

    return Library.fromJson(response);
  }

  // ==================== TRIPS ====================
  
  Future<List<Trip>> getActiveTrips() async {
    final response = await _supabase
        .from('trips')
        .select('''
          *,
          traveler:traveler_id(id, full_name, average_rating, phone)
        ''')
        .eq('status', 'activo')
        .gte('depart_date', DateTime.now().toIso8601String().split('T')[0])
        .order('depart_date');

    return (response as List)
        .map((json) => Trip.fromJson(json))
        .toList();
  }

  Future<List<Trip>> getTripsByTraveler(String travelerId) async {
    final response = await _supabase
        .from('trips')
        .select('''
          *,
          traveler:traveler_id(id, full_name, average_rating, phone)
        ''')
        .eq('traveler_id', travelerId)
        .order('depart_date', ascending: false);

    return (response as List)
        .map((json) => Trip.fromJson(json))
        .toList();
  }

  Future<String> createTrip(Map<String, dynamic> tripData) async {
    final response = await _supabase
        .from('trips')
        .insert(tripData)
        .select()
        .single();

    return response['id'];
  }

  // ==================== DONATIONS ====================
  
  Future<List<Donation>> getPendingDonations() async {
    final response = await _supabase
        .from('donations')
        .select('''
          *,
          donor:donor_id(id, full_name, city, average_rating),
          target_library:target_library_id(id, name, city, needs)
        ''')
        .eq('status', 'pendiente')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Donation.fromJson(json))
        .toList();
  }

  Future<List<Donation>> getDonationsByDonor(String donorId) async {
    final response = await _supabase
        .from('donations')
        .select('''
          *,
          donor:donor_id(id, full_name, city, average_rating),
          target_library:target_library_id(id, name, city, needs)
        ''')
        .eq('donor_id', donorId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Donation.fromJson(json))
        .toList();
  }

  Future<String> createDonation(Map<String, dynamic> donationData) async {
    final response = await _supabase
        .from('donations')
        .insert(donationData)
        .select()
        .single();

    return response['id'];
  }

  // ==================== SHIPMENTS ====================
  
  Future<List<Shipment>> getShipmentsByUser(String userId) async {
    final response = await _supabase
        .from('shipments')
        .select('''
          *,
          donation:donation_id(id, title, author, weight_kg),
          trip:trip_id(id, origin_city, dest_city, depart_date),
          traveler:traveler_id(id, full_name, phone),
          donor:donor_id(id, full_name, phone),
          target_library:target_library_id(id, name, contact_phone)
        ''')
        .or('traveler_id.eq.$userId,donor_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Shipment.fromJson(json))
        .toList();
  }

  Future<String> createShipment(Map<String, dynamic> shipmentData) async {
    final response = await _supabase
        .from('shipments')
        .insert(shipmentData)
        .select()
        .single();

    return response['id'];
  }

  Future<void> confirmDelivery({
    required String shipmentId,
    required String confirmationMethod, // 'pin' or 'qr'
    required String value,
  }) async {
    final updates = <String, dynamic>{
      'delivered_at': DateTime.now().toIso8601String(),
      'status': 'entregado',
    };

    if (confirmationMethod == 'pin') {
      updates['pin_ingresado'] = value;
    } else {
      updates['scan_value'] = value;
    }

    await _supabase
        .from('shipments')
        .update(updates)
        .eq('id', shipmentId);

    // Actualizar estado de la donación
    final shipment = await _supabase
        .from('shipments')
        .select('donation_id')
        .eq('id', shipmentId)
        .single();

    await _supabase
        .from('donations')
        .update({'status': 'entregado'})
        .eq('id', shipment['donation_id']);
  }

  // ==================== RATINGS ====================
  
  Future<void> createRating({
    required String aboutUserId,
    required String byUserId,
    required String shipmentId,
    required String roleOfAbout,
    required int stars,
    String? comment,
  }) async {
    await _supabase.from('ratings').insert({
      'about_user_id': aboutUserId,
      'by_user_id': byUserId,
      'shipment_id': shipmentId,
      'role_of_about': roleOfAbout,
      'stars': stars,
      'comment': comment,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==================== NOTIFICATIONS ====================
  
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==================== SEARCH ====================
  
  Future<List<Trip>> searchTripsToLibrary(String libraryId) async {
    final library = await getLibraryById(libraryId);
    if (library == null) return [];

    final response = await _supabase
        .from('trips')
        .select('''
          *,
          traveler:traveler_id(id, full_name, average_rating, phone)
        ''')
        .eq('status', 'activo')
        .eq('dest_city', library.city)
        .gte('depart_date', DateTime.now().toIso8601String().split('T')[0])
        .order('depart_date');

    return (response as List)
        .map((json) => Trip.fromJson(json))
        .toList();
  }
}