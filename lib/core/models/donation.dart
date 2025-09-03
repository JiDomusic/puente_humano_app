import 'user_profile.dart';
import 'library.dart';

class Donation {
  final String id;
  final String donationCode;
  final String donorId;
  final String title;
  final String author;
  final double weightKg;
  final String targetLibraryId;
  final String? notes;
  final String status;
  final DateTime createdAt;
  
  // Relaciones
  final UserProfile? donor;
  final Library? targetLibrary;

  Donation({
    required this.id,
    required this.donationCode,
    required this.donorId,
    required this.title,
    required this.author,
    required this.weightKg,
    required this.targetLibraryId,
    this.notes,
    this.status = 'pendiente',
    required this.createdAt,
    this.donor,
    this.targetLibrary,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      donationCode: json['donation_code'] as String,
      donorId: json['donor_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
      targetLibraryId: json['target_library_id'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
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
      'donation_code': donationCode,
      'donor_id': donorId,
      'title': title,
      'author': author,
      'weight_kg': weightKg,
      'target_library_id': targetLibraryId,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullTitle => '$title - $author';
  
  String get statusText {
    switch (status) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_camino':
        return 'En camino';
      case 'entregado':
        return 'Entregado';
      default:
        return status;
    }
  }
  
  bool get isPending => status == 'pendiente';
  bool get isInTransit => status == 'en_camino';
  bool get isDelivered => status == 'entregado';
}