import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String listingId;
  final String landlordId;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final String city;
  final String university;
  final String roomType;
  final int totalCapacity;
  final int currentOccupants;
  final int availableSlots;
  final double pricePerSlot;
  final String genderPreference;
  final List<String> amenities;
  final String houseRules;
  final List<String> photos;
  final bool isVerified;
  final bool membershipActive;
  final DateTime createdAt;

  ListingModel({
    required this.listingId,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.university,
    required this.roomType,
    required this.totalCapacity,
    required this.currentOccupants,
    required this.availableSlots,
    required this.pricePerSlot,
    this.genderPreference = 'any',
    this.amenities = const [],
    this.houseRules = '',
    this.photos = const [],
    this.isVerified = false,
    this.membershipActive = false,
    required this.createdAt,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // ── Helper functions for safe type conversion ──
      String safeString(dynamic value, String defaultVal) {
        if (value == null) return defaultVal;
        return value.toString().trim();
      }

      double safeDouble(dynamic value, double defaultVal) {
        if (value == null) return defaultVal;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? defaultVal;
        return defaultVal;
      }

      int safeInt(dynamic value, int defaultVal) {
        if (value == null) return defaultVal;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value) ?? defaultVal;
        return defaultVal;
      }

      bool safeBool(dynamic value, bool defaultVal) {
        if (value == null) return defaultVal;
        if (value is bool) return value;
        if (value is String) return value.toLowerCase() == 'true';
        return defaultVal;
      }

      List<String> safeList(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          return value
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
        return [];
      }

      print('🔄 Parsing: ${doc.id}');
      print('   Raw title: ${data['title']}');
      print('   Raw price: ${data['pricePerSlot']}');
      print('   Raw university: ${data['university']}');

      return ListingModel(
        listingId: safeString(data['listingId'], doc.id),
        landlordId: safeString(data['landlordId'], ''),
        title: safeString(data['title'], ''),
        description: safeString(data['description'], ''),
        location: safeString(data['location'], ''),
        latitude: safeDouble(data['latitude'], 0.0),
        longitude: safeDouble(data['longitude'], 0.0),
        city: safeString(data['city'], ''),
        university: safeString(data['university'], ''),
        roomType: safeString(data['roomType'], 'Single'),
        totalCapacity: safeInt(data['totalCapacity'], 1),
        currentOccupants: safeInt(data['currentOccupants'], 0),
        availableSlots: safeInt(data['availableSlots'], 1),
        pricePerSlot: safeDouble(data['pricePerSlot'], 0.0),
        genderPreference: safeString(data['genderPreference'], 'Any'),
        amenities: safeList(data['amenities']),
        houseRules: safeString(data['houseRules'], ''),
        photos: safeList(data['photos']),
        isVerified: safeBool(data['isVerified'], false),
        membershipActive: safeBool(data['membershipActive'], false),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing listing ${doc.id}: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'listingId': listingId,
      'landlordId': landlordId,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'university': university,
      'roomType': roomType,
      'totalCapacity': totalCapacity,
      'currentOccupants': currentOccupants,
      'availableSlots': availableSlots,
      'pricePerSlot': pricePerSlot,
      'genderPreference': genderPreference,
      'amenities': amenities,
      'houseRules': houseRules,
      'photos': photos,
      'isVerified': isVerified,
      'membershipActive': membershipActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isAvailable =>
      availableSlots > 0 && membershipActive && isVerified;
}