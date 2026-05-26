import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// LISTING REVIEWS WIDGET
// Shows all reviews for a listing
// on the listing detail screen.
// ─────────────────────────────────────────────
class ListingReviewsWidget extends StatelessWidget {
  final String listingId;

  const ListingReviewsWidget({
    super.key,
    required this.listingId,
  });

  // ─────────────────────────────────────────────
  // FORMAT TIME AGO
  // ─────────────────────────────────────────────
  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final time = timestamp.toDate();
    final diff = now.difference(time);

    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('reviews')
          .where('listingId', isEqualTo: listingId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF2B658B)),
            ),
          );
        }

        final reviews = snapshot.data?.docs ?? [];

        if (reviews.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: const Color(0xFFDDE3F0)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.star_outline_rounded,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    'No reviews yet',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to review!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate average rating
        final totalRating = reviews.fold<double>(
            0,
            (sum, doc) =>
                sum + (doc['rating'] as num).toDouble());
        final avgRating = totalRating / reviews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFDDE3F0)),
              ),
              child: Row(
                children: [
                  // Average rating
                  Column(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < avgRating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: const Color(0xFFF09418),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reviews.length} reviews',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),

                  // Rating bars
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final star = 5 - index;
                        final count = reviews
                            .where((r) => r['rating'] == star)
                            .length;
                        final percentage = reviews.isEmpty
                            ? 0.0
                            : count / reviews.length;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$star',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.star_rounded,
                                  size: 12,
                                  color: Color(0xFFF09418)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  child:
                                      LinearProgressIndicator(
                                    value: percentage,
                                    backgroundColor:
                                        Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            Color(0xFFF09418)),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$count',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Review list
            ...reviews.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final rating = data['rating'] as int? ?? 0;
              final review = data['review'] ?? '';
              final studentId = data['studentId'] ?? '';
              final initial = studentId.isNotEmpty
                  ? studentId[0].toUpperCase()
                  : 'S';
              final timestamp =
                  data['createdAt'] as Timestamp?;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFDDE3F0)),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  const Color(0xFF2B658B),
                              child: Text(
                                initial,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Student',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    const Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 14,
                              color: const Color(0xFFF09418),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF5C6B8A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}