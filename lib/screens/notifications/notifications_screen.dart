import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/notification.dart';
import '../../core/services/notification_service.dart';
import '../../providers/auth_provider_simple.dart';
import '../../utils/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      final notifications = await _notificationService.getUserNotifications(user.id);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (!notification.isRead) {
      await _notificationService.markAsRead(notification.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(isRead: true);
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      await _notificationService.markAllAsRead(user.id);
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    await _notificationService.deleteNotification(notification.id);
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xE6D282),
      appBar: AppBar(
        title: Text('${l10n.notifications} ${unreadCount > 0 ? '($unreadCount)' : ''}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: l10n.backToHome,
          ),
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: l10n.markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: isMobile ? 64 : 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: isMobile ? 16 : 24),
                          Text(
                            l10n.noNotifications,
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationCard(notification, isMobile);
                      },
                    ),
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, bool isMobile) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead 
            ? BorderSide.none 
            : BorderSide(color: Colors.blue[300]!, width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: isMobile ? 20 : 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'read':
                _markAsRead(notification);
                break;
              case 'delete':
                _deleteNotification(notification);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                value: 'read',
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_read),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context).markAsRead),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          _markAsRead(notification);
          // Navegar a la pantalla relacionada si es necesario
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.donation:
        return Colors.green[600]!;
      case NotificationType.trip:
        return Colors.blue[600]!;
      case NotificationType.request:
        return Colors.orange[600]!;
      case NotificationType.rating:
        return Colors.amber[600]!;
      case NotificationType.message:
        return Colors.purple[600]!;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.donation:
        return Icons.volunteer_activism;
      case NotificationType.trip:
        return Icons.local_shipping;
      case NotificationType.request:
        return Icons.request_page;
      case NotificationType.rating:
        return Icons.star;
      case NotificationType.message:
        return Icons.message;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // Navegar según el tipo de notificación
    switch (notification.type) {
      case NotificationType.donation:
        if (notification.relatedId != null) {
          context.push('/donations/${notification.relatedId}');
        }
        break;
      case NotificationType.trip:
        if (notification.relatedId != null) {
          context.push('/trips/${notification.relatedId}');
        }
        break;
      case NotificationType.request:
        if (notification.relatedId != null) {
          context.push('/requests/${notification.relatedId}');
        }
        break;
      default:
        break;
    }
  }
}