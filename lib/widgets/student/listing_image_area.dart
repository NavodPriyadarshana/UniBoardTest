import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// LISTING IMAGE AREA WIDGET
// Shows listing photo placeholder with
// back button, save button and badges.
// ─────────────────────────────────────────────
class ListingImageArea extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingImageArea({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final Color cardColor = listing['color'] as Color? ?? const Color(0xFF2B658B);
    final int slotsLeft = listing['slotsLeft'] as int? ?? 0;

    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        children: [
          // Background gradient image area
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cardColor, cardColor.withOpacity(0.7)],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.home_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Save button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          // Room type badge
          Positioned(
            bottom: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                listing['roomType'] ?? 'Single',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cardColor,
                ),
              ),
            ),
          ),

          // Slots left badge
          Positioned(
            bottom: 14,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: slotsLeft <= 2
                    ? const Color(0xFFF09418)
                    : const Color(0xFF2B658B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$slotsLeft slot${slotsLeft == 1 ? '' : 's'} left',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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