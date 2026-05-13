import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// LISTING HOUSE RULES WIDGET
// Shows house rules set by landlord
// ─────────────────────────────────────────────
class ListingHouseRules extends StatelessWidget {
  final String rules;

  const ListingHouseRules({super.key, required this.rules});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'House rules',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE3F0)),
          ),
          child: Text(
            rules,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF5C6B8A),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}