import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

// ─────────────────────────────────────────────
// ADD LISTING SCREEN
// Landlord fills in boarding details.
// University + Location covers all faculty areas.
// ─────────────────────────────────────────────
class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() =>
      _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _slotsController = TextEditingController();
  final _houseRulesController = TextEditingController();
  final _amenityController = TextEditingController();

  // Dropdown values
  String? _selectedUniversity;
  String? _selectedRoomType;
  String? _selectedGender;

  // Amenities list
  List<String> _amenities = [];

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

  static const List<String> _roomTypes = [
    'Single',
    'Double',
    'Shared',
  ];

  static const List<String> _genders = [
    'Any',
    'Male',
    'Female',
  ];

  static const List<String> _suggestedAmenities = [
    'WiFi',
    'AC',
    'Hot Water',
    'Cooking',
    'Parking',
    'Laundry',
    'Security',
    'Garden',
    'Attached Bath',
    'CCTV',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _slotsController.dispose();
    _houseRulesController.dispose();
    _amenityController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // ADD AMENITY
  // ─────────────────────────────────────────────
  void _addAmenity(String amenity) {
    if (amenity.isNotEmpty && !_amenities.contains(amenity)) {
      setState(() => _amenities.add(amenity));
    }
    _amenityController.clear();
  }

  void _removeAmenity(String amenity) {
    setState(() => _amenities.remove(amenity));
  }

  // ─────────────────────────────────────────────
  // PUBLISH LISTING
  // Saves listing to Firestore
  // ─────────────────────────────────────────────
  Future<void> _publishListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUniversity == null) {
      _showError('Please select the nearest university');
      return;
    }
    if (_selectedRoomType == null) {
      _showError('Please select room type');
      return;
    }
    if (_selectedGender == null) {
      _showError('Please select gender preference');
      return;
    }
    if (_amenities.isEmpty) {
      _showError('Please add at least one amenity');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // Generate listing ID
      final listingId = FirebaseFirestore.instance
          .collection('listings')
          .doc()
          .id;

      final price = double.tryParse(_priceController.text) ?? 0;
      final slots = int.tryParse(_slotsController.text) ?? 1;

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .set({
        'listingId': listingId,
        'landlordId': currentUser.uid,
        'title': '${_selectedRoomType ?? 'Room'} near ${_selectedUniversity ?? 'University'} — ${_locationController.text.trim()}',
        'description': _descriptionController.text.trim(),
        'location': '${_locationController.text.trim()}, ${_cityController.text.trim()}',
        'city': _cityController.text.trim(),
        'university': _selectedUniversity,
        'roomType': _selectedRoomType,
        'genderPreference': _selectedGender,
        'pricePerSlot': price,
        'totalCapacity': slots,
        'availableSlots': slots,
        'currentOccupants': 0,
        'amenities': _amenities,
        'houseRules': _houseRulesController.text.trim(),
        'photos': [],
        'isVerified': false,
        'membershipActive': true,
        'latitude': 0.0,
        'longitude': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Listing Published! 🎉',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E))),
            content: Text(
              'Your listing has been submitted for verification. It will be visible to students once verified by our admin team.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFF09418),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Error publishing listing: $e');
      _showError('Failed to publish listing. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
      ),
    );
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
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Location/Area'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _locationController,
                                      hint: 'e.g. Kamburupitiya',
                                      icon: Icons.location_on_outlined,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Required' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('City'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _cityController,
                                      hint: 'e.g. Matara',
                                      icon: Icons.location_city_outlined,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Required' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Room Type'),
                                    const SizedBox(height: 8),
                                    _buildDropdown(
                                      value: _selectedRoomType,
                                      items: _roomTypes,
                                      hint: 'Select',
                                      onChanged: (val) => setState(
                                          () => _selectedRoomType = val),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Gender'),
                                    const SizedBox(height: 8),
                                    _buildDropdown(
                                      value: _selectedGender,
                                      items: _genders,
                                      hint: 'Select',
                                      onChanged: (val) => setState(
                                          () => _selectedGender = val),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Price/Month (LKR)'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _priceController,
                                      hint: 'e.g. 8500',
                                      icon: Icons.payments_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Required' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Total Slots'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _slotsController,
                                      hint: 'e.g. 4',
                                      icon: Icons.people_outline_rounded,
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Required' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Nearest University'),
                          const SizedBox(height: 8),
                          _buildUniversityDropdown(),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8EC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFF09418)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                    Icons.info_outline_rounded,
                                    size: 16,
                                    color: Color(0xFFF09418)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Select the university your boarding is closest to. If near a specific faculty, mention it in the location field above.',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: const Color(0xFF854F0B)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Amenities'),
                          const SizedBox(height: 8),
                          _buildAmenities(),
                          const SizedBox(height: 16),
                          _buildLabel('House Rules'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _houseRulesController,
                            hint: 'e.g. Gate closes at 9PM. No visitors after 8PM.',
                            icon: Icons.rule_outlined,
                            maxLines: 3,
                            validator: (v) => v!.isEmpty
                                ? 'Please enter house rules'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Description'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _descriptionController,
                            hint: 'Describe your boarding room...',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                            validator: (v) => v!.isEmpty
                                ? 'Please enter a description'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          _buildPublishButton(),
                          const SizedBox(height: 16),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: Color(0xFFF09418), size: 18),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Add New Listing',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fill in your boarding details',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF5C6B8A),
          ),
        ),
      ],
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
              ? const Color(0xFFF09418)
              : const Color(0xFFDDE3F0),
          width: _selectedUniversity != null ? 1.5 : 1,
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
              Text('Select nearest university',
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

  // ── Generic dropdown ──
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? const Color(0xFFF09418)
              : const Color(0xFFDDE3F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade400)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade400, size: 18),
          style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF1A1A2E)),
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item,
                        style:
                            GoogleFonts.poppins(fontSize: 13)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── Amenities ──
  Widget _buildAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Suggested amenities
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._amenities.map((amenity) {
              return GestureDetector(
                onTap: () => _removeAmenity(amenity),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(amenity,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF3B6D11),
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.close_rounded,
                          size: 14,
                          color: Color(0xFF3B6D11)),
                    ],
                  ),
                ),
              );
            }),
            // Add button
            GestureDetector(
              onTap: () => _showAmenityPicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFF09418)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 14,
                        color: Color(0xFFF09418)),
                    const SizedBox(width: 4),
                    Text('Add',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFFF09418),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAmenityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Amenities',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E))),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedAmenities.map((amenity) {
                  final isAdded =
                      _amenities.contains(amenity);
                  return GestureDetector(
                    onTap: () {
                      if (isAdded) {
                        _removeAmenity(amenity);
                      } else {
                        _addAmenity(amenity);
                      }
                      Navigator.pop(context);
                      _showAmenityPicker();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAdded
                            ? const Color(0xFFEAF3DE)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: isAdded
                              ? const Color(0xFF3B6D11)
                              : const Color(0xFFDDE3F0),
                        ),
                      ),
                      child: Text(amenity,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isAdded
                                  ? const Color(0xFF3B6D11)
                                  : const Color(0xFF1A1A2E),
                              fontWeight: isAdded
                                  ? FontWeight.w600
                                  : FontWeight.w400)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF09418),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text('Done',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Publish button ──
  Widget _buildPublishButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _publishListing,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF09418),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF09418).withOpacity(0.35),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.publish_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Publish Listing',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
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
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(
          fontSize: 14, color: const Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: Colors.grey.shade400, size: 20)
            : null,
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
              color: Color(0xFFF09418), width: 1.5),
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