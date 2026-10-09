import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/manager_scaffold.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/payment_success_dialog.dart';
import '../../../../core/upi/upi_helper.dart';
import '../../../../core/services/whatsapp_reminder_helper.dart';
import '../../data/repositories/billing_repository.dart';
import '../providers/billing_provider.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(currentMonthBillsProvider);
    final pendingAsync = ref.watch(totalPendingAmountProvider);

    return ManagerScaffold(
      title: 'Bill Collections',
      subtitle: 'Customer payment management',
      titleIcon: Icons.payments_rounded,
      body: Column(
        children: [
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
                            'Pending Collections',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${pending.toStringAsFixed(0)}',
                            style: AppTypography.textTheme.displayMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: billsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: AppTypography.textTheme.bodyMedium,
                ),
              ),
              data: (bills) {
                final unpaid = bills.where((b) => !b.isPaid).toList();
                if (unpaid.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'All collections completed!',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: unpaid.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _PendingPaymentCard(
                    bill: unpaid[i],
                    onCollect: () =>
                        _showUpiCollectionModal(context, ref, unpaid[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUpiCollectionModal(
    BuildContext context,
    WidgetRef ref,
    BillModel bill,
  ) {
    const defaultUpiId = 'paalkaran@oksbi';
    const defaultPayeeName = 'Vanthenda Paalkaran';
    final upiUri = UpiPaymentHelper.buildUpiUri(
      upiId: defaultUpiId,
      payeeName: defaultPayeeName,
      amount: bill.amountDue,
      billReference: bill.id,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Customer Bill Collection',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${bill.customerName} • Month ${bill.billingMonth}/${bill.billingYear}',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic Zero-Commission UPI QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.subtleShadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: upiUri,
                version: QrVersions.auto,
                size: 180.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Show this QR code for the customer to scan & pay',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${bill.amountDue.toStringAsFixed(0)}',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            // Action: Confirm UPI Received
            PremiumButton(
              text:
                  'Confirm UPI Received (₹${bill.amountDue.toStringAsFixed(0)})',
              icon: Icons.check_circle_outline,
              onPressed: () async {
                await ref
                    .read(billingNotifierProvider.notifier)
                    .recordPayment(
                      billId: bill.id,
                      amount: bill.amountDue,
                      method: 'upi',
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  PaymentSuccessDialog.show(
                    context,
                    amount: bill.amountDue,
                    customerName: bill.customerName,
                    billReference: bill.id,
                    paymentMethod: 'Direct UPI Transfer',
                    onDismiss: () {},
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Action: Record Cash Collected
            OutlinedButton.icon(
              icon: const Icon(
                Icons.payments_outlined,
                color: AppColors.secondary,
              ),
              label: Text(
                'Record Cash Collected (₹${bill.amountDue.toStringAsFixed(0)})',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.secondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await ref
                    .read(billingNotifierProvider.notifier)
                    .recordPayment(
                      billId: bill.id,
                      amount: bill.amountDue,
                      method: 'cash',
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  PaymentSuccessDialog.show(
                    context,
                    amount: bill.amountDue,
                    customerName: bill.customerName,
                    billReference: bill.id,
                    paymentMethod: 'Cash Settlement',
                    onDismiss: () {},
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Action: Send WhatsApp Bill Reminder
            TextButton.icon(
              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 18),
              label: const Text(
                'Send Bill Invoice via WhatsApp',
                style: TextStyle(
                  color: Color(0xFF25D366),
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                WhatsAppReminderHelper.sendWhatsAppReminder(
                  phone: '9840123456',
                  bill: bill,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback onCollect;

  const _PendingPaymentCard({required this.bill, required this.onCollect});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      hasShadow: false,
      onTap: onCollect,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2, color: AppColors.primary),
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
                  'Month ${bill.billingMonth}/${bill.billingYear} • Tap to collect',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${bill.amountDue.toStringAsFixed(0)}',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Unpaid Due',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
