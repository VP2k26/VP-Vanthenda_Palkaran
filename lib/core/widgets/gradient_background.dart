import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

/// A reusable full-screen background wrapper with radial gradient & SVG texture overlay.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final double textureOpacity;

  const GradientBackground({
    super.key,
    required this.child,
    this.textureOpacity = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // SVG Pattern Texture overlay
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/svg_file/pattern.svg',
              fit: BoxFit.cover,
            ),
          ),
          // Main Screen Content
          child,
        ],
      ),
    );
  }
}
