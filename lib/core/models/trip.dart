import 'user_profile.dart';

class Trip {
  final String id;
  final String tripCode;
  final String travelerId;
  final String originCity;
  final String originCountry;
  final double originLat;
  final double originLng;
  final String destCity;
  final String destCountry;
  final double destLat;
  final double destLng;
  final DateTime departDate;
  final DateTime arriveDate;
  final double capacityKg;
  final double usedKg;
  final String? notes;
  final String status;
  final DateTime createdAt;
  
  // Relaciones
  final UserProfile? traveler;

  Trip({
    required this.id,
    required this.tripCode,
    required this.travelerId,
    required this.originCity,
    required this.originCountry,
    required this.originLat,
    required this.originLng,
    required this.destCity,
    required this.destCountry,
    required this.destLat,
    required this.destLng,
    required this.departDate,
    required this.arriveDate,
    required this.capacityKg,
    this.usedKg = 0,
    this.notes,
    this.status = 'activo',
    required this.createdAt,
    this.traveler,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      tripCode: json['trip_code'] as String,
      travelerId: json['traveler_id'] as String,
      originCity: json['origin_city'] as String,
      originCountry: json['origin_country'] as String,
      originLat: (json['origin_lat'] as num).toDouble(),
      originLng: (json['origin_lng'] as num).toDouble(),
      destCity: json['dest_city'] as String,
      destCountry: json['dest_country'] as String,
      destLat: (json['dest_lat'] as num).toDouble(),
      destLng: (json['dest_lng'] as num).toDouble(),
      departDate: DateTime.parse(json['depart_date']),
      arriveDate: DateTime.parse(json['arrive_date']),
      capacityKg: (json['capacity_kg'] as num).toDouble(),
      usedKg: (json['used_kg'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      traveler: json['traveler'] != null 
          ? UserProfile.fromJson(json['traveler'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'used_kg': usedKg,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get availableKg => capacityKg - usedKg;
  
  bool get hasCapacity => availableKg > 0;
  
  String get route => '$originCity → $destCity';
  
  int get durationDays => arriveDate.difference(departDate).inDays + 1;
  
  bool get isActive => status == 'activo' && departDate.isAfter(DateTime.now());
}