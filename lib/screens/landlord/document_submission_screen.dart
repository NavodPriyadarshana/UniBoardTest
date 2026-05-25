import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// DOCUMENT SUBMISSION SCREEN
// Landlord uploads verification documents
// before registration. Admin reviews within
// 24 hours and sends OTP on approval.
// ─────────────────────────────────────────────
class DocumentSubmissionScreen extends StatefulWidget {
  final String landlordEmail;
  final String landlordName;

  const DocumentSubmissionScreen({
    super.key,
    required this.landlordEmail,
    required this.landlordName,
  });

  @override
  State<DocumentSubmissionScreen> createState() =>
      _DocumentSubmissionScreenState();
}

class _DocumentSubmissionScreenState
    extends State<DocumentSubmissionScreen> {

  // Selected files
  File? _nicFront;
  File? _nicBack;
  File? _propertyDoc;
  File? _policeReport;

  // File names for display
  String? _nicFrontName;
  String? _nicBackName;
  String? _propertyDocName;
  String? _policeReportName;

  bool _isLoading = false;

  // ─────────────────────────────────────────────
  // PICK PDF FILE
  // ─────────────────────────────────────────────
  Future<void> _pickFile(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        setState(() {
          switch (docType) {
            case 'nicFront':
              _nicFront = file;
              _nicFrontName = fileName;
              break;
            case 'nicBack':
              _nicBack = file;
              _nicBackName = fileName;
              break;
            case 'propertyDoc':
              _propertyDoc = file;
              _propertyDocName = fileName;
              break;
            case 'policeReport':
              _policeReport = file;
              _policeReportName = fileName;
              break;
          }
        });
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // UPLOAD FILE TO FIREBASE STORAGE
  // ─────────────────────────────────────────────
  Future<String?> _uploadFile(
      File file, String path) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // SUBMIT DOCUMENTS
  // Uploads all docs to Firebase Storage
  // Saves application to Firestore
  // ─────────────────────────────────────────────
  Future<void> _submitDocuments() async {
    if (_nicFront == null ||
        _nicBack == null ||
        _propertyDoc == null ||
        _policeReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
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

      final basePath =
          'landlord_documents/$applicationId';

      // Upload all documents
      final nicFrontUrl = await _uploadFile(
          _nicFront!, '$basePath/nic_front.pdf');
      final nicBackUrl = await _uploadFile(
          _nicBack!, '$basePath/nic_back.pdf');
      final propertyUrl = await _uploadFile(
          _propertyDoc!, '$basePath/property_doc.pdf');
      final policeUrl = await _uploadFile(
          _policeReport!, '$basePath/police_report.pdf');

      // Save application to Firestore
      await FirebaseFirestore.instance
          .collection('landlord_applications')
          .doc(applicationId)
          .set({
        'applicationId': applicationId,
        'landlordName': widget.landlordName,
        'landlordEmail': widget.landlordEmail,
        'nicFront': nicFrontUrl,
        'nicBack': nicBackUrl,
        'propertyDoc': propertyUrl,
        'policeReport': policeUrl,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
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
                color: const Color(0xFF1A1A2E),
              ),
            ),
            content: Text(
              'Thank you ${widget.landlordName}! Your documents have been submitted successfully.\n\nOur admin team will review your documents within 24 hours. You will receive an email at ${widget.landlordEmail} with further instructions.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFF09418),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit. Try again.'),
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildInfoBanner(),
                        const SizedBox(height: 20),
                        _buildUploadField(
                          label: 'NIC — Front Side',
                          docType: 'nicFront',
                          fileName: _nicFrontName,
                          isUploaded: _nicFront != null,
                        ),
                        const SizedBox(height: 14),
                        _buildUploadField(
                          label: 'NIC — Back Side',
                          docType: 'nicBack',
                          fileName: _nicBackName,
                          isUploaded: _nicBack != null,
                        ),
                        const SizedBox(height: 14),
                        _buildUploadField(
                          label: 'Property Ownership Document',
                          docType: 'propertyDoc',
                          fileName: _propertyDocName,
                          isUploaded: _propertyDoc != null,
                        ),
                        const SizedBox(height: 14),
                        _buildUploadField(
                          label: 'Police Clearance Report',
                          docType: 'policeReport',
                          fileName: _policeReportName,
                          isUploaded: _policeReport != null,
                        ),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Row(
      children: [
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
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification Documents',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              'Upload required PDF documents',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF5C6B8A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Info banner ──
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF09418)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: Color(0xFFF09418)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please upload clear PDF copies of your documents. Our admin team will review within 24 hours and notify you via email.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF854F0B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Upload field ──
  Widget _buildUploadField({
    required String label,
    required String docType,
    required String? fileName,
    required bool isUploaded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickFile(docType),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isUploaded
                  ? const Color(0xFFEAF3DE)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUploaded
                    ? const Color(0xFF3B6D11)
                    : const Color(0xFFF09418),
                width: 1.5,
                style: isUploaded
                    ? BorderStyle.solid
                    : BorderStyle.solid,
              ),
            ),
            child: isUploaded
                ? Row(
                    children: [
                      const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF3B6D11),
                          size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fileName ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF3B6D11),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            switch (docType) {
                              case 'nicFront':
                                _nicFront = null;
                                _nicFrontName = null;
                                break;
                              case 'nicBack':
                                _nicBack = null;
                                _nicBackName = null;
                                break;
                              case 'propertyDoc':
                                _propertyDoc = null;
                                _propertyDocName = null;
                                break;
                              case 'policeReport':
                                _policeReport = null;
                                _policeReportName = null;
                                break;
                            }
                          });
                        },
                        child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF3B6D11),
                            size: 18),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file_rounded,
                          color: Color(0xFFF09418),
                          size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Tap to upload PDF',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFFF09418),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── Submit button ──
  Widget _buildSubmitButton() {
    final allUploaded = _nicFront != null &&
        _nicBack != null &&
        _propertyDoc != null &&
        _policeReport != null;

    return GestureDetector(
      onTap: (_isLoading || !allUploaded)
          ? null
          : _submitDocuments,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: allUploaded
              ? const Color(0xFFF09418)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: allUploaded
              ? [
                  BoxShadow(
                    color: const Color(0xFFF09418)
                        .withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
                  'Submit Documents',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}