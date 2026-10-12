import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routing/app_routes.dart';
import 'transition_utils.dart';

/// Reusable Animated Bottom Dock with smooth sliding pill & micro-scaling
class AnimatedBottomBar extends StatelessWidget {
  final int currentIndex;

  const AnimatedBottomBar({super.key, required this.currentIndex});

  static const List<_BarItem> _items = [
    _BarItem(
      route: AppRoutes.dashboard,
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _BarItem(
      route: AppRoutes.delivery,
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping_rounded,
      label: 'Route',
    ),
    _BarItem(
      route: AppRoutes.customers,
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_alt_rounded,
      label: 'CRM',
    ),
    _BarItem(
      route: AppRoutes.settings,
      icon: Icons.tune_rounded,
      activeIcon: Icons.tune_rounded,
      label: 'Settings',
    ),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    HapticFeedback.selectionClick();
    context.go(_items[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6BE),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final isSelected = currentIndex == index;
          final item = _items[index];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onTap(context, index),
            child: AnimatedContainer(
              duration: AppTransitions.normal,
              curve: AppTransitions.defaultCurve,
              transform: Matrix4.translationValues(0, isSelected ? -7 : 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Pill / Squircle Container
                  AnimatedScale(
                    scale: isSelected ? 1.06 : 1.0,
                    duration: AppTransitions.fast,
                    curve: AppTransitions.defaultCurve,
                    child: AnimatedContainer(
                      duration: AppTransitions.normal,
                      curve: AppTransitions.defaultCurve,
                      width: 56,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTransitions.darkBrown
                            : const Color(0xFFFFF9E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTransitions.darkBrown
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
                        child: AnimatedSwitcher(
                          duration: AppTransitions.fast,
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            key: ValueKey(isSelected),
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : AppTransitions.darkBrown,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Label with subtle weight / color transition
                  AnimatedDefaultTextStyle(
                    duration: AppTransitions.fast,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTransitions.darkBrown
                          : AppTransitions.mediumBrown,
                      letterSpacing: 0.1,
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BarItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _BarItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
