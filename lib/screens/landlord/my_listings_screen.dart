import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'add_listing_screen.dart';
import 'edit_listing_screen.dart';

// ─────────────────────────────────────────────
// MY LISTINGS SCREEN
// Shows all listings created by the landlord.
// Landlord can view, edit or delete listings.
// ─────────────────────────────────────────────
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() =>
      _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {

  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  // ─────────────────────────────────────────────
  // FETCH LANDLORD LISTINGS FROM FIRESTORE
  // ─────────────────────────────────────────────
  Future<void> _fetchListings() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .where('landlordId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _listings = snapshot.docs
              .map((doc) => doc.data())
              .toList();
        });
      }
    } catch (e) {
      print('❌ Error fetching listings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // DELETE LISTING
  // ─────────────────────────────────────────────
  Future<void> _deleteListing(String listingId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Listing',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E))),
        content: Text(
            'Are you sure you want to delete this listing?',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: const Color(0xFFF09418),
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('listings')
                    .doc(listingId)
                    .delete();
                _fetchListings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Listing deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Delete error: $e');
              }
            },
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F9EE), Color(0xFFF1F3FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchListings,
                  color: const Color(0xFFF09418),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 8),
                        _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 60),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFFF09418)),
                                ),
                              )
                            : _listings.isEmpty
                                ? _buildEmpty()
                                : _buildListings(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and Add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFDDE3F0)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color(0xFFF09418),
                    size: 18,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AddListingScreen()),
                  );
                  _fetchListings();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF09418),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('Add',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'My Listings',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your boarding listings',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF5C6B8A),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ──
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 60, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.home_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No listings yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap Add to create your first listing',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddListingScreen()),
                );
                _fetchListings();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF09418),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Add Listing',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Listings list ──
  Widget _buildListings() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        return _buildListingCard(_listings[index]);
      },
    );
  }

  // ── Listing card ──
  Widget _buildListingCard(Map<String, dynamic> listing) {
    final String listingId = listing['listingId'] ?? '';
    final String roomType = listing['roomType'] ?? 'Single';
    final String location = listing['location'] ?? '';
    final double price =
        (listing['pricePerSlot'] as num? ?? 0).toDouble();
    final int totalSlots = listing['totalCapacity'] as int? ?? 0;
    final int availableSlots =
        listing['availableSlots'] as int? ?? 0;
    final int occupied = totalSlots - availableSlots;
    final bool isVerified = listing['isVerified'] as bool? ?? false;

    final Color cardColor = roomType == 'Single'
        ? const Color(0xFFF09418)
        : roomType == 'Double'
            ? const Color(0xFF3B8B65)
            : const Color(0xFF2B658B);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16)),
            child: Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor,
                    cardColor.withOpacity(0.7)
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.home_rounded,
                        size: 40,
                        color: Colors.white.withOpacity(0.2)),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(roomType,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cardColor)),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? const Color(0xFFEAF3DE)
                            : const Color(0xFFFFF8EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isVerified ? 'Verified' : 'Pending',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isVerified
                                ? const Color(0xFF3B6D11)
                                : const Color(0xFFF09418)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  listing['title'] ?? 'Listing',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13,
                        color: Color(0xFFF09418)),
                    const SizedBox(width: 4),
                    Text(location,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF5C6B8A))),
                  ],
                ),
                const SizedBox(height: 10),

                // Price and action buttons
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LKR ${_formatPrice(price.toInt())}/mo',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF09418),
                      ),
                    ),
                    Row(
                      children: [
                        // Edit button
                        GestureDetector(
                          onTap: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditListingScreen(
                                  listing: listing,
                                ),
                              ),
                            );
                            if (updated == true) _fetchListings();
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8EC),
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(
                                      0xFFF09418)),
                            ),
                            child: const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: Color(0xFFF09418)),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Delete button
                        GestureDetector(
                          onTap: () =>
                              _deleteListing(listingId),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(
                                      0xFFFFCCCC)),
                            ),
                            child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: Color(0xFFE53935)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Stats row
                Row(
                  children: [
                    _buildStat('Slots',
                        '$occupied/$totalSlots'),
                    const SizedBox(width: 8),
                    _buildStat('Available',
                        '$availableSlots'),
                    const SizedBox(width: 8),
                    _buildStat('Status',
                        isVerified ? 'Active' : 'Pending',
                        color: isVerified
                            ? const Color(0xFF3B6D11)
                            : const Color(0xFFF09418)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value,
      {Color color = const Color(0xFF1A1A2E)}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade500)),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
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