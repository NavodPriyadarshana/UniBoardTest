import 'package:flutter/material.dart';
import '../../widgets/student/home_header.dart';
import '../../widgets/student/home_search_bar.dart';
import '../../widgets/student/home_filter_chips.dart';
import '../../widgets/student/listing_card.dart';
import '../../widgets/student/bottom_nav_bar.dart';

// ─────────────────────────────────────────────
// STUDENT HOME SCREEN
// Main screen shown after student logs in.
// Composed of smaller reusable widgets.
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

  // Dummy listings — will be replaced with Firestore data
  final List<Map<String, dynamic>> _listings = [
    {
      'title': 'Room near SLTC University',
      'location': 'Malabe, Colombo',
      'distance': '0.8 km away',
      'price': 8500,
      'rating': 4.5,
      'roomType': 'Shared',
      'slotsLeft': 2,
      'isVerified': true,
      'color': Color(0xFF2B658B),
    },
    {
      'title': 'Cozy Single Room, Kelaniya',
      'location': 'Kelaniya, Western',
      'distance': '1.2 km away',
      'price': 12000,
      'rating': 4.8,
      'roomType': 'Single',
      'slotsLeft': 4,
      'isVerified': true,
      'color': Color(0xFFF09418),
    },
    {
      'title': 'Double Room near UOM',
      'location': 'Moratuwa, Western',
      'distance': '0.5 km away',
      'price': 9500,
      'rating': 4.2,
      'roomType': 'Double',
      'slotsLeft': 1,
      'isVerified': true,
      'color': Color(0xFF3B8B65),
    },
  ];

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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Header widget
                      HomeHeader(studentName: widget.studentName),
                      const SizedBox(height: 16),

                      // Search bar widget
                      const HomeSearchBar(),
                      const SizedBox(height: 14),

                      // Filter chips widget
                      HomeFilterChips(
                        selectedIndex: _selectedFilter,
                        onFilterSelected: (index) {
                          setState(() => _selectedFilter = index);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Section title
                      _buildSectionTitle(),
                      const SizedBox(height: 12),

                      // Listing cards
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _listings.length,
                        itemBuilder: (context, index) {
                          return ListingCard(listing: _listings[index]);
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom nav widget
              BottomNavBar(
                selectedIndex: _selectedNav,
                onItemSelected: (index) {
                  setState(() => _selectedNav = index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section title with "See all" button
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nearby Boardings',
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
            child: const Text(
              'See all',
              style: TextStyle(
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
}
