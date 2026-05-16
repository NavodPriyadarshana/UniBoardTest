import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/listing_model.dart';
import '../../services/listing_service.dart';
import '../../widgets/student/listing_card.dart';

// ─────────────────────────────────────────────
// SEARCH SCREEN
// University filter first then search bar
// then room type, price and gender filters.
// ─────────────────────────────────────────────
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController _searchController =
      TextEditingController();
  final ListingService _listingService = ListingService();

  List<ListingModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  String? _selectedUniversity;
  String? _selectedRoomType;
  String? _selectedGender;
  double? _selectedMaxPrice;

  static const List<String> _universities = [
    'SLTC Research University',
    'University of Colombo',
    'University of Moratuwa',
    'University of Kelaniya',
    'University of Sri Jayewardenepura',
    'University of Peradeniya',
    'University of Ruhuna',
    'University of Jaffna',
    'NSBM Green University',
    'SLIIT - Sri Lanka Institute of IT',
    'IIT - Informatics Institute of Technology',
    'Other',
  ];

  static const List<String> _roomTypes = [
    'Single',
    'Double',
    'Shared',
  ];

  static const List<String> _genders = [
    'Any',
    'Male',
    'Female',
  ];

  static const List<Map<String, dynamic>> _prices = [
    {'label': 'Up to LKR 5,000',  'value': 5000.0},
    {'label': 'Up to LKR 8,000',  'value': 8000.0},
    {'label': 'Up to LKR 12,000', 'value': 12000.0},
    {'label': 'Up to LKR 20,000', 'value': 20000.0},
    {'label': 'Any Price',        'value': null},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SEARCH LISTINGS
  // ─────────────────────────────────────────────
  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    try {
      final results = await _listingService.searchListings(
        university: _selectedUniversity,
        roomType: _selectedRoomType,
        gender: _selectedGender == 'Any' ? null : _selectedGender,
        maxPrice: _selectedMaxPrice,
      );

      // Further filter by location text if entered
      final query = _searchController.text.trim().toLowerCase();
      final filtered = query.isEmpty
          ? results
          : results.where((l) {
              return l.title.toLowerCase().contains(query) ||
                  l.location.toLowerCase().contains(query) ||
                  l.city.toLowerCase().contains(query) ||
                  l.university.toLowerCase().contains(query) ||
                  l.description.toLowerCase().contains(query);
            }).toList();

      if (mounted) setState(() => _results = filtered);
    } catch (e) {
      print('❌ Search error: $e');
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // CLEAR FILTERS
  // ─────────────────────────────────────────────
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedUniversity = null;
      _selectedRoomType = null;
      _selectedGender = null;
      _selectedMaxPrice = null;
      _results = [];
      _hasSearched = false;
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 4),

                // ── Step 1: University filter (full width) ──
                _buildUniversityFilter(),
                const SizedBox(height: 12),

                // ── Step 2: Search bar ──
                _buildSearchBar(),
                const SizedBox(height: 12),

                // ── Step 3: Other filters (grid) ──
                _buildOtherFilters(),
                const SizedBox(height: 16),

                // ── Search button ──
                _buildSearchButton(),
                const SizedBox(height: 16),

                // ── Results ──
                if (_hasSearched) _buildResults(),
                const SizedBox(height: 16),
              ],
            ),
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
          // ── Back button and Clear on same row ──
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
                    color: Color(0xFF2B658B),
                    size: 18,
                  ),
                ),
              ),
              if (_hasSearched)
                GestureDetector(
                  onTap: _clearFilters,
                  child: Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFFF09418),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Title below back button ──
          Text(
            'Search Boardings',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your perfect boarding',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF5C6B8A),
            ),
          ),
        ],
      ),
    );
  }

  // ── University filter full width ──
  Widget _buildUniversityFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select University',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedUniversity != null
                    ? const Color(0xFF2B658B)
                    : const Color(0xFFDDE3F0),
                width: _selectedUniversity != null ? 1.5 : 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedUniversity,
                hint: Row(
                  children: [
                    const Icon(Icons.school_outlined,
                        color: Color(0xFF2B658B), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Select your university',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF2B658B),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF1A1A2E),
                ),
                onChanged: (val) =>
                    setState(() => _selectedUniversity = val),
                items: _universities
                    .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u,
                              style: GoogleFonts.poppins(fontSize: 13)),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search by Location',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Malabe, Kelaniya, Moratuwa...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF2B658B),
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFDDE3F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF2B658B), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
            onChanged: (value) => setState(() {}),
            onSubmitted: (_) => _search(),
          ),
        ],
      ),
    );
  }

  // ── Other filters grid ──
  Widget _buildOtherFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More Filters',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              _buildDropdown(
                label: 'Room Type',
                value: _selectedRoomType,
                items: _roomTypes,
                onChanged: (val) =>
                    setState(() => _selectedRoomType = val),
              ),
              _buildDropdown(
                label: 'Gender',
                value: _selectedGender,
                items: _genders,
                onChanged: (val) =>
                    setState(() => _selectedGender = val),
              ),
              _buildPriceDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  // ── Generic dropdown ──
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? const Color(0xFF2B658B)
              : const Color(0xFFDDE3F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade400)),
              Text('All',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF2B658B),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          isExpanded: true,
          icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2B658B),
              size: 18),
          style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF1A1A2E)),
          onChanged: onChanged,
          selectedItemBuilder: (context) =>
              items.map((item) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade400)),
                Text(item,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2B658B),
                        fontWeight: FontWeight.w500)),
              ],
            );
          }).toList(),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item,
                        style:
                            GoogleFonts.poppins(fontSize: 13)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── Price dropdown ──
  Widget _buildPriceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedMaxPrice != null
              ? const Color(0xFF2B658B)
              : const Color(0xFFDDE3F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double?>(
          value: _selectedMaxPrice,
          hint: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Max Price',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade400)),
              Text('Any',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF2B658B),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          isExpanded: true,
          icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2B658B),
              size: 18),
          style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF1A1A2E)),
          onChanged: (val) =>
              setState(() => _selectedMaxPrice = val),
          selectedItemBuilder: (context) =>
              _prices.map((p) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Max Price',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade400)),
                Text(
                    (p['label'] as String).length > 12
                        ? (p['label'] as String)
                                .substring(0, 12) +
                            '...'
                        : p['label'] as String,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2B658B),
                        fontWeight: FontWeight.w500)),
              ],
            );
          }).toList(),
          items: _prices
              .map((p) => DropdownMenuItem<double?>(
                    value: p['value'] as double?,
                    child: Text(p['label'] as String,
                        style:
                            GoogleFonts.poppins(fontSize: 12)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── Search button ──
  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _search,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF2B658B),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B658B).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Search',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Results ──
  Widget _buildResults() {
    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 40, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No listings found',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try adjusting your filters',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Results',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '${_results.length} found',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF09418),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            return ListingCard(
                listing: _listingToMap(_results[index]));
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
      'distance': listing.city,
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