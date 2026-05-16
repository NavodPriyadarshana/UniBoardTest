import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../models/booking_model.dart';
import 'add_listing_screen.dart';
import 'my_listings_screen.dart';
import 'landlord_bookings_screen.dart';
import 'landlord_profile_screen.dart';

// ─────────────────────────────────────────────
// LANDLORD HOME SCREEN
// Main dashboard shown after landlord logs in.
// Shows membership status, stats, quick actions
// and recent booking requests.
// ─────────────────────────────────────────────
class LandlordHomeScreen extends StatefulWidget {
  final String landlordName;

  const LandlordHomeScreen({
    super.key,
    required this.landlordName,
  });

  @override
  State<LandlordHomeScreen> createState() =>
      _LandlordHomeScreenState();
}

class _LandlordHomeScreenState
    extends State<LandlordHomeScreen> {

  final AuthService _authService = AuthService();
  int _selectedNav = 0;
  int _listingsCount = 0;
  int _bookingsCount = 0;
  int _pendingCount = 0;
  List<Map<String, dynamic>> _recentBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ─────────────────────────────────────────────
  // LOAD DASHBOARD DATA
  // Fetches listings and bookings counts
  // ─────────────────────────────────────────────
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // Fetch listings count
      final listingsSnap = await FirebaseFirestore.instance
          .collection('listings')
          .where('landlordId', isEqualTo: currentUser.uid)
          .get();

      // Fetch bookings
      final bookingsSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('landlordId', isEqualTo: currentUser.uid)
          .get();

      // Count pending bookings
      final pending = bookingsSnap.docs
          .where((d) => d['status'] == 'pending')
          .length;

      // Get recent bookings (last 5)
      final recent = bookingsSnap.docs
          .take(5)
          .map((d) => d.data())
          .toList();

      if (mounted) {
        setState(() {
          _listingsCount = listingsSnap.docs.length;
          _bookingsCount = bookingsSnap.docs.length;
          _pendingCount = pending;
          _recentBookings = recent;
        });
      }
    } catch (e) {
      print('❌ Dashboard error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // GREETING based on time of day
  // ─────────────────────────────────────────────
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
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
                  onRefresh: _loadDashboardData,
                  color: const Color(0xFFF09418),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildMembershipCard(),
                        const SizedBox(height: 16),
                        _buildStats(),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                        const SizedBox(height: 16),
                        _buildRecentBookings(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    final initial = widget.landlordName.isNotEmpty
        ? widget.landlordName[0].toUpperCase()
        : 'L';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFFF09418),
                ),
              ),
              Text(
                '${widget.landlordName} 👋',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LandlordProfileScreen(
                    landlordName: widget.landlordName,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFF09418),
              child: Text(
                initial,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Membership card ──
  Widget _buildMembershipCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF09418), Color(0xFFF5C060)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF09418).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membership Status',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active — Premium',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Renews Jun 2026',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats row ──
  Widget _buildStats() {
    final stats = [
      {'label': 'Listings',  'value': _listingsCount, 'color': const Color(0xFFF09418)},
      {'label': 'Bookings',  'value': _bookingsCount, 'color': const Color(0xFF2B658B)},
      {'label': 'Pending',   'value': _pendingCount,  'color': const Color(0xFF3B6D11)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: stat['label'] != 'Pending' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFDDE3F0)),
              ),
              child: Column(
                children: [
                  Text(
                    _isLoading
                        ? '-'
                        : stat['value'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: stat['color'] as Color,
                    ),
                  ),
                  Text(
                    stat['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Quick actions ──
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              _buildActionCard(
                icon: Icons.add_circle_outline_rounded,
                label: 'Add Listing',
                isPrimary: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddListingScreen()),
                ),
              ),
              _buildActionCard(
                icon: Icons.list_alt_rounded,
                label: 'My Listings',
                isPrimary: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyListingsScreen()),
                ),
              ),
              _buildActionCard(
                icon: Icons.calendar_today_rounded,
                label: 'Bookings',
                isPrimary: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const LandlordBookingsScreen()),
                ),
              ),
              _buildActionCard(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                isPrimary: false,
                onTap: () {
                  // TODO: Navigate to messages screen
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFFF09418)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFFDDE3F0)),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFFF09418)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isPrimary
                    ? Colors.white
                    : const Color(0xFF2B658B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : const Color(0xFF2B658B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent bookings ──
  Widget _buildRecentBookings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Bookings',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const LandlordBookingsScreen()),
                ),
                child: Text(
                  'See all',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFFF09418),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFF09418)))
              : _recentBookings.isEmpty
                  ? _buildEmptyBookings()
                  : Column(
                      children: _recentBookings
                          .map((b) => _buildBookingItem(b))
                          .toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildEmptyBookings() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'No bookings yet',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final studentId = booking['studentId'] ?? '';
    final initial = studentId.isNotEmpty
        ? studentId[0].toUpperCase()
        : 'S';

    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (status) {
      case 'confirmed':
        statusColor = const Color(0xFF3B6D11);
        statusBg = const Color(0xFFEAF3DE);
        statusLabel = 'Confirmed';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusBg = const Color(0xFFFFF0F0);
        statusLabel = 'Rejected';
        break;
      default:
        statusColor = const Color(0xFFF09418);
        statusBg = const Color(0xFFFFF8EC);
        statusLabel = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2B658B),
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Request',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  booking['listingId'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ──
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,              'label': 'Home'},
      {'icon': Icons.list_alt_rounded,          'label': 'Listings'},
      {'icon': Icons.calendar_today_rounded,    'label': 'Bookings'},
      {'icon': Icons.chat_bubble_outline_rounded,'label': 'Messages'},
      {'icon': Icons.person_outline_rounded,    'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFDDE3F0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final bool isSelected = _selectedNav == index;
          final Color itemColor = isSelected
              ? const Color(0xFFF09418)
              : Colors.grey.shade400;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedNav = index);
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyListingsScreen()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const LandlordBookingsScreen()),
                );
              } else if (index == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LandlordProfileScreen(
                      landlordName: widget.landlordName,
                    ),
                  ),
                );
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[index]['icon'] as IconData,
                    size: 26, color: itemColor),
                const SizedBox(height: 4),
                Text(
                  items[index]['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: itemColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
