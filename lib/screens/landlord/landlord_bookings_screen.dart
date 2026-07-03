import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

// ─────────────────────────────────────────────
// LANDLORD BOOKINGS SCREEN
// Shows all booking requests for landlord.
// Landlord can accept or reject pending requests.
// ─────────────────────────────────────────────
class LandlordBookingsScreen extends StatefulWidget {
  const LandlordBookingsScreen({super.key});

  @override
  State<LandlordBookingsScreen> createState() =>
      _LandlordBookingsScreenState();
}

class _LandlordBookingsScreenState
    extends State<LandlordBookingsScreen> {

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
          .where('landlordId', isEqualTo: currentUser.uid)
          .get();

      if (mounted) {
        setState(() {
          _bookings = snapshot.docs
              .map((doc) => doc.data())
              .toList();
        });
      }
    } catch (e) {
      print('❌ Error fetching bookings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 0) return _bookings;
    final status = _filters[_selectedFilter].toLowerCase();
    return _bookings.where((b) => b['status'] == status).toList();
  }

  // ─────────────────────────────────────────────
  // UPDATE BOOKING STATUS
  // Accept or reject a booking request
  // Sends push notification to student
  // ─────────────────────────────────────────────
  Future<void> _updateBookingStatus(
      String bookingId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': status});

      // ── Get booking data for notification ──
      final booking = _bookings.firstWhere(
          (b) => b['bookingId'] == bookingId);
      final studentId = booking['studentId'] ?? '';
      print('🔔 BookingId: $bookingId');
      print('🔔 StudentId: $studentId');
      print('🔔 Status: $status');

      // ── If accepted update available slots ──
      if (status == 'confirmed') {
        final listingId = booking['listingId'] ?? '';
        if (listingId.isNotEmpty) {
          final listingDoc = await FirebaseFirestore
              .instance
              .collection('listings')
              .doc(listingId)
              .get();
          if (listingDoc.exists) {
            final currentSlots =
                listingDoc['availableSlots'] as int? ?? 0;
            if (currentSlots > 0) {
              await FirebaseFirestore.instance
                  .collection('listings')
                  .doc(listingId)
                  .update({
                'availableSlots': currentSlots - 1,
                'currentOccupants': FieldValue.increment(1),
              });
            }
          }
        }

        // ── Send notification to student ──
        if (studentId.isNotEmpty) {
          print('🔔 Sending confirmed notification to: $studentId');
          await NotificationService.sendNotificationToUser(
            userId: studentId,
            title: 'Booking Confirmed! 🎉',
            body: 'Your booking request has been confirmed by the landlord.',
          );
          print('🔔 Notification sent!');
        } else {
          print('❌ studentId is empty!');
        }
      }

      // ── Send rejection notification to student ──
      if (status == 'rejected' && studentId.isNotEmpty) {
        await NotificationService.sendNotificationToUser(
          userId: studentId,
          title: 'Booking Update',
          body: 'Your booking request was not accepted this time. Please try another listing.',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'confirmed'
                ? '✅ Booking accepted! Student notified.'
                : '❌ Booking rejected. Student notified.'),
            backgroundColor: status == 'confirmed'
                ? const Color(0xFF3B6D11)
                : Colors.red.shade400,
          ),
        );
        _fetchBookings();
      }
    } catch (e) {
      print('❌ Update error: $e');
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
                  onRefresh: _fetchBookings,
                  color: const Color(0xFFF09418),
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
                                      color: Color(0xFFF09418)),
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
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE3F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Color(0xFFF09418), size: 18),
            ),
          ),
          const SizedBox(height: 20),
          Text('Booking Requests',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text('Manage student booking requests',
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
                      ? const Color(0xFFF09418) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF09418)
                        : const Color(0xFFDDE3F0),
                  ),
                ),
                child: Center(
                  child: Text(_filters[index],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white : const Color(0xFF5C6B8A),
                      )),
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
            Icon(Icons.calendar_today_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 0
                  ? 'No booking requests yet'
                  : 'No ${_filters[_selectedFilter].toLowerCase()} requests',
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
    final String bookingId = booking['bookingId'] ?? '';
    final String studentId = booking['studentId'] ?? '';
    final String listingId = booking['listingId'] ?? '';
    final String status = booking['status'] ?? 'pending';
    final double amount =
        (booking['amount'] as num? ?? 0).toDouble();
    final String initial =
        studentId.isNotEmpty ? studentId[0].toUpperCase() : 'S';

    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (status) {
      case 'confirmed':
        statusColor = const Color(0xFF27500A);
        statusBg = const Color(0xFFEAF3DE);
        statusLabel = 'Confirmed';
        break;
      case 'rejected':
        statusColor = const Color(0xFFA32D2D);
        statusBg = const Color(0xFFFCEBEB);
        statusLabel = 'Rejected';
        break;
      default:
        statusColor = const Color(0xFF854F0B);
        statusBg = const Color(0xFFFAEEDA);
        statusLabel = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF2B658B),
                    child: Text(initial,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student Request',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E))),
                      Text(
                        studentId.length > 20
                            ? '${studentId.substring(0, 20)}...'
                            : studentId,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
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
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Listing: $listingId',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF5C6B8A)),
                      overflow: TextOverflow.ellipsis),
                ),
                Text('LKR ${_formatPrice(amount.toInt())}',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF09418))),
              ],
            ),
          ),

          if (status == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _updateBookingStatus(
                        bookingId, 'rejected'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFF09595)),
                      ),
                      child: Center(
                        child: Text('Reject',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFA32D2D))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _updateBookingStatus(
                        bookingId, 'confirmed'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3DE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF97C459)),
                      ),
                      child: Center(
                        child: Text('Accept',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3B6D11))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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