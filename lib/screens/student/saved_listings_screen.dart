import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/listing_model.dart';
import '../../widgets/student/listing_card.dart';

// ─────────────────────────────────────────────
// SAVED LISTINGS SCREEN
// Shows all listings saved by the student.
// Student can unsave listings from here.
// ─────────────────────────────────────────────
class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() =>
      _SavedListingsScreenState();
}

class _SavedListingsScreenState
    extends State<SavedListingsScreen> {

  final AuthService _authService = AuthService();
  List<ListingModel> _savedListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedListings();
  }

  // ─────────────────────────────────────────────
  // FETCH SAVED LISTINGS
  // Gets saved listing IDs from user document
  // then fetches each listing from Firestore
  // ─────────────────────────────────────────────
  Future<void> _fetchSavedListings() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // Get user document with saved listings
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return;

      final savedIds = List<String>.from(
          userDoc.data()?['savedListings'] ?? []);

      if (savedIds.isEmpty) {
        if (mounted) setState(() => _savedListings = []);
        return;
      }

      // Fetch each saved listing
      final List<ListingModel> listings = [];
      for (final id in savedIds) {
        final doc = await FirebaseFirestore.instance
            .collection('listings')
            .doc(id)
            .get();
        if (doc.exists) {
          listings.add(ListingModel.fromFirestore(doc));
        }
      }

      if (mounted) setState(() => _savedListings = listings);
    } catch (e) {
      print('❌ Error fetching saved listings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  onRefresh: _fetchSavedListings,
                  color: const Color(0xFF2B658B),
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 8),
                        _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 60),
                                child: Center(
                                  child:
                                      CircularProgressIndicator(
                                          color: Color(
                                              0xFF2B658B)),
                                ),
                              )
                            : _savedListings.isEmpty
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
                color: Color(0xFF2B658B),
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Saved Listings',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your favourite boarding listings',
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
            Icon(Icons.favorite_border_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No saved listings yet',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any listing to save it',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Listings ──
  Widget _buildListings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '${_savedListings.length} saved',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF09418),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _savedListings.length,
          itemBuilder: (context, index) {
            return ListingCard(
              listing: _listingToMap(_savedListings[index]),
            );
          },
        ),
      ],
    );
  }

  // ── Convert ListingModel to Map ──
  Map<String, dynamic> _listingToMap(ListingModel listing) {
    return {
      'listingId': listing.listingId,
      'title': listing.title,
      'location': listing.location,
      'distance': listing.city.isNotEmpty
          ? listing.city
          : 'Sri Lanka',
      'price': listing.pricePerSlot.toInt(),
      'rating': 4.5,
      'roomType': listing.roomType,
      'slotsLeft': listing.availableSlots,
      'totalCapacity': listing.totalCapacity,
      'isVerified': listing.isVerified,
      'color': _getRoomColor(listing.roomType),
      'landlordId': listing.landlordId,
      'landlordName': 'Landlord',
      'gender': listing.genderPreference,
      'amenities': listing.amenities,
      'houseRules': listing.houseRules,
      'photos': listing.photos,
      'city': listing.city,
      'university': listing.university,
      'latitude': listing.latitude,
      'longitude': listing.longitude,
    };
  }

  Color _getRoomColor(String roomType) {
    switch (roomType.toLowerCase()) {
      case 'single': return const Color(0xFFF09418);
      case 'double': return const Color(0xFF3B8B65);
      default:       return const Color(0xFF2B658B);
    }
  }
}