import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

typedef AntigravityCard = PremiumCard;

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool hasShadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    // Warm frosted cream — matches the dashboard card palette
    const warmCream = Color(0xFFFFFBEE);
    const warmBorder = Color(0xFFF0DFB2);

    Widget card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? warmCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: warmBorder.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: hasShadow
            ? [
                const BoxShadow(
                  color: AppColors.mediumShadow,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                  spreadRadius: -4,
                ),
                const BoxShadow(
                  color: AppColors.subtleShadow,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}
