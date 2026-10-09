import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/mock_data.dart';

class StaffModel {
  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String role;
  final String? passcode;
  final bool isActive;
  final DateTime createdAt;

  const StaffModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    required this.role,
    this.passcode,
    required this.isActive,
    required this.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String? ?? 'vendor-1',
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'delivery',
        passcode: json['passcode'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'role': role,
        'passcode': passcode,
        'is_active': isActive,
      };

  StaffModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? phone,
    String? role,
    String? passcode,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return StaffModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      passcode: passcode ?? this.passcode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

final staffRepositoryProvider =
    Provider<StaffRepository>((ref) => StaffRepository());

class StaffRepository {
  Future<List<StaffModel>> fetchStaff() async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    return List<StaffModel>.from(
      MockDataStore.staff.where((s) => s.isActive),
    );

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final res = await SupabaseService.client
        .from('staff')
        .select()
        .eq('is_active', true)
        .order('name');
    return (res as List).map((e) => StaffModel.fromJson(e)).toList();
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<void> createStaff(StaffModel staff) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    final newStaff = staff.copyWith(
      id: 's-${MockDataStore.staff.length + 1}',
      vendorId: 'vendor-1',
      createdAt: DateTime.now(),
    );
    MockDataStore.staff.add(newStaff);

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    final staffJson = staff.toJson();
    await SupabaseService.client.from('staff').insert(staffJson);
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<void> updateStaff(StaffModel staff) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    final index = MockDataStore.staff.indexWhere((s) => s.id == staff.id);
    if (index != -1) {
      MockDataStore.staff[index] = staff;
    }

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    await SupabaseService.client
        .from('staff')
        .update(staff.toJson())
        .eq('id', staff.id);
    // ───────────────────────────────────────────────────────────────
    */
  }

  Future<void> deactivateStaff(String id) async {
    // ── DEV MOCK DATA MODE ──────────────────────────────────────────
    final index = MockDataStore.staff.indexWhere((s) => s.id == id);
    if (index != -1) {
      MockDataStore.staff[index] =
          MockDataStore.staff[index].copyWith(isActive: false);
    }

    /*
    // ── PRODUCTION SUPABASE QUERY (Uncomment when ready) ───────────
    await SupabaseService.client
        .from('staff')
        .update({'is_active': false})
        .eq('id', id);
    // ───────────────────────────────────────────────────────────────
    */
  }
}
