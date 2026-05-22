import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

// ─────────────────────────────────────────────
// CHAT SERVICE
// Handles all Firestore chat operations.
// Creates chats and fetches chat lists.
// ─────────────────────────────────────────────
class ChatService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ─────────────────────────────────────────────
  // GET OR CREATE CHAT
  // Returns existing chat ID or creates new one
  // ─────────────────────────────────────────────
  Future<String> getOrCreateChat({
    required String studentId,
    required String landlordId,
    required String listingId,
    required String listingTitle,
  }) async {
    try {
      // Check if chat already exists
      final existing = await _firestore
          .collection('chats')
          .where('studentId', isEqualTo: studentId)
          .where('landlordId', isEqualTo: landlordId)
          .where('listingId', isEqualTo: listingId)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

      // Create new chat
      final chatRef = _firestore.collection('chats').doc();
      await chatRef.set({
        'chatId': chatRef.id,
        'studentId': studentId,
        'landlordId': landlordId,
        'listingId': listingId,
        'listingTitle': listingTitle,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return chatRef.id;
    } catch (e) {
      print('❌ Error getting/creating chat: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // GET CHATS STREAM
  // Returns real time stream of user chats
  // ─────────────────────────────────────────────
  Stream<QuerySnapshot> getChatsStream(
      String userId, bool isLandlord) {
    final field =
        isLandlord ? 'landlordId' : 'studentId';
    return _firestore
        .collection('chats')
        .where(field, isEqualTo: userId)
        .snapshots();
  }
}