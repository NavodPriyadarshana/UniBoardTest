import 'package:flutter/material.dart';

// This class holds all the colors used throughout the UniBoard app.
// Using a central color file keeps the design consistent across all screens.
class AppColors {

  // ── PRIMARY COLORS ──────────────────────────────
  // The main blue color used for buttons, icons, highlights
  static const Color primary = Color(0xFF1A73E8);
  // A darker blue used for pressed states or headers
  static const Color primaryDark = Color(0xFF0D47A1);
  // A very light blue used for backgrounds of highlighted areas
  static const Color primaryLight = Color(0xFFE8F0FE);

  // ── SECONDARY COLORS ────────────────────────────
  // Teal/green color used for landlord-related elements
  static const Color secondary = Color(0xFF00897B);
  // Light teal for landlord background highlights
  static const Color secondaryLight = Color(0xFFE0F2F1);

  // ── BACKGROUND COLORS ───────────────────────────
  // The main background color of all screens (light grey)
  static const Color background = Color(0xFFF5F7FA);
  // White color used for cards and containers
  // Using hex value instead of Colors.white to allow const usage
  static const Color card = Color(0xFFFFFFFF);

  // ── TEXT COLORS ─────────────────────────────────
  // Dark color for main text (titles, headings)
  static const Color textDark = Color(0xFF1C1C2E);
  // Grey color for subtitle and hint text
  static const Color textLight = Color(0xFF8A8A9A);
  // White text used on colored buttons
  static const Color textWhite = Color(0xFFFFFFFF);

  // ── STATUS COLORS ───────────────────────────────
  // Green - used for success messages & confirmed bookings
  static const Color success = Color(0xFF43A047);
  // Red - used for error messages & rejected bookings
  static const Color error = Color(0xFFE53935);
  // Orange - used for warnings & pending bookings
  static const Color warning = Color(0xFFFB8C00);
  // Blue - used for info messages
  static const Color info = Color(0xFF1E88E5);

  // ── MISC COLORS ─────────────────────────────────
  // Yellow - used for star ratings
  static const Color star = Color(0xFFFFC107);
  // Light grey - used for input field borders
  static const Color border = Color(0xFFE5E7EB);
  // Very light grey - used for divider lines
  static const Color divider = Color(0xFFF0F0F0);

  // ── ROLE COLORS ─────────────────────────────────
  // Blue theme for student screens
  static const Color studentColor = Color(0xFF1A73E8);
  // Teal theme for landlord screens
  static const Color landlordColor = Color(0xFF00897B);
  // Purple theme for admin screens
  static const Color adminColor = Color(0xFF6A1B9A);
}