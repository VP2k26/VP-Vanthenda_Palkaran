import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/customer_repository.dart';

final customersListProvider =
    FutureProvider<List<CustomerModel>>((ref) async {
  final repo = ref.read(customerRepositoryProvider);
  return repo.fetchCustomers();
});

class CustomerNotifier extends Notifier<AsyncValue<List<CustomerModel>>> {
  @override
  AsyncValue<List<CustomerModel>> build() => const AsyncData([]);

  Future<void> loadCustomers() async {
    state = const AsyncLoading();
    try {
      final customers =
          await ref.read(customerRepositoryProvider).fetchCustomers();
      state = AsyncData(customers);
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> addCustomer(CustomerModel customer) async {
    final prev = state.valueOrNull ?? [];
    try {
      final created = await ref
          .read(customerRepositoryProvider)
          .createCustomer(customer);
      state = AsyncData([...prev, created]);
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      final updated = await ref
          .read(customerRepositoryProvider)
          .updateCustomer(customer);
      final prev = state.valueOrNull ?? [];
      state = AsyncData(
          prev.map((c) => c.id == customer.id ? updated : c).toList());
    } on Exception catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deactivate(String customerId) async {
    await ref
        .read(customerRepositoryProvider)
        .deactivateCustomer(customerId);
    await loadCustomers();
  }
}

final customerNotifierProvider = NotifierProvider<CustomerNotifier,
    AsyncValue<List<CustomerModel>>>(
  CustomerNotifier.new,
);
