import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/supabase_service.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/transitions/transitions.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  Future<void> _handleNavigation(BuildContext context) async {
    if (SupabaseService.isAuthenticated) {
      final route = await AuthNotifier.routeForRole();
      if (context.mounted) context.go(route);
    } else {
      if (context.mounted) context.go(AppRoutes.language);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSplashTransition(
      onAnimationComplete: () => _handleNavigation(context),
    );
  }
}
