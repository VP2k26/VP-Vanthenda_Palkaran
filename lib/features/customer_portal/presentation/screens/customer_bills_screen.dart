import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

part 'customer_bills_screen.g.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class CustomerBill {
  final String id;
  final int billingMonth;
  final int billingYear;
  final double totalLiters;
  final double totalAmount;
  final double amountPaid;
  final double amountDue;
  final bool isPaid;

  const CustomerBill({
    required this.id,
    required this.billingMonth,
    required this.billingYear,
    required this.totalLiters,
    required this.totalAmount,
    required this.amountPaid,
    required this.amountDue,
    required this.isPaid,
  });

  factory CustomerBill.fromJson(Map<String, dynamic> json) => CustomerBill(
        id: json['id'] as String,
        billingMonth: json['billing_month'] as int,
        billingYear: json['billing_year'] as int,
        totalLiters:
            (json['total_liters'] as num?)?.toDouble() ?? 0,
        totalAmount:
            (json['total_amount'] as num?)?.toDouble() ?? 0,
        amountPaid:
            (json['amount_paid'] as num?)?.toDouble() ?? 0,
        amountDue:
            (json['amount_due'] as num?)?.toDouble() ?? 0,
        isPaid: json['is_paid'] as bool? ?? false,
      );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

@riverpod
Future<List<CustomerBill>> customerBills(CustomerBillsRef ref) async {
  final customerId = SupabaseService.currentUserId;
  if (customerId == null) return [];

  final res = await SupabaseService.client
      .from('bills')
      .select()
      .eq('customer_id', customerId)
      .order('billing_year', ascending: false)
      .order('billing_month', ascending: false);

  return (res as List).map((e) => CustomerBill.fromJson(e)).toList();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CustomerBillsScreen extends ConsumerWidget {
  const CustomerBillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(customerBillsProvider);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Bills')),
      body: billsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Could not load bills',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.error)),
        ),
        data: (bills) {
          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No bills yet',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(
                              color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bills.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final bill = bills[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: bill.isPaid
                        ? AppColors.secondary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${months[bill.billingMonth - 1]} ${bill.billingYear}',
                            style: AppTypography.textTheme.titleSmall,
                          ),
                          Text(
                            '${bill.totalLiters.toStringAsFixed(1)}L total',
                            style: AppTypography.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${bill.totalAmount.toStringAsFixed(0)}',
                          style: AppTypography.textTheme.titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w700),
                        ),
                        if (bill.isPaid)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary
                                  .withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text('Paid',
                                style: AppTypography
                                    .textTheme.labelSmall
                                    ?.copyWith(
                                        color: AppColors.secondary)),
                          )
                        else
                          Text(
                            'Due: ₹${bill.amountDue.toStringAsFixed(0)}',
                            style: AppTypography.textTheme.labelSmall
                                ?.copyWith(color: AppColors.warning),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
