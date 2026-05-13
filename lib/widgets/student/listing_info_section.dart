import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// LISTING INFO SECTION WIDGET
// Shows title, verified badge and location
// ─────────────────────────────────────────────
class ListingInfoSection extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingInfoSection({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and verified badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                listing['title'] ?? 'Boarding Room',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (listing['isVerified'] == true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: Color(0xFF3B6D11),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3B6D11),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Location and distance
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 14,
              color: Color(0xFF2B658B),
            ),
            const SizedBox(width: 4),
            Text(
              listing['location'] ?? 'Colombo',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF5C6B8A),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '• ${listing['distance'] ?? '1 km away'}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}