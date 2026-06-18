
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hirfahome/models/chat_message.dart';
import 'package:hirfahome/repositories/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? requestId;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.requestId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatRepository _chatRepository;
  final _messageController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatRepository = context.read<ChatRepository>();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getChatRoomId() {
    final List<String> ids = [_currentUser?.uid ?? '', widget.receiverId];
    ids.sort();
    return ids.join('_');
  }

  void _markMessagesAsRead() async {
    if (_currentUser != null) {
      await _chatRepository.markAsRead(_getChatRoomId(), _currentUser.uid);
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUser == null) return;

    _messageController.clear();

    final message = ChatMessage(
      senderId: _currentUser.uid,
      receiverId: widget.receiverId,
      message: text,
      requestId: widget.requestId,
      lu: false,
    );

    try {
      await _chatRepository.sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      _messageController.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'envoi : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: Text('Erreur d\'authentification.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1C),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE65100),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('En ligne', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.requestId != null) _buildDemandeBanner(),

          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatRepository.getMessages(_currentUser.uid, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
                }

                _markMessagesAsRead();

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12)),
                      child: Text('Début de votre conversation sécurisée', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients && _scrollController.position.pixels < 50) {
                    _scrollToBottom();
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _currentUser.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFE65100) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(msg.message, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14, height: 1.3)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_formatTime(msg.timestamp), style: TextStyle(color: isMe ? Colors.white70 : Colors.grey.shade500, fontSize: 9)),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    msg.lu ? Icons.done_all : Icons.check,
                                    size: 12,
                                    color: msg.lu ? Colors.blue.shade200 : Colors.white70,
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1))]),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFFF5F2EE), borderRadius: BorderRadius.circular(24)),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Écrivez votre message...',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE65100),
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandeBanner() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('demandes').doc(widget.requestId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
        final title = snapshot.data!['titre'] as String? ?? 'Demande d\'intervention';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFE65100).withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Color(0xFFE65100), size: 18),
              const SizedBox(width: 8),
              Text(
                'Lié à : $title',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100), fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}