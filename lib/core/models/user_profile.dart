enum UserRole {
  donante('Donante'),
  transportista('Transportista'), 
  biblioteca('Biblioteca');

  const UserRole(this.displayName);
  final String displayName;
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String language;
  final String phone;
  final String city;
  final String country;
  final int? age;
  final double? lat;
  final double? lng;
  final String? photo;
  final double? averageRating;
  final int ratingsCount;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.language,
    required this.phone,
    required this.city,
    required this.country,
    this.age,
    this.lat,
    this.lng,
    this.photo,
    this.averageRating,
    this.ratingsCount = 0,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.donante,
      ),
      language: json['language'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      age: json['age'] as int?,
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      photo: json['photo'] as String?,
      averageRating: json['average_rating']?.toDouble(),
      ratingsCount: json['ratings_count'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'language': language,
      'phone': phone,
      'city': city,
      'country': country,
      'age': age,
      'lat': lat,
      'lng': lng,
      'photo': photo,
      'average_rating': averageRating,
      'ratings_count': ratingsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? city,
    String? country,
    int? age,
    double? lat,
    double? lng,
    String? photo,
    double? averageRating,
    int? ratingsCount,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role,
      language: language,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      country: country ?? this.country,
      age: age ?? this.age,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      photo: photo ?? this.photo,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      createdAt: createdAt,
    );
  }
}