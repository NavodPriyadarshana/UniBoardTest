import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String studentId;
  final String landlordId;
  final String listingId;
  final String status;
  final bool advancePaid;
  final double amount;
  final bool visitConfirmed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.bookingId,
    required this.studentId,
    required this.landlordId,
    required this.listingId,
    this.status = 'pending',
    this.advancePaid = false,
    required this.amount,
    this.visitConfirmed = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: data['bookingId'] ?? '',
      studentId: data['studentId'] ?? '',
      landlordId: data['landlordId'] ?? '',
      listingId: data['listingId'] ?? '',
      status: data['status'] ?? 'pending',
      advancePaid: data['advancePaid'] ?? false,
      amount: (data['amount'] ?? 0.0).toDouble(),
      visitConfirmed: data['visitConfirmed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'studentId': studentId,
      'landlordId': landlordId,
      'listingId': listingId,
      'status': status,
      'advancePaid': advancePaid,
      'amount': amount,
      'visitConfirmed': visitConfirmed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
}