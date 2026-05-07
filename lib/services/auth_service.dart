import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// AuthService is the bridge between our app and Firebase.
// All Firebase Auth and Firestore user operations go here.
// Screens call this service instead of talking to Firebase directly.
//
// Usage:
//   final authService = AuthService();
//   await authService.registerWithEmail(...)
//   await authService.loginWithEmail(...)
//   await authService.logout()

class AuthService {

  // Firebase Auth instance - handles login, register, logout
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance - stores and reads user data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // GET CURRENT USER
  // Returns the currently logged in user.
  // Returns null if no one is logged in.
  // ─────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ─────────────────────────────────────────────
  // AUTH STATE STREAM
  // Listens for login/logout changes automatically.
  // Fires whenever user logs in or logs out.
  // Used to keep user logged in after app restart.
  // ─────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─────────────────────────────────────────────
  // REGISTER NEW USER
  // Step 1: Creates account in Firebase Auth
  // Step 2: Saves user details to Firestore
  // Returns the new UserModel if successful
  // Throws error message string if failed
  // ─────────────────────────────────────────────
  Future<UserModel?> registerWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String university = '', // only used for students
  }) async {
    try {
      // Step 1: Create Firebase Auth account
      // This gives the user a unique ID (uid)
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Step 2: Get the uid Firebase assigned
      final String uid = credential.user!.uid;

      // Step 3: Build a UserModel with all details
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

      // Step 4: Save user data to Firestore 'users' collection
      // Document ID = uid so we can find it easily later
      await _firestore
          .collection('users')
          .doc(uid)
          .set(newUser.toFirestore());

      return newUser;

    } on FirebaseAuthException catch (e) {
      // Convert Firebase error code to readable message
      throw _handleAuthError(e);
    }
  }

  // ─────────────────────────────────────────────
  // LOGIN EXISTING USER
  // Step 1: Signs in with Firebase Auth
  // Step 2: Fetches user data from Firestore
  // Returns UserModel if successful
  // Throws error message string if failed
  // ─────────────────────────────────────────────
  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Sign in with Firebase Auth
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Step 2: Fetch user details from Firestore
      final UserModel? user =
          await getUserById(credential.user!.uid);

      return user;

    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ─────────────────────────────────────────────
  // GET USER BY ID
  // Fetches a single user's data from Firestore
  // using their uid
  // ─────────────────────────────────────────────
  Future<UserModel?> getUserById(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      // Return null if user document not found
      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);

    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // Signs out the current user from Firebase Auth
  // ─────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────
  // FORGOT PASSWORD
  // Sends a password reset email via Firebase
  // User clicks the link in email to reset password
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
  // Converts Firebase error codes into simple
  // readable messages shown to the user
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