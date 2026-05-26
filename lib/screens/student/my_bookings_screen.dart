import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'write_review_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

class _MyBookingsScreenState
    extends State<MyBookingsScreen> {

  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  int _selectedFilter = 0;

  final List<String> _filters = [
    'All', 'Pending', 'Confirmed', 'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('studentId', isEqualTo: currentUser.uid)
          .get();

      final List<Map<String, dynamic>> bookingsWithDetails = [];
      for (final doc in snapshot.docs) {
        final booking = doc.data();
        final listingId = booking['listingId'] ?? '';

        if (listingId.isNotEmpty) {
          try {
            final listingDoc = await FirebaseFirestore
                .instance
                .collection('listings')
                .doc(listingId)
                .get();

            if (listingDoc.exists) {
              booking['listingData'] = listingDoc.data();
            }
          } catch (e) {
            print('Error fetching listing: $e');
          }
        }
        bookingsWithDetails.add(booking);
      }

      if (mounted) {
        setState(() => _bookings = bookingsWithDetails);
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 0) return _bookings;
    final status = _filters[_selectedFilter].toLowerCase();
    return _bookings
        .where((b) => b['status'] == status)
        .toList();
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
                  onRefresh: _fetchBookings,
                  color: const Color(0xFF2B658B),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 8),
                        _buildFilterTabs(),
                        const SizedBox(height: 16),
                        _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 60),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF2B658B)),
                                ),
                              )
                            : _filteredBookings.isEmpty
                                ? _buildEmpty()
                                : _buildBookingsList(),
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
                border: Border.all(color: const Color(0xFFDDE3F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Color(0xFF2B658B), size: 18),
            ),
          ),
          const SizedBox(height: 20),
          Text('My Bookings',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text('Track your booking requests',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFF5C6B8A))),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final bool isSelected = _selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: Container(
                margin: EdgeInsets.only(
                    right: index < _filters.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2B658B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2B658B)
                        : const Color(0xFFDDE3F0),
                  ),
                ),
                child: Center(
                  child: Text(
                    _filters[index],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF5C6B8A),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bookmark_outline_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 0
                  ? 'No bookings yet'
                  : 'No ${_filters[_selectedFilter].toLowerCase()} bookings',
              style: GoogleFonts.poppins(
                  fontSize: 15, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 8),
            Text('Pull down to refresh',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade300)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(_filteredBookings[index]);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final String status = booking['status'] ?? 'pending';
    final Map<String, dynamic> listingData =
        booking['listingData'] as Map<String, dynamic>? ?? {};
    final String title = listingData['title'] ?? 'Boarding Listing';
    final String location = listingData['location'] ?? 'Location';
    final double price =
        (listingData['pricePerSlot'] as num? ?? 0).toDouble();
    final String roomType = listingData['roomType'] ?? 'Room';
    final bool isReviewed = booking['isReviewed'] as bool? ?? false;

    Color cardColor;
    Color statusColor;
    Color statusBg;
    String statusLabel;
    String statusMessage;

    switch (status) {
      case 'confirmed':
        cardColor = const Color(0xFFF09418);
        statusColor = const Color(0xFF27500A);
        statusBg = const Color(0xFFEAF3DE);
        statusLabel = 'Confirmed';
        statusMessage = 'Booking confirmed ✓';
        break;
      case 'rejected':
        cardColor = const Color(0xFF888780);
        statusColor = const Color(0xFFA32D2D);
        statusBg = const Color(0xFFFCEBEB);
        statusLabel = 'Rejected';
        statusMessage = 'Request rejected';
        break;
      default:
        cardColor = const Color(0xFF2B658B);
        statusColor = const Color(0xFF854F0B);
        statusBg = const Color(0xFFFAEEDA);
        statusLabel = 'Pending';
        statusMessage = 'Awaiting response';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              height: 70,
              width: double.infinity,
              color: cardColor,
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.home_rounded,
                        size: 36,
                        color: Colors.white.withOpacity(0.2)),
                  ),
                  Positioned(
                    top: 8, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
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
                    top: 8, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(statusLabel,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: Color(0xFF2B658B)),
                    const SizedBox(width: 4),
                    Text(location,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF5C6B8A))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LKR ${_formatPrice(price.toInt())}/mo',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B658B)),
                    ),
                    Text(
                      statusMessage,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor),
                    ),
                  ],
                ),

                // ── Write Review button ──
                if (status == 'confirmed' && !isReviewed) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WriteReviewScreen(
                            listingId: booking['listingId'] ?? '',
                            listingTitle: title,
                            listingLocation: location,
                            landlordId:
                                listingData['landlordId'] ?? '',
                            bookingId: booking['bookingId'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF2B658B)),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFF2B658B), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Write a Review',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2B658B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ── Already reviewed badge ──
                if (status == 'confirmed' && isReviewed) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3DE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF3B6D11), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Review Submitted',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B6D11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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