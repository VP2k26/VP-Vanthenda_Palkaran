import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routing/app_routes.dart';
import 'transition_utils.dart';

/// Reusable Animated Drawer with frosted glass scrim & spring-slide entry
class AnimatedSidebarDrawer extends StatefulWidget {
  final String currentRoute;

  const AnimatedSidebarDrawer({super.key, this.currentRoute = ''});

  static Future<void> show(BuildContext context, {String currentRoute = ''}) {
    HapticFeedback.lightImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Drawer',
      barrierColor: Colors.transparent,
      transitionDuration: AppTransitions.medium,
      pageBuilder: (_, __, ___) =>
          AnimatedSidebarDrawer(currentRoute: currentRoute),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: AppTransitions.defaultCurve,
        );

        return Stack(
          children: [
            // Frosted Backdrop Scrim Fade
            FadeTransition(
              opacity: curve,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: AppTransitions.darkBrown.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
            // Slide in Drawer from Left
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          ],
        );
      },
    );
  }

  @override
  State<AnimatedSidebarDrawer> createState() => _AnimatedSidebarDrawerState();
}

class _AnimatedSidebarDrawerState extends State<AnimatedSidebarDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<_DrawerMenuItem> _menuItems = [
    _DrawerMenuItem(
      title: 'Customers',
      subtitle: 'Add, view & edit customers',
      icon: Icons.people_alt_rounded,
      route: AppRoutes.customers,
    ),
    _DrawerMenuItem(
      title: 'Daily Deliveries',
      subtitle: "Today's deliveries & route map",
      icon: Icons.local_shipping_rounded,
      route: AppRoutes.delivery,
    ),
    _DrawerMenuItem(
      title: 'Milk Card',
      subtitle: 'Daily delivery records & cards',
      icon: Icons.calendar_month_rounded,
      route: AppRoutes.milkCard,
    ),
    _DrawerMenuItem(
      title: 'Billing',
      subtitle: 'Generate & publish monthly bills',
      icon: Icons.receipt_long_rounded,
      route: AppRoutes.billing,
    ),
    _DrawerMenuItem(
      title: 'Payments',
      subtitle: 'View collection & payment history',
      icon: Icons.payments_rounded,
      route: AppRoutes.payments,
    ),
    _DrawerMenuItem(
      title: 'Vacation Requests',
      subtitle: 'Pause dates & scheduled leaves',
      icon: Icons.beach_access_rounded,
      route: AppRoutes.vacation,
    ),
    _DrawerMenuItem(
      title: 'Extra Milk Requests',
      subtitle: 'Urgent extra milk requests',
      icon: Icons.bolt_rounded,
      route: AppRoutes.emergency,
    ),
    _DrawerMenuItem(
      title: 'Reports & Analytics',
      subtitle: 'Volume trends, revenue & growth',
      icon: Icons.analytics_rounded,
      route: AppRoutes.analytics,
    ),
    _DrawerMenuItem(
      title: 'Staff Management',
      subtitle: 'Delivery boys & route assignments',
      icon: Icons.badge_outlined,
      route: AppRoutes.staff,
    ),
    _DrawerMenuItem(
      title: 'Settings',
      subtitle: 'Shop profile, milk types & rates',
      icon: Icons.settings_rounded,
      route: AppRoutes.settings,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTransitions.slow,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate(String route) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    if (widget.currentRoute != route) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.82,
          margin: const EdgeInsets.only(right: 40, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6EE),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(28),
            ),
            border: Border.all(
              color: const Color(0x334A2E18),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drawer Header ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3AB),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTransitions.darkBrown,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: Color(0xFFFFF3AB),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vanthenda Paalkaran',
                            style: GoogleFonts.fraunces(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTransitions.darkBrown,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Dairy Operations Portal',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppTransitions.mediumBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppTransitions.darkBrown,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0x224A2E18)),

              // ── Cascading Menu List ────────────────────────────────
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final isSelected = widget.currentRoute == item.route;

                    // Staggered interval animation per item
                    final interval = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        (index / _menuItems.length) * 0.6,
                        1.0,
                        curve: AppTransitions.defaultCurve,
                      ),
                    );

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.2, 0),
                        end: Offset.zero,
                      ).animate(interval),
                      child: FadeTransition(
                        opacity: interval,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () => _navigate(item.route),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: AppTransitions.fast,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTransitions.darkBrown
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: isSelected
                                        ? const Color(0xFFFFF3AB)
                                        : AppTransitions.darkBrown,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : AppTransitions.darkBrown,
                                          ),
                                        ),
                                        Text(
                                          item.subtitle,
                                          style: GoogleFonts.outfit(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? const Color(0xFFFFF3AB)
                                                    .withValues(alpha: 0.8)
                                                : const Color(0xFF6E5647),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFFFFF3AB),
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _DrawerMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
