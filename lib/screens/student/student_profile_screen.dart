import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../auth/role_selection_screen.dart';

// ─────────────────────────────────────────────
// STUDENT PROFILE SCREEN
// Shows student info and sign out button.
// Navigated to from bottom nav Profile tab.
// ─────────────────────────────────────────────
class StudentProfileScreen extends StatefulWidget {
  final String studentName;
  final String university;

  const StudentProfileScreen({
    super.key,
    required this.studentName,
    required this.university,
  });

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState
    extends State<StudentProfileScreen> {

  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ─────────────────────────────────────────────
  // LOAD USER DATA FROM FIRESTORE
  // ─────────────────────────────────────────────
  Future<void> _loadUserData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final user = await _authService
            .getUserById(currentUser.uid);
        if (mounted) setState(() => _user = user);
      }
    } catch (e) {
      print('❌ Error loading user: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // SIGN OUT
  // Logs out user and navigates to role selection
  // ─────────────────────────────────────────────
  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: const Color(0xFF2B658B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
            colors: [
              Color(0xFFF1F9EE),
              Color(0xFFF1F3FA),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2B658B),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildAvatar(),
                      const SizedBox(height: 24),
                      _buildInfoCards(),
                      const SizedBox(height: 24),
                      _buildSignOutButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Profile',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to edit profile screen
            },
            child: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF2B658B),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar with name and role ──
  Widget _buildAvatar() {
    final name = _user?.name ?? widget.studentName;
    final initial = name.isNotEmpty
        ? name[0].toUpperCase()
        : 'S';

    return Column(
      children: [
        // Avatar circle
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF2B658B),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Name
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),

        const SizedBox(height: 4),

        // Role
        Text(
          'Student',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF5C6B8A),
          ),
        ),

        const SizedBox(height: 10),

        // Verified badge
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3DE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Verified Account',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B6D11),
            ),
          ),
        ),
      ],
    );
  }

  // ── Info cards ──
  Widget _buildInfoCards() {
    final email = _user?.email ?? '';
    final phone = _user?.phone ?? '';
    final university = _user?.university ??
        widget.university;
    final createdAt = _user?.createdAt;
    final memberSince = createdAt != null
        ? '${_getMonth(createdAt.month)} ${createdAt.year}'
        : '';

    final items = [
      {
        'label': 'Email Address',
        'value': email,
        'icon': Icons.email_outlined,
      },
      {
        'label': 'Phone Number',
        'value': phone,
        'icon': Icons.phone_outlined,
      },
      {
        'label': 'University',
        'value': university,
        'icon': Icons.school_outlined,
      },
      {
        'label': 'Member Since',
        'value': memberSince,
        'icon': Icons.calendar_today_outlined,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFDDE3F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: const Color(0xFF2B658B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['value'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1A1A2E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Sign Out button ──
  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _signOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFFCCCC),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 20,
                color: Color(0xFFE53935),
              ),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Month name helper ──
  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}