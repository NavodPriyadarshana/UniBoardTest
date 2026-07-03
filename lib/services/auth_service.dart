import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─────────────────────────────────────────────
  // SAVE FCM TOKEN TO FIRESTORE
  // Called after login to save device token
  // ─────────────────────────────────────────────
  Future<void> _saveFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .update({'fcmToken': token});

      print('✅ FCM Token saved: $token');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER NEW USER
  // ─────────────────────────────────────────────
  Future<UserModel?> registerWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String university = '',
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final String uid = credential.user!.uid;

      final UserModel newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: role,
        university: university,
        profileImage: '',
        createdAt: DateTime.now(),
        savedListings: [],
        bookings: [],
        listings: [],
        verified: false,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(newUser.toFirestore());

      // ── Save FCM token after registration ──
      await _saveFcmToken(uid);

      return newUser;

    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ─────────────────────────────────────────────
  // LOGIN EXISTING USER
  // ─────────────────────────────────────────────
  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final String uid = credential.user!.uid;

      // ── Save FCM token after login ──
      await _saveFcmToken(uid);

      final UserModel? user = await getUserById(uid);

      return user;

    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ─────────────────────────────────────────────
  // GET USER BY ID
  // ─────────────────────────────────────────────
  Future<UserModel?> getUserById(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);

    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ─────────────────────────────────────────────
  // ERROR HANDLER
  // ─────────────────────────────────────────────
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}