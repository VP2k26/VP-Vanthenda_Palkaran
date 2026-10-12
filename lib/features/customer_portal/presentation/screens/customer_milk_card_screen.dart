import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

part 'customer_milk_card_screen.g.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

@riverpod
Future<List<Map<String, dynamic>>> customerMilkCardData(
    CustomerMilkCardDataRef ref, {
    required int month,
    required int year,
  }) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];

  final from = DateTime(year, month, 1).toIso8601String().split('T')[0];
  final to = DateTime(year, month + 1, 0).toIso8601String().split('T')[0];

  final res = await SupabaseService.client
      .from('deliveries')
      .select()
      .eq('customer_id', userId)
      .gte('delivery_date', from)
      .lte('delivery_date', to)
      .order('delivery_date');

  return (res as List).cast<Map<String, dynamic>>();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CustomerMilkCardScreen extends ConsumerStatefulWidget {
  const CustomerMilkCardScreen({super.key});

  @override
  ConsumerState<CustomerMilkCardScreen> createState() =>
      _CustomerMilkCardScreenState();
}

class _CustomerMilkCardScreenState
    extends ConsumerState<CustomerMilkCardScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (next.isBefore(DateTime.now().add(const Duration(days: 31)))) {
      setState(() => _currentMonth = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveriesAsync = ref.watch(customerMilkCardDataProvider(
      month: _currentMonth.month,
      year: _currentMonth.year,
    ));
    final monthLabel = DateFormat('MMMM yyyy').format(_currentMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Milk Card')),
      body: Column(
        children: [
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(monthLabel,
                    style: AppTypography.textTheme.titleMedium),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: deliveriesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Could not load milk card',
                    style: AppTypography.textTheme.bodyMedium),
              ),
              data: (deliveries) {
                final daysInMonth =
                    DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
                double totalLiters = 0;
                for (final d in deliveries) {
                  totalLiters += (d['quantity'] as num).toDouble();
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          _Pill(
                            label: 'Total Liters',
                            value: '${totalLiters.toStringAsFixed(1)}L',
                            color: AppColors.primary,
                          ),
                          _Pill(
                            label: 'Days Delivered',
                            value:
                                '${deliveries.length}/$daysInMonth',
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: daysInMonth,
                        itemBuilder: (context, idx) {
                          final day = idx + 1;
                          final hasDelivery = deliveries.any((d) {
                            final date = DateTime.parse(
                                d['delivery_date'] as String);
                            return date.day == day;
                          });
                          final isToday =
                              day == DateTime.now().day &&
                                  _currentMonth.month ==
                                      DateTime.now().month &&
                                  _currentMonth.year ==
                                      DateTime.now().year;

                          return Container(
                            decoration: BoxDecoration(
                              color: hasDelivery
                                  ? AppColors.secondary
                                      .withValues(alpha: 0.2)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isToday ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: AppTypography
                                    .textTheme.labelSmall
                                    ?.copyWith(
                                  color: hasDelivery
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                  fontWeight: hasDelivery
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
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
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Pill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTypography.textTheme.titleLarge
                  ?.copyWith(color: color)),
          Text(label,
              style: AppTypography.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
