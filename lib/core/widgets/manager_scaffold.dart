import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routing/app_routes.dart';
import '../transitions/transitions.dart';
import 'gradient_background.dart';

/// A standardised Scaffold for all Manager Portal secondary screens.
/// Provides the warm-cream GradientBackground, brand-consistent AppBar,
/// and proper back navigation — matching the Dashboard's visual palette.
class ManagerScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final bool showBackButton;
  final int? currentNavIndex;

  // Brand palette (mirrors dashboard)
  static const Color _dark = Color(0xFF3D2314);
  static const Color _mid = Color(0xFF5A3E2B);
  static const Color _gold = Color(0xFFFFF3AB);
  static const Color _border = Color(0xFFF0DFB2);

  const ManagerScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.titleIcon,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
    this.showBackButton = true,
    this.currentNavIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Make status bar icons dark (readable on warm cream)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar ??
          (currentNavIndex != null
              ? AnimatedBottomBar(currentIndex: currentNavIndex!)
              : null),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // ── Brand App Bar ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 6,
                  bottom: 12,
                  left: 6,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.55),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: _border.withValues(alpha: 0.7),
                      width: 1,
                    ),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Back button
                    if (showBackButton)
                      InkWell(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go('/dashboard'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: _dark,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 12),

                    // Icon badge (optional)
                    if (titleIcon != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _border.withValues(alpha: 0.8), width: 1),
                        ),
                        child: Icon(titleIcon, color: _dark, size: 18),
                      ),
                      const SizedBox(width: 10),
                    ] else
                      const SizedBox(width: 4),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.fraunces(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: _mid,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Action buttons
                    if (actions != null) ...actions!,
                  ],
                ),
              ),

              // ── Screen body ───────────────────────────────────────────
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standalone Reusable Bottom Dock Navigation Bar matching Home screen design system
class ManagerBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const ManagerBottomNavBar({super.key, required this.currentIndex});

  static const Color _darkBrown = Color(0xFF3D2314);
  static const Color _mediumBrown = Color(0xFF5A3E2B);

  void _onNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    HapticFeedback.selectionClick();

    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.delivery);
        break;
      case 2:
        context.go(AppRoutes.customers);
        break;
      case 3:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3AB).withValues(alpha: 0.60),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
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
          _buildNavTab(
            context,
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          _buildNavTab(
            context,
            index: 1,
            icon: Icons.local_shipping_rounded,
            label: 'Route',
          ),
          _buildNavTab(
            context,
            index: 2,
            icon: Icons.people_alt_rounded,
            label: 'CRM',
          ),
          _buildNavTab(
            context,
            index: 3,
            icon: Icons.tune_rounded,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onNavTap(context, index),
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
}
