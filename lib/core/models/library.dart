class Library {
  final String id;
  final String libraryCode;
  final String name;
  final String contactEmail;
  final String? contactPhone;
  final String address;
  final String city;
  final String country;
  final double lat;
  final double lng;
  final String? needs;
  final int receivedCount;
  final String? about;
  final DateTime createdAt;

  Library({
    required this.id,
    required this.libraryCode,
    required this.name,
    required this.contactEmail,
    this.contactPhone,
    required this.address,
    required this.city,
    required this.country,
    required this.lat,
    required this.lng,
    this.needs,
    this.receivedCount = 0,
    this.about,
    required this.createdAt,
  });

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'] as String,
      libraryCode: json['library_code'] as String,
      name: json['name'] as String,
      contactEmail: json['contact_email'] as String,
      contactPhone: json['contact_phone'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      needs: json['needs'] as String?,
      receivedCount: json['received_count'] ?? 0,
      about: json['about'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'library_code': libraryCode,
      'name': name,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'address': address,
      'city': city,
      'country': country,
      'lat': lat,
      'lng': lng,
      'needs': needs,
      'received_count': receivedCount,
      'about': about,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullAddress => '$address, $city, $country';
  
  List<String> get needsList {
    if (needs == null || needs!.isEmpty) return [];
    return needs!.split(',').map((n) => n.trim()).toList();
  }
}