import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener mensajes entre dos usuarios
  Future<List<ChatMessage>> getMessages(String userId1, String userId2) async {
    try {
      final response = await _supabase
          .from('chats')
          .select()
          .or('sender_id.eq.$userId1,receiver_id.eq.$userId1')
          .or('sender_id.eq.$userId2,receiver_id.eq.$userId2')
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .where((message) => 
              (message.senderId == userId1 && message.receiverId == userId2) ||
              (message.senderId == userId2 && message.receiverId == userId1))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar mensajes: $e');
    }
  }

  // Enviar un nuevo mensaje
  Future<bool> sendMessage(ChatMessage message) async {
    try {
      final messageData = {
        'sender_id': message.senderId,
        'receiver_id': message.receiverId,
        'message': message.message,
        'is_read': message.isRead,
        'created_at': message.createdAt.toIso8601String(),
      };
      
      await _supabase.from('chats').insert(messageData);
      return true;
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String senderId, String receiverId) async {
    try {
      await _supabase
          .from('chats')
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId);
    } catch (e) {
      throw Exception('Error al marcar mensajes como leídos: $e');
    }
  }

  // Obtener perfil de usuario por ID
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Error al cargar perfil de usuario: $e');
    }
  }

  // Obtener conversaciones del usuario actual
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select('''
            *,
            sender:users(id, full_name, photo, role),
            receiver:users(id, full_name, photo, role)
          ''')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      // Agrupar por conversación y obtener el último mensaje de cada una
      Map<String, Map<String, dynamic>> conversationsMap = {};
      
      for (var message in response as List) {
        final otherUserId = message['sender_id'] == userId 
            ? message['receiver_id'] 
            : message['sender_id'];
            
        if (!conversationsMap.containsKey(otherUserId)) {
          conversationsMap[otherUserId] = {
            'last_message': message,
            'other_user': message['sender_id'] == userId 
                ? message['receiver'] 
                : message['sender'],
            'unread_count': 0,
          };
        }
        
        // Contar mensajes no leídos
        if (message['sender_id'] != userId && !message['is_read']) {
          conversationsMap[otherUserId]!['unread_count'] = 
              (conversationsMap[otherUserId]!['unread_count'] as int) + 1;
        }
      }
      
      return conversationsMap.values.toList();
    } catch (e) {
      throw Exception('Error al cargar conversaciones: $e');
    }
  }
}