import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// This class defines all text styles used in the UniBoard app.
// Using predefined styles ensures consistent typography across all screens.
class AppTextStyles {

  // ── HEADINGS ────────────────────────────────────
  // Large heading - used for main screen titles like "Find your boarding"
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800, // Extra bold
    color: AppColors.textDark,
    letterSpacing: -1, // Slightly tighter spacing for big text
  );

  // Medium heading - used for section titles like "Welcome back!"
  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  // Small heading - used for card titles and screen subtitles
  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // ── BODY TEXT ───────────────────────────────────
  // Large body text - used for descriptions and important content
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular weight
    color: AppColors.textDark,
  );

  // Medium body text - used for general content
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  // Small body text - used for hints and secondary info
  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight, // Grey color for less important text
  );

  // ── BUTTON TEXT ─────────────────────────────────
  // Used for all button labels like "Sign In", "Book Now"
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite, // White text on colored buttons
    letterSpacing: 0.3,
  );

  // ── SMALL LABELS ────────────────────────────────
  // Used for tiny labels like tags, badges, timestamps
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );

  // Used for form field labels and small headers
  static TextStyle label = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}