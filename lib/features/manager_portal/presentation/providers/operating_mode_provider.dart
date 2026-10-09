import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BusinessOperatingMode {
  solo, // Single person / Owner delivers themselves
  team, // Multi-user / Has delivery staff
}

enum Gender { male, female, other }

enum BusinessType { soleProprietor, partnership, company }

enum PaymentCycle { daily, weekly, monthly }

class BusinessProfileState {
  // ── Section 1: Personal Profile ──────────────────────────────────
  final String ownerName;
  final String email;
  final String phone;
  final int? age;
  final Gender gender;
  final String preferredLanguage;

  // ── Section 2: Business Details ──────────────────────────────────
  final String dairyName;
  final BusinessType businessType;
  final String address;
  final String routeArea;
  final String workingHoursFrom;
  final String workingHoursTo;
  final List<int> deliveryDays; // 0=Mon … 6=Sun
  final BusinessOperatingMode operatingMode;
  final String fssaiLicense;
  final String gstNumber;

  // ── Section 3: Products, Rates & Payments ────────────────────────
  final double cowMilkRate;
  final double buffaloMilkRate;
  final List<Map<String, dynamic>> extraMilkTypes; // [{name, rate}]
  final List<String> packSizes; // ['250ml','500ml','1L','2L']
  final double minOrderLiters;
  final String upiId;
  final PaymentCycle paymentCycle;
  final bool latePaymentReminder;

  const BusinessProfileState({
    // Personal
    this.ownerName = 'Sundar Rajan',
    this.email = '',
    this.phone = '+91 98765 43210',
    this.age,
    this.gender = Gender.male,
    this.preferredLanguage = 'Tamil',
    // Business
    this.dairyName = 'Sri Krishna Dairy & Milk Supply',
    this.businessType = BusinessType.soleProprietor,
    this.address = '14, North Car Street, Triplicane, Chennai',
    this.routeArea = 'Triplicane West & Royapettah',
    this.workingHoursFrom = '05:00 AM',
    this.workingHoursTo = '09:00 AM',
    this.deliveryDays = const [0, 1, 2, 3, 4, 5, 6],
    this.operatingMode = BusinessOperatingMode.solo,
    this.fssaiLicense = '',
    this.gstNumber = '',
    // Products & Payments
    this.cowMilkRate = 54.0,
    this.buffaloMilkRate = 64.0,
    this.extraMilkTypes = const [],
    this.packSizes = const ['500ml', '1L'],
    this.minOrderLiters = 0.5,
    this.upiId = 'srikrishna.dairy@okaxis',
    this.paymentCycle = PaymentCycle.monthly,
    this.latePaymentReminder = true,
  });

  bool get isSolo => operatingMode == BusinessOperatingMode.solo;

  BusinessProfileState copyWith({
    String? ownerName,
    String? email,
    String? phone,
    int? age,
    Gender? gender,
    String? preferredLanguage,
    String? dairyName,
    BusinessType? businessType,
    String? address,
    String? routeArea,
    String? workingHoursFrom,
    String? workingHoursTo,
    List<int>? deliveryDays,
    BusinessOperatingMode? operatingMode,
    String? fssaiLicense,
    String? gstNumber,
    double? cowMilkRate,
    double? buffaloMilkRate,
    List<Map<String, dynamic>>? extraMilkTypes,
    List<String>? packSizes,
    double? minOrderLiters,
    String? upiId,
    PaymentCycle? paymentCycle,
    bool? latePaymentReminder,
  }) {
    return BusinessProfileState(
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      dairyName: dairyName ?? this.dairyName,
      businessType: businessType ?? this.businessType,
      address: address ?? this.address,
      routeArea: routeArea ?? this.routeArea,
      workingHoursFrom: workingHoursFrom ?? this.workingHoursFrom,
      workingHoursTo: workingHoursTo ?? this.workingHoursTo,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      operatingMode: operatingMode ?? this.operatingMode,
      fssaiLicense: fssaiLicense ?? this.fssaiLicense,
      gstNumber: gstNumber ?? this.gstNumber,
      cowMilkRate: cowMilkRate ?? this.cowMilkRate,
      buffaloMilkRate: buffaloMilkRate ?? this.buffaloMilkRate,
      extraMilkTypes: extraMilkTypes ?? this.extraMilkTypes,
      packSizes: packSizes ?? this.packSizes,
      minOrderLiters: minOrderLiters ?? this.minOrderLiters,
      upiId: upiId ?? this.upiId,
      paymentCycle: paymentCycle ?? this.paymentCycle,
      latePaymentReminder: latePaymentReminder ?? this.latePaymentReminder,
    );
  }
}

class BusinessProfileNotifier extends Notifier<BusinessProfileState> {
  @override
  BusinessProfileState build() {
    return const BusinessProfileState();
  }

  void updateProfile(BusinessProfileState newState) {
    state = newState;
  }

  void setOperatingMode(BusinessOperatingMode mode) {
    state = state.copyWith(operatingMode: mode);
  }

  void patchPersonal({
    String? ownerName,
    String? email,
    String? phone,
    int? age,
    Gender? gender,
    String? preferredLanguage,
  }) {
    state = state.copyWith(
      ownerName: ownerName,
      email: email,
      phone: phone,
      age: age,
      gender: gender,
      preferredLanguage: preferredLanguage,
    );
  }
}

final businessProfileProvider =
    NotifierProvider<BusinessProfileNotifier, BusinessProfileState>(
      BusinessProfileNotifier.new,
    );
