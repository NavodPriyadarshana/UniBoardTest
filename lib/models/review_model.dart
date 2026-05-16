import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String studentId;
  final String landlordId;
  final String listingId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.studentId,
    required this.landlordId,
    required this.listingId,
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      reviewId: data['reviewId'] ?? '',
      studentId: data['studentId'] ?? '',
      landlordId: data['landlordId'] ?? '',
      listingId: data['listingId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reviewId': reviewId,
      'studentId': studentId,
      'landlordId': landlordId,
      'listingId': listingId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}