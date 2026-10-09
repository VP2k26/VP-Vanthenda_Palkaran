import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../manager_portal/presentation/providers/operating_mode_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Manager-Specific Business Details Controllers
  final _dairyNameController =
      TextEditingController(text: 'Sri Krishna Dairy & Milk Supply');
  final _addressController =
      TextEditingController(text: '14, North Car Street, Triplicane, Chennai');
  final _upiIdController =
      TextEditingController(text: 'srikrishna.dairy@okaxis');
  double _cowRate = 54.0;
  double _buffaloRate = 64.0;
  BusinessOperatingMode _operatingMode = BusinessOperatingMode.solo;

  final _formKey = GlobalKey<FormState>();

  String _selectedRole = 'customer'; // 'vendor', 'manager', 'customer'
  int _currentRoleIndex = 2; // 0: vendor, 1: manager, 2: customer
  int _previousRoleIndex = 2;

  AnimationController? _liquidAnimController;
  Animation<double>? _liquidAnimation;

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _emailSent = false;

  // Custom Warm Brown Palette linked to AppColors
  static const Color _brandBrown = AppColors.brandBrown;
  static const Color _borderBrown = AppColors.brandBrownLight;
  static const Color _textBrown = AppColors.textBrown;
  static const Color _unselectedYellow = Color(0xFFFFF2BD);

  void _ensureAnimationInitialized() {
    if (_liquidAnimController == null) {
      _liquidAnimController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      );
      _liquidAnimation = CurvedAnimation(
        parent: _liquidAnimController!,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _ensureAnimationInitialized();
  }

  @override
  void dispose() {
    _liquidAnimController?.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dairyNameController.dispose();
    _addressController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _onRoleSelected(String role, int index) {
    if (_currentRoleIndex == index) return;
    _ensureAnimationInitialized();
    HapticFeedback.lightImpact();
    setState(() {
      _previousRoleIndex = _currentRoleIndex;
      _currentRoleIndex = index;
      _selectedRole = role;
    });
    _liquidAnimController?.forward(from: 0.0);
  }

  void _onSkipForTesting() {
    HapticFeedback.lightImpact();
    if (_selectedRole == 'manager') {
      ref.read(businessProfileProvider.notifier).updateProfile(
            BusinessProfileState(
              dairyName: _dairyNameController.text.trim().isEmpty
                  ? 'Sri Krishna Dairy & Milk Supply'
                  : _dairyNameController.text.trim(),
              ownerName: _usernameController.text.trim().isEmpty
                  ? 'Sundar Rajan'
                  : _usernameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? '+91 98765 43210'
                  : _phoneController.text.trim(),
              address: _addressController.text.trim(),
              upiId: _upiIdController.text.trim(),
              cowMilkRate: _cowRate,
              buffaloMilkRate: _buffaloRate,
              operatingMode: _operatingMode,
            ),
          );
      context.go(AppRoutes.dashboard);
    } else if (_selectedRole == 'vendor') {
      context.go(AppRoutes.delivery);
    } else {
      context.go(AppRoutes.customerHome);
    }
  }

  Future<void> _onSignUp() async {
    String destinationRoute;
    switch (_selectedRole) {
      case 'manager':
        // Save manager's business profile & operating model into state
        ref.read(businessProfileProvider.notifier).updateProfile(
              BusinessProfileState(
                dairyName: _dairyNameController.text.trim().isEmpty
                    ? 'Sri Krishna Dairy & Milk Supply'
                    : _dairyNameController.text.trim(),
                ownerName: _usernameController.text.trim().isEmpty
                    ? 'Sundar Rajan'
                    : _usernameController.text.trim(),
                phone: _phoneController.text.trim().isEmpty
                    ? '+91 98765 43210'
                    : _phoneController.text.trim(),
                address: _addressController.text.trim(),
                upiId: _upiIdController.text.trim(),
                cowMilkRate: _cowRate,
                buffaloMilkRate: _buffaloRate,
                operatingMode: _operatingMode,
              ),
            );
        destinationRoute = AppRoutes.setupProfile; // → 3-step wizard first
        break;
      case 'vendor':
        destinationRoute = AppRoutes.delivery; // Vendor / Delivery Portal
        break;
      case 'customer':
      default:
        destinationRoute = AppRoutes.customerHome; // Customer Portal
        break;
    }

    // Optional background register if credentials entered
    if (_emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      ref
          .read(authNotifierProvider.notifier)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
          );
    }

    if (mounted) {
      context.go(destinationRoute);
    }

    /*
    // ── PRODUCTION SUPABASE AUTH MODE (Uncomment when ready) ──────────
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service & Privacy Policy'),
          backgroundColor: _brandBrown,
        ),
      );
      return;
    }

    final route = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
        );

    if (!mounted) return;
    if (route != null) {
      context.go(route);
    } else {
      final hasError = ref.read(authNotifierProvider).hasError;
      if (!hasError) {
        setState(() => _emailSent = true);
      }
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
              // ── Top Bar with Back arrow & Circular Brand Logo + Skip ───
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => context.go(AppRoutes.login),
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
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _onSkipForTesting,
                          style: TextButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFFF3AB).withValues(alpha: 0.65),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: _brandBrown.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.fast_forward_rounded,
                            size: 14,
                            color: _brandBrown,
                          ),
                          label: Text(
                            'Skip (Test)',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _brandBrown,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                  ],
                ),
              ),

              // ── Main Content Area (Perfect Mobile Fit) ────────────
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: _emailSent
                          ? _buildEmailSentCard()
                          : _buildDairyCard(authState, isLoading),
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
        color: Colors.white.withValues(alpha: 0.25),
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
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Dairy Brand Illustration / Logo ─────────────────────
            SizedBox(
              width: 100,
              height: 74,
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
                          width: 95,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/svg_file/cowlogo.svg',
                    width: 95,
                    height: 68,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            // ── Brand Title ─────────────────────────────────────────
            Text(
              'Dairy Daily',
              style: GoogleFonts.fraunces(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: _brandBrown,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),

            // ── Subtitle ────────────────────────────────────────────
            Text(
              'CREATE YOUR ACCOUNT',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _textBrown,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // ── 3-Role Liquid Gooey Stretchy Selector ────────────────
            _buildRoleSelector(),
            const SizedBox(height: 14),

            // ── Field: USERNAME ─────────────────────────────────────
            _buildUnderlineField(
              controller: _usernameController,
              label: 'USERNAME',
              svgAsset: 'assets/svg_file/username.svg',
              iconWidth: 18,
              iconHeight: 18,
              keyboardType: TextInputType.name,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter username';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Field: MOBILE NUMBER ────────────────────────────────
            _buildUnderlineField(
              controller: _phoneController,
              label: 'MOBILE NUMBER',
              svgAsset: 'assets/svg_file/call.svg',
              iconWidth: 16,
              iconHeight: 20,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter mobile number';
                }
                if (v.trim().length < 10) {
                  return 'Enter a valid 10-digit mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

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
            const SizedBox(height: 12),

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
            const SizedBox(height: 14),

            // ── Manager-Specific Shop & Operating Model Setup ───────
            if (_selectedRole == 'manager') ...[
              _buildManagerShopSection(),
              const SizedBox(height: 14),
            ],

            // ── Terms & Privacy Checkbox ────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (val) =>
                        setState(() => _agreeToTerms = val ?? false),
                    activeColor: _brandBrown,
                    checkColor: Colors.white,
                    side: const BorderSide(color: _borderBrown, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'I agree to the ',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: _textBrown,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: _brandBrown,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' & '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: _brandBrown,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Submit Action Button (At the very bottom) ───────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _onSignUp,
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
                        _selectedRole == 'manager'
                            ? 'REGISTER & LAUNCH DASHBOARD'
                            : 'SIGN UP',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Secondary Skip Button for Fast Testing ──────────────
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: _onSkipForTesting,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _brandBrown,
                  side: BorderSide(
                    color: _brandBrown.withValues(alpha: 0.4),
                    width: 1.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Skip Setup (Testing Mode)',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _brandBrown,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Footer: Already have account? Log In ────────────────
            RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: _textBrown,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: 'Log In',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: _brandBrown,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.go(AppRoutes.login),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Manager-Specific Shop & Operating Model Section Widget ─────────
  Widget _buildManagerShopSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _brandBrown.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 18, color: _brandBrown),
              const SizedBox(width: 7),
              Text(
                'Milk Booth & Business Details',
                style: GoogleFonts.fraunces(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _brandBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dairy / Shop Name
          _buildUnderlineField(
            controller: _dairyNameController,
            label: 'DAIRY / SHOP NAME',
            svgAsset: 'assets/svg_file/username.svg',
            iconWidth: 16,
            iconHeight: 16,
          ),
          const SizedBox(height: 10),
          // Address & Route Area
          _buildUnderlineField(
            controller: _addressController,
            label: 'DAIRY ADDRESS & LOCALITY',
            svgAsset: 'assets/svg_file/call.svg',
            iconWidth: 15,
            iconHeight: 18,
          ),
          const SizedBox(height: 12),

          // Base Milk Rates Stepper Row
          Row(
            children: [
              Expanded(
                child: _buildRateBox(
                  label: 'Cow Rate',
                  rate: _cowRate,
                  color: const Color(0xFF2E7D32),
                  onMinus: () {
                    if (_cowRate > 20) setState(() => _cowRate -= 1);
                  },
                  onPlus: () {
                    if (_cowRate < 150) setState(() => _cowRate += 1);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRateBox(
                  label: 'Buffalo Rate',
                  rate: _buffaloRate,
                  color: const Color(0xFF512DA8),
                  onMinus: () {
                    if (_buffaloRate > 20) setState(() => _buffaloRate -= 1);
                  },
                  onPlus: () {
                    if (_buffaloRate < 150) setState(() => _buffaloRate += 1);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // UPI ID
          _buildUnderlineField(
            controller: _upiIdController,
            label: 'UPI ID (FOR PAYMENTS)',
            svgAsset: 'assets/svg_file/mail.svg',
            iconWidth: 16,
            iconHeight: 14,
          ),
          const SizedBox(height: 16),

          // Distribution & Operating Model
          Text(
            'DISTRIBUTION / OPERATING MODEL',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _textBrown,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          // Solo vs Multi-user Cards
          _buildOperatingModelOption(
            mode: BusinessOperatingMode.solo,
            title: '🚴 Solo Milkman (Single Person)',
            subtitle: 'I deliver milk myself • Tab 1 opens Active Delivery Routes directly.',
          ),
          const SizedBox(height: 8),
          _buildOperatingModelOption(
            mode: BusinessOperatingMode.team,
            title: '👥 Multi-Staff (Team Mode)',
            subtitle: 'I have delivery boys • Assign routes & monitor live team completion.',
          ),
        ],
      ),
    );
  }

  Widget _buildRateBox({
    required String label,
    required double rate,
    required Color color,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _brandBrown.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onMinus,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    shape: BoxShape.circle,
                    border: Border.all(color: _brandBrown.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.remove, size: 14, color: _brandBrown),
                ),
              ),
              Text(
                '₹${rate.toStringAsFixed(0)}/L',
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: _brandBrown,
                ),
              ),
              InkWell(
                onTap: onPlus,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    shape: BoxShape.circle,
                    border: Border.all(color: _brandBrown.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.add, size: 14, color: _brandBrown),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingModelOption({
    required BusinessOperatingMode mode,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _operatingMode == mode;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _operatingMode = mode);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _brandBrown : _brandBrown.withValues(alpha: 0.15),
            width: isSelected ? 1.6 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _brandBrown : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _brandBrown : const Color(0xFF8C7355),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _brandBrown,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: _textBrown,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3-Role Segmented Selector with Gooey Liquid Stretchy Physics ──
  Widget _buildRoleSelector() {
    _ensureAnimationInitialized();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double tabWidth = totalWidth / 3;

        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: _unselectedYellow.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _brandBrown, width: 1.6),
            boxShadow: [
              BoxShadow(
                color: _brandBrown.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.4),
            child: Stack(
              children: [
                // ── The Liquid Gooey Active Indicator Background ─────
                AnimatedBuilder(
                  animation: _liquidAnimation!,
                  builder: (context, child) {
                    final progress = _liquidAnimController!.isAnimating
                        ? _liquidAnimation!.value
                        : 1.0;
                    return CustomPaint(
                      size: Size(totalWidth, 64),
                      painter: LiquidIndicatorPainter(
                        fromIndex: _previousRoleIndex,
                        toIndex: _currentRoleIndex,
                        progress: progress,
                        tabWidth: tabWidth,
                      ),
                    );
                  },
                ),

                // ── Interactive Segments Row ─────────────────────────
                Row(
                  children: [
                    _buildRoleSegment(
                      role: 'vendor',
                      index: 0,
                      label: 'Vendor',
                      selectedAsset: 'assets/svg_file/van_selected.svg',
                      unselectedAsset: 'assets/svg_file/van_unselected.svg',
                    ),
                    _buildRoleSegment(
                      role: 'manager',
                      index: 1,
                      label: 'Manager',
                      selectedAsset: 'assets/svg_file/manager_selected.svg',
                      unselectedAsset: 'assets/svg_file/manager_unselected.svg',
                    ),
                    _buildRoleSegment(
                      role: 'customer',
                      index: 2,
                      label: 'Customer',
                      selectedAsset: 'assets/svg_file/milksplash_selected.svg',
                      unselectedAsset:
                          'assets/svg_file/milksplash_unselected.svg',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Individual Role Segment with Dynamic Floating Buoy Transform ──
  Widget _buildRoleSegment({
    required String role,
    required int index,
    required String label,
    required String selectedAsset,
    required String unselectedAsset,
  }) {
    final isSelected = _selectedRole == role;
    final currentAsset = isSelected ? selectedAsset : unselectedAsset;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onRoleSelected(role, index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            alignment: Alignment.center,
            transform: Matrix4.translationValues(0, isSelected ? -2.5 : 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.08 : 0.94,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  child: SizedBox(
                    height: 28,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: SvgPicture.asset(
                        currentAsset,
                        key: ValueKey('${role}_$isSelected'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: GoogleFonts.inter(
                    fontSize: isSelected ? 12 : 11.2,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFFFFFDE0) : _brandBrown,
                    letterSpacing: isSelected ? 0.3 : 0.0,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
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

  // ── Email Verification Pending Card ───────────────────────────────
  Widget _buildEmailSentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 24,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: _brandBrown.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _brandBrown.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: _brandBrown,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Check Your Email',
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _brandBrown,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'We sent an activation link to\n${_emailController.text.trim()}\n\nClick the link to verify your account, then sign in.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _textBrown,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Go to Sign In'),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _emailSent = false),
            child: Text(
              'Use a different email',
              style: GoogleFonts.inter(
                color: _brandBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── LIQUID GOOEY STRETCH PAINTER ─────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
class LiquidIndicatorPainter extends CustomPainter {
  final int fromIndex;
  final int toIndex;
  final double progress;
  final double tabWidth;

  LiquidIndicatorPainter({
    required this.fromIndex,
    required this.toIndex,
    required this.progress,
    required this.tabWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Calculate horizontal anchors
    final double fromCenterX = (fromIndex * tabWidth) + (tabWidth / 2);
    final double toCenterX = (toIndex * tabWidth) + (tabWidth / 2);

    // Liquid velocity-based center interpolation
    final double currentCenterX = ui.lerpDouble(
      fromCenterX,
      toCenterX,
      progress,
    )!;

    final double blobWidth = tabWidth * 0.94;
    final double blobHeight = size.height * 0.90;

    // Fluid liquid stretch: snappy mid-air stretch (peak at progress = 0.5)
    final double stretchFactor = math.sin(progress * math.pi);
    final double dynamicWidth =
        blobWidth + (stretchFactor * 16 * (fromIndex - toIndex).abs());

    final Rect blobRect = Rect.fromCenter(
      center: Offset(currentCenterX, size.height / 2),
      width: dynamicWidth,
      height: blobHeight,
    );

    final RRect roundedBlob = RRect.fromRectAndRadius(
      blobRect,
      const Radius.circular(14),
    );

    // 2. Base Rich Chocolate Liquid Gradient (Direct GPU Shader)
    final Paint liquidPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(blobRect.left, blobRect.top),
        Offset(blobRect.right, blobRect.bottom),
        [
          const Color(0xFF5A3A1F), // Rich warm chocolate top
          const Color(0xFF3D2512), // Deep dark chocolate bottom
        ],
      )
      ..style = PaintingStyle.fill;

    canvas.drawRRect(roundedBlob, liquidPaint);

    // 3. Crisp Liquid Top Border Highlight (Zero-cost hardware line)
    final Paint borderPaint = Paint()
      ..color = const Color(0xFFFFF2BD).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(roundedBlob, borderPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fromIndex != fromIndex ||
        oldDelegate.toIndex != toIndex;
  }
}
