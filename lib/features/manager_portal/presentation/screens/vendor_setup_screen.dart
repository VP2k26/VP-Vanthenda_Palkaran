import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/manager_scaffold.dart';
import '../providers/operating_mode_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VendorSetupScreen — 3-Step Onboarding Wizard for New Managers
// ─────────────────────────────────────────────────────────────────────────────

class VendorSetupScreen extends ConsumerStatefulWidget {
  const VendorSetupScreen({super.key});

  @override
  ConsumerState<VendorSetupScreen> createState() => _VendorSetupScreenState();
}

class _VendorSetupScreenState extends ConsumerState<VendorSetupScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // ── Form Keys per step ──────────────────────────────────────────────────
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // ── Section 1: Personal Profile ─────────────────────────────────────────
  final _ownerNameCtrl = TextEditingController(text: 'Sundar Rajan');
  final _emailCtrl = TextEditingController(text: 'sundar@gmail.com');
  final _phoneCtrl = TextEditingController(text: '9876543210');
  final _ageCtrl = TextEditingController(text: '35');
  Gender _gender = Gender.male;
  String _language = 'Tamil';

  // ── Section 2: Business Details ─────────────────────────────────────────
  final _dairyNameCtrl = TextEditingController(
    text: 'Sri Krishna Dairy & Milk Supply',
  );
  BusinessType _businessType = BusinessType.soleProprietor;
  final _addressCtrl = TextEditingController(
    text: '14, North Car Street, Triplicane, Chennai',
  );
  final _routeAreaCtrl = TextEditingController(
    text: 'Triplicane West & Royapettah',
  );
  TimeOfDay _workFrom = const TimeOfDay(hour: 5, minute: 0);
  TimeOfDay _workTo = const TimeOfDay(hour: 9, minute: 0);
  final List<bool> _deliveryDays = List.filled(7, true);
  BusinessOperatingMode _operatingMode = BusinessOperatingMode.solo;
  final _fssaiCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  // ── Section 3: Products, Rates & Payments ───────────────────────────────
  double _cowRate = 54.0;
  double _buffaloRate = 64.0;
  final List<Map<String, dynamic>> _extraMilks = [];
  final List<String> _allPackSizes = ['250ml', '500ml', '1L', '2L'];
  final List<bool> _packSelected = [false, true, true, false];
  double _minOrder = 0.5;
  final _upiCtrl = TextEditingController(text: 'srikrishna.dairy@okaxis');
  PaymentCycle _paymentCycle = PaymentCycle.monthly;
  bool _lateReminder = true;

  // ── Theme ────────────────────────────────────────────────────────────────
  static const Color _dark = Color(0xFF4A2E18);
  static const Color _mid = Color(0xFF7C5329);
  static const Color _cardBg = Color(0xFFFFFDF7);
  static const Color _gold = Color(0xFFF0DFB2);

  final List<String> _stepTitles = [
    'Personal Profile',
    'Business Details',
    'Products & Payments',
  ];
  final List<IconData> _stepIcons = [
    Icons.person_rounded,
    Icons.storefront_rounded,
    Icons.water_drop_rounded,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _dairyNameCtrl.dispose();
    _addressCtrl.dispose();
    _routeAreaCtrl.dispose();
    _fssaiCtrl.dispose();
    _gstCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  // ── Navigation helpers ───────────────────────────────────────────────────

  void _nextStep() {
    final keys = [_step1Key, _step2Key, _step3Key];
    if (!keys[_currentStep].currentState!.validate()) return;
    HapticFeedback.lightImpact();
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onFinish();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _onFinish() async {
    setState(() => _isLoading = true);
    final selectedPacks = [
      for (int i = 0; i < _allPackSizes.length; i++)
        if (_packSelected[i]) _allPackSizes[i],
    ];
    ref
        .read(businessProfileProvider.notifier)
        .updateProfile(
          BusinessProfileState(
            ownerName: _ownerNameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            age: int.tryParse(_ageCtrl.text.trim()),
            gender: _gender,
            preferredLanguage: _language,
            dairyName: _dairyNameCtrl.text.trim(),
            businessType: _businessType,
            address: _addressCtrl.text.trim(),
            routeArea: _routeAreaCtrl.text.trim(),
            workingHoursFrom: _workFrom.format(context),
            workingHoursTo: _workTo.format(context),
            deliveryDays: [
              for (int i = 0; i < 7; i++)
                if (_deliveryDays[i]) i,
            ],
            operatingMode: _operatingMode,
            fssaiLicense: _fssaiCtrl.text.trim(),
            gstNumber: _gstCtrl.text.trim(),
            cowMilkRate: _cowRate,
            buffaloMilkRate: _buffaloRate,
            extraMilkTypes: _extraMilks,
            packSizes: selectedPacks,
            minOrderLiters: _minOrder,
            upiId: _upiCtrl.text.trim(),
            paymentCycle: _paymentCycle,
            latePaymentReminder: _lateReminder,
          ),
        );
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Profile created! Configured as ${_operatingMode == BusinessOperatingMode.solo ? "Solo Milkman" : "Multi-Staff Team"}.',
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.go(AppRoutes.dashboard);
    }
  }

  void _onSkip() {
    HapticFeedback.lightImpact();
    ref
        .read(businessProfileProvider.notifier)
        .updateProfile(const BusinessProfileState());
    context.go(AppRoutes.dashboard);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const ManagerBottomNavBar(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildStep1(), _buildStep2(), _buildStep3()],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3AB).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gold, width: 1),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: _dark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Milk Booth Setup',
                        style: GoogleFonts.fraunces(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      Text(
                        'Step ${_currentStep + 1} of 3 — ${_stepTitles[_currentStep]}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: _mid,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _onSkip,
                style: TextButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFAF6EE).withValues(alpha: 0.85),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side:
                        const BorderSide(color: Color(0x444A2E18), width: 0.8),
                  ),
                ),
                icon: const Icon(
                  Icons.fast_forward_rounded,
                  size: 15,
                  color: _dark,
                ),
                label: Text(
                  'Skip',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step Indicator ───────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: List.generate(3, (i) {
          final done = i < _currentStep;
          final active = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                // Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: active ? 40 : 32,
                  height: active ? 40 : 32,
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFF2E7D32)
                        : active
                        ? _dark
                        : const Color(0xFFECE4D6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: _dark.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Icon(
                            _stepIcons[i],
                            color: active
                                ? Colors.white
                                : _mid.withValues(alpha: 0.7),
                            size: active ? 20 : 16,
                          ),
                  ),
                ),
                // Connector line
                if (i < 2)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: done
                              ? [
                                  const Color(0xFF2E7D32),
                                  const Color(0xFF2E7D32),
                                ]
                              : [
                                  const Color(0xFFECE4D6),
                                  const Color(0xFFECE4D6),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
          ),
        ),
      ),
    );
  }

  // ── Bottom Navigation Bar ────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: _cardBg.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(color: _gold.withValues(alpha: 0.6), width: 1),
            ),
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: _prevStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _dark,
                      side: const BorderSide(
                          color: Color(0x664A2E18), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(
                      'Back',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _currentStep < 2
                                    ? 'Next: ${_stepTitles[_currentStep + 1]}'
                                    : 'Complete Setup ✓',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _currentStep < 2
                                  ? Icons.arrow_forward_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 18,
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

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 1: Personal Profile
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep1() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _step1Key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionCard(
              title: 'Who are you?',
              subtitle: 'Your personal information.',
              icon: Icons.person_rounded,
              child: Column(
                children: [
                  _field(
                    ctrl: _ownerNameCtrl,
                    label: 'Full Name',
                    hint: 'e.g. Sundar Rajan',
                    icon: Icons.badge_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _emailCtrl,
                    label: 'Email Address',
                    hint: 'e.g. sundar@gmail.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: false, // set true when prefilling from Supabase
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email required';
                      }
                      if (!v.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _phoneCtrl,
                    label: 'Mobile Number',
                    hint: 'e.g. 9876543210',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Phone required';
                      }
                      if (v.trim().length < 10) {
                        return 'Enter 10-digit number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _ageCtrl,
                    label: 'Age',
                    hint: 'e.g. 35',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gender
            _sectionCard(
              title: 'Gender',
              subtitle: null,
              icon: Icons.wc_rounded,
              child: Row(
                children: [
                  for (final g in Gender.values)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: g != Gender.values.last ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _gender == g
                                ? _dark
                                : const Color(0xFFECE4D6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              g == Gender.male
                                  ? '👨 Male'
                                  : g == Gender.female
                                  ? '👩 Female'
                                  : '🧑 Other',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _gender == g ? Colors.white : _mid,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Preferred Language
            _sectionCard(
              title: 'Preferred Language',
              subtitle: 'App will use this language for notifications',
              icon: Icons.language_rounded,
              child: Row(
                children: [
                  for (final lang in ['Tamil', 'English'])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _language = lang),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: lang == 'Tamil' ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _language == lang
                                ? _dark
                                : const Color(0xFFECE4D6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              lang == 'Tamil' ? '🇮🇳 Tamil' : '🇬🇧 English',
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _language == lang ? Colors.white : _mid,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),),),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2: Business Details
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep2() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _step2Key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Shop Info
            _sectionCard(
              title: 'Dairy / Shop Info',
              subtitle: 'Details about your milk business',
              icon: Icons.storefront_rounded,
              child: Column(
                children: [
                  _field(
                    ctrl: _dairyNameCtrl,
                    label: 'Dairy / Shop Name',
                    hint: 'e.g. Sri Krishna Dairy',
                    icon: Icons.store_rounded,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Shop name required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  // Business Type
                  _label('Business Type'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final t in BusinessType.values)
                        GestureDetector(
                          onTap: () => setState(() => _businessType = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _businessType == t
                                  ? _dark
                                  : const Color(0xFFECE4D6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              t == BusinessType.soleProprietor
                                  ? 'Sole Proprietor'
                                  : t == BusinessType.partnership
                                  ? 'Partnership'
                                  : 'Company',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _businessType == t ? Colors.white : _mid,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _addressCtrl,
                    label: 'Shop / Dairy Address',
                    hint: 'Full address with pincode',
                    icon: Icons.location_on_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _routeAreaCtrl,
                    label: 'Delivery Locality / Route Area',
                    hint: 'e.g. Triplicane West & Royapettah',
                    icon: Icons.map_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Working Hours
            _sectionCard(
              title: 'Working Hours',
              subtitle: 'Your typical delivery timing',
              icon: Icons.schedule_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: _timePicker(
                      label: 'Opens At',
                      time: _workFrom,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _workFrom,
                        );
                        if (t != null) setState(() => _workFrom = t);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '→',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: _timePicker(
                      label: 'Closes At',
                      time: _workTo,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _workTo,
                        );
                        if (t != null) setState(() => _workTo = t);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Days
            _sectionCard(
              title: 'Delivery Days',
              subtitle: 'Which days do you deliver milk?',
              icon: Icons.calendar_month_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (i) {
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _deliveryDays[i] = !_deliveryDays[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _deliveryDays[i]
                            ? _dark
                            : const Color(0xFFECE4D6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          days[i],
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _deliveryDays[i] ? Colors.white : _mid,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Operating Model
            _sectionCard(
              title: 'Operating Model',
              subtitle: 'How do you run your deliveries?',
              icon: Icons.hub_outlined,
              child: Column(
                children: [
                  _operatingCard(
                    mode: BusinessOperatingMode.solo,
                    emoji: '🚴',
                    title: 'Solo Milkman',
                    subtitle:
                        'I deliver milk myself — single person operation.',
                    badgeLabel: 'Single Person',
                    badgeColor: const Color(0xFF2E7D32),
                    badgeBg: const Color(0xFFE8F5E9),
                  ),
                  const SizedBox(height: 10),
                  _operatingCard(
                    mode: BusinessOperatingMode.team,
                    emoji: '👥',
                    title: 'Multi-Staff Team',
                    subtitle:
                        'I have delivery boys — assign routes & track them from dashboard.',
                    badgeLabel: 'Team Mode',
                    badgeColor: const Color(0xFF1976D2),
                    badgeBg: const Color(0xFFE3F2FD),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Optional registrations
            _sectionCard(
              title: 'Registrations (Optional)',
              subtitle: 'FSSAI & GST if applicable',
              icon: Icons.verified_outlined,
              child: Column(
                children: [
                  _field(
                    ctrl: _fssaiCtrl,
                    label: 'FSSAI License Number',
                    hint: 'Optional',
                    icon: Icons.card_membership_rounded,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _gstCtrl,
                    label: 'GST Number',
                    hint: 'Optional',
                    icon: Icons.receipt_long_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),),),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 3: Products, Rates & Payments
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep3() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _step3Key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Milk Rates
            _sectionCard(
              title: 'Milk Rates (₹ per Litre)',
              subtitle: 'Set your default rates — you can change them anytime.',
              icon: Icons.water_drop_rounded,
              child: Column(
                children: [
                  _rateTile(
                    emoji: '🐄',
                    label: 'Cow Milk',
                    color: const Color(0xFF2E7D32),
                    bg: const Color(0xFFE8F5E9),
                    rate: _cowRate,
                    onChanged: (v) => setState(() => _cowRate = v),
                  ),
                  const Divider(height: 20, color: Color(0x224A2E18)),
                  _rateTile(
                    emoji: '🐃',
                    label: 'Buffalo Milk',
                    color: const Color(0xFF512DA8),
                    bg: const Color(0xFFEDE7F6),
                    rate: _buffaloRate,
                    onChanged: (v) => setState(() => _buffaloRate = v),
                  ),

                  // Extra milk types
                  if (_extraMilks.isNotEmpty)
                    const Divider(height: 20, color: Color(0x224A2E18)),
                  for (int i = 0; i < _extraMilks.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '🥛 ${_extraMilks[i]['name']} — ₹${(_extraMilks[i]['rate'] as double).toStringAsFixed(0)}/L',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: _dark,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _extraMilks.removeAt(i)),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _addExtraMilkType,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _dark,
                      side: const BorderSide(
                        color: Color(0x664A2E18),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'Add another milk type',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pack Sizes
            _sectionCard(
              title: 'Pack Sizes Available',
              subtitle: 'Which quantities do you offer?',
              icon: Icons.local_drink_rounded,
              child: Wrap(
                spacing: 10,
                children: List.generate(_allPackSizes.length, (i) {
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _packSelected[i] = !_packSelected[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _packSelected[i]
                            ? _dark
                            : const Color(0xFFECE4D6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _allPackSizes[i],
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _packSelected[i] ? Colors.white : _mid,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Min Order
            _sectionCard(
              title: 'Minimum Daily Order',
              subtitle: 'Smallest quantity a customer can order per day',
              icon: Icons.minimize_rounded,
              child: Row(
                children: [
                  _stepperBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (_minOrder > 0.25) {
                        setState(
                          () => _minOrder = double.parse(
                            (_minOrder - 0.25).toStringAsFixed(2),
                          ),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_minOrder.toStringAsFixed(2)} L',
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                    ),
                  ),
                  _stepperBtn(
                    icon: Icons.add,
                    onTap: () {
                      if (_minOrder < 5.0) {
                        setState(
                          () => _minOrder = double.parse(
                            (_minOrder + 0.25).toStringAsFixed(2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payments
            _sectionCard(
              title: 'Payments & UPI',
              subtitle: 'How customers will pay you',
              icon: Icons.payment_rounded,
              child: Column(
                children: [
                  _field(
                    ctrl: _upiCtrl,
                    label: 'UPI ID',
                    hint: 'e.g. dairyname@okaxis or 9876543210@upi',
                    icon: Icons.qr_code_2_rounded,
                  ),
                  const SizedBox(height: 16),
                  _label('Payment Collection Cycle'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final c in PaymentCycle.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _paymentCycle = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(
                                right: c != PaymentCycle.values.last ? 8 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _paymentCycle == c
                                    ? _dark
                                    : const Color(0xFFECE4D6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  c == PaymentCycle.daily
                                      ? 'Daily'
                                      : c == PaymentCycle.weekly
                                      ? 'Weekly'
                                      : 'Monthly',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _paymentCycle == c
                                        ? Colors.white
                                        : _mid,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Late Payment Reminder',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _dark,
                            ),
                          ),
                          Text(
                            'Notify customers with pending dues',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: _mid,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _lateReminder,
                        onChanged: (v) => setState(() => _lateReminder = v),
                        activeColor: _dark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        ),),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _addExtraMilkType() {
    final nameCtrl = TextEditingController();
    double rate = 50.0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Add Milk Type',
            style: GoogleFonts.fraunces(
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Milk Type Name',
                  hintText: 'e.g. Toned, Full Cream',
                  labelStyle: GoogleFonts.outfit(color: _mid),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Rate: ₹${rate.toStringAsFixed(0)}/L',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const Spacer(),
                  _stepperBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (rate > 10) setS(() => rate -= 1);
                    },
                  ),
                  const SizedBox(width: 6),
                  _stepperBtn(
                    icon: Icons.add,
                    onTap: () {
                      if (rate < 200) setS(() => rate += 1);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.outfit(color: _mid)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  setState(
                    () => _extraMilks.add({
                      'name': nameCtrl.text.trim(),
                      'rate': rate,
                    }),
                  );
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _dark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Add',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared Widgets ───────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required String? subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _dark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3AB).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _dark, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fraunces(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(fontSize: 11.5, color: _mid),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.outfit(fontSize: 14.5, color: _dark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _mid, size: 20),
        labelStyle: GoogleFonts.outfit(
          fontSize: 13,
          color: _mid,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.outfit(
          fontSize: 13,
          color: _mid.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: readOnly
            ? const Color(0xFFF5F0E8)
            : Colors.white.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _gold.withValues(alpha: 0.7), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _gold.withValues(alpha: 0.7), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _dark.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: _mid,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _timePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _gold.withValues(alpha: 0.7), width: 1),
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 11, color: _mid)),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _operatingCard({
    required BusinessOperatingMode mode,
    required String emoji,
    required String title,
    required String subtitle,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    final selected = _operatingMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _operatingMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _dark.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _dark : _gold,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 12, color: _mid),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _dark : _mid,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rateTile({
    required String emoji,
    required String label,
    required Color color,
    required Color bg,
    required double rate,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              Text(
                '₹${rate.toStringAsFixed(0)} per litre',
                style: GoogleFonts.outfit(fontSize: 12, color: _mid),
              ),
            ],
          ),
        ),
        _stepperBtn(
          icon: Icons.remove,
          onTap: () {
            if (rate > 20) {
              onChanged(rate - 1);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '₹${rate.toStringAsFixed(0)}',
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
        ),
        _stepperBtn(
          icon: Icons.add,
          onTap: () {
            if (rate < 200) {
              onChanged(rate + 1);
            }
          },
        ),
      ],
    );
  }

  Widget _stepperBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFECE4D6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: _dark),
      ),
    );
  }
}
