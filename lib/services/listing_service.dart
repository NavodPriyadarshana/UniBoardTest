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
  // Fetches all listings then filters locally
  // This allows partial matching for university
  // and location — more flexible than exact match
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

      // Start with Firestore filters for indexed fields
      Query query = _firestore.collection(_collection);

      if (roomType != null && roomType.isNotEmpty) {
        query = query.where('roomType', isEqualTo: roomType);
      }
      if (gender != null && gender.isNotEmpty && gender != 'Any') {
        query = query.where('genderPreference', isEqualTo: gender);
      }
      if (maxPrice != null) {
        query = query.where('pricePerSlot',
            isLessThanOrEqualTo: maxPrice);
      }

      final QuerySnapshot snapshot = await query.get();
      List<ListingModel> results = snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();

      // ── Local filtering for university and location ──
      // Uses contains() for partial matching
      // This covers all faculty areas of a university
      if (university != null && university.isNotEmpty) {
        final uniLower = university.toLowerCase();
        results = results.where((l) {
          return l.university.toLowerCase().contains(uniLower) ||
              l.location.toLowerCase().contains(uniLower) ||
              l.city.toLowerCase().contains(uniLower) ||
              uniLower.contains(l.city.toLowerCase());
        }).toList();
      }

      if (city != null && city.isNotEmpty) {
        final cityLower = city.toLowerCase();
        results = results.where((l) {
          return l.city.toLowerCase().contains(cityLower) ||
              l.location.toLowerCase().contains(cityLower);
        }).toList();
      }

      print('✅ Found ${results.length} listings');
      return results;
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