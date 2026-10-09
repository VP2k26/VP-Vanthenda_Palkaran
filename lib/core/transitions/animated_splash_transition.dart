import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import 'transition_utils.dart';

/// Centralized Animated Splash Screen Component with buttery smooth 60/120fps Lottie flow & brand reveal
class AnimatedSplashTransition extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final Duration initialPauseDuration;
  final Duration backgroundDuration;
  final Duration logoFadeDuration;
  final Duration holdDuration;

  const AnimatedSplashTransition({
    super.key,
    this.onAnimationComplete,
    this.initialPauseDuration = const Duration(milliseconds: 1000),
    this.backgroundDuration = const Duration(milliseconds: 1400),
    this.logoFadeDuration = const Duration(milliseconds: 600),
    this.holdDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<AnimatedSplashTransition> createState() =>
      _AnimatedSplashTransitionState();
}

class _AnimatedSplashTransitionState extends State<AnimatedSplashTransition>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;

  bool _isAnimationStarted = false;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: widget.backgroundDuration,
    );

    _logoController = AnimationController(
      vsync: this,
      duration: widget.logoFadeDuration,
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: AppTransitions.defaultCurve,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache logo image into GPU memory so it doesn't drop frames when fading in
    precacheImage(const AssetImage('assets/images/logo.png'), context);
  }

  void _onLottieLoaded(LottieComposition composition) {
    if (_isAnimationStarted || !mounted) return;
    _isAnimationStarted = true;

    // 1. Initial State: Display clean frame for 0.5 sec (initialPauseDuration)
    _bgController.value = 0.0;

    Future.delayed(widget.initialPauseDuration, () {
      if (!mounted) return;

      // 2. Start background flow animation (rises & fills colors)
      _bgController
        ..duration = widget.backgroundDuration
        ..forward().then((_) {
          if (!mounted) return;

          // 3. Smooth logo fade-in & scale
          _logoController.forward().then((_) {
            // 4. Hold completed screen, then navigate
            Future.delayed(widget.holdDuration, () {
              if (mounted) {
                widget.onAnimationComplete?.call();
              }
            });
          });
        });
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Isolated Background Flow Layer (GPU Raster Cached) ────
          RepaintBoundary(
            child: SizedBox.expand(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  // Push bottom yellow wave 85px below viewport during initial pause
                  final double bottomYOffset = _bgController.value < 0.20
                      ? (1.0 - (_bgController.value / 0.20)) * 85.0
                      : 0.0;

                  return Transform.translate(
                    offset: Offset(0, bottomYOffset),
                    child: child,
                  );
                },
                child: Lottie.asset(
                  'assets/animations/Flow_1.json',
                  controller: _bgController,
                  onLoaded: _onLottieLoaded,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      'Error loading splash animation: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 2. Isolated Center Brand Logo Layer ──────────────────────
          RepaintBoundary(
            child: Center(
              child: FadeTransition(
                opacity: _logoFadeAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Card Container with Dual Ambient Glow
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFFEAE2C5),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandBrown.withValues(
                                alpha: 0.18,
                              ),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: const Color(
                                0xFFF5ECAB,
                              ).withValues(alpha: 0.35),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brand Name
                      Text(
                        'Vanthenda Paalkaran',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandBrown,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'வந்தேண்டா பால்காரன்',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandBrownLight,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
