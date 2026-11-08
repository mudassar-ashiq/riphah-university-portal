import 'package:flutter/material.dart';

import '../models/portal_models.dart';
import '../services/auth_service.dart';
import '../services/portal_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_background.dart';
import '../widgets/section_widgets.dart';

/// Login / sign up screen. Uses real Firebase accounts:
/// sign up creates the auth user and writes the student's profile
/// document to Firestore; login signs in with FirebaseAuth. The
/// [AuthGate] in main.dart swaps to the portal when sign-in succeeds.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authService,
    required this.repository,
  });

  final AuthService authService;
  final PortalRepository repository;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _programController = TextEditingController();
  final _sectionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _busy = false;
  int _semester = 5;

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _programController.dispose();
    _sectionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _required(String? value, String message) {
    if (_isLogin) return null;
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isLogin) {
        await widget.authService.signIn(email: email, password: password);
      } else {
        final uid =
            await widget.authService.signUp(email: email, password: password);
        await widget.repository.createProfile(
          UserProfile(
            uid: uid,
            name: _nameController.text.trim(),
            roll: _rollController.text.trim(),
            program: _programController.text.trim(),
            semester: _semester,
            section: _sectionController.text.trim(),
            email: email,
            role: 'student',
          ),
        );
      }
      // AuthGate listens to the auth state and opens the portal.
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Enter your email above first, then tap Forgot password.');
      return;
    }
    try {
      await widget.authService.sendPasswordReset(email);
      if (mounted) {
        _showError('Password reset email sent to $email.');
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/riphah_building.jpg',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF001E35)
                                        .withValues(alpha: 0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 16,
                            right: 16,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Riphah University Portal',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'serif',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Riphah International University — '
                                  'Sahiwal Campus',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isLogin
                          ? 'Sahiwal Campus — log in to your student portal'
                          : 'Sahiwal Campus — create your student account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF5A6474),
                      ),
                    ),
                    const SizedBox(height: 28),
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ModeToggle(
                              isLogin: _isLogin,
                              onChanged: (login) {
                                setState(() => _isLogin = login);
                                _formKey.currentState?.reset();
                              },
                            ),
                            const SizedBox(height: 24),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeInOut,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_isLogin) ...[
                                    TextFormField(
                                      controller: _nameController,
                                      textInputAction: TextInputAction.next,
                                      decoration: glassFieldDecoration(
                                        label: 'Full name',
                                        icon: Icons.person_outline_rounded,
                                      ),
                                      validator: (v) => _required(
                                          v, 'Please enter your full name'),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _rollController,
                                      textInputAction: TextInputAction.next,
                                      decoration: glassFieldDecoration(
                                        label: 'Roll number',
                                        icon: Icons.badge_outlined,
                                        hint: 'e.g. F24-BSSE-0077',
                                      ),
                                      validator: (v) => _required(
                                          v, 'Please enter your roll number'),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _programController,
                                      textInputAction: TextInputAction.next,
                                      decoration: glassFieldDecoration(
                                        label: 'Program',
                                        icon: Icons.school_outlined,
                                        hint: 'e.g. BSSE',
                                      ),
                                      validator: (v) => _required(
                                          v, 'Please enter your program'),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child:
                                              DropdownButtonFormField<int>(
                                            initialValue: _semester,
                                            isExpanded: true,
                                            dropdownColor:
                                                Colors.white,
                                            decoration: glassFieldDecoration(
                                              label: 'Semester',
                                            ),
                                            items: [
                                              for (var i = 1; i <= 8; i++)
                                                DropdownMenuItem(
                                                  value: i,
                                                  child: Text('Semester $i'),
                                                ),
                                            ],
                                            onChanged: (v) => setState(
                                                () => _semester = v ?? 5),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: _sectionController,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: glassFieldDecoration(
                                              label: 'Section',
                                              icon: Icons.group_outlined,
                                              hint: 'e.g. A',
                                            ),
                                            validator: (v) => _required(
                                                v, 'Please enter your section'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: glassFieldDecoration(
                                      label: 'University email',
                                      icon: Icons.mail_outline_rounded,
                                    ),
                                    validator: _validateEmail,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration:
                                        glassFieldDecoration(
                                          label: 'Password',
                                          icon: Icons.lock_outline_rounded,
                                        ).copyWith(
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                          ),
                                        ),
                                    validator: _validatePassword,
                                  ),
                                ],
                              ),
                            ),
                            if (_isLogin)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _busy ? null : _forgotPassword,
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _busy ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFCC22),
                                  foregroundColor: const Color(0xFF001E35),
                                  elevation: 2,
                                  shadowColor: const Color(0xFF001E35)
                                      .withValues(alpha: 0.25),
                                  shape: const StadiumBorder(),
                                ),
                                child: _busy
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Color(0xFF001E35),
                                        ),
                                      )
                                    : Text(
                                        _isLogin ? 'Log In' : 'Sign Up',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF001E35),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Real student accounts — your profile and records '
                      'are stored privately in your own account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8F98),
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

/// Pill-shaped Login / Sign Up switch with a sliding highlight.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isLogin, required this.onChanged});

  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5EA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF003366).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          _segment('Login', isLogin, () => onChanged(true)),
          _segment('Sign Up', !isLogin, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected ? const Color(0xFFFFCC22) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFF001E35)
                  : const Color(0xFF5A6474),
            ),
          ),
        ),
      ),
    );
  }
}
