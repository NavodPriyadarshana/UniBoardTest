import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandlordBookingsScreen extends StatelessWidget {
  const LandlordBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F9EE), Color(0xFFF1F3FA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 64, color: Color(0xFFF09418)),
                const SizedBox(height: 16),
                Text('Bookings Screen',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                Text('Coming soon...',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade400)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF09418),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Go Back',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}