import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/student/listing_image_area.dart';
import '../../widgets/student/listing_info_section.dart';
import '../../widgets/student/listing_amenities.dart';
import '../../widgets/student/listing_house_rules.dart';
import '../../widgets/student/listing_landlord_card.dart';
import '../../widgets/student/listing_book_button.dart';

// ─────────────────────────────────────────────
// LISTING DETAIL SCREEN
// Shows full details of a boarding listing.
// Navigated to when student taps a listing card.
// ─────────────────────────────────────────────
class ListingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingDetailScreen({
    super.key,
    required this.listing,
  });

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
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image area with back and save buttons
                    ListingImageArea(listing: listing),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title, verified badge, location
                          ListingInfoSection(listing: listing),
                          const SizedBox(height: 16),

                          // Stat cards — price, slots, type, gender
                          _buildStatCards(),
                          const SizedBox(height: 16),

                          // Amenities
                          ListingAmenities(
                            amenities: List<String>.from(
                              listing['amenities'] ?? ['WiFi', 'AC', 'Cooking'],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // House rules
                          ListingHouseRules(
                            rules: listing['houseRules'] ??
                                'Gate closes at 9:00 PM. No visitors after 8:00 PM. Quiet hours after 10:00 PM.',
                          ),
                          const SizedBox(height: 16),

                          // Landlord card
                          ListingLandlordCard(listing: listing),
                          const SizedBox(height: 16),

                          // Rating and reviews
                          _buildRating(),
                          const SizedBox(height: 16),

                          // Physical visit warning
                          _buildVisitWarning(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Book button pinned at bottom ──
            ListingBookButton(listing: listing),
          ],
        ),
      ),
    );
  }

  // ── 4 stat cards: Price, Slots, Type, Gender ──
  Widget _buildStatCards() {
    final stats = [
      {
        'label': 'Monthly Rent',
        'value': 'LKR ${_formatPrice(listing['price'] ?? 0)}',
        'color': const Color(0xFF2B658B),
      },
      {
        'label': 'Available Slots',
        'value': '${listing['slotsLeft'] ?? 0} of ${listing['totalCapacity'] ?? 4}',
        'color': const Color(0xFFF09418),
      },
      {
        'label': 'Room Type',
        'value': listing['roomType'] ?? 'Single',
        'color': const Color(0xFF1A1A2E),
      },
      {
        'label': 'Gender',
        'value': listing['gender'] ?? 'Any',
        'color': const Color(0xFF1A1A2E),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE3F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stat['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                stat['value'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: stat['color'] as Color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Star rating and reviews ──
  Widget _buildRating() {
    final double rating = (listing['rating'] ?? 4.5).toDouble();
    return Row(
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : (i < rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
            size: 18,
            color: const Color(0xFFF09418),
          );
        }),
        const SizedBox(width: 6),
        Text(
          '$rating (12 reviews)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF5C6B8A),
          ),
        ),
      ],
    );
  }

  // ── Physical visit warning ──
  Widget _buildVisitWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF09418)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFFF09418),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Physical visit recommended before making any payment',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF854F0B),
                height: 1.4,
              ),
            ),
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