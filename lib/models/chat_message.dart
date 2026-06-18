import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String? id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime? timestamp;
  final String? requestId; // Lien optionnel vers une demande d'intervention
  final bool lu; // Indicateur d'état de lecture

  const ChatMessage({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.timestamp,
    this.requestId,
    this.lu = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data, String id) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      message: data['message'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      requestId: data['requestId'] as String?,
      lu: data['lu'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp != null 
          ? Timestamp.fromDate(timestamp!) 
          : FieldValue.serverTimestamp(),
      if (requestId != null) 'requestId': requestId,
      'lu': lu,
    };
  }
}