// ═══ FILE: lib/views/shared/chat_screen.dart ═══
import "dart:ui";
//
// HirfaHome — Real-time chat screen.
//
// Professional redesign using AppTheme design system:
//  - AppColors / AppSpacing / AppRadius / AppTextStyles tokens
//  - AppDecorations for cards and inputs
//  - StatusBadge for linked-request banner
//  - EmptyState for first-message state
//  - Localized strings (FR/AR/EN) via AppStrings
//  - Read-receipt indicators (✓ / ✓✓)
//  - Smooth auto-scroll to latest message
//  - Date dividers between messages from different days
//  - RTL-friendly (handled centrally by MaterialApp.builder)
//
// Security:
//  - Messages are gated by Firestore rules — only the two room participants
//    can read/write (room ID = sorted UIDs joined with '_').
//  - The receiver can only mark messages as read (update 'lu' field).
//  - Sender can only create messages where senderId == auth.uid.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/models/chat_message.dart';
import 'package:hirfahome/repositories/chat_repository.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/widgets/empty_state.dart';
import 'package:hirfahome/widgets/error_state.dart';
import 'package:hirfahome/widgets/glass_scaffold.dart';
import 'package:hirfahome/widgets/glass_container.dart';
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
  final _scrollController = ScrollController();
  final _currentUser = FirebaseAuth.instance.currentUser;
  bool _isSending = false;
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
  /// Builds the deterministic chat room ID from the two participants' UIDs.
  /// Convention: UIDs sorted alphabetically and joined with '_'.
  /// This guarantees that two users always share the same room ID regardless
  /// of who initiated the conversation.
  String _getChatRoomId() {
    final ids = [_currentUser?.uid ?? '', widget.receiverId];
    ids.sort();
    return ids.join('_');
  }
  /// Marks all unread messages in this room as read.
  /// Called on init and on each new message arrival.
  Future<void> _markMessagesAsRead() async {
    if (_currentUser == null) return;
    try {
      await _chatRepository.markAsRead(_getChatRoomId(), _currentUser.uid);
    } catch (_) {
      // Silent — non-critical failure.
    }
  }
  /// Sends the message currently in the input field.
  /// Resets the field immediately for snappy UX, restores it on failure.
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUser == null) return;
    setState(() => _isSending = true);
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
      // Restore the text so the user can retry.
      _messageController.text = text;
      if (!mounted) return;
      final lang = context.read<LanguageViewModel>().lang;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t('chat_send_error', lang)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
          margin: const EdgeInsets.all(AppSpacing.base),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  /// Formats a DateTime as "HH:mm" (24-hour).
  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  /// Formats a DateTime as a date divider label.
  /// Today → "Aujourd'hui", Yesterday → "Hier", older → "dd/MM/yyyy".
  String _formatDateDivider(DateTime date, String lang) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) {
      return lang == 'ar' ? 'اليوم' : (lang == 'en' ? 'Today' : "Aujourd'hui");
    }
    if (diff == 1) {
      return lang == 'ar' ? 'أمس' : (lang == 'en' ? 'Yesterday' : 'Hier');
    }
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>().lang;
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar(title: widget.receiverName),
        body: ErrorState(
          message: AppStrings.t('chat_auth_error', lang),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _ChatAppBar(
        receiverName: widget.receiverName,
        lang: lang,
      ),
      body: Column(
        children: [
          // Optional banner showing the linked request.
          if (widget.requestId != null) _buildDemandeBanner(lang),
          // Message list.
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatRepository.getMessages(
                _currentUser.uid,
                widget.receiverId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: AppStrings.t('chat_load_error', lang),
                  );
                }
                // Mark messages as read whenever new data arrives.
                _markMessagesAsRead();
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return EmptyState(
                    icon: Icons.forum_outlined,
                    title: AppStrings.t('chat_empty_title', lang),
                    message: AppStrings.t('chat_empty_message', lang),
                  );
                }
                // Auto-scroll to bottom when new messages arrive.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients &&
                      _scrollController.position.pixels < 50) {
                    _scrollToBottom();
                  }
                });
                return _MessageList(
                  messages: messages,
                  currentUserId: _currentUser.uid,
                  scrollController: _scrollController,
                  formatDate: (d) => _formatDateDivider(d, lang),
                  formatTime: _formatTime,
                );
              },
            ),
          ),
          // Input bar.
          _ChatInputBar(
            controller: _messageController,
            isSending: _isSending,
            onSend: _sendMessage,
            lang: lang,
          ),
        ],
      ),
    );
  }
  /// Builds the banner showing the linked request (if any).
  /// Displays the request title and a small "Lié à la demande" caption.
  Widget _buildDemandeBanner(String lang) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('demandes')
          .doc(widget.requestId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final title = (data?['titre'] as String?)?.isNotEmpty == true
            ? data!['titre'] as String
            : AppStrings.t('chat_linked_to_request', lang);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.t('chat_linked_to_request', lang),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════════════════
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String receiverName;
  final String lang;
  const _ChatAppBar({required this.receiverName, required this.lang});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.55),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: NavigationToolbar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : AppColors.textPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                middle: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _initials(receiverName),
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receiverName,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary),
                          ),
                          Row(
                            children: [
                              Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.t('chat_online', lang),
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  /// Returns the initials of a name (e.g. "Mohamed B." → "MB").
  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    final first = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    final last = parts[1].isNotEmpty ? parts[1][0].toUpperCase() : '';
    return '$first$last';
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// MESSAGE LIST (with date dividers)
// ═══════════════════════════════════════════════════════════════════════════
class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final String currentUserId;
  final ScrollController scrollController;
  final String Function(DateTime) formatDate;
  final String Function(DateTime?) formatTime;
  const _MessageList({
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    required this.formatDate,
    required this.formatTime,
  });
  @override
  Widget build(BuildContext context) {
    // Sort messages chronologically (oldest first).
    // The ListView is reversed, so we iterate from newest to oldest.
    final sorted = List<ChatMessage>.from(messages)
      ..sort((a, b) {
        final at = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final msg = sorted[index];
        final isMe = msg.senderId == currentUserId;
        // Show date divider when the day changes between this message and
        // the next-older one.
        final older = index + 1 < sorted.length ? sorted[index + 1] : null;
        final showDateDivider = _shouldShowDateDivider(msg, older);
        return Column(
          children: [
            if (showDateDivider && msg.timestamp != null)
              _DateDivider(date: msg.timestamp!, label: formatDate(msg.timestamp!)),
            _MessageBubble(
              message: msg,
              isMe: isMe,
              formatTime: formatTime,
            ),
          ],
        );
      },
    );
  }
  /// Returns true when the message is from a different day than the
  /// previous one (or when there is no previous message).
  bool _shouldShowDateDivider(ChatMessage current, ChatMessage? previous) {
    if (previous == null) return true;
    final c = current.timestamp;
    final p = previous.timestamp;
    if (c == null || p == null) return false;
    return c.year != p.year || c.month != p.month || c.day != p.day;
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ═══════════════════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String Function(DateTime?) formatTime;
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.formatTime,
  });
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(isMe ? AppRadius.lg : AppRadius.xs),
            bottomRight: Radius.circular(isMe ? AppRadius.xs : AppRadius.lg),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 0.5,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Message body.
            Text(
              message.message,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.35,
                color: isMe ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Timestamp + read receipt.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isMe
                        ? AppColors.onPrimary.withValues(alpha: 0.7)
                        : AppColors.textHint,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.lu ? Icons.done_all_rounded : Icons.check_rounded,
                    size: 13,
                    color: message.lu
                        ? AppColors.onPrimary.withValues(alpha: 0.95)
                        : AppColors.onPrimary.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// DATE DIVIDER
// ═══════════════════════════════════════════════════════════════════════════
class _DateDivider extends StatelessWidget {
  final DateTime date;
  final String label;
  const _DateDivider({required this.date, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// INPUT BAR
// ═══════════════════════════════════════════════════════════════════════════
class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final String lang;
  const _ChatInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.lang,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 120),
          child: GlassContainer(
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text field (expands).
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: AppStrings.t('chat_input_hint', lang),
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Send button (circular).
                _SendButton(
                  isSending: isSending,
                  onPressed: onSend,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _SendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onPressed;
  const _SendButton({required this.isSending, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isSending ? null : onPressed,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: isSending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: AppColors.onPrimary,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
