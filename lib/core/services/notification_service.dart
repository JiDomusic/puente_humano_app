import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Crear notificación
  Future<bool> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? userId,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'title': title,
        'message': message,
        'type': type.value,
        'user_id': userId,
        'related_id': relatedId,
        'data': data,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error creando notificación: $e');
      return false;
    }
  }

  // Obtener notificaciones de un usuario
  Future<List<AppNotification>> getUserNotifications(String userId, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<AppNotification>((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo notificaciones: $e');
      return [];
    }
  }

  // Obtener notificaciones no leídas
  Future<List<AppNotification>> getUnreadNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return response
          .map<AppNotification>((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo notificaciones no leídas: $e');
      return [];
    }
  }

  // Marcar notificación como leída
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      return true;
    } catch (e) {
      print('Error marcando notificación como leída: $e');
      return false;
    }
  }

  // Marcar todas las notificaciones como leídas
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      return true;
    } catch (e) {
      print('Error marcando todas las notificaciones como leídas: $e');
      return false;
    }
  }

  // Eliminar notificación
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
      return true;
    } catch (e) {
      print('Error eliminando notificación: $e');
      return false;
    }
  }

  // Contar notificaciones no leídas
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      
      return response.length;
    } catch (e) {
      print('Error contando notificaciones no leídas: $e');
      return 0;
    }
  }

  // Notificaciones para actividades específicas
  Future<void> notifyNewDonation({
    required String donorId,
    required String donorName,
    required String bookTitle,
    required String donationId,
  }) async {
    // Notificar a TODOS los usuarios
    await _notifyAllUsers(
      title: '📚 Nueva donación disponible',
      message: '$donorName ha donado "$bookTitle" para compartir con la comunidad',
      type: NotificationType.donation,
      relatedId: donationId,
      excludeUserId: donorId,
    );
  }

  Future<void> notifyNewTrip({
    required String transporterId,
    required String transporterName,
    required String origin,
    required String destination,
    required String tripId,
  }) async {
    // Notificar a TODOS los usuarios
    await _notifyAllUsers(
      title: '🚛 Nuevo viaje disponible',
      message: '$transporterName viaja de $origin a $destination y puede llevar libros',
      type: NotificationType.trip,
      relatedId: tripId,
      excludeUserId: transporterId,
    );
  }

  Future<void> notifyBookRequest({
    required String libraryId,
    required String libraryName,
    required String bookRequested,
    required String requestId,
  }) async {
    // Notificar a TODOS los usuarios
    await _notifyAllUsers(
      title: '📖 Solicitud de libro',
      message: '$libraryName necesita "$bookRequested" para su comunidad',
      type: NotificationType.request,
      relatedId: requestId,
      excludeUserId: libraryId,
    );
  }

  // Nueva notificación cuando una biblioteca recibe libros
  Future<void> notifyBookDelivered({
    required String libraryId,
    required String libraryName,
    required String donorName,
    required String transporterName,
    required String bookTitle,
    required String deliveryId,
  }) async {
    // Notificar a TODOS los usuarios sobre la entrega exitosa
    await _notifyAllUsers(
      title: '🎉 Entrega exitosa completada',
      message: '$libraryName recibió "$bookTitle" de $donorName gracias a $transporterName',
      type: NotificationType.donation,
      relatedId: deliveryId,
      excludeUserId: null, // Todos deben ver este éxito, incluso los involucrados
    );
  }

  // Nueva notificación cuando se completa una conexión
  Future<void> notifySuccessfulConnection({
    required String donorName,
    required String transporterName,
    required String libraryName,
    required String bookTitle,
    required String connectionId,
  }) async {
    // Notificar a TODOS sobre el éxito de la red
    await _notifyAllUsers(
      title: '🌟 Conexión exitosa en PuenteHumano',
      message: '¡$donorName, $transporterName y $libraryName conectaron exitosamente para entregar "$bookTitle"!',
      type: NotificationType.message,
      relatedId: connectionId,
      excludeUserId: null,
    );
  }

  // Método auxiliar para notificar a usuarios por rol
  Future<void> _notifyUsersByRole({
    required String role,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    String? excludeUserId,
  }) async {
    try {
      // Obtener usuarios del rol especificado
      var query = _supabase
          .from('users')
          .select('id')
          .eq('role', role);

      if (excludeUserId != null) {
        query = query.neq('id', excludeUserId);
      }

      final users = await query;

      // Crear notificaciones para cada usuario
      for (final user in users) {
        await createNotification(
          title: title,
          message: message,
          type: type,
          userId: user['id'],
          relatedId: relatedId,
        );
      }
    } catch (e) {
      print('Error notificando a usuarios por rol: $e');
    }
  }

  // Método auxiliar para notificar a TODOS los usuarios
  Future<void> _notifyAllUsers({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
    String? excludeUserId,
  }) async {
    try {
      // Obtener TODOS los usuarios
      var query = _supabase
          .from('users')
          .select('id');

      if (excludeUserId != null) {
        query = query.neq('id', excludeUserId);
      }

      final users = await query;

      // Crear notificaciones para cada usuario
      for (final user in users) {
        await createNotification(
          title: title,
          message: message,
          type: type,
          userId: user['id'],
          relatedId: relatedId,
        );
      }
    } catch (e) {
      print('Error notificando a todos los usuarios: $e');
    }
  }
}