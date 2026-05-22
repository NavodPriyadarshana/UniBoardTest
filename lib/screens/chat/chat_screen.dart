import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

// ─────────────────────────────────────────────
// CHAT SCREEN
// Real time messaging between student
// and landlord using Firestore streams.
// ─────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String listingTitle;
  final bool isLandlord;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    required this.listingTitle,
    this.isLandlord = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _messageController =
      TextEditingController();
  final ScrollController _scrollController =
      ScrollController();
  final AuthService _authService = AuthService();

  String get _currentUserId =>
      _authService.currentUser?.uid ?? '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SEND MESSAGE
  // Saves message to Firestore subcollection
  // ─────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      final messageId = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc()
          .id;

      // Save message to subcollection
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .set({
        'messageId': messageId,
        'senderId': _currentUserId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update last message in chat document
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      print('❌ Error sending message: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F9EE), Color(0xFFF1F3FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMessages()),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    final String initial = widget.receiverName.isNotEmpty
        ? widget.receiverName[0].toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: widget.isLandlord
            ? const Color(0xFFF09418)
            : const Color(0xFF2B658B),
      ),
      child: Row(
        children: [
          // ── Back button ──
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // ── Landlord avatar ──
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Landlord name and listing ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.listingTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Messages stream ──
  Widget _buildMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
                color: Color(0xFF2B658B)),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No messages yet',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start the conversation!',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data!.docs;

        // Scroll to bottom on new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data =
                messages[index].data() as Map<String, dynamic>;
            final bool isMe =
                data['senderId'] == _currentUserId;

            // Show date divider
            final showDivider = index == 0;

            return Column(
              children: [
                if (showDivider) _buildDateDivider('Today'),
                _buildMessageBubble(data, isMe),
              ],
            );
          },
        );
      },
    );
  }

  // ── Date divider ──
  Widget _buildDateDivider(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8),
            child: Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          Expanded(
              child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  // ── Message bubble ──
  Widget _buildMessageBubble(
      Map<String, dynamic> data, bool isMe) {
    final String message = data['message'] ?? '';
    final Timestamp? timestamp =
        data['timestamp'] as Timestamp?;
    final String time = timestamp != null
        ? _formatTime(timestamp.toDate())
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF2B658B),
              child: Text(
                widget.receiverName.isNotEmpty
                    ? widget.receiverName[0].toUpperCase()
                    : 'U',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? (widget.isLandlord
                            ? const Color(0xFFF09418)
                            : const Color(0xFF2B658B))
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft:
                          Radius.circular(isMe ? 14 : 0),
                      bottomRight:
                          Radius.circular(isMe ? 0 : 14),
                    ),
                    border: isMe
                        ? null
                        : Border.all(
                            color:
                                const Color(0xFFDDE3F0)),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isMe
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all_rounded,
                          size: 14,
                          color: widget.isLandlord
                              ? const Color(0xFFF09418)
                              : const Color(0xFF2B658B)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Input area ──
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFDDE3F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.isLandlord
                    ? const Color(0xFFF09418)
                    : const Color(0xFF2B658B),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}