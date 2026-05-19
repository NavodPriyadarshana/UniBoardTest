import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────
// LISTING IMAGE AREA WIDGET
// Shows listing photo placeholder with
// back button, save button and badges.
// Save button toggles Firestore savedListings
// ─────────────────────────────────────────────
class ListingImageArea extends StatefulWidget {
  final Map<String, dynamic> listing;

  const ListingImageArea({super.key, required this.listing});

  @override
  State<ListingImageArea> createState() => _ListingImageAreaState();
}

class _ListingImageAreaState extends State<ListingImageArea> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  // ── Check if listing is already saved ──
  Future<void> _checkIfSaved() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final savedIds = List<String>.from(
          doc.data()?['savedListings'] ?? []);
      if (mounted) {
        setState(() => _isSaved = savedIds.contains(
            widget.listing['listingId'] ?? ''));
      }
    } catch (e) {
      print('❌ Error checking saved: $e');
    }
  }

  // ── Toggle save/unsave listing ──
  Future<void> _toggleSave() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final listingId = widget.listing['listingId'] ?? '';
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      if (_isSaved) {
        await userRef.update({
          'savedListings': FieldValue.arrayRemove([listingId]),
        });
      } else {
        await userRef.update({
          'savedListings': FieldValue.arrayUnion([listingId]),
        });
      }
      if (mounted) setState(() => _isSaved = !_isSaved);
    } catch (e) {
      print('❌ Error toggling save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor =
        widget.listing['color'] as Color? ??
            const Color(0xFF2B658B);
    final int slotsLeft =
        widget.listing['slotsLeft'] as int? ?? 0;

    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        children: [
          // Background gradient image area
          Container(
            height: 240,
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
              child: Icon(
                Icons.home_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Save button ── toggles save/unsave
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: _toggleSave,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _isSaved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isSaved
                      ? Colors.red
                      : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),

          // Room type badge
          Positioned(
            bottom: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.listing['roomType'] ?? 'Single',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cardColor,
                ),
              ),
            ),
          ),

          // Slots left badge
          Positioned(
            bottom: 14,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: slotsLeft <= 2
                    ? const Color(0xFFF09418)
                    : const Color(0xFF2B658B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$slotsLeft slot${slotsLeft == 1 ? '' : 's'} left',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}