import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

// ─────────────────────────────────────────────
// LISTING SERVICE
// Handles all Firestore operations for listings.
// ─────────────────────────────────────────────
class ListingService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'listings';

  // ─────────────────────────────────────────────
  // GET ALL LISTINGS — No filters for debugging
  // ─────────────────────────────────────────────
  Future<List<ListingModel>> getAllListings() async {
    try {
      print('🔍 Fetching all listings...');
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .get();

      print('✅ Found ${snapshot.docs.length} listings');
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching listings: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // GET LISTINGS BY UNIVERSITY
  // ─────────────────────────────────────────────
  Future<List<ListingModel>> getListingsByUniversity(
      String university) async {
    try {
      print('🔍 Fetching listings for: $university');
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('university', isEqualTo: university)
          .get();

      print('✅ Found ${snapshot.docs.length} listings');
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching by university: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // GET LISTING BY ID
  // ─────────────────────────────────────────────
  Future<ListingModel?> getListingById(String listingId) async {
    try {
      print('🔍 Fetching listing: $listingId');
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(listingId)
          .get();

      if (!doc.exists) {
        print('❌ Listing not found');
        return null;
      }
      print('✅ Listing found');
      return ListingModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error fetching listing: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // SEARCH LISTINGS
  // ─────────────────────────────────────────────
  Future<List<ListingModel>> searchListings({
    String? university,
    String? city,
    String? roomType,
    String? gender,
    double? maxPrice,
  }) async {
    try {
      print('🔍 Searching listings...');
      Query query = _firestore.collection(_collection);

      if (university != null && university.isNotEmpty) {
        query = query.where('university', isEqualTo: university);
      }
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      if (roomType != null && roomType.isNotEmpty) {
        query = query.where('roomType', isEqualTo: roomType);
      }
      if (gender != null && gender.isNotEmpty && gender != 'Any') {
        query = query.where('genderPreference', isEqualTo: gender);
      }

      final QuerySnapshot snapshot = await query.get();
      print('✅ Found ${snapshot.docs.length} listings');
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error searching listings: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // GET LISTINGS STREAM
  // ─────────────────────────────────────────────
  Stream<List<ListingModel>> getListingsStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
          print('📡 Stream update: ${snapshot.docs.length} listings');
          return snapshot.docs
              .map((doc) => ListingModel.fromFirestore(doc))
              .toList();
        });
  }
}