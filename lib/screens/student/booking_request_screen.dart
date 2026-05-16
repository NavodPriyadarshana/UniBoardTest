import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';

// ─────────────────────────────────────────────
// BOOKING REQUEST SCREEN
// Student reviews listing details and
// sends a booking request to the landlord.
// ─────────────────────────────────────────────
class BookingRequestScreen extends StatefulWidget {
  final Map<String, dynamic> listing;

  const BookingRequestScreen({
    super.key,
    required this.listing,
  });

  @override
  State<BookingRequestScreen> createState() =>
      _BookingRequestScreenState();
}

class _BookingRequestScreenState
    extends State<BookingRequestScreen> {

  final TextEditingController _messageController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SEND BOOKING REQUEST
  // Saves booking to Firestore bookings collection
  // ─────────────────────────────────────────────
  Future<void> _sendBookingRequest() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      // Generate unique booking ID
      final bookingId = FirebaseFirestore.instance
          .collection('bookings')
          .doc()
          .id;

      // Create booking model
      final booking = BookingModel(
        bookingId: bookingId,
        studentId: currentUser.uid,
        landlordId: widget.listing['landlordId'] ?? '',
        listingId: widget.listing['listingId'] ?? '',
        status: 'pending',
        advancePaid: false,
        amount: (widget.listing['price'] ?? 0).toDouble(),
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set(booking.toFirestore());

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Request Sent! 🎉',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            content: Text(
              'Your booking request has been sent to the landlord. You will be notified once they respond.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2B658B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Booking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request. Try again.'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int price = widget.listing['price'] ?? 0;

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
                      _buildHeader(),
                      const SizedBox(height: 8),
                      _buildListingSummary(),
                      const SizedBox(height: 16),
                      _buildBookingDetails(price),
                      const SizedBox(height: 16),
                      _buildMessageBox(),
                      const SizedBox(height: 16),
                      _buildVisitWarning(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _buildConfirmButton(),
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
          // Back button
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
            'Request Booking',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review and confirm your request',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF5C6B8A),
            ),
          ),
        ],
      ),
    );
  }

  // ── Listing summary card ──
  Widget _buildListingSummary() {
    final Color cardColor =
        widget.listing['color'] as Color? ??
            const Color(0xFF2B658B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDE3F0)),
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
                child: Center(
                  child: Icon(Icons.home_rounded,
                      size: 40,
                      color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),

            // Listing details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.listing['title'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFF2B658B)),
                      const SizedBox(width: 4),
                      Text(
                        widget.listing['location'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF5C6B8A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LKR ${_formatPrice(widget.listing['price'] ?? 0)}/month',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B658B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3DE),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.listing['roomType'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B6D11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Booking details ──
  Widget _buildBookingDetails(int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: const Color(0xFFDDE3F0)),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Monthly Rent',
                  'LKR ${_formatPrice(price)}',
                  isLast: false,
                ),
                _buildDetailRow(
                  'Advance Payment',
                  'LKR ${_formatPrice(price)}',
                  subtitle: '1 month advance',
                  isLast: false,
                ),
                _buildDetailRow(
                  'Total Due Now',
                  'LKR ${_formatPrice(price)}',
                  isTotal: true,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    String? subtitle,
    bool isTotal = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                    color: Color(0xFFDDE3F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isTotal ? 14 : 13,
                  fontWeight: isTotal
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 13,
              fontWeight: FontWeight.w700,
              color: isTotal
                  ? const Color(0xFF2B658B)
                  : const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ── Message to landlord ──
  Widget _buildMessageBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message to Landlord',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            maxLines: 4,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              hintText:
                  'Hi, I am interested in this room. I am a student at...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFFDDE3F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF2B658B), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  // ── Physical visit warning ──
  Widget _buildVisitWarning() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
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
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please visit the property before confirming payment for your safety',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF854F0B),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirm button ──
  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFDDE3F0))),
      ),
      child: GestureDetector(
        onTap: _isLoading ? null : _sendBookingRequest,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF2B658B),
            borderRadius: BorderRadius.circular(16),
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
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Send Booking Request',
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}