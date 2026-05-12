import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/student/listing_detail_screen.dart';

// ─────────────────────────────────────────────
// LISTING CARD WIDGET
// Shows individual boarding listing details.
// Tapping navigates to ListingDetailScreen.
// ─────────────────────────────────────────────
class ListingCard extends StatefulWidget {
  final Map<String, dynamic> listing;

  const ListingCard({super.key, required this.listing});

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final Color cardColor = listing['color'] as Color;
    final int slotsLeft = listing['slotsLeft'] as int;

    return GestureDetector(
      onTap: () {
        // Navigate to listing detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(listing: widget.listing),
          ),
        );
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDDE3F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageArea(cardColor, slotsLeft, listing['roomType']),
            _buildCardBody(listing),
          ],
        ),
      ),
    );
  }

  // ── Image area with badges ──
  Widget _buildImageArea(Color cardColor, int slotsLeft, String roomType) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Container(
        height: 148,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor, cardColor.withOpacity(0.7)],
          ),
        ),
        child: Stack(
          children: [
            // Background icon
            Center(
              child: Icon(
                Icons.home_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.2),
              ),
            ),

            // Room type badge
            Positioned(
              top: 12, left: 12,
              child: _Badge(
                label: roomType,
                bgColor: Colors.white.withOpacity(0.92),
                textColor: cardColor,
              ),
            ),

            // Slots left badge
            Positioned(
              top: 12, right: 12,
              child: _Badge(
                label: '$slotsLeft slot${slotsLeft == 1 ? '' : 's'} left',
                bgColor: slotsLeft <= 2
                    ? const Color(0xFFF09418)
                    : const Color(0xFF2B658B),
                textColor: Colors.white,
              ),
            ),

            // Save button
            Positioned(
              bottom: 12, right: 12,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 18,
                  color: Color(0xFF2B658B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card body with details ──
  Widget _buildCardBody(Map<String, dynamic> listing) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Title and rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  listing['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      size: 16, color: Color(0xFFF09418)),
                  const SizedBox(width: 2),
                  Text(
                    listing['rating'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Location and distance
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 14, color: Color(0xFF2B658B)),
              const SizedBox(width: 4),
              Text(
                listing['location'],
                style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF5C6B8A)),
              ),
              const SizedBox(width: 4),
              Text(
                '• ${listing['distance']}',
                style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Price and verified badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'LKR ${_formatPrice(listing['price'])}',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2B658B),
                      ),
                    ),
                    TextSpan(
                      text: ' /month',
                      style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              if (listing['isVerified'] == true) const _VerifiedBadge(),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

// ─────────────────────────────────────────────
// BADGE WIDGET
// ─────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VERIFIED BADGE WIDGET
// ─────────────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 13, color: Color(0xFF3B6D11)),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B6D11),
            ),
          ),
        ],
      ),
    );
  }
}
