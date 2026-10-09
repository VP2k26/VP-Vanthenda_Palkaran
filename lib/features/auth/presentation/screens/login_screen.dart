import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/routing/app_routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Custom Warm Brown Palette linked to AppColors
  static const Color _brandBrown = AppColors.brandBrown;
  static const Color _borderBrown = AppColors.brandBrownLight;
  static const Color _textBrown = AppColors.textBrown;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    // ── DEV / SETUP MODE: Direct Entry to Admin Dashboard ────────────
    if (_emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      ref.read(authNotifierProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }

    if (mounted) {
      context.go(AppRoutes.dashboard);
    }

    /*
    // ── PRODUCTION SUPABASE AUTH MODE (Uncomment when ready) ──────────
    if (!_formKey.currentState!.validate()) return;

    final route = await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (route != null && mounted) {
      context.go(route);
    }
    // ─────────────────────────────────────────────────────────────────
    */
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar with Back arrow & Circular Brand Logo ────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => context.go(AppRoutes.language),
                      borderRadius: BorderRadius.circular(20),
                      splashColor: _brandBrown.withValues(alpha: 0.15),
                      highlightColor: _brandBrown.withValues(alpha: 0.08),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: _brandBrown,
                        ),
                      ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _brandBrown.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _brandBrown.withValues(alpha: 0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(2.5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Main Content Area ────────────────────────────────
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: _buildDairyCard(authState, isLoading),
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

  // ── Main Frosted Translucent Dairy Card ───────────────────────────
  Widget _buildDairyCard(AsyncValue<void> authState, bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.25,
        ), // Translucent frosted glass
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _brandBrown.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Dairy Brand Illustration / Logo ─────────────────────
            SizedBox(
              width: 104,
              height: 78,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 0,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: 3.5,
                        sigmaY: 2.0,
                      ),
                      child: Opacity(
                        opacity: 0.65,
                        child: SvgPicture.asset(
                          'assets/svg_file/cowshadow.svg',
                          width: 96,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/svg_file/cowlogo.svg',
                    width: 98,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ── Brand Title ─────────────────────────────────────────
            Text(
              'Dairy Daily',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _brandBrown,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),

            // ── Subtitle ────────────────────────────────────────────
            Text(
              'WELCOME BACK',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _textBrown,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // ── Field: EMAIL ────────────────────────────────────────
            _buildUnderlineField(
              controller: _emailController,
              label: 'EMAIL',
              svgAsset: 'assets/svg_file/mail.svg',
              iconWidth: 20,
              iconHeight: 14,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Field: PASSWORD ─────────────────────────────────────
            _buildUnderlineField(
              controller: _passwordController,
              label: 'PASSWORD',
              svgAsset: 'assets/svg_file/password.svg',
              iconWidth: 18,
              iconHeight: 18,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textBrown,
                  size: 19,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter password';
                }
                if (v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // ── Forgot Password Link ────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email.'),
                      backgroundColor: _brandBrown,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: _brandBrown,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

            // ── Error Message Banner if any ─────────────────────────
            if (authState.hasError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authState.error.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),

            // ── Submit Action Button (SIGN IN) ──────────────────────
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isLoading ? null : _onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandBrown,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: _brandBrown.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'SIGN IN',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Footer: Don't have an account? Sign Up ──────────────
            RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: _textBrown,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: 'Sign Up',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: _brandBrown,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.go(AppRoutes.signup),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Custom Underline Input Field with Perfect Icon Alignment ─────
  Widget _buildUnderlineField({
    required TextEditingController controller,
    required String label,
    required String svgAsset,
    required double iconWidth,
    required double iconHeight,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: _brandBrown,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _textBrown,
          letterSpacing: 1.0,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: Container(
          width: 30,
          height: 24,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(right: 8, bottom: 2),
          child: SvgPicture.asset(
            svgAsset,
            width: iconWidth,
            height: iconHeight,
            fit: BoxFit.contain,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 24,
        ),
        suffixIcon: suffixIcon,
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _borderBrown, width: 1.6),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _brandBrown, width: 2.2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.6),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2.0),
        ),
      ),
      validator: validator,
    );
  }
}
