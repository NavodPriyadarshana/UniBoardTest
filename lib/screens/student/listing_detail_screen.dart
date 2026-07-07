import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/student/listing_image_area.dart';
import '../../widgets/student/listing_info_section.dart';
import '../../widgets/student/listing_amenities.dart';
import '../../widgets/student/listing_house_rules.dart';
import '../../widgets/student/listing_landlord_card.dart';
import '../../widgets/student/listing_book_button.dart';
import '../../widgets/student/listing_reviews_widget.dart';

// ─────────────────────────────────────────────
// LISTING DETAIL SCREEN
// Shows full details of a boarding listing.
// Navigated to when student taps a listing card.
// ─────────────────────────────────────────────
class ListingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> listing;

  const ListingDetailScreen({
    super.key,
    required this.listing,
  });

  @override
  State<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState
    extends State<ListingDetailScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Book Button with Fully Booked check ──
  Widget _buildBookButton() {
    final availableSlots = widget.listing['availableSlots'];
    final totalCapacity = widget.listing['totalCapacity'];
    final currentOccupants = widget.listing['currentOccupants'];



    final int slots = (availableSlots as num? ?? 0).toInt();
    final int total = (totalCapacity as num? ?? 0).toInt();
    final int occupants = (currentOccupants as num? ?? 0).toInt();

    final bool isFullyBooked =
        slots <= 0 || (total > 0 && occupants >= total);



    if (isFullyBooked) {
      return Container(
        margin: const EdgeInsets.all(16),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Fully Booked',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }
    return ListingBookButton(listing: widget.listing);
  }

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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoGallery(),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          ListingInfoSection(
                              listing: widget.listing),
                          const SizedBox(height: 16),

                          _buildStatCards(),
                          const SizedBox(height: 16),

                          ListingAmenities(
                            amenities: List<String>.from(
                              widget.listing['amenities'] ??
                                  ['WiFi', 'AC', 'Cooking'],
                            ),
                          ),
                          const SizedBox(height: 16),

                          ListingHouseRules(
                            rules: widget.listing['houseRules'] ??
                                'Gate closes at 9:00 PM.',
                          ),
                          const SizedBox(height: 16),

                          ListingLandlordCard(
                              listing: widget.listing),
                          const SizedBox(height: 16),

                          // ── Location Map Section ──
                          _buildMapSection(),
                          const SizedBox(height: 16),

                          // ── Reviews Section ──
                          Text(
                            'Reviews',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListingReviewsWidget(
                            listingId:
                                widget.listing['listingId'] ?? '',
                          ),
                          const SizedBox(height: 16),

                          _buildVisitWarning(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildBookButton(),
          ],
        ),
      ),
    );
  }

  // ── Google Maps Section ──
  Widget _buildMapSection() {
    final double lat =
        (widget.listing['latitude'] as num? ?? 6.9271)
            .toDouble();
    final double lng =
        (widget.listing['longitude'] as num? ?? 79.8612)
            .toDouble();

    final LatLng position = LatLng(lat, lng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 200,
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: position,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('listing'),
                  position: position,
                  infoWindow: InfoWindow(
                    title: widget.listing['title'] ?? 'Boarding',
                    snippet:
                        widget.listing['location'] ?? '',
                  ),
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                size: 14, color: Color(0xFF2B658B)),
            const SizedBox(width: 8),
            Text(
              widget.listing['location'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF5C6B8A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Photo Gallery ──
  Widget _buildPhotoGallery() {
    final List<dynamic> photos =
        widget.listing['photos'] as List<dynamic>? ?? [];

    if (photos.isEmpty) {
      return ListingImageArea(listing: widget.listing);
    }

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Image.network(
                    photos[index],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 250,
                        color: const Color(0xFF2B658B),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) {
                      return ListingImageArea(
                          listing: widget.listing);
                    },
                  ),
                  // Photo counter
                  Positioned(
                    bottom: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${index + 1}/${photos.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Back button ──
          Positioned(
            top: 25,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Color(0xFF2B658B),
                      size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final stats = [
      {
        'label': 'Monthly Rent',
        'value':
            'LKR ${_formatPrice(widget.listing['price'] ?? 0)}',
        'color': const Color(0xFF2B658B),
      },
      {
        'label': 'Available Slots',
        'value':
            '${widget.listing['slotsLeft'] ?? 0} of ${widget.listing['totalCapacity'] ?? 4}',
        'color': const Color(0xFFF09418),
      },
      {
        'label': 'Room Type',
        'value': widget.listing['roomType'] ?? 'Single',
        'color': const Color(0xFF1A1A2E),
      },
      {
        'label': 'Gender',
        'value': widget.listing['gender'] ?? 'Any',
        'color': const Color(0xFF1A1A2E),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: const Color(0xFFDDE3F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stat['label'] as String,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500),
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
          const Icon(Icons.info_outline_rounded,
              size: 18, color: Color(0xFFF09418)),
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