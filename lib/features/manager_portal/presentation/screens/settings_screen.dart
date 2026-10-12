import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/manager_scaffold.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_card.dart';

import '../providers/operating_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessProfile = ref.watch(businessProfileProvider);

    return ManagerScaffold(
      title: 'Settings',
      subtitle: 'Business & app preferences',
      titleIcon: Icons.settings_rounded,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          PremiumCard(
            padding: const EdgeInsets.all(20),
            hasShadow: false,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront_outlined,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessProfile.dairyName,
                        style: AppTypography.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Owner: ${businessProfile.ownerName} • ${businessProfile.phone}',
                        style: AppTypography.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: businessProfile.isSolo
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          businessProfile.isSolo
                              ? '🚴 Solo Milkman (Self Delivery)'
                              : '👥 Multi-Staff (Team Mode)',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: businessProfile.isSolo
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  onPressed: () => context.push(AppRoutes.setupProfile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Business & Payment Setup
          Text(
            'Business & Payments',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          PremiumCard(
            padding: EdgeInsets.zero,
            hasShadow: false,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.hub_outlined,
                  label: 'Operating & Distribution Model',
                  onTap: () => context.push(AppRoutes.setupProfile),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.qr_code_2,
                  label: 'UPI ID & Payment QR Setup',
                  onTap: () => _showUpiConfigSheet(context),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Milk Price Setup',
                  onTap: () => context.push(AppRoutes.milkTypes),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.group_outlined,
                  label: 'Staff Management',
                  onTap: () => context.push(AppRoutes.staff),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Operations & Tools
          Text(
            'Operations & AI Tools',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          PremiumCard(
            padding: EdgeInsets.zero,
            hasShadow: false,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.beach_access_outlined,
                  label: 'Vacation Requests',
                  onTap: () => context.push(AppRoutes.vacation),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.electric_bolt_outlined,
                  label: 'Emergency Orders',
                  onTap: () => context.push(AppRoutes.emergency),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.trending_up_outlined,
                  label: 'Tomorrow Demand Forecast',
                  onTap: () => context.push(AppRoutes.demandForecast),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.smart_toy_outlined,
                  label: 'AI Operations Assistant',
                  onTap: () => context.push(AppRoutes.aiAssistant),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.analytics_outlined,
                  label: 'Business Analytics',
                  onTap: () => context.push(AppRoutes.analytics),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account & Support
          Text(
            'App & Account',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          PremiumCard(
            padding: EdgeInsets.zero,
            hasShadow: false,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: 'About Vanthenda Paalkaran',
                  onTap: () => _showAbout(context),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showUpiConfigSheet(BuildContext context) {
    final upiCtrl = TextEditingController(text: 'paalkaran@oksbi');
    final nameCtrl = TextEditingController(text: 'Vanthenda Paalkaran');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Manager UPI Configuration',
              style: AppTypography.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Customers will scan and transfer milk payments directly to this UPI account with zero commissions.',
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: upiCtrl,
              decoration: const InputDecoration(
                labelText: 'UPI ID (e.g. 9840123456@paytm / name@oksbi)',
                prefixIcon: Icon(Icons.qr_code_2),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Payee Business Name',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Save UPI Settings',
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'UPI ID updated to ${upiCtrl.text.trim()}!'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vanthenda Paalkaran',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Vanthenda Paalkaran • Zero-Commission Dairy ERP',
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out',
            style: AppTypography.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.go(AppRoutes.login);
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: AppTypography.textTheme.bodyLarge?.copyWith(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
      onTap: onTap,
    );
  }
}
