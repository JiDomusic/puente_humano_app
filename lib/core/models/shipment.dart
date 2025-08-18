import 'user_profile.dart';
import 'library.dart';
import 'donation.dart';
import 'trip.dart';

class Shipment {
  final String id;
  final String shipmentCode;
  final String donationId;
  final String tripId;
  final String travelerId;
  final String donorId;
  final String targetLibraryId;
  final String status;
  final String pin;
  final String qrText;
  final String? scanValue;
  final String? pinIngresado;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  
  // Relaciones
  final Donation? donation;
  final Trip? trip;
  final UserProfile? traveler;
  final UserProfile? donor;
  final Library? targetLibrary;

  Shipment({
    required this.id,
    required this.shipmentCode,
    required this.donationId,
    required this.tripId,
    required this.travelerId,
    required this.donorId,
    required this.targetLibraryId,
    this.status = 'en_camino',
    required this.pin,
    required this.qrText,
    this.scanValue,
    this.pinIngresado,
    this.deliveredAt,
    required this.createdAt,
    this.donation,
    this.trip,
    this.traveler,
    this.donor,
    this.targetLibrary,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] as String,
      shipmentCode: json['shipment_code'] as String,
      donationId: json['donation_id'] as String,
      tripId: json['trip_id'] as String,
      travelerId: json['traveler_id'] as String,
      donorId: json['donor_id'] as String,
      targetLibraryId: json['target_library_id'] as String,
      status: json['status'] as String,
      pin: json['pin'] as String,
      qrText: json['qr_text'] as String,
      scanValue: json['scan_value'] as String?,
      pinIngresado: json['pin_ingresado'] as String?,
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      donation: json['donation'] != null 
          ? Donation.fromJson(json['donation'])
          : null,
      trip: json['trip'] != null 
          ? Trip.fromJson(json['trip'])
          : null,
      traveler: json['traveler'] != null 
          ? UserProfile.fromJson(json['traveler'])
          : null,
      donor: json['donor'] != null 
          ? UserProfile.fromJson(json['donor'])
          : null,
      targetLibrary: json['target_library'] != null 
          ? Library.fromJson(json['target_library'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipment_code': shipmentCode,
      'donation_id': donationId,
      'trip_id': tripId,
      'traveler_id': travelerId,
      'donor_id': donorId,
      'target_library_id': targetLibraryId,
      'status': status,
      'pin': pin,
      'qr_text': qrText,
      'scan_value': scanValue,
      'pin_ingresado': pinIngresado,
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case 'en_camino':
        return 'En camino';
      case 'entregado':
        return 'Entregado';
      default:
        return status;
    }
  }
  
  bool get isInTransit => status == 'en_camino';
  bool get isDelivered => status == 'entregado';
  
  bool get isConfirmed {
    return (pinIngresado != null && pinIngresado == pin) ||
           (scanValue != null && scanValue == qrText);
  }
  
  String get bookTitle => donation?.title ?? 'Libro sin título';
  String get bookAuthor => donation?.author ?? 'Autor desconocido';
  String get libraryName => targetLibrary?.name ?? 'Biblioteca';
  String get travelerName => traveler?.fullName ?? 'Transportista';
  String get donorName => donor?.fullName ?? 'Donante';
}