import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/supabase_service.dart';
import '../../../../core/database/mock_data.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../manager_portal/data/repositories/customer_repository.dart';
import '../providers/delivery_provider.dart';

class StaffHomeScreen extends ConsumerStatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  ConsumerState<StaffHomeScreen> createState() =>
      _StaffHomeScreenState();
}

class _StaffHomeScreenState extends ConsumerState<StaffHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(deliveryNotifierProvider.notifier)
          .loadTodaysDeliveries(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveriesState = ref.watch(deliveryNotifierProvider);
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM').format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Route",
                style: AppTypography.textTheme.titleLarge),
            Text(
              dateStr,
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(deliveryNotifierProvider.notifier)
                .loadTodaysDeliveries(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: GradientBackground(
        child: deliveriesState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Could not load deliveries',
                  style: AppTypography.textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref
                    .read(deliveryNotifierProvider.notifier)
                    .loadTodaysDeliveries(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: AppColors.secondary),
                  const SizedBox(height: 16),
                  Text('No deliveries today!',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(color: AppColors.secondary)),
                ],
              ),
            );
          }

          final done = deliveries.where((d) => d.isDelivered).length;

          return Column(
            children: [
              // Progress
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress',
                              style: AppTypography.textTheme.titleSmall),
                          Text(
                            '$done / ${deliveries.length}',
                            style: AppTypography.textTheme.titleSmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: deliveries.isEmpty
                            ? 0
                            : done / deliveries.length,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: deliveries.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = deliveries[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: d.isDelivered
                              ? AppColors.secondary
                                  .withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: d.isDelivered
                                  ? AppColors.secondary
                                      .withValues(alpha: 0.12)
                                  : AppColors.primary
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              d.isDelivered
                                  ? Icons.check_circle_outline
                                  : Icons.water_drop_outlined,
                              color: d.isDelivered
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final cust = MockDataStore.customers.firstWhere(
                                  (c) => c.id == d.customerId,
                                  orElse: () => CustomerModel(
                                    id: d.customerId,
                                    vendorId: d.vendorId,
                                    name: d.customerId.length > 6
                                        ? 'Customer #${d.customerId.substring(0, 6)}'
                                        : 'Customer #${d.customerId}',
                                    phone: '',
                                    address: '',
                                    area: '',
                                    defaultMorningQty: 0,
                                    defaultEveningQty: 0,
                                    milkTypeId: '',
                                    isActive: true,
                                    createdAt: DateTime.now(),
                                  ),
                                );
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cust.name,
                                      style: AppTypography
                                          .textTheme.titleSmall,
                                    ),
                                    Text(
                                      '${d.session} · ${d.quantity}L${cust.area.isNotEmpty ? ' · ${cust.area}' : ''}',
                                      style: AppTypography
                                          .textTheme.bodySmall,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          if (!d.isDelivered)
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(deliveryNotifierProvider
                                      .notifier)
                                  .markDelivered(d.id),
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  minimumSize: const Size(0, 0)),
                              child: const Text('Done'),
                            )
                          else
                            Text(
                              'Done',
                              style: AppTypography.textTheme.labelSmall
                                  ?.copyWith(
                                      color: AppColors.secondary),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
