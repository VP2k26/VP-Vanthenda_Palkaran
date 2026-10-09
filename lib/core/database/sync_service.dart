import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hive_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(Supabase.instance.client);
});

class SyncService {
  final SupabaseClient _supabase;

  SyncService(this._supabase);

  /// Synchronizes offline data with Supabase
  Future<void> syncAll() async {
    try {
      await _syncDeliveries();
      await _syncCustomers();
    } catch (e) {
      log('Sync Error: $e');
    }
  }

  Future<void> _syncDeliveries() async {
    final box = HiveService.deliveriesBox;
    final pendingDeliveries = box.values.where((d) => d.syncStatus != 'Synced').toList();

    for (var delivery in pendingDeliveries) {
      try {
        await _supabase.from('deliveries').upsert({
          'id': delivery.id,
          'vendor_id': delivery.vendorId,
          'customer_id': delivery.customerId,
          'milk_type_id': delivery.milkTypeId,
          'delivery_date': delivery.deliveryDate.toIso8601String(),
          'session': delivery.session,
          'quantity': delivery.quantity,
          'price_applied': delivery.priceApplied,
          'status': delivery.status,
          'sync_status': 'Synced',
        });
        
        delivery.syncStatus = 'Synced';
        await box.put(delivery.id, delivery);
      } catch (e) {
        log('Failed to sync delivery ${delivery.id}: $e');
      }
    }
  }

  Future<void> _syncCustomers() async {
    // Customer sync implementation
  }
}
