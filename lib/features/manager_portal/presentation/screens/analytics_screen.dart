import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vanthenda_paalkaran/core/routing/app_routes.dart';
import '../../../../core/database/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/manager_scaffold.dart';

part 'analytics_screen.g.dart';

class AnalyticsSummary {
  final int todayDeliveries;
  final int monthDeliveries;
  final double monthLiters;
  final double monthRevenue;
  final int activeCustomers;
  final double pendingAmount;

  const AnalyticsSummary({
    required this.todayDeliveries,
    required this.monthDeliveries,
    required this.monthLiters,
    required this.monthRevenue,
    required this.activeCustomers,
    required this.pendingAmount,
  });
}

@riverpod
Future<AnalyticsSummary> analyticsSummary(AnalyticsSummaryRef ref) async {
  // ── DEV MOCK DATA MODE ──────────────────────────────────────────
  int todayDeliveries = MockDataStore.deliveries.length;
  int monthDeliveries = MockDataStore.deliveries.length * 30;
  double monthLiters = 0;
  double monthRevenue = 0;

  for (final b in MockDataStore.bills) {
    monthLiters += b.totalLiters;
    monthRevenue += b.totalAmount;
  }

  final activeCustomers = MockDataStore.customers.where((c) => c.isActive).length;

  double pendingAmount = 0;
  for (final b in MockDataStore.bills) {
    if (!b.isPaid) {
      pendingAmount += b.amountDue;
    }
  }

  return AnalyticsSummary(
    todayDeliveries: todayDeliveries,
    monthDeliveries: monthDeliveries,
    monthLiters: monthLiters,
    monthRevenue: monthRevenue,
    activeCustomers: activeCustomers,
    pendingAmount: pendingAmount,
  );

  /*
  // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
  final vendorId = SupabaseService.currentUserId;
  if (vendorId == null) {
    return const AnalyticsSummary(
      todayDeliveries: 0,
      monthDeliveries: 0,
      monthLiters: 0,
      monthRevenue: 0,
      activeCustomers: 0,
      pendingAmount: 0,
    );
  }

  final today = DateTime.now().toIso8601String().split('T')[0];
  final firstOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1)
          .toIso8601String()
          .split('T')[0];

  final results = await Future.wait([
    SupabaseService.client
        .from('deliveries')
        .select('id')
        .eq('vendor_id', vendorId)
        .eq('delivery_date', today),
    SupabaseService.client
        .from('deliveries')
        .select('quantity, total_amount')
        .eq('vendor_id', vendorId)
        .gte('delivery_date', firstOfMonth),
    SupabaseService.client
        .from('customers')
        .select('id')
        .eq('vendor_id', vendorId)
        .eq('is_active', true),
    SupabaseService.client
        .from('bills')
        .select('amount_due')
        .eq('vendor_id', vendorId)
        .eq('is_paid', false),
  ]);

  final todayDeliveries = (results[0] as List).length;
  final monthDeliveries = (results[1] as List).length;

  double monthLiters = 0;
  double monthRevenue = 0;
  for (final d in (results[1] as List)) {
    monthLiters += (d['quantity'] as num).toDouble();
    monthRevenue += (d['total_amount'] as num).toDouble();
  }

  final activeCustomers = (results[2] as List).length;

  double pendingAmount = 0;
  for (final b in (results[3] as List)) {
    pendingAmount += (b['amount_due'] as num).toDouble();
  }

  return AnalyticsSummary(
    todayDeliveries: todayDeliveries,
    monthDeliveries: monthDeliveries,
    monthLiters: monthLiters,
    monthRevenue: monthRevenue,
    activeCustomers: activeCustomers,
    pendingAmount: pendingAmount,
  );
  // ───────────────────────────────────────────────────────────────
  */
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);

    return ManagerScaffold(
      title: 'Analytics',
      subtitle: 'Business performance insights',
      titleIcon: Icons.bar_chart_rounded,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF3D2314)),
          onPressed: () => ref.invalidate(analyticsSummaryProvider),
        ),
      ],
      body: summaryAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Color(0xFF4A2E18))),
        error: (e, _) => Center(
          child: Text('Error loading analytics',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.error)),
        ),
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2E18),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _AnalyticsCard(
                    label: "Today's Deliveries",
                    value: '${summary.todayDeliveries}',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.primary,
                  ),
                  _AnalyticsCard(
                    label: 'Month Deliveries',
                    value: '${summary.monthDeliveries}',
                    icon: Icons.calendar_month_outlined,
                    color: AppColors.info,
                  ),
                  _AnalyticsCard(
                    label: 'Month Liters',
                    value: '${summary.monthLiters.toStringAsFixed(1)}L',
                    icon: Icons.water_drop_outlined,
                    color: AppColors.secondary,
                  ),
                  _AnalyticsCard(
                    label: 'Month Revenue',
                    value:
                        '₹${NumberFormat('#,##0').format(summary.monthRevenue)}',
                    icon: Icons.currency_rupee,
                    color: AppColors.success,
                  ),
                  _AnalyticsCard(
                    label: 'Active Customers',
                    value: '${summary.activeCustomers}',
                    icon: Icons.people_outlined,
                    color: AppColors.primary,
                  ),
                  _AnalyticsCard(
                    label: 'Pending Amount',
                    value:
                        '₹${NumberFormat('#,##0').format(summary.pendingAmount)}',
                    icon: Icons.receipt_outlined,
                    color: AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Forecasting', style: AppTypography.textTheme.titleLarge),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.trending_up_outlined,
                title: 'Demand Forecast',
                subtitle: 'Predict tomorrow\'s milk demand',
                color: AppColors.info,
                onTap: () => context.go(AppRoutes.demandForecast),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.smart_toy_outlined,
                title: 'AI Assistant',
                subtitle: 'Ask questions about your business',
                color: AppColors.secondary,
                onTap: () => context.go(AppRoutes.aiAssistant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.textTheme.titleSmall),
                  Text(subtitle,
                      style: AppTypography.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
