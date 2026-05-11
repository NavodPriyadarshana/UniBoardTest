import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// HOME HEADER WIDGET
// Shows time-based greeting, student name
// and profile avatar with initial letter.
// ─────────────────────────────────────────────
class HomeHeader extends StatelessWidget {
  final String studentName;

  const HomeHeader({super.key, required this.studentName});

  // Returns greeting based on time of day
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting and name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2B658B),
                ),
              ),
              Text(
                '$studentName 👋',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          // Profile avatar with initial letter
          GestureDetector(
            onTap: () {
              // TODO: Navigate to profile screen
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2B658B),
              child: Text(
                studentName.isNotEmpty
                    ? studentName[0].toUpperCase()
                    : 'S',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}