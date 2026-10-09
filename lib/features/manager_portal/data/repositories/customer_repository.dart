import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/mock_data.dart';

class CustomerModel {
  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String address;
  final String area;
  final double defaultMorningQty;
  final double defaultEveningQty;
  final String milkTypeId;
  final bool isActive;
  final DateTime createdAt;
  final int? routeSequence;
  final DateTime? vacationStartDate;
  final DateTime? vacationEndDate;
  final double unitPrice;
  final String paymentStatus; // 'Paid', 'Partial', 'Due'
  final String? assignedStaffName;

  const CustomerModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    required this.address,
    required this.area,
    required this.defaultMorningQty,
    required this.defaultEveningQty,
    required this.milkTypeId,
    required this.isActive,
    required this.createdAt,
    this.routeSequence,
    this.vacationStartDate,
    this.vacationEndDate,
    this.unitPrice = 50.0,
    this.paymentStatus = 'Paid',
    this.assignedStaffName,
  });

  bool get isOnVacation {
    if (vacationStartDate == null || vacationEndDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(vacationStartDate!.year, vacationStartDate!.month, vacationStartDate!.day);
    final end = DateTime(vacationEndDate!.year, vacationEndDate!.month, vacationEndDate!.day);
    return today.isAfter(start.subtract(const Duration(days: 1))) &&
        today.isBefore(end.add(const Duration(days: 1)));
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String? ?? 'vendor-1',
        name: json['name'] as String? ?? 'Unknown',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        area: json['area'] as String? ?? '',
        defaultMorningQty:
            (json['default_morning_qty'] as num?)?.toDouble() ?? 0.0,
        defaultEveningQty:
            (json['default_evening_qty'] as num?)?.toDouble() ?? 0.0,
        milkTypeId: json['default_milk_type_id'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        routeSequence: json['route_sequence'] as int?,
        vacationStartDate: json['vacation_start_date'] != null
            ? DateTime.tryParse(json['vacation_start_date'] as String)
            : null,
        vacationEndDate: json['vacation_end_date'] != null
            ? DateTime.tryParse(json['vacation_end_date'] as String)
            : null,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 50.0,
        paymentStatus: json['payment_status'] as String? ?? 'Paid',
        assignedStaffName: json['assigned_staff_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'address': address,
        'default_morning_qty': defaultMorningQty,
        'default_evening_qty': defaultEveningQty,
        if (milkTypeId.isNotEmpty) 'default_milk_type_id': milkTypeId,
        'is_active': isActive,
        if (routeSequence != null) 'route_sequence': routeSequence,
        if (vacationStartDate != null)
          'vacation_start_date': vacationStartDate!.toIso8601String(),
        if (vacationEndDate != null)
          'vacation_end_date': vacationEndDate!.toIso8601String(),
        'unit_price': unitPrice,
        'payment_status': paymentStatus,
        if (assignedStaffName != null)
          'assigned_staff_name': assignedStaffName,
      };

  CustomerModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? phone,
    String? address,
    String? area,
    double? defaultMorningQty,
    double? defaultEveningQty,
    String? milkTypeId,
    bool? isActive,
    DateTime? createdAt,
    int? routeSequence,
    DateTime? vacationStartDate,
    DateTime? vacationEndDate,
    double? unitPrice,
    String? paymentStatus,
    String? assignedStaffName,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      area: area ?? this.area,
      defaultMorningQty: defaultMorningQty ?? this.defaultMorningQty,
      defaultEveningQty: defaultEveningQty ?? this.defaultEveningQty,
      milkTypeId: milkTypeId ?? this.milkTypeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      routeSequence: routeSequence ?? this.routeSequence,
      vacationStartDate: vacationStartDate ?? this.vacationStartDate,
      vacationEndDate: vacationEndDate ?? this.vacationEndDate,
      unitPrice: unitPrice ?? this.unitPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
    );
  }
}

final customerRepositoryProvider =
    Provider<CustomerRepository>((ref) => CustomerRepository());

class CustomerRepository {
  Future<List<CustomerModel>> fetchCustomers() async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    return List<CustomerModel>.from(
      MockDataStore.customers.where((c) => c.isActive),
    );

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final res = await SupabaseService.client
        .from('customers')
        .select()
        .eq('is_active', true)
        .order('name');
    return (res as List).map((e) => CustomerModel.fromJson(e)).toList();
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    final newCustomer = customer.copyWith(
      id: 'c-${MockDataStore.customers.length + 1}',
      vendorId: 'vendor-1',
      createdAt: DateTime.now(),
    );
    MockDataStore.customers.add(newCustomer);
    return newCustomer;

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final data = customer.toJson();
    final res =
        await SupabaseService.client.from('customers').insert(data).select().single();
    return CustomerModel.fromJson(res);
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    final index = MockDataStore.customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      MockDataStore.customers[index] = customer;
    }
    return customer;

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final res = await SupabaseService.client
        .from('customers')
        .update(customer.toJson())
        .eq('id', customer.id)
        .select()
        .single();
    return CustomerModel.fromJson(res);
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<void> deactivateCustomer(String customerId) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    final index = MockDataStore.customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      MockDataStore.customers[index] =
          MockDataStore.customers[index].copyWith(isActive: false);
    }

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    await SupabaseService.client
        .from('customers')
        .update({'is_active': false})
        .eq('id', customerId);
    // ───────────────────────────────────────────────────────────────
    */
  }
}
