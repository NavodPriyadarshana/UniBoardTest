import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

// ─────────────────────────────────────────────
// WRITE REVIEW SCREEN
// Student writes a review for a confirmed
// booking after their stay.
// ─────────────────────────────────────────────
class WriteReviewScreen extends StatefulWidget {
  final String listingId;
  final String listingTitle;
  final String listingLocation;
  final String landlordId;
  final String bookingId;

  const WriteReviewScreen({
    super.key,
    required this.listingId,
    required this.listingTitle,
    required this.listingLocation,
    required this.landlordId,
    required this.bookingId,
  });

  @override
  State<WriteReviewScreen> createState() =>
      _WriteReviewScreenState();
}

class _WriteReviewScreenState
    extends State<WriteReviewScreen> {

  final AuthService _authService = AuthService();
  final _reviewController = TextEditingController();
  int _selectedRating = 0;
  bool _isLoading = false;

  final List<String> _ratingLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SUBMIT REVIEW
  // ─────────────────────────────────────────────
  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      final reviewId = FirebaseFirestore.instance
          .collection('reviews')
          .doc()
          .id;

      // Save review to Firestore
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .set({
        'reviewId': reviewId,
        'listingId': widget.listingId,
        'landlordId': widget.landlordId,
        'studentId': currentUser.uid,
        'bookingId': widget.bookingId,
        'rating': _selectedRating,
        'review': _reviewController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update average rating on listing
      await _updateListingRating();

      // Mark booking as reviewed
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'isReviewed': true});

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Review Submitted! ⭐',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E)),
            ),
            content: Text(
              'Thank you for your review! It helps other students make better decisions.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF2B658B),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Review error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE LISTING AVERAGE RATING
  // ─────────────────────────────────────────────
  Future<void> _updateListingRating() async {
    try {
      final reviews = await FirebaseFirestore.instance
          .collection('reviews')
          .where('listingId', isEqualTo: widget.listingId)
          .get();

      if (reviews.docs.isEmpty) return;

      final totalRating = reviews.docs.fold<int>(
          0, (sum, doc) => sum + (doc['rating'] as int));
      final avgRating = totalRating / reviews.docs.length;

      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .update({
        'rating': avgRating,
        'reviewCount': reviews.docs.length,
      });
    } catch (e) {
      print('❌ Rating update error: $e');
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildListingCard(),
                  const SizedBox(height: 28),
                  _buildStarRating(),
                  const SizedBox(height: 24),
                  _buildReviewField(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Row(
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
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a Review',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              'Share your experience',
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

  // ── Listing card ──
  Widget _buildListingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2B658B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listingTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12,
                        color: Color(0xFF2B658B)),
                    const SizedBox(width: 4),
                    Text(
                      widget.listingLocation,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF5C6B8A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Star rating ──
  Widget _buildStarRating() {
    return Column(
      children: [
        Center(
          child: Text(
            'How was your experience?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedRating = starIndex),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  starIndex <= _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 40,
                  color: starIndex <= _selectedRating
                      ? const Color(0xFFF09418)
                      : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        if (_selectedRating > 0)
          Center(
            child: Text(
              _ratingLabels[_selectedRating],
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF09418),
              ),
            ),
          ),
      ],
    );
  }

  // ── Review text field ──
  Widget _buildReviewField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Review',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reviewController,
          maxLines: 4,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            hintText:
                'Share your experience about this boarding...',
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
    );
  }

  // ── Submit button ──
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submitReview,
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
                      color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Submit Review',
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
    );
  }
}