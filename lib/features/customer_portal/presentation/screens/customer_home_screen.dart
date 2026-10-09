import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/database/supabase_service.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/gradient_background.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends ConsumerState<CustomerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello!',
                        style: AppTypography.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        SupabaseService.auth.currentUser?.email ??
                            'Customer',
                        style: AppTypography.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(Icons.logout_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ],
              ),
            ),
            // Menu grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _PortalCard(
                      icon: Icons.credit_card_outlined,
                      title: 'Milk Card',
                      subtitle: 'View delivery history',
                      color: AppColors.primary,
                      onTap: () => context.go(AppRoutes.milkCard),
                    ),
                    _PortalCard(
                      icon: Icons.receipt_outlined,
                      title: 'My Bills',
                      subtitle: 'View invoices',
                      color: AppColors.warning,
                      onTap: () {},
                    ),
                    _PortalCard(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'My details',
                      color: AppColors.secondary,
                      onTap: () {},
                    ),
                    _PortalCard(
                      icon: Icons.beach_access_outlined,
                      title: 'Vacation',
                      subtitle: 'Request leave',
                      color: AppColors.info,
                      onTap: () {},
                    ),
                    _PortalCard(
                      icon: Icons.warning_amber_outlined,
                      title: 'Emergency',
                      subtitle: 'Raise request',
                      color: AppColors.error,
                      onTap: () {},
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

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseService.auth.signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }
}

class _PortalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PortalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.subtleShadow,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, style: AppTypography.textTheme.titleSmall),
            Text(subtitle,
                style: AppTypography.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
