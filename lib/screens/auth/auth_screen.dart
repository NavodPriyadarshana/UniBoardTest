import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../student/student_home_screen.dart';
import '../landlord/landlord_home_screen.dart';

class AuthScreen extends StatefulWidget {
  final String role;
  final int initialTabIndex;
  const AuthScreen({
    super.key,
    required this.role,
    this.initialTabIndex = 0,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get _roleColor {
    return widget.role == 'landlord'
        ? const Color(0xFFF09418)
        : const Color(0xFF2B658B);
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
            stops: [0.0, 1.0],
            colors: [Color(0xFFF1F9EE), Color(0xFFF1F3FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar: back button ──
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _roleColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // ── White bottom sheet ──
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildTabBar(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                                  _SignInForm(
                                    role: widget.role,
                                    roleColor: _roleColor,
                                  ),
                                  _SignUpForm(
                                    role: widget.role,
                                    roleColor: _roleColor,
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: _roleColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _roleColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade500,
          labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Sign Up'),
                ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIGN IN FORM
// ─────────────────────────────────────────────
class _SignInForm extends StatefulWidget {
  final String role;
  final Color roleColor;
  const _SignInForm({required this.role, required this.roleColor});

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await _authService.loginWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted && user != null) {
        // ── Check role matches selected role ──
        if (widget.role == 'landlord' && user.isStudent) {
          await _authService.logout();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'This is a student account. Please use the student login.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (widget.role == 'student' && user.isLandlord) {
          await _authService.logout();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'This is a landlord account. Please use the landlord login.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (user.isStudent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentHomeScreen(
                studentName: user.name,
                university: user.university,
              ),
            ),
          );
        } else if (user.isLandlord) {
          // ── Navigate to Landlord Dashboard ──
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LandlordHomeScreen(
                landlordName: user.name,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      await _authService
          .sendPasswordResetEmail(_emailController.text);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Email Sent! 📧',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700)),
            content: Text(
              'A password reset link has been sent to ${_emailController.text}.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK',
                    style: GoogleFonts.poppins(
                        color: widget.roleColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Sign in to your ${widget.role} account',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              roleColor: widget.roleColor,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your email';
                if (!value.contains('@'))
                  return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              roleColor: widget.roleColor,
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: () => setState(
                    () => _passwordVisible = !_passwordVisible),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your password';
                if (value.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _forgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: widget.roleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildButton(
              label: 'Sign In',
              isLoading: _isLoading,
              roleColor: widget.roleColor,
              onTap: _signIn,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIGN UP FORM
// ─────────────────────────────────────────────
class _SignUpForm extends StatefulWidget {
  final String role;
  final Color roleColor;
  const _SignUpForm({required this.role, required this.roleColor});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedUniversity;

  final AuthService _authService = AuthService();

  static const List<String> _universities = [
    'University of Colombo',
    'University of Moratuwa',
    'University of Kelaniya',
    'University of Sri Jayewardenepura',
    'University of Peradeniya',
    'University of Ruhuna',
    'University of Jaffna',
    'University of Vavuniya',
    'Eastern University of Sri Lanka',
    'South Eastern University of Sri Lanka',
    'Rajarata University of Sri Lanka',
    'Sabaragamuwa University of Sri Lanka',
    'Wayamba University of Sri Lanka',
    'Uva Wellassa University',
    'University of the Visual & Performing Arts',
    'Open University of Sri Lanka',
    'NSBM Green University',
    'SLIIT - Sri Lanka Institute of IT',
    'SLTC Research University',
    'IIT - Informatics Institute of Technology',
    'NIBM - National Institute of Business Management',
    'APIIT Sri Lanka',
    'Esoft Metro Campus',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.role == 'student' && _selectedUniversity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your university'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await _authService.registerWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        role: widget.role,
        university: widget.role == 'student'
            ? (_selectedUniversity ?? '')
            : '',
      );
      if (mounted && user != null) {
        // ── Check role matches selected role ──
        if (widget.role == 'landlord' && user.isStudent) {
          await _authService.logout();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'This is a student account. Please use the student login.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (widget.role == 'student' && user.isLandlord) {
          await _authService.logout();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'This is a landlord account. Please use the landlord login.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (user.isStudent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentHomeScreen(
                studentName: user.name,
                university: user.university,
              ),
            ),
          );
        } else if (user.isLandlord) {
          // ── Navigate to Landlord Dashboard ──
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LandlordHomeScreen(
                landlordName: user.name,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Join Uniboard as a ${widget.role}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Hint for landlord registration ──
            if (widget.role == 'landlord')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF09418)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: Color(0xFFF09418)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please register with the same email used during pre-registration.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF854F0B),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            _buildLabel('Full name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter your full name',
              icon: Icons.person_outline_rounded,
              roleColor: widget.roleColor,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              roleColor: widget.roleColor,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your email';
                if (!value.contains('@'))
                  return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Phone Number'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              roleColor: widget.roleColor,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your phone number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.role == 'student') ...[
              _buildLabel('University'),
              const SizedBox(height: 8),
              _buildUniversityDropdown(widget.roleColor),
              const SizedBox(height: 16),
            ],
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              roleColor: widget.roleColor,
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: () => setState(
                    () => _passwordVisible = !_passwordVisible),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter a password';
                if (value.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Confirm Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: 'Re-enter your password',
              icon: Icons.lock_outline_rounded,
              roleColor: widget.roleColor,
              obscureText: !_confirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: () => setState(() =>
                    _confirmPasswordVisible =
                        !_confirmPasswordVisible),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please confirm your password';
                if (value != _passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildButton(
              label: 'Create Account',
              isLoading: _isLoading,
              roleColor: widget.roleColor,
              onTap: _signUp,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversityDropdown(Color roleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUniversity,
          hint: Row(
            children: [
              Icon(Icons.school_outlined,
                  color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 12),
              Text('Enter your University',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400)),
            ],
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade400),
          style: GoogleFonts.poppins(
              fontSize: 14, color: const Color(0xFF1A1A2E)),
          onChanged: (String? value) =>
              setState(() => _selectedUniversity = value),
          items: _universities.map((String university) {
            return DropdownMenuItem<String>(
              value: university,
              child: Text(university,
                  style: GoogleFonts.poppins(fontSize: 13)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED HELPER WIDGETS
// ─────────────────────────────────────────────
Widget _buildLabel(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1A1A2E),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  required Color roleColor,
  bool obscureText = false,
  Widget? suffixIcon,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    validator: validator,
    style: GoogleFonts.poppins(
        fontSize: 14, color: const Color(0xFF1A1A2E)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
          fontSize: 14, color: Colors.grey.shade400),
      prefixIcon:
          Icon(icon, color: Colors.grey.shade400, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: roleColor, width: 1.5),
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
          horizontal: 16, vertical: 16),
    ),
  );
}

Widget _buildButton({
  required String label,
  required bool isLoading,
  required Color roleColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: roleColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: roleColor.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                label,
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