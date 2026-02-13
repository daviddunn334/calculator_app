import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _termsHovered = false;
  bool _privacyHovered = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_agreedToTerms || !_agreedToPrivacy) {
      setState(() {
        _errorMessage = 'You must agree to both the Terms of Service and Privacy Policy';
      });
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Create user profile in Firestore
      if (userCredential.user != null) {
        await _userService.createUserProfile(
          userId: userCredential.user!.uid,
          email: _emailController.text.trim(),
          displayName: _nameController.text.trim().isNotEmpty 
              ? _nameController.text.trim() 
              : null,
          acceptedTerms: _agreedToTerms,
          acceptedPrivacy: _agreedToPrivacy,
        );
        
        // Send email verification automatically
        try {
          await _authService.sendEmailVerification();
          print('Email verification sent to new user');
        } catch (e) {
          print('Error sending verification email: $e');
        }
      }
      
      // Navigate to email verification screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/email_verification');
      }
    } catch (e) {
      print('Signup error: $e');
      String errorMessage = 'An error occurred during signup';
      
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'This email is already registered';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Please enter a valid email address';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak. Please use a stronger password';
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 5,
          child: _buildBrandingSection(),
        ),
        // Right side - Signup panel
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: _buildSignupPanel(maxWidth: 500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: _buildSignupPanel(maxWidth: 440),
        ),
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Container(
      padding: const EdgeInsets.all(80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Image.asset(
            'assets/logos/logo_main.png',
            width: 300,
            height: 300,
          ),
          const SizedBox(height: 40),
          
          // App name
          const Text(
            'Integrity Specialists',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEDF9FF),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tagline
          const Text(
            'Join our professional community of NDT experts.',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFFAEBBC8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          
          // Feature highlights
          _buildFeatureItem(Icons.analytics_outlined, 'AI-Powered Analysis'),
          const SizedBox(height: 24),
          _buildFeatureItem(Icons.calculate_outlined, 'Professional NDT Tools'),
          const SizedBox(height: 24),
          _buildFeatureItem(Icons.insights_outlined, 'Real-time Insights'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5BFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupPanel({required double maxWidth}) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF2A313B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo (mobile only)
                  if (MediaQuery.of(context).size.width < 1200) ...[
                    Center(
                      child: Image.asset(
                        'assets/logos/logo_main_white.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Welcome text
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEDF9FF),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Join the professional NDT community',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFAEBBC8),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Full Name field
                  _buildCustomTextField(
                    controller: _nameController,
                    label: 'Full name',
                    hint: 'John Smith',
                    icon: Icons.person_outline,
                    validator: (value) => value == null || value.isEmpty 
                        ? 'Please enter your name' 
                        : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Email field
                  _buildCustomTextField(
                    controller: _emailController,
                    label: 'Email address',
                    hint: 'your.email@company.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty 
                        ? 'Please enter your email' 
                        : (!value.contains('@') ? 'Please enter a valid email' : null),
                  ),
                  const SizedBox(height: 20),
                  
                  // Password field
                  _buildCustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFFAEBBC8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) => value == null || value.length < 6 
                        ? 'Password must be at least 6 characters' 
                        : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Confirm Password field
                  _buildCustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm password',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFFAEBBC8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) => value == null || value.isEmpty 
                        ? 'Please confirm your password' 
                        : (value != _passwordController.text ? 'Passwords do not match' : null),
                  ),
                  const SizedBox(height: 24),
                  
                  // Terms checkbox
                  _buildCustomCheckbox(
                    value: _agreedToTerms,
                    isHovered: _termsHovered,
                    onChanged: (val) {
                      setState(() {
                        _agreedToTerms = val ?? false;
                      });
                    },
                    onHoverChanged: (isHovered) {
                      setState(() {
                        _termsHovered = isHovered;
                      });
                    },
                    text: 'I agree to the ',
                    linkText: 'Terms of Service',
                    onTap: () {
                      Navigator.of(context).pushNamed('/terms_of_service');
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Privacy checkbox
                  _buildCustomCheckbox(
                    value: _agreedToPrivacy,
                    isHovered: _privacyHovered,
                    onChanged: (val) {
                      setState(() {
                        _agreedToPrivacy = val ?? false;
                      });
                    },
                    onHoverChanged: (isHovered) {
                      setState(() {
                        _privacyHovered = isHovered;
                      });
                    },
                    text: 'I agree to the ',
                    linkText: 'Privacy Policy',
                    onTap: () {
                      Navigator.of(context).pushNamed('/privacy_policy');
                    },
                  ),
                  
                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE637E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFE637E).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFFE637E), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFFE637E),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Create Account button
                  _buildPrimaryButton(
                    onPressed: (_isLoading || !_agreedToTerms || !_agreedToPrivacy)
                        ? null
                        : _signup,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Color(0xFF7F8A96),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign in link
                  _buildSecondaryButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text(
                      'Sign in instead',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEDF9FF),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            color: Color(0xFFEDF9FF),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF7F8A96),
              fontSize: 15,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFFAEBBC8), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF242A33),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6C5BFF),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFE637E),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFE637E),
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFFE637E),
              fontSize: 12,
            ),
          ),
          cursorColor: const Color(0xFF6C5BFF),
        ),
      ],
    );
  }

  Widget _buildCustomCheckbox({
    required bool value,
    required bool isHovered,
    required Function(bool?) onChanged,
    required Function(bool) onHoverChanged,
    required String text,
    required String linkText,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF6C5BFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? const Color(0xFF6C5BFF)
                      : (isHovered
                          ? const Color(0xFF6C5BFF)
                          : Colors.white.withOpacity(0.2)),
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Label with link
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAEBBC8),
                  ),
                  children: [
                    TextSpan(text: text),
                    WidgetSpan(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: onTap,
                          child: Text(
                            linkText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6C5BFF),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        color: onPressed != null
            ? const Color(0xFF6C5BFF)
            : const Color(0xFF6C5BFF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: const Color(0xFF6C5BFF).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF6C5BFF),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Color(0xFF6C5BFF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
