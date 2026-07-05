import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'document_submission_screen.dart';

class LandlordPreRegistrationScreen extends StatefulWidget {
  const LandlordPreRegistrationScreen({super.key});

  @override
  State<LandlordPreRegistrationScreen> createState() =>
      _LandlordPreRegistrationScreenState();
}

class _LandlordPreRegistrationScreenState
    extends State<LandlordPreRegistrationScreen> {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // ── Check if email already registered ──
      // Query Firestore users collection
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('email',
              isEqualTo: _emailController.text.trim())
          .get();

      if (existingUser.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'This email is already registered. Please use a different email.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentSubmissionScreen(
              landlordName: _nameController.text.trim(),
              landlordEmail: _emailController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Pre-registration error: $e');
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentSubmissionScreen(
              landlordName: _nameController.text.trim(),
              landlordEmail: _emailController.text.trim(),
            ),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Back button ──
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
                            size: 18),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Title ──
                    Text(
                      'Get Started',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your details to begin the verification process.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF5C6B8A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Name field ──
                    Text('Full Name',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1A1A2E)),
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.person_outline,
                            color: Colors.grey.shade400,
                            size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFDDE3F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFF09418),
                              width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      validator: (v) => v!.isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Email field ──
                    Text('Email Address',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1A1A2E)),
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: Colors.grey.shade400,
                            size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFDDE3F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFF09418),
                              width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      validator: (v) {
                        if (v!.isEmpty)
                          return 'Please enter your email';
                        if (!v.contains('@'))
                          return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // ── Info box ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFF09418)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16,
                              color: Color(0xFFF09418)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Use a new email not previously registered on UniBoard.',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF854F0B),
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Continue button ──
                    GestureDetector(
                      onTap: _isLoading ? null : _proceed,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF09418),
                          borderRadius: BorderRadius.circular(16),
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
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5))
                              : Text(
                                  'Continue',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}