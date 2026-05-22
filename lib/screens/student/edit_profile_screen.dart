import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';

// ─────────────────────────────────────────────
// EDIT PROFILE SCREEN
// Student can update name, phone and university.
// Email is not editable (Firebase restriction).
// ─────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentUniversity;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.currentUniversity,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final AuthService _authService = AuthService();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedUniversity;
  bool _isLoading = false;
  File? _pickedImage;
  String? _profileImageUrl;
  final _formKey = GlobalKey<FormState>();

  static const List<String> _universities = [
    'SLTC Research University',
    'University of Colombo',
    'University of Moratuwa',
    'University of Kelaniya',
    'University of Sri Jayewardenepura',
    'University of Peradeniya',
    'University of Ruhuna',
    'University of Jaffna',
    'NSBM Green University',
    'SLIIT - Sri Lanka Institute of IT',
    'IIT - Informatics Institute of Technology',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.currentName);
    _phoneController =
        TextEditingController(text: widget.currentPhone);
    _selectedUniversity = widget.currentUniversity
            .isNotEmpty
        ? widget.currentUniversity
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // PICK IMAGE — Camera or Gallery
  // ─────────────────────────────────────────────
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Profile Photo',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Camera option
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _selectImage(
                          ImageSource.camera);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3EDF4),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                              Icons.camera_alt_rounded,
                              color: Color(0xFF2B658B),
                              size: 32),
                          const SizedBox(height: 8),
                          Text('Camera',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: const Color(
                                      0xFF2B658B))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Gallery option
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _selectImage(
                          ImageSource.gallery);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3DE),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                              Icons.photo_library_rounded,
                              color: Color(0xFF3B6D11),
                              size: 32),
                          const SizedBox(height: 8),
                          Text('Gallery',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: const Color(
                                      0xFF3B6D11))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 400,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  // ─────────────────────────────────────────────
  // UPLOAD IMAGE TO FIREBASE STORAGE
  // ─────────────────────────────────────────────
  Future<String?> _uploadImage(String userId) async {
    if (_pickedImage == null) return null;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');
      await ref.putFile(_pickedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // SAVE CHANGES
  // Updates user document in Firestore
  // ─────────────────────────────────────────────
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // Upload image if picked
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(currentUser.uid);
      }

      final Map<String, dynamic> updates = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'university': _selectedUniversity ?? '',
      };

      if (imageUrl != null) {
        updates['profilePicture'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF3B6D11),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildAvatar(),
                          const SizedBox(height: 24),
                          _buildLabel('Full Name'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => v!.isEmpty
                                ? 'Please enter your name'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Phone Number'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            hint: 'Enter your phone number',
                            icon: Icons.phone_outlined,
                            keyboardType:
                                TextInputType.phone,
                            validator: (v) => v!.isEmpty
                                ? 'Please enter your phone'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('University'),
                          const SizedBox(height: 8),
                          _buildUniversityDropdown(),
                          const SizedBox(height: 16),

                          // Email — not editable
                          _buildLabel('Email Address'),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.email_outlined,
                                    color: Colors.grey.shade400,
                                    size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _authService.currentUser
                                            ?.email ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.lock_outline_rounded,
                                    color: Colors.grey.shade400,
                                    size: 16),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email cannot be changed',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                        ],
                      ),
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
              border:
                  Border.all(color: const Color(0xFFDDE3F0)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Color(0xFF2B658B),
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              'Update your information',
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

  // ── Avatar ──
  Widget _buildAvatar() {
    final String name = _nameController.text;
    final String initial =
        name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF2B658B),
              backgroundImage: _pickedImage != null
                  ? FileImage(_pickedImage!)
                  : null,
              child: _pickedImage == null
                  ? Text(
                      initial,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF09418),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── University dropdown ──
  Widget _buildUniversityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _selectedUniversity != null
              ? const Color(0xFF2B658B)
              : const Color(0xFFDDE3F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUniversity,
          hint: Row(
            children: [
              Icon(Icons.school_outlined,
                  color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 10),
              Text('Select university',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400)),
            ],
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade400),
          style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF1A1A2E)),
          onChanged: (val) =>
              setState(() => _selectedUniversity = val),
          items: _universities
              .map((u) => DropdownMenuItem(
                    value: u,
                    child: Text(u,
                        style:
                            GoogleFonts.poppins(fontSize: 13)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── Save button ──
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _saveChanges,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF2B658B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B658B).withOpacity(0.35),
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
                      color: Colors.white, strokeWidth: 2.5))
              : Text(
                  'Save Changes',
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

  // ── Text field ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(
          fontSize: 14, color: const Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 13, color: Colors.grey.shade400),
        prefixIcon:
            Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFDDE3F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color(0xFF2B658B), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }
}