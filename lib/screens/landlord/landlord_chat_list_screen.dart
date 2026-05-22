import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../screens/chat/chat_screen.dart';

// ─────────────────────────────────────────────
// LANDLORD CHAT LIST SCREEN
// Shows all student conversations
// for the landlord in real time.
// ─────────────────────────────────────────────
class LandlordChatListScreen extends StatefulWidget {
  const LandlordChatListScreen({super.key});

  @override
  State<LandlordChatListScreen> createState() =>
      _LandlordChatListScreenState();
}

class _LandlordChatListScreenState
    extends State<LandlordChatListScreen> {

  final AuthService _authService = AuthService();

  String get _currentUserId =>
      _authService.currentUser?.uid ?? '';

  // ─────────────────────────────────────────────
  // FORMAT TIMESTAMP
  // ─────────────────────────────────────────────
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final time = timestamp.toDate();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute =
          time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = [
        'Mon', 'Tue', 'Wed',
        'Thu', 'Fri', 'Sat', 'Sun'
      ];
      return days[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              Expanded(child: _buildChatList()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFDDE3F0)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Color(0xFFF09418),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'Student conversations',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF5C6B8A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chat list using stream ──
  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('landlordId',
              isEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
                color: Color(0xFFF09418)),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return _buildEmpty();
        }

        final chats = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
              horizontal: 24),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final data =
                chats[index].data()
                    as Map<String, dynamic>;
            return _buildChatItem(data);
          },
        );
      },
    );
  }

  // ── Empty state ──
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Students will contact you here',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat item ──
  Widget _buildChatItem(Map<String, dynamic> chat) {
    final String chatId = chat['chatId'] ?? '';
    final String studentId = chat['studentId'] ?? '';
    final String listingTitle =
        chat['listingTitle'] ?? '';
    final String lastMessage =
        chat['lastMessage'] ?? '';
    final Timestamp? lastMessageTime =
        chat['lastMessageTime'] as Timestamp?;
    final String initial = studentId.isNotEmpty
        ? studentId[0].toUpperCase()
        : 'S';
    final String timeStr = _formatTime(lastMessageTime);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId,
              receiverId: studentId,
              receiverName: 'Student',
              listingTitle: listingTitle,
              isLandlord: true,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFDDE3F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Student avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF2B658B),
              child: Text(
                initial,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Student',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    listingTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF5C6B8A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage.isEmpty
                        ? 'No messages yet'
                        : lastMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}