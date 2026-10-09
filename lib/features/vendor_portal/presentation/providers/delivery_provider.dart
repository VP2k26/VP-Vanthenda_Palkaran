import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/delivery_repository.dart';

// ─── Delivery Notifier ────────────────────────────────────────────────────────

class DeliveryNotifier extends Notifier<AsyncValue<List<DeliveryModel>>> {
  @override
  AsyncValue<List<DeliveryModel>> build() {
    // Load deliveries on start
    Future.microtask(() => loadTodaysDeliveries());
    return const AsyncLoading();
  }

  Future<void> loadTodaysDeliveries() async {
    try {
      final deliveries = await ref
          .read(deliveryRepositoryProvider)
          .fetchTodaysDeliveries();
      state = AsyncData(deliveries);
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> markDelivered(String deliveryId) async {
    await ref.read(deliveryRepositoryProvider).markDelivered(deliveryId);
    await loadTodaysDeliveries();
  }

  Future<void> toggleDelivery(String deliveryId) async {
    await ref.read(deliveryRepositoryProvider).toggleDeliveryStatus(deliveryId);
    await loadTodaysDeliveries();
  }

  Future<void> addDelivery(DeliveryModel delivery) async {
    final prev = state.valueOrNull ?? [];
    try {
      final created = await ref
          .read(deliveryRepositoryProvider)
          .createDelivery(delivery);
      state = AsyncData([...prev, created]);
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final deliveryNotifierProvider =
    NotifierProvider<DeliveryNotifier, AsyncValue<List<DeliveryModel>>>(
  DeliveryNotifier.new,
);

// ─── Delivery History & Fulfillment Tracker Provider ─────────────────────────

final deliveryHistoryProvider =
    FutureProvider<List<DailyHistoryRecord>>((ref) async {
  final repo = ref.read(deliveryRepositoryProvider);
  return repo.fetchDeliveryHistory();
});

// ─── Customer Milk Card Provider (parameterized via family) ───────────────────

final customerMilkCardProvider = FutureProvider.family<List<DeliveryModel>,
    ({String customerId, DateTime from, DateTime to})>(
  (ref, params) async {
    final repo = ref.read(deliveryRepositoryProvider);
    return repo.fetchCustomerDeliveries(
      customerId: params.customerId,
      from: params.from,
      to: params.to,
    );
  },
);
