import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// LISTING AMENITIES WIDGET
// Shows amenity chips in a wrap layout
// ─────────────────────────────────────────────
class ListingAmenities extends StatelessWidget {
  final List<String> amenities;

  const ListingAmenities({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                amenity,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3B6D11),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}