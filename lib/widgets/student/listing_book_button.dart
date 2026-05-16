import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/student/booking_request_screen.dart';

// ─────────────────────────────────────────────
// LISTING BOOK BUTTON WIDGET
// Pinned at bottom — Request Booking button
// Navigates to BookingRequestScreen on tap
// ─────────────────────────────────────────────
class ListingBookButton extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingBookButton({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFDDE3F0), width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingRequestScreen(
                listing: listing,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF2B658B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B658B).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Request Booking',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}