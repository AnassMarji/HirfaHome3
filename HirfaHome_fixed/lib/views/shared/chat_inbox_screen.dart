// ═══ FILE: lib/views/shared/chat_inbox_screen.dart ═══
//
// HirfaHome — Chat Inbox Screen
//
// Lists all chat conversations for the current user.
// Tapping a conversation opens ChatScreen with the other participant.
//
// IMPORTANT: This screen does NOT use any glass widgets or backdrop blur
// filters — those crash when navigation happens on top of them. Plain
// Container with glass-mimicking decoration is used instead.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_screen.dart';

class ChatInboxScreen extends StatelessWidget {
  final String currentUid;

  const ChatInboxScreen({super.key, required this.currentUid});

  /// Extracts the other user's UID from a room ID formatted as "uidA_uidB".
  /// Since the room ID is sorted alphabetically, either part could be first.
  String _getOtherUid(String roomId) {
    final parts = roomId.split('_');
    if (parts.length < 2) return '';
    return parts[0] == currentUid ? parts[1] : parts[0];
  }

  /// Formats a timestamp as "HH:mm" if today, "dd/MM" if older.
  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final isToday = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
    if (isToday) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter client-side for rooms belonging to the current user.
          // Primary: check participants array field (reliable).
          // Fallback: check doc.id.contains(currentUid) for old rooms
          // that don't have the participants field yet.
          final allDocs = snapshot.data?.docs ?? [];
          final myRooms = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              final participants = data['participants'] as List<dynamic>?;
              if (participants != null) {
                return participants.contains(currentUid);
              }
            }
            // Fallback to string contains for old rooms without participants field
            return doc.id.contains(currentUid);
          }).toList();

          if (myRooms.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 56,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune conversation pour le moment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: myRooms.length,
            itemBuilder: (context, index) {
              final roomId = myRooms[index].id;
              final otherUid = _getOtherUid(roomId);

              return FutureBuilder<
                  (
                    String,
                    String,
                    DateTime?,
                    int,
                  )>(
                future: _fetchRoomData(roomId, otherUid),
                builder: (context, roomSnap) {
                  if (roomSnap.connectionState == ConnectionState.waiting) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: SizedBox()),
                        title: Container(
                          height: 14,
                          width: 120,
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                        subtitle: Container(
                          height: 12,
                          width: 200,
                          color: colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                      ),
                    );
                  }

                  final data = roomSnap.data;
                  if (data == null) {
                    return const SizedBox.shrink();
                  }

                  final (contactName, lastMessage, lastTime, unreadCount) = data;
                  final hasInitial =
                      contactName.isNotEmpty;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            colorScheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          hasInitial
                              ? contactName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        contactName.isNotEmpty ? contactName : 'Utilisateur',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        lastMessage.isNotEmpty
                            ? lastMessage
                            : 'Démarrez la conversation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(lastTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            receiverId: otherUid,
                            receiverName: contactName.isNotEmpty
                                ? contactName
                                : 'Utilisateur',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Fetches (contactName, lastMessage, lastTimestamp, unreadCount) for a room.
  Future<(String, String, DateTime?, int)> _fetchRoomData(
      String roomId, String otherUid) async {
    try {
      // 1. Fetch contact name from users/{otherUid}
      String contactName = 'Utilisateur';
      if (otherUid.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          contactName =
              userDoc.data()!['nom'] as String? ?? 'Utilisateur';
        }
      }

      // 2. Fetch last message
      final lastMsgSnap = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      String lastMessage = '';
      DateTime? lastTime;
      if (lastMsgSnap.docs.isNotEmpty) {
        final msgData = lastMsgSnap.docs.first.data();
        lastMessage = msgData['message'] as String? ?? '';
        final ts = msgData['timestamp'];
        if (ts is Timestamp) {
          lastTime = ts.toDate();
        }
      }

      // 3. Count unread messages (lu == false AND receiverId == currentUid)
      final unreadSnap = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .where('lu', isEqualTo: false)
          .where('receiverId', isEqualTo: currentUid)
          .get();

      final unreadCount = unreadSnap.docs.length;

      return (contactName, lastMessage, lastTime, unreadCount);
    } catch (e) {
      return ('Utilisateur', '', null, 0);
    }
  }
}
