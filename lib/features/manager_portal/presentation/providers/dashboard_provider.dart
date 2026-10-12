import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../vendor_portal/data/repositories/delivery_repository.dart';
import '../../data/repositories/customer_repository.dart';

// Dashboard Stats Provider
final dashboardStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final deliveryRepo = ref.read(deliveryRepositoryProvider);
  return deliveryRepo.fetchDashboardStats();
});

// Active Customers Count Provider
final activeCustomerCountProvider = FutureProvider<int>((ref) async {
  final customerRepo = ref.read(customerRepositoryProvider);
  final customers = await customerRepo.fetchCustomers();
  return customers.length;
});

// Today's Deliveries List Provider
final todaysDeliveriesProvider =
    FutureProvider<List<DeliveryModel>>((ref) async {
  final deliveryRepo = ref.read(deliveryRepositoryProvider);
  return deliveryRepo.fetchTodaysDeliveries();
});

// Vendor Info Provider (simple placeholder)
final vendorInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return {'name': 'Vanthenda Paalkaran'};
});
