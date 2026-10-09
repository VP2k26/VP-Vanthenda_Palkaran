import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/mock_data.dart';

class BillModel {
  final String id;
  final String vendorId;
  final String customerId;
  final String customerName;
  final int billingMonth;
  final int billingYear;
  final double totalLiters;
  final double totalAmount;
  final double amountPaid;
  final double amountDue;
  final bool isPaid;
  final DateTime? paidAt;

  const BillModel({
    required this.id,
    required this.vendorId,
    required this.customerId,
    required this.customerName,
    required this.billingMonth,
    required this.billingYear,
    required this.totalLiters,
    required this.totalAmount,
    required this.amountPaid,
    required this.amountDue,
    required this.isPaid,
    this.paidAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String? ?? 'vendor-1',
        customerId: json['customer_id'] as String,
        customerName: json['customer_name'] as String? ?? '',
        billingMonth: json['billing_month'] as int,
        billingYear: json['billing_year'] as int,
        totalLiters: (json['total_liters'] as num?)?.toDouble() ?? 0,
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
        amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
        amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0,
        isPaid: json['is_paid'] as bool? ?? false,
        paidAt: json['paid_at'] != null
            ? DateTime.parse(json['paid_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'customer_name': customerName,
        'billing_month': billingMonth,
        'billing_year': billingYear,
        'amount_due': amountDue,
        'is_paid': isPaid,
      };

  BillModel copyWith({
    String? id,
    String? vendorId,
    String? customerId,
    String? customerName,
    int? billingMonth,
    int? billingYear,
    double? totalLiters,
    double? totalAmount,
    double? amountPaid,
    double? amountDue,
    bool? isPaid,
    DateTime? paidAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      billingMonth: billingMonth ?? this.billingMonth,
      billingYear: billingYear ?? this.billingYear,
      totalLiters: totalLiters ?? this.totalLiters,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      amountDue: amountDue ?? this.amountDue,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

final billingRepositoryProvider =
    Provider<BillingRepository>((ref) => BillingRepository());

class BillingRepository {
  Future<List<BillModel>> fetchMonthlyBills() async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    return List<BillModel>.from(MockDataStore.bills);

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final now = DateTime.now();
    final res = await SupabaseService.client
        .from('bills')
        .select()
        .eq('billing_month', now.month)
        .eq('billing_year', now.year)
        .order('customer_name');
    return (res as List).map((e) => BillModel.fromJson(e)).toList();
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<List<BillModel>> fetchBillsForCustomer(String customerId) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    return MockDataStore.bills
        .where((b) => b.customerId == customerId)
        .toList();

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final res = await SupabaseService.client
        .from('bills')
        .select()
        .eq('customer_id', customerId)
        .order('billing_year', ascending: false)
        .order('billing_month', ascending: false);
    return (res as List).map((e) => BillModel.fromJson(e)).toList();
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<double> getPendingAmount() async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    double total = 0;
    for (final b in MockDataStore.bills) {
      if (!b.isPaid) {
        total += b.amountDue;
      }
    }
    return total;

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final res = await SupabaseService.client
        .from('bills')
        .select('pending_amount')
        .eq('is_paid', false);
    double total = 0;
    for (final b in (res as List)) {
      total += (b['pending_amount'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<void> generateMonthlyBills() async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    for (final c in MockDataStore.customers) {
      final exists = MockDataStore.bills.any((b) => b.customerId == c.id);
      if (!exists) {
        final dailyQty = c.defaultMorningQty + c.defaultEveningQty;
        final totalLiters = dailyQty * 30;
        final totalAmount = totalLiters * 50.0;
        MockDataStore.bills.add(
          BillModel(
            id: 'bill-${MockDataStore.bills.length + 1}',
            vendorId: 'vendor-1',
            customerId: c.id,
            customerName: c.name,
            billingMonth: DateTime.now().month,
            billingYear: DateTime.now().year,
            totalLiters: totalLiters,
            totalAmount: totalAmount,
            amountPaid: 0,
            amountDue: totalAmount,
            isPaid: false,
          ),
        );
      }
    }

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final vendorId = SupabaseService.currentUserId;
    if (vendorId == null) return;
    await SupabaseService.client.rpc('generate_monthly_bills',
        params: {'p_vendor_id': vendorId});
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<void> markAsPaid(String billId) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    final index = MockDataStore.bills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      final b = MockDataStore.bills[index];
      MockDataStore.bills[index] = b.copyWith(
        isPaid: true,
        amountPaid: b.totalAmount,
        amountDue: 0,
        paidAt: DateTime.now(),
      );
    }

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    await SupabaseService.client.from('bills').update({'is_paid': true}).eq('id', billId);
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<void> recordPayment({
    required String billId,
    required double amount,
    required String paymentMethod,
  }) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    await markAsPaid(billId);

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    await SupabaseService.client.from('payments').insert({
      'bill_id': billId,
      'amount': amount,
      'payment_method': paymentMethod,
      'paid_at': DateTime.now().toIso8601String(),
    });
    await SupabaseService.client.from('bills').update({
      'amount_paid': amount,
      'amount_due': 0,
      'is_paid': true,
      'paid_at': DateTime.now().toIso8601String(),
    }).eq('id', billId);
    // ───────────────────────────────────────────────────────────────
    */
  }
}
