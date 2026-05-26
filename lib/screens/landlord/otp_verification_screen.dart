import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'membership_plans_screen.dart';

// ─────────────────────────────────────────────
// OTP VERIFICATION SCREEN
// Landlord enters 6 digit OTP sent by admin
// after document verification approval.
// OTP is verified against Firestore record.
// ─────────────────────────────────────────────
class OtpVerificationScreen extends StatefulWidget {
  final String landlordEmail;
  final String landlordName;

  const OtpVerificationScreen({
    super.key,
    required this.landlordEmail,
    required this.landlordName,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {

  // 6 controllers for 6 OTP digits
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // GET ENTERED OTP
  // ─────────────────────────────────────────────
  String get _enteredOtp =>
      _controllers.map((c) => c.text).join();

  // ─────────────────────────────────────────────
  // VERIFY OTP
  // Checks OTP against Firestore record
  // ─────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    if (_enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6 digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check OTP in Firestore
      final query = await FirebaseFirestore.instance
          .collection('landlord_otps')
          .where('email', isEqualTo: widget.landlordEmail)
          .where('otp', isEqualTo: _enteredOtp)
          .where('isUsed', isEqualTo: false)
          .get();

      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid or expired OTP. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Check OTP expiry
      final otpDoc = query.docs.first;
      final expiresAt =
          otpDoc['expiresAt'] as Timestamp?;

      if (expiresAt != null &&
          expiresAt.toDate().isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP has expired. Please request a new one.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Mark OTP as used
      await FirebaseFirestore.instance
          .collection('landlord_otps')
          .doc(otpDoc.id)
          .update({'isUsed': true});

      // Navigate to membership plans
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MembershipPlansScreen(
              landlordEmail: widget.landlordEmail,
              landlordName: widget.landlordName,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ OTP verification error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed. Try again.'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  const Color(0xFFDDE3F0)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color(0xFFF09418),
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8EC),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFF09418),
                          width: 2),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 36,
                      color: Color(0xFFF09418),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Check Your Email',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit OTP to',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF5C6B8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.landlordEmail,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF09418),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Divider(color: Colors.grey.shade200),

                  const SizedBox(height: 24),

                  Text(
                    'Enter verification code',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // OTP input boxes
                  _buildOtpInputs(),

                  const SizedBox(height: 32),

                  // Verify button
                  GestureDetector(
                    onTap: _isLoading ? null : _verifyOtp,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF09418),
                        borderRadius:
                            BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF09418)
                                .withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Verify OTP',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Resend option
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF5C6B8A),
                        ),
                      ),
                      GestureDetector(
                        onTap: _isResending
                            ? null
                            : () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please contact admin to resend OTP'),
                                    backgroundColor:
                                        Color(0xFFF09418),
                                  ),
                                );
                              },
                        child: Text(
                          'Resend',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF09418),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── OTP input boxes ──
  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 46,
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFF09418), width: 2),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                // Move to next box
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                // Move to previous box on delete
                _focusNodes[index - 1].requestFocus();
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }
}