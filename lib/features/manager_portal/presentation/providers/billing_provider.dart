import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/billing_repository.dart';

final currentMonthBillsProvider =
    FutureProvider<List<BillModel>>((ref) async {
  return ref.read(billingRepositoryProvider).fetchMonthlyBills();
});

final totalPendingAmountProvider =
    FutureProvider<double>((ref) async {
  return ref.read(billingRepositoryProvider).getPendingAmount();
});

class BillingNotifier extends Notifier<AsyncValue<List<BillModel>>> {
  @override
  AsyncValue<List<BillModel>> build() => const AsyncData([]);

  Future<void> loadBills() async {
    state = const AsyncLoading();
    try {
      final bills =
          await ref.read(billingRepositoryProvider).fetchMonthlyBills();
      state = AsyncData(bills);
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> generateBills() async {
    state = const AsyncLoading();
    try {
      await ref.read(billingRepositoryProvider).generateMonthlyBills();
      await loadBills();
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> recordPayment({
    required String billId,
    required double amount,
    required String method,
  }) async {
    await ref.read(billingRepositoryProvider).recordPayment(
          billId: billId,
          amount: amount,
          paymentMethod: method,
        );
    await loadBills();
  }
}

final billingNotifierProvider =
    NotifierProvider<BillingNotifier, AsyncValue<List<BillModel>>>(
  BillingNotifier.new,
);
