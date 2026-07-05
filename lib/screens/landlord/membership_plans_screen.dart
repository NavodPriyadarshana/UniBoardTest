import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_screen.dart';

// ─────────────────────────────────────────────
// MEMBERSHIP PLANS SCREEN
// Landlord selects a membership plan
// after OTP verification.
// Payment integration coming soon.
// ─────────────────────────────────────────────
class MembershipPlansScreen extends StatelessWidget {
  final String landlordEmail;
  final String landlordName;

  const MembershipPlansScreen({
    super.key,
    required this.landlordEmail,
    required this.landlordName,
  });

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFDDE3F0)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Color(0xFFF09418),
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Choose Your Plan',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a membership to start listing',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF5C6B8A),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Plans
                  _buildPlanCard(
                    context: context,
                    title: 'Basic',
                    price: 'LKR 1,500',
                    period: '/month',
                    features: [
                      'Up to 2 listings',
                      'Basic support',
                      'Booking management',
                    ],
                    isPrimary: false,
                  ),

                  const SizedBox(height: 16),

                  _buildPlanCard(
                    context: context,
                    title: 'Standard',
                    price: 'LKR 2,500',
                    period: '/month',
                    features: [
                      'Up to 5 listings',
                      'Priority support',
                      'Featured listings',
                      'Analytics dashboard',
                    ],
                    isPrimary: true,
                    badge: 'Most Popular',
                  ),

                  const SizedBox(height: 16),

                  _buildPlanCard(
                    context: context,
                    title: 'Premium',
                    price: 'LKR 4,500',
                    period: '/month',
                    features: [
                      'Unlimited listings',
                      'Priority support',
                      'Featured listings',
                      'Advanced analytics',
                    ],
                    isPrimary: false,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPrimary,
    String? badge,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFFF09418)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFFF09418)
              : const Color(0xFFDDE3F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? const Color(0xFFF09418).withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isPrimary
                      ? Colors.white
                      : const Color(0xFF1A1A2E),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isPrimary
                      ? Colors.white
                      : const Color(0xFFF09418),
                ),
              ),
              Text(
                period,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isPrimary
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF5C6B8A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: isPrimary
                          ? Colors.white
                          : const Color(0xFF3B6D11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isPrimary
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          // Select plan button
          GestureDetector(
            onTap: () {
              // Navigate to auth screen Sign Up tab
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => AuthScreen(
                    role: 'landlord',
                    initialTabIndex: 1,
                  ),
                ),
                (route) => false,
              );
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white
                    : const Color(0xFFF09418),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Select $title',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isPrimary
                        ? const Color(0xFFF09418)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}