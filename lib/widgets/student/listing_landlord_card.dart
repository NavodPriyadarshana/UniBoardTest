import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../screens/chat/chat_screen.dart';

// ─────────────────────────────────────────────
// LISTING LANDLORD CARD WIDGET
// Shows landlord info with chat and call buttons
// ─────────────────────────────────────────────
class ListingLandlordCard extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingLandlordCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final String landlordName =
        listing['landlordName'] ?? 'Landlord';
    final String initial = landlordName.isNotEmpty
        ? landlordName[0].toUpperCase()
        : 'L';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Landlord',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFDDE3F0)),
          ),
          child: Row(
            children: [
              // Landlord avatar
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

              // Name and verified label
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      landlordName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'Verified Landlord',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              // Chat button
              GestureDetector(
                onTap: () async {
                  final authService = AuthService();
                  final chatService = ChatService();
                  final currentUser =
                      authService.currentUser;
                  if (currentUser == null) return;

                  try {
                    final chatId =
                        await chatService.getOrCreateChat(
                      studentId: currentUser.uid,
                      landlordId:
                          listing['landlordId'] ?? '',
                      listingId:
                          listing['listingId'] ?? '',
                      listingTitle:
                          listing['title'] ?? '',
                    );

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            receiverId:
                                listing['landlordId'] ??
                                    '',
                            receiverName: landlordName,
                            listingTitle:
                                listing['title'] ?? '',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    print('❌ Chat error: $e');
                  }
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: Color(0xFF3B6D11),
                  ),
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }
}