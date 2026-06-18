
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../services/notification_service.dart'; // AJOUT : FCM notifications (CDC §8.1)
import 'chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getChatRoomId(String uid1, String uid2) {
    final List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  @override
  Stream<List<ChatMessage>> getMessages(String currentUserId, String otherUserId) {
    final roomId = _getChatRoomId(currentUserId, otherUserId);
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    final roomId = _getChatRoomId(message.senderId, message.receiverId);
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());

    // AJOUT : Notifier le destinataire du nouveau message (CDC §8.1)
    await _notifyNewMessage(message);
  }

  /// Envoie une notification push au destinataire du message.
  ///
  /// - Récupère le nom de l'expéditeur depuis users/{senderId}.nom
  /// - Récupère le fcmToken du destinataire depuis users/{receiverId}.fcmToken
  /// - Envoie le titre (nom de l'expéditeur) et les 50 premiers caractères du message
  Future<void> _notifyNewMessage(ChatMessage message) async {
    try {
      // Récupérer le nom de l'expéditeur
      final senderDoc = await _firestore.collection('users').doc(message.senderId).get();
      final senderName = senderDoc.data()?['nom'] as String? ?? 'Nouveau message';

      // Récupérer le fcmToken du destinataire
      final receiverDoc = await _firestore.collection('users').doc(message.receiverId).get();
      final receiverToken = receiverDoc.data()?['fcmToken'] as String?;

      if (receiverToken == null || receiverToken.isEmpty) return;

      // Tronquer le message à 50 caractères
      final bodyPreview = message.message.length > 50
          ? '${message.message.substring(0, 50)}…'
          : message.message;

      await NotificationService.sendToToken(
        token: receiverToken,
        title: senderName,
        body: bodyPreview,
      );
    } catch (e) {
      debugPrint('_notifyNewMessage error: $e');
    }
  }

  @override
  Future<void> markAsRead(String roomId, String currentUserId) async {
    final messagesQuery = await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('lu', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messagesQuery.docs) {
      batch.update(doc.reference, {'lu': true});
    }
    await batch.commit();
  }
}