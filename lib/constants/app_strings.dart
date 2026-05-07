// ignore_for_file: constant_identifier_names

// This class stores all text strings used throughout the UniBoard app.
// Centralizing strings makes it easy to update text and
// also makes the app ready for multiple languages in the future.
class AppStrings {
  // Private constructor - prevents creating instances of this class
  // since all fields are static (class-level, not instance-level)
  AppStrings._();

  // ── APP INFO ────────────────────────────────────
  static const String appName = 'UniBoard';
  static const String appTagline = 'Student Boarding Finder';

  // ── AUTH SCREEN STRINGS ─────────────────────────
  static const String login = 'Sign In';
  static const String register = 'Create Account';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account? ";
  static const String hasAccount = 'Already have an account? ';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String logout = 'Sign Out';

  // ── ROLE SELECTION STRINGS ──────────────────────
  static const String student = 'Student';
  static const String landlord = 'Landlord';
  static const String admin = 'Admin';
  static const String studentSubtitle =
      'Find & book boardings near your university';
  static const String landlordSubtitle =
      'List your property and manage bookings';
  static const String adminSubtitle = 'Manage the UniBoard platform';

  // ── SEARCH & LISTING STRINGS ────────────────────
  static const String searchHint = 'Search by location, university...';
  static const String noListings = 'No listings found.';
  static const String noSaved =
      'No saved boardings yet.\nTap ♡ to save one!';

  // ── ROOM TYPE OPTIONS ───────────────────────────
  static const String single = 'Single';
  static const String double_ = 'Double';
  static const String shared = 'Shared';
  static const String studio = 'Studio';

  // ── GENDER PREFERENCE OPTIONS ───────────────────
  static const String male = 'Male';
  static const String female = 'Female';
  static const String any = 'Any';

  // ── BOOKING STATUS LABELS ───────────────────────
  static const String pending = 'Pending';
  static const String confirmed = 'Confirmed';
  static const String rejected = 'Rejected';
  static const String cancelled = 'Cancelled';

  // ── ERROR MESSAGES ──────────────────────────────
  static const String errorGeneral =
      'Something went wrong. Please try again.';
  static const String errorEmail = 'Please enter a valid email address.';
  static const String errorPassword = 'Minimum 6 characters required.';
  static const String errorName = 'Please enter your name.';
  static const String errorPhone = 'Please enter your phone number.';
}