
import '../models/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> getMessages(String currentUserId, String otherUserId);
  Future<void> sendMessage(ChatMessage message);
  Future<void> markAsRead(String roomId, String currentUserId);
}