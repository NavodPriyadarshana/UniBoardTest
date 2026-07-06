import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import '../auth/auth_screen.dart';

// ─────────────────────────────────────────────
// MEMBERSHIP PLANS SCREEN
// Landlord selects a membership plan
// after OTP verification.
// PayHere sandbox payment integration.
// ─────────────────────────────────────────────
class MembershipPlansScreen extends StatelessWidget {
  final String landlordEmail;
  final String landlordName;

  const MembershipPlansScreen({
    super.key,
    required this.landlordEmail,
    required this.landlordName,
  });

  // ─────────────────────────────────────────────
  // LAUNCH PAYHERE PAYMENT
  // ─────────────────────────────────────────────
  void _launchPayhere({
    required BuildContext context,
    required String planName,
    required String price,
  }) {
    // Clean amount: "LKR 1,500" → "1500.00"
    final cleaned = price
        .replaceAll('LKR ', '')
        .replaceAll(',', '')
        .replaceAll('/mo', '')
        .trim();
    final amount = double.tryParse(cleaned) ?? 0.0;

    final nameParts = landlordName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'N';

    // ── PayHere payment object ──
    Map paymentObject = {
      "sandbox": true,
      "merchant_id": "1236736",
      "merchant_secret": "MjY2ODM4NDUzNzQ5MDI4Nzk3NDQwNTU4MTU3Njk0Mjc2NTgwMjY3",
      "notify_url": "https://uniboard-fd52f.web.app",
      "order_id": "ORD${DateTime.now().millisecondsSinceEpoch}",
      "items": "UniBoard $planName Plan",
      "amount": amount.toStringAsFixed(2),
      "currency": "LKR",
      "first_name": firstName,
      "last_name": lastName,
      "email": landlordEmail,
      "phone": "0771234567",
      "address": "Sri Lanka",
      "city": "Colombo",
      "country": "Sri Lanka",
      "delivery_address": "Sri Lanka",
      "delivery_city": "Colombo",
      "delivery_country": "Sri Lanka",
      "custom_1": "",
      "custom_2": "",
    };

    PayHere.startPayment(
      paymentObject,
      // ── Payment success ──
      (paymentId) {
        debugPrint('Payment Success! ID: $paymentId');
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const AuthScreen(
                role: 'landlord',
                initialTabIndex: 1,
              ),
            ),
            (route) => false,
          );
        }
      },
      // ── Payment error ──
      (error) {
        debugPrint('Payment Error: $error');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      // ── Payment dismissed ──
      () {
        debugPrint('Payment dismissed');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment cancelled.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'name': 'Basic',
        'price': 'LKR 1,500',
        'period': '/month',
        'features': [
          'Up to 2 listings',
          'Basic support',
          'Standard visibility',
        ],
        'isPrimary': false,
        'badge': null,
      },
      {
        'name': 'Standard',
        'price': 'LKR 2,500',
        'period': '/month',
        'features': [
          'Up to 5 listings',
          'Priority support',
          'Enhanced visibility',
          'Analytics dashboard',
        ],
        'isPrimary': true,
        'badge': 'Most Popular',
      },
      {
        'name': 'Premium',
        'price': 'LKR 4,500',
        'period': '/month',
        'features': [
          'Unlimited listings',
          '24/7 support',
          'Top visibility',
          'Advanced analytics',
          'Featured badge',
        ],
        'isPrimary': false,
        'badge': 'Best Value',
      },
    ];

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
                  // ── Header ──
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFDDE3F0)),
                      ),
                      child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color(0xFFF09418), size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Choose Your Plan',
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text('Select a membership plan to continue',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF5C6B8A))),
                  const SizedBox(height: 24),

                  // ── Plan cards ──
                  ...plans.map((plan) {
                    final isPrimary = plan['isPrimary'] as bool;
                    final badge = plan['badge'] as String?;
                    final features = plan['features'] as List;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isPrimary
                                  ? const Color(0xFFF09418)
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                color: isPrimary
                                    ? const Color(0xFFF09418)
                                    : const Color(0xFFDDE3F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isPrimary
                                      ? const Color(0xFFF09418)
                                          .withOpacity(0.3)
                                      : Colors.black
                                          .withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(plan['name'] as String,
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isPrimary
                                            ? Colors.white
                                            : const Color(
                                                0xFF1A1A2E))),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(plan['price'] as String,
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight:
                                                FontWeight.w700,
                                            color: isPrimary
                                                ? Colors.white
                                                : const Color(
                                                    0xFFF09418))),
                                    Text(plan['period'] as String,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: isPrimary
                                                ? Colors.white
                                                    .withOpacity(0.7)
                                                : const Color(
                                                    0xFF5C6B8A))),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...features.map((feature) =>
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(
                                              bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                              Icons
                                                  .check_circle_rounded,
                                              size: 16,
                                              color: isPrimary
                                                  ? Colors.white
                                                  : const Color(
                                                      0xFF3B6D11)),
                                          const SizedBox(width: 8),
                                          Text(feature as String,
                                              style:
                                                  GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: isPrimary
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF1A1A2E))),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 16),

                                // ── Select Plan button ──
                                GestureDetector(
                                  onTap: () => _launchPayhere(
                                    context: context,
                                    planName:
                                        plan['name'] as String,
                                    price: plan['price'] as String,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isPrimary
                                          ? Colors.white
                                          : const Color(0xFFF09418),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text('Select Plan',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: isPrimary
                                                  ? const Color(
                                                      0xFFF09418)
                                                  : Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (badge != null)
                            Positioned(
                              top: 12, right: 12,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPrimary
                                      ? Colors.white
                                      : const Color(0xFFF09418),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(badge,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isPrimary
                                            ? const Color(0xFFF09418)
                                            : Colors.white)),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '🔒 Secure payment powered by PayHere',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500),
                    ),
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
}