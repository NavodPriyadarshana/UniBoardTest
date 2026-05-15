import 'package:flutter/material.dart';
import '../../models/listing_model.dart';
import '../../services/listing_service.dart';
import '../../widgets/student/home_header.dart';
import '../../widgets/student/home_search_bar.dart';
import '../../widgets/student/home_filter_chips.dart';
import '../../widgets/student/listing_card.dart';
import '../../widgets/student/bottom_nav_bar.dart';
import 'student_profile_screen.dart';

// ─────────────────────────────────────────────
// STUDENT HOME SCREEN
// Main screen shown after student logs in.
// Shows all verified listings from Firestore.
// Student can filter by any university.
// ─────────────────────────────────────────────
class StudentHomeScreen extends StatefulWidget {
  final String studentName;
  final String university;

  const StudentHomeScreen({
    super.key,
    required this.studentName,
    required this.university,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {

  int _selectedFilter = 0;
  int _selectedNav = 0;
  bool _isLoading = true;
  List<ListingModel> _listings = [];
  List<ListingModel> _filteredListings = [];

  final ListingService _listingService = ListingService();

  // Filter options
  final List<String> _filters = [
    'All',
    'Single',
    'Double',
    'Shared',
    'Male',
    'Female',
  ];

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  // ─────────────────────────────────────────────
  // FETCH ALL LISTINGS FROM FIRESTORE
  // Shows all verified listings
  // Student can filter/search as needed
  // ─────────────────────────────────────────────
  Future<void> _fetchListings() async {
    setState(() => _isLoading = true);
    try {
      // Fetch ALL listings — not restricted to one university
      final listings = await _listingService.getAllListings();

      if (mounted) {
        setState(() {
          _listings = listings;
          _filteredListings = listings;
        });
      }
    } catch (e) {
      print('❌ Error in _fetchListings: $e');
      if (mounted) {
        setState(() {
          _listings = [];
          _filteredListings = [];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // APPLY FILTER
  // Filters listings by room type or gender
  // ─────────────────────────────────────────────
  void _applyFilter(int index) {
    setState(() {
      _selectedFilter = index;
      if (index == 0) {
        // All — show everything
        _filteredListings = _listings;
      } else if (index == 4) {
        // Male filter
        _filteredListings = _listings
            .where((l) =>
                l.genderPreference.toLowerCase() == 'male' ||
                l.genderPreference.toLowerCase() == 'any')
            .toList();
      } else if (index == 5) {
        // Female filter
        _filteredListings = _listings
            .where((l) =>
                l.genderPreference.toLowerCase() == 'female' ||
                l.genderPreference.toLowerCase() == 'any')
            .toList();
      } else {
        // Filter by room type (Single, Double, Shared)
        _filteredListings = _listings
            .where((l) =>
                l.roomType.toLowerCase() ==
                _filters[index].toLowerCase())
            .toList();
      }
    });
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
                  color: const Color(0xFF2B658B),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        HomeHeader(studentName: widget.studentName),
                        const SizedBox(height: 16),
                        const HomeSearchBar(),
                        const SizedBox(height: 14),
                        HomeFilterChips(
                          selectedIndex: _selectedFilter,
                          onFilterSelected: _applyFilter,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle(),
                        const SizedBox(height: 12),
                        _buildListings(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              BottomNavBar(
                selectedIndex: _selectedNav,
                onItemSelected: (index) {
                  if (index == 4) {
                    // Navigate to profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentProfileScreen(
                          studentName: widget.studentName,
                          university: widget.university,
                        ),
                      ),
                    );
                  } else {
                    setState(() => _selectedNav = index);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section title ──
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedFilter == 0
                ? 'All Boardings'
                : _selectedFilter >= 4
                    ? '${_filters[_selectedFilter]} Preferred'
                    : '${_filters[_selectedFilter]} Rooms',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to all listings screen
            },
            child: Text(
              '${_filteredListings.length} found',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF09418),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Listings — loading, empty or list ──
  Widget _buildListings() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2B658B),
          ),
        ),
      );
    }

    if (_filteredListings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.home_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _listings.isEmpty
                    ? 'No listings available yet'
                    : 'No ${_filters[_selectedFilter]} rooms found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredListings.length,
      itemBuilder: (context, index) {
        return ListingCard(
          listing: _listingToMap(_filteredListings[index]),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // CONVERT ListingModel TO MAP FOR ListingCard
  // ─────────────────────────────────────────────
  Map<String, dynamic> _listingToMap(ListingModel listing) {
    return {
      'listingId': listing.listingId,
      'title': listing.title,
      'location': listing.location,
      'distance': listing.city.isNotEmpty ? listing.city : 'Sri Lanka',
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

  // ── Assign color based on room type ──
  Color _getRoomColor(String roomType) {
    switch (roomType.toLowerCase()) {
      case 'single':
        return const Color(0xFFF09418);
      case 'double':
        return const Color(0xFF3B8B65);
      case 'shared':
        return const Color(0xFF2B658B);
      default:
        return const Color(0xFF2B658B);
    }
  }
}