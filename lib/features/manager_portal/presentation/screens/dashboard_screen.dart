import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../providers/dashboard_provider.dart';
import '../providers/operating_mode_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedNavIndex = 0;

  // Custom Deep Brown & Cream Translucent Palette matching design
  static const Color _darkBrown = Color(0xFF3D2314);
  static const Color _mediumBrown = Color(0xFF5A3E2B);
  static const Color _lightBeige = Color(0xFFFAF6EE);
  static const Color _goldHalo = Color.fromARGB(255, 255, 224, 110);
  static const Color _cardBgTranslucent = Color(
    0xEAFFFBEA,
  ); // ~92% Opacity Frosted Warm Cream for clean readability and UI match

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedNavIndex = index);

    // Smooth micro-delay so the user sees the pop-up spring animation play
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      switch (index) {
        case 0:
          break; // Dashboard (Home)
        case 1:
          final isSolo = ref.read(businessProfileProvider).isSolo;
          context.push(isSolo ? AppRoutes.delivery : AppRoutes.staff);
          break;
        case 2:
          context.push(AppRoutes.customers); // Customers CRM
          break;
        case 3:
          context.push(AppRoutes.settings); // Settings / Operations
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // ── 1. Top App Bar (Flushed from the very top with NO border) ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 12,
                  left: 18,
                  right: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3AB).withValues(alpha: 0.55),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(26),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: _darkBrown,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: _lightBeige,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Vanthenda Palkaran',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.fraunces(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: _darkBrown,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: () => context.push(AppRoutes.emergency),
                          icon: const Icon(
                            Icons.notifications,
                            color: _darkBrown,
                            size: 24,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: () => _openSideMenu(context),
                          icon: const Icon(
                            Icons.more_vert,
                            color: _darkBrown,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── 2. Scrollable Body Content ──────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: _darkBrown,
                  onRefresh: () async {
                    ref.invalidate(dashboardStatsProvider);
                    ref.invalidate(activeCustomerCountProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        // ── Card A: Today's Dispatch Target ───────────────
                        _buildDispatchTargetCard(),
                        const SizedBox(height: 16),

                        // ── Card B & C: 2-Column Metrics ─────────────────
                        statsAsync.when(
                          loading: () => _buildTwoColumnMetrics(
                            revenue: '₹38,400',
                            pendingRoutes: '12',
                          ),
                          error: (_, __) => _buildTwoColumnMetrics(
                            revenue: '₹38,400',
                            pendingRoutes: '12',
                          ),
                          data: (stats) {
                            final rev =
                                stats['revenueToday'] ??
                                stats['pending_amount'] ??
                                38400;
                            final routes =
                                stats['pendingDeliveries'] ??
                                stats['today_count'] ??
                                12;
                            return _buildTwoColumnMetrics(
                              revenue: '₹${rev.toString()}',
                              pendingRoutes: '$routes',
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // ── Card D: Recent Deliveries List ────────────────
                        _buildRecentDeliveriesCard(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 3. Bottom Dock Navigation Bar ───────────────────────────
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dispatch Target Card Widget ─────────────────────────────────────────
  Widget _buildDispatchTargetCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBgTranslucent,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color.fromARGB(
            255,
            133,
            133,
            133,
          ).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(11, 94, 93, 93),
            blurRadius: 16,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    234,
                    255,
                    244,
                    201,
                  ).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_drink_rounded,
                  size: 18,
                  color: _darkBrown,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Today's Dispatch Target",
                style: GoogleFonts.fraunces(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Custom Progress Slider Bar with LayoutBuilder (Zero Overflow)
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  // Background track
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        223,
                        220,
                        197,
                      ).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Filled progress
                  FractionallySizedBox(
                    widthFactor: 0.375,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: _darkBrown,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Circular Thumb Indicator
                  Positioned(
                    left: (trackWidth * 0.375) - 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _lightBeige,
                        shape: BoxShape.circle,
                        border: Border.all(color: _darkBrown, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Sub-Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Morning: 45L / 120L Deliverd',
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _darkBrown,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '37.5%',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _darkBrown,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Completed',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _mediumBrown,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Two Column Metric Cards ─────────────────────────────────────────────
  Widget _buildTwoColumnMetrics({
    required String revenue,
    required String pendingRoutes,
  }) {
    return Row(
      children: [
        // Left: Today Revenue
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _cardBgTranslucent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(11, 94, 93, 93),
                  blurRadius: 16,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.payments_outlined,
                    size: 22,
                    color: _darkBrown.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  revenue,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _darkBrown,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today Revenue',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _mediumBrown,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Right: Pending Routes
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _cardBgTranslucent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color.fromARGB(
                  255,
                  133,
                  133,
                  133,
                ).withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(11, 94, 93, 93),
                  blurRadius: 16,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.map_outlined,
                    size: 22,
                    color: _darkBrown.withValues(alpha: 0.85),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      pendingRoutes,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _darkBrown,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.alt_route_rounded,
                      size: 20,
                      color: _darkBrown,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pending Routes',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _mediumBrown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Recent Deliveries Section Card ──────────────────────────────────────
  Widget _buildRecentDeliveriesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(234, 255, 244, 201).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color.fromARGB(
            255,
            114,
            114,
            114,
          ).withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(11, 94, 93, 93),
            blurRadius: 16,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Deliveries',
                style: GoogleFonts.fraunces(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _darkBrown,
                ),
              ),
              InkWell(
                onTap: () => context.push(AppRoutes.customers),
                child: Text(
                  'View all',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B6B50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Recent Delivery Items
          _buildDeliveryItem(
            name: 'Karthik R.',
            product: 'Milk',
            time: '06:15 AM',
            qty: '1.5L Cow',
          ),
          const SizedBox(height: 10),
          _buildDeliveryItem(
            name: 'Priya S.',
            product: 'Milk',
            time: '06:22 AM',
            qty: '1.5L Cow',
          ),
          const SizedBox(height: 10),
          _buildDeliveryItem(
            name: 'Ramesh K.',
            product: 'Milk',
            time: '06:30 AM',
            qty: '1.5L Cow',
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryItem({
    required String name,
    required String product,
    required String time,
    required String qty,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5DDD0)),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: _darkBrown,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Name, Product, and Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _darkBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _darkBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Delivered $time',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _darkBrown,
                  ),
                ),
              ],
            ),
          ),

          // Quantity & Gold Halo Check Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                qty,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _darkBrown,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: const BoxDecoration(
                  color: _goldHalo,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 11, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom Dock Navigation Bar (Matching exact step mockup) ───────────
  Widget _buildBottomNavigationBar() {
    return Container(
      clipBehavior: Clip.none,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5BA).withValues(alpha: 0.88),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavTab(index: 0, icon: Icons.home_rounded, label: 'Home'),
          _buildNavTab(
            index: 1,
            icon: Icons.local_shipping_rounded,
            label: 'Route',
          ),
          _buildNavTab(index: 2, icon: Icons.people_alt_rounded, label: 'CRM'),
          _buildNavTab(index: 3, icon: Icons.tune_rounded, label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isSelected ? -8 : 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill / Squircle Button Container
            AnimatedScale(
              scale: isSelected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 56,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3D2314)
                      : const Color(0xFFFFF9E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3D2314)
                        : const Color(0xFFF0DFB2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0x443D2314)
                          : const Color(0x14000000),
                      blurRadius: isSelected ? 10 : 4,
                      offset: Offset(0, isSelected ? 5 : 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? Colors.white : _darkBrown,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Always-visible label
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _darkBrown : _mediumBrown,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Slide-in Side Menu (from Left to Right) ───────────────────────────
  void _openSideMenu(BuildContext context) {
    HapticFeedback.selectionClick();
    final businessProfile = ref.read(businessProfileProvider);
    final isSolo = businessProfile.isSolo;
    final dairyName = businessProfile.dairyName.trim().isNotEmpty
        ? businessProfile.dairyName
        : 'Sri Krishna Dairy';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(32),
                ),
                border: Border.all(color: const Color(0xFFEAE2C5), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x284A2E18),
                    blurRadius: 28,
                    offset: Offset(8, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Top Header: Dairy Profile & Close Button ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFEAE2C5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _darkBrown.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dairyName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: _darkBrown,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isSolo
                                        ? 'Solo Vendor & Manager'
                                        : 'Vendor & Manager',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 24,
                              color: _darkBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEAE2C5)),

                    // ── 2. Scrollable Menu Body (Manage Operations) ──
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Section 1: Manage Operations ──
                            _buildSectionHeader('MANAGE OPERATIONS'),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: Icons.groups_rounded,
                              title: 'Customers',
                              subtitle: 'Add, view & edit customers',
                              route: AppRoutes.customers,
                            ),
                            const SizedBox(height: 4),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: Icons.local_shipping_rounded,
                              title: 'Daily Deliveries',
                              subtitle: "Today's deliveries & route map",
                              route: AppRoutes.delivery,
                            ),
                            const SizedBox(height: 4),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: Icons.calendar_month_rounded,
                              title: 'Milk Card',
                              subtitle: 'Daily delivery records & cards',
                              route: AppRoutes.milkCard,
                            ),
                            const SizedBox(height: 16),

                            // ── Section 2: Billing & Payments ──
                            _buildSectionHeader('BILLING & PAYMENTS'),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: Icons.receipt_long_rounded,
                              title: 'Billing',
                              subtitle: 'Generate & publish monthly bills',
                              route: AppRoutes.billing,
                            ),
                            const SizedBox(height: 4),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: Icons.payments_rounded,
                              title: 'Payments',
                              subtitle: 'View collection & payment history',
                              route: AppRoutes.payments,
                            ),
                            const SizedBox(height: 16),

                            // ── Section 3: Requests ──
                            _buildSectionHeader('REQUESTS'),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: Icons.beach_access_rounded,
                              title: 'Vacation Requests',
                              subtitle: 'Pause dates & scheduled leaves',
                              route: AppRoutes.vacation,
                            ),
                            const SizedBox(height: 4),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: Icons.bolt_rounded,
                              title: 'Extra Milk Requests',
                              subtitle: 'Urgent extra milk requests',
                              route: AppRoutes.emergency,
                            ),
                            const SizedBox(height: 16),

                            // ── Section 4: Analytics & Staff/Solo ──
                            _buildSectionHeader('REPORTS & STAFF'),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: Icons.analytics_rounded,
                              title: 'Reports & Analytics',
                              subtitle: 'Volume trends, revenue & growth',
                              route: AppRoutes.analytics,
                            ),
                            const SizedBox(height: 4),
                            _buildSideMenuItem(
                              context: dialogContext,
                              icon: isSolo
                                  ? Icons.delivery_dining_rounded
                                  : Icons.badge_rounded,
                              title: isSolo
                                  ? 'Solo Delivery Mode'
                                  : 'Staff Management',
                              subtitle: isSolo
                                  ? 'Single Vendor • Direct route run'
                                  : 'Delivery boys & route assignments',
                              badgeText: isSolo ? 'Solo Run' : null,
                              route: isSolo
                                  ? AppRoutes.delivery
                                  : AppRoutes.staff,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // ── 3. Bottom Footer (Settings & Sign Out) ──
                    const Divider(height: 1, color: Color(0xFFEAE2C5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          _buildSideMenuItem(
                            context: dialogContext,
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            subtitle: 'Shop profile, milk types & rates',
                            route: AppRoutes.settings,
                          ),
                          const SizedBox(height: 4),
                          _SideMenuItemTile(
                            icon: Icons.logout_rounded,
                            title: 'Sign Out',
                            subtitle: 'Switch or exit account',
                            darkBrown: const Color(0xFFDC2626),
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              _confirmSignOut(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 6, top: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: _darkBrown.withValues(alpha: 0.55),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSideMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    String? badgeText,
    required String route,
  }) {
    return _SideMenuItemTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      badgeText: badgeText,
      darkBrown: _darkBrown,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 140), () {
          if (mounted) this.context.push(route);
        });
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFDF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: _darkBrown,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out from Manager Portal?',
          style: GoogleFonts.outfit(color: _darkBrown.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: _darkBrown.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign Out',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.go(AppRoutes.login);
    }
  }
}

// ── Interactive Side Menu Item Tile with Touch Feedback ──────────────────────
class _SideMenuItemTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Color darkBrown;
  final VoidCallback onTap;

  const _SideMenuItemTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badgeText,
    required this.darkBrown,
    required this.onTap,
  });

  @override
  State<_SideMenuItemTile> createState() => _SideMenuItemTileState();
}

class _SideMenuItemTileState extends State<_SideMenuItemTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.darkBrown.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.darkBrown.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 20, color: widget.darkBrown),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.title,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: widget.darkBrown,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.badgeText!,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: widget.darkBrown.withValues(alpha: 0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: widget.darkBrown.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}
