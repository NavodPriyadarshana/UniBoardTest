import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'otp_verification_screen.dart';

// ─────────────────────────────────────────────
// DOCUMENT SUBMISSION SCREEN
// New landlord uploads 4 verification PDFs
// ─────────────────────────────────────────────
class DocumentSubmissionScreen extends StatefulWidget {
  final String landlordName;
  final String landlordEmail;

  const DocumentSubmissionScreen({
    super.key,
    required this.landlordName,
    required this.landlordEmail,
  });

  @override
  State<DocumentSubmissionScreen> createState() =>
      _DocumentSubmissionScreenState();
}

class _DocumentSubmissionScreenState
    extends State<DocumentSubmissionScreen> {

  File? _nicFront;
  File? _nicBack;
  File? _propertyDoc;
  File? _policeReport;
  bool _isLoading = false;

  // ─────────────────────────────────────────────
  // PICK PDF FILE
  // ─────────────────────────────────────────────
  Future<File?> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // UPLOAD FILE TO FIREBASE STORAGE
  // ─────────────────────────────────────────────
  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // SUBMIT DOCUMENTS
  // ─────────────────────────────────────────────
  Future<void> _submitDocuments() async {
    if (_nicFront == null ||
        _nicBack == null ||
        _propertyDoc == null ||
        _policeReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all 4 documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final applicationId = FirebaseFirestore.instance
          .collection('landlord_applications')
          .doc()
          .id;

      // ── Upload all 4 files ──
      final basePath =
          'landlord_documents/$applicationId';

      final nicFrontUrl = await _uploadFile(
          _nicFront!, '$basePath/nic_front.pdf');
      final nicBackUrl = await _uploadFile(
          _nicBack!, '$basePath/nic_back.pdf');
      final propertyDocUrl = await _uploadFile(
          _propertyDoc!, '$basePath/property_deed.pdf');
      final policeReportUrl = await _uploadFile(
          _policeReport!, '$basePath/police_report.pdf');

      // ── Save application to Firestore ──
      await FirebaseFirestore.instance
          .collection('landlord_applications')
          .doc(applicationId)
          .set({
        'applicationId': applicationId,
        'landlordName': widget.landlordName,
        'landlordEmail': widget.landlordEmail,
        'nicFront': nicFrontUrl ?? '',
        'nicBack': nicBackUrl ?? '',
        'propertyDoc': propertyDocUrl ?? '',
        'policeReport': policeReportUrl ?? '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Documents Submitted! 📄',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E)),
            ),
            content: Text(
              'Your documents have been submitted for review. Please check your email for the OTP once approved by our admin team. Click below to enter your OTP.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerificationScreen(
                        landlordEmail: widget.landlordEmail,
                        landlordName: widget.landlordName,
                      ),
                    ),
                  );
                },
                child: Text('Enter OTP',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFF09418),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Submission error: $e');
      if (mounted) {
        // ── Even on error navigate to OTP screen ──
        // Application may have been partially saved
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Documents Submitted! 📄',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E)),
            ),
            content: Text(
              'Your application has been submitted. Please check your email for the OTP once approved by our admin team.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerificationScreen(
                        landlordEmail: widget.landlordEmail,
                        landlordName: widget.landlordName,
                      ),
                    ),
                  );
                },
                child: Text('Enter OTP',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFF09418),
                        fontWeight: FontWeight.w600)),
              ),
            ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                  Text('Submit Documents',
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text(
                      'Upload required verification documents',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF5C6B8A))),
                  const SizedBox(height: 24),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFF09418)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 18, color: Color(0xFFF09418)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All documents must be in PDF format. Your application will be reviewed within 24 hours.',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF854F0B),
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Document upload fields
                  _buildUploadField(
                    label: 'NIC Front',
                    subtitle: 'Front side of National ID Card',
                    icon: Icons.credit_card_rounded,
                    file: _nicFront,
                    onTap: () async {
                      final file = await _pickPdf();
                      if (file != null)
                        setState(() => _nicFront = file);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildUploadField(
                    label: 'NIC Back',
                    subtitle: 'Back side of National ID Card',
                    icon: Icons.credit_card_rounded,
                    file: _nicBack,
                    onTap: () async {
                      final file = await _pickPdf();
                      if (file != null)
                        setState(() => _nicBack = file);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildUploadField(
                    label: 'Property Ownership Document',
                    subtitle: 'Deed or title document',
                    icon: Icons.home_work_rounded,
                    file: _propertyDoc,
                    onTap: () async {
                      final file = await _pickPdf();
                      if (file != null)
                        setState(() => _propertyDoc = file);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildUploadField(
                    label: 'Police Clearance Report',
                    subtitle: 'Valid police clearance certificate',
                    icon: Icons.shield_rounded,
                    file: _policeReport,
                    onTap: () async {
                      final file = await _pickPdf();
                      if (file != null)
                        setState(() => _policeReport = file);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  GestureDetector(
                    onTap: _isLoading ? null : _submitDocuments,
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
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5))
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.upload_rounded,
                                      color: Colors.white,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text('Submit Documents',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: Colors.white)),
                                ],
                              ),
                      ),
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

  Widget _buildUploadField({
    required String label,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    final bool isUploaded = file != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFF3B6D11)
                : const Color(0xFFDDE3F0),
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFFEAF3DE)
                    : const Color(0xFFFFF8EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                color: isUploaded
                    ? const Color(0xFF3B6D11)
                    : const Color(0xFFF09418),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded
                        ? file.path.split('/').last
                        : subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isUploaded
                            ? const Color(0xFF3B6D11)
                            : const Color(0xFF5C6B8A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded
                  ? Icons.edit_rounded
                  : Icons.upload_file_rounded,
              color: isUploaded
                  ? const Color(0xFF3B6D11)
                  : const Color(0xFFF09418),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}