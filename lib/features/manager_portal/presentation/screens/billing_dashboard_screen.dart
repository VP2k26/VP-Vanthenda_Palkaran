import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/billing_provider.dart';
import '../../data/repositories/billing_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/manager_scaffold.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';

class BillingDashboardScreen extends ConsumerStatefulWidget {
  const BillingDashboardScreen({super.key});

  @override
  ConsumerState<BillingDashboardScreen> createState() =>
      _BillingDashboardScreenState();
}

class _BillingDashboardScreenState
    extends ConsumerState<BillingDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(billingNotifierProvider.notifier).loadBills(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billsState = ref.watch(billingNotifierProvider);
    final pendingAsync = ref.watch(totalPendingAmountProvider);

    return ManagerScaffold(
      title: 'Billing',
      subtitle: 'Monthly bill generation & tracking',
      titleIcon: Icons.receipt_long_rounded,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: PremiumButton(
            text: 'Generate',
            isOutlined: true,
            icon: Icons.autorenew,
            onPressed: () => _confirmGenerate(context),
          ),
        ),
      ],
      body: RefreshIndicator(
        color: const Color(0xFF4A2E18),
        onRefresh: () async =>
            ref.read(billingNotifierProvider.notifier).loadBills(),
        child: Column(
          children: [
            // Summary card
            pendingAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (pending) => Padding(
                padding: const EdgeInsets.all(16),
                child: PremiumCard(
                  backgroundColor: AppColors.primary,
                  hasShadow: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pending Collection',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.surface.withOpacity(0.8),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${NumberFormat('#,##0').format(pending)}',
                              style: AppTypography.textTheme.displayMedium
                                  ?.copyWith(
                                    color: AppColors.surface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 32,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: billsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load bills',
                        style: AppTypography.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      PremiumButton(
                        text: 'Retry',
                        isOutlined: true,
                        onPressed: () => ref
                            .read(billingNotifierProvider.notifier)
                            .loadBills(),
                      ),
                    ],
                  ),
                ),
                data: (bills) {
                  if (bills.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppColors.border,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No bills this month',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          PremiumButton(
                            text: 'Generate Bills',
                            onPressed: () => _confirmGenerate(context),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: bills.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _BillCard(
                      bill: bills[i],
                      onPay: () => _showPaymentSheet(context, bills[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmGenerate(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Generate Bills',
          style: AppTypography.textTheme.titleLarge,
        ),
        content: Text(
          'Generate bills for all active customers this month?',
          style: AppTypography.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          PremiumButton(
            text: 'Generate',
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(billingNotifierProvider.notifier).generateBills();
    }
  }

  void _showPaymentSheet(BuildContext context, BillModel bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(
        bill: bill,
        onRecord: (method) {
          ref
              .read(billingNotifierProvider.notifier)
              .recordPayment(
                billId: bill.id,
                amount: bill.amountDue,
                method: method,
              );
        },
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback onPay;

  const _BillCard({required this.bill, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      hasShadow: false,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bill.isPaid
                  ? AppColors.secondary.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              bill.isPaid
                  ? Icons.check_circle_outline
                  : Icons.receipt_long_outlined,
              color: bill.isPaid ? AppColors.secondary : AppColors.warning,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.customerName,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bill.totalLiters.toStringAsFixed(1)}L · ₹${bill.totalAmount.toStringAsFixed(0)}',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (bill.isPaid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PAID',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${bill.amountDue.toStringAsFixed(0)}',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                PremiumButton(
                  text: 'Record Collection',
                  isOutlined: true,
                  onPressed: onPay,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PaymentSheet extends StatefulWidget {
  final BillModel bill;
  final void Function(String method) onRecord;

  const _PaymentSheet({required this.bill, required this.onRecord});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  String _method = 'cash';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 24),
            Text(
              'Record Customer Payment',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Collecting payment from ${widget.bill.customerName}',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            PremiumCard(
              backgroundColor: AppColors.surfaceVariant,
              hasShadow: false,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Outstanding Due',
                    style: AppTypography.textTheme.bodyMedium,
                  ),
                  Text(
                    '₹${widget.bill.amountDue.toStringAsFixed(0)}',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Mode Received:',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _modeChip('cash', '💵 Cash at Doorstep'),
                _modeChip('upi', '📱 Direct UPI Transfer'),
                _modeChip('bank_transfer', '🏦 Bank Transfer'),
              ],
            ),
            const SizedBox(height: 28),
            PremiumButton(
              text:
                  'Record ₹${widget.bill.amountDue.toStringAsFixed(0)} Collected',
              onPressed: () {
                widget.onRecord(_method);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(String id, String label) {
    final isSelected = _method == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _method = id),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
        color: isSelected ? AppColors.surface : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}
