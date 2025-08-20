enum NotificationType {
  donation('donation'),
  trip('trip'),
  request('request'),
  rating('rating'),
  message('message');

  const NotificationType(this.value);
  final String value;
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? userId;
  final String? relatedId; // ID de la donación, viaje, etc.
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.userId,
    this.relatedId,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.value == json['type'],
        orElse: () => NotificationType.message,
      ),
      userId: json['user_id'] as String?,
      relatedId: json['related_id'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'user_id': userId,
      'related_id': relatedId,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? title,
    String? message,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type,
      userId: userId,
      relatedId: relatedId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}