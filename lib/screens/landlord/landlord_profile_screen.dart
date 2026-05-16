import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../auth/role_selection_screen.dart';

class LandlordProfileScreen extends StatefulWidget {
  final String landlordName;
  const LandlordProfileScreen({super.key, required this.landlordName});

  @override
  State<LandlordProfileScreen> createState() => _LandlordProfileScreenState();
}

class _LandlordProfileScreenState extends State<LandlordProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final user = await _authService.getUserById(currentUser.uid);
        if (mounted) setState(() => _user = user);
      }
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFFF09418), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
            child: Text('Sign Out', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.name ?? widget.landlordName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'L';

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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFF09418)))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFDDE3F0)),
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFF09418), size: 18),
                                  ),
                                ),
                                const Icon(Icons.edit_outlined, color: Color(0xFFF09418), size: 24),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text('My Profile', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                          ],
                        ),
                      ),

                      // Avatar
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFFF09418),
                        child: Text(initial, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                      Text(name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 4),
                      Text('Landlord', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF5C6B8A))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFFFF8EC), borderRadius: BorderRadius.circular(20)),
                        child: Text('Verified Landlord', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFF09418))),
                      ),
                      const SizedBox(height: 24),

                      // Info cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _infoCard('Email Address', _user?.email ?? '', Icons.email_outlined),
                            _infoCard('Phone Number', _user?.phone ?? '', Icons.phone_outlined),
                            _infoCard('Member Since',
                              _user?.createdAt != null
                                  ? '${_getMonth(_user!.createdAt.month)} ${_user!.createdAt.year}'
                                  : '',
                              Icons.calendar_today_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign out
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GestureDetector(
                          onTap: _signOut,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFFCCCC)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFE53935)),
                                const SizedBox(width: 8),
                                Text('Sign Out', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFFE53935))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFF09418)),
              const SizedBox(width: 10),
              Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A2E), fontWeight: FontWeight.w500))),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}