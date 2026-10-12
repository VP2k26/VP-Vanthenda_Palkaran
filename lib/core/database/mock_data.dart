import '../../features/manager_portal/data/repositories/customer_repository.dart';
import '../../features/manager_portal/data/repositories/billing_repository.dart';
import '../../features/manager_portal/data/repositories/staff_repository.dart';
import '../../features/vendor_portal/data/repositories/delivery_repository.dart';
import '../../features/manager_portal/presentation/screens/milk_types_screen.dart';
// ── Vendor Model ─────────────────────────────────────────────────────────
class VendorModel {
  final String id;
  final String businessName;
  final String ownerName;
  final String phone;
  final String upiId;
  final List<String> assignedAreas;
  final double rating;
  final double dailyCapacityLiters;
  final int activeCustomersCount;

  const VendorModel({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.upiId,
    required this.assignedAreas,
    this.rating = 4.9,
    this.dailyCapacityLiters = 250.0,
    this.activeCustomersCount = 35,
  });
}

/// Central Mock Database Store for Local Dev & Testing without backend
class MockDataStore {
  MockDataStore._();

  // ── Mock Vendors mapped to Localities ────────────────────────────────────
  static final List<VendorModel> vendors = [
    const VendorModel(
      id: 'vendor-1',
      businessName: 'Vanthenda Central Dairy',
      ownerName: 'Vaishal Malu',
      phone: '9840111222',
      upiId: 'paalkaran@oksbi',
      assignedAreas: ['Anna Nagar', 'Kilpauk', 'Shenoy Nagar'],
      rating: 4.9,
      dailyCapacityLiters: 350.0,
      activeCustomersCount: 65,
    ),
    const VendorModel(
      id: 'vendor-2',
      businessName: 'Sri Krishna Dairy Farm',
      ownerName: 'Gopalakrishnan R',
      phone: '9840222333',
      upiId: 'srikrishna@oksbi',
      assignedAreas: ['T Nagar', 'Mylapore', 'Nungambakkam'],
      rating: 4.8,
      dailyCapacityLiters: 220.0,
      activeCustomersCount: 42,
    ),
    const VendorModel(
      id: 'vendor-3',
      businessName: 'Aavin Green Milk Hub',
      ownerName: 'Sundaram P',
      phone: '9840333444',
      upiId: 'aavingreen@oksbi',
      assignedAreas: ['Velachery', 'Adyar', 'Besant Nagar'],
      rating: 4.7,
      dailyCapacityLiters: 280.0,
      activeCustomersCount: 50,
    ),
    const VendorModel(
      id: 'vendor-4',
      businessName: 'Gokulam Fresh Dairy',
      ownerName: 'Karthikeyan M',
      phone: '9840444555',
      upiId: 'gokulam@oksbi',
      assignedAreas: ['Tambaram', 'Chromepet', 'Sanatorium'],
      rating: 4.9,
      dailyCapacityLiters: 190.0,
      activeCustomersCount: 38,
    ),
  ];

  /// Finds the assigned vendor by area name
  static VendorModel getVendorForArea(String area) {
    for (final v in vendors) {
      if (v.assignedAreas.any((a) => a.toLowerCase() == area.toLowerCase())) {
        return v;
      }
    }
    return vendors.first;
  }

  /// Finds a vendor by ID
  static VendorModel getVendorById(String id) {
    return vendors.firstWhere(
      (v) => v.id == id,
      orElse: () => vendors.first,
    );
  }

  // ── Milk (Standard Rate) ────────────────────────────────────────────────
  static double milkPricePerLiter = 50.0;
  static final List<MilkTypeModel> milkTypes = [
    const MilkTypeModel(
      id: 'mt-1',
      vendorId: 'vendor-1',
      name: 'Milk',
      pricePerLiter: 50.0,
      isActive: true,
    ),
  ];

  // ── Customers ───────────────────────────────────────────────────────────
  static final List<CustomerModel> customers = [
    CustomerModel(
      id: 'c-1',
      vendorId: 'vendor-1',
      name: 'Ramesh Kumar',
      phone: '9840123456',
      address: 'No 14, Gandhi Street',
      area: 'Anna Nagar',
      defaultMorningQty: 1.0,
      defaultEveningQty: 0.5,
      milkTypeId: 'mt-1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      routeSequence: 1,
      paymentStatus: 'Paid',
      assignedStaffName: 'Muthu K (Staff #1)',
    ),
    CustomerModel(
      id: 'c-2',
      vendorId: 'vendor-1',
      name: 'Priya Sharma',
      phone: '9840234567',
      address: 'Flat 3B, Sunshine Apts',
      area: 'T Nagar',
      defaultMorningQty: 1.5,
      defaultEveningQty: 0.0,
      milkTypeId: 'mt-1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      routeSequence: 2,
      vacationStartDate: DateTime.now().subtract(const Duration(days: 1)),
      vacationEndDate: DateTime.now().add(const Duration(days: 4)),
      paymentStatus: 'Paid',
      assignedStaffName: 'Muthu K (Staff #1)',
    ),
    CustomerModel(
      id: 'c-3',
      vendorId: 'vendor-1',
      name: 'Anbu Selvan',
      phone: '9840345678',
      address: '22/4, Temple Road',
      area: 'Mylapore',
      defaultMorningQty: 2.0,
      defaultEveningQty: 1.0,
      milkTypeId: 'mt-2',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      routeSequence: 3,
      paymentStatus: 'Due',
      assignedStaffName: 'Karthik S (Staff #2)',
    ),
    CustomerModel(
      id: 'c-4',
      vendorId: 'vendor-1',
      name: 'Deepa Patel',
      phone: '9840456789',
      address: '7, Lake View Avenue',
      area: 'Velachery',
      defaultMorningQty: 1.0,
      defaultEveningQty: 1.0,
      milkTypeId: 'mt-1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      routeSequence: 4,
      paymentStatus: 'Partial',
      assignedStaffName: 'Muthu K (Staff #1)',
    ),
    CustomerModel(
      id: 'c-5',
      vendorId: 'vendor-1',
      name: 'Murugan G',
      phone: '9840567890',
      address: '55, Bazaar Street',
      area: 'Tambaram',
      defaultMorningQty: 0.5,
      defaultEveningQty: 0.5,
      milkTypeId: 'mt-1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      routeSequence: 5,
      paymentStatus: 'Paid',
      assignedStaffName: 'Karthik S (Staff #2)',
    ),
    CustomerModel(
      id: 'c-6',
      vendorId: 'vendor-1',
      name: 'Lakshmi Narayanan',
      phone: '9840678901',
      address: '108, 2nd Main Road',
      area: 'Adyar',
      defaultMorningQty: 2.0,
      defaultEveningQty: 0.0,
      milkTypeId: 'mt-1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
      routeSequence: 6,
      paymentStatus: 'Due',
      assignedStaffName: 'Muthu K (Staff #1)',
    ),
  ];

  // ── Today's Deliveries ───────────────────────────────────────────────────
  static final List<DeliveryModel> deliveries = [
    DeliveryModel(
      id: 'del-1',
      vendorId: 'vendor-1',
      customerId: 'c-1',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'morning',
      quantity: 1.0,
      pricePerLiter: 50.0,
      totalAmount: 50.0,
      isDelivered: true,
      isExtraMilk: false,
    ),
    DeliveryModel(
      id: 'del-2',
      vendorId: 'vendor-1',
      customerId: 'c-2',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'morning',
      quantity: 1.5,
      pricePerLiter: 50.0,
      totalAmount: 75.0,
      isDelivered: true,
      isExtraMilk: false,
    ),
    DeliveryModel(
      id: 'del-3',
      vendorId: 'vendor-1',
      customerId: 'c-3',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'morning',
      quantity: 2.0,
      pricePerLiter: 50.0,
      totalAmount: 100.0,
      isDelivered: false,
      isExtraMilk: false,
    ),
    DeliveryModel(
      id: 'del-4',
      vendorId: 'vendor-1',
      customerId: 'c-4',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'morning',
      quantity: 1.0,
      pricePerLiter: 50.0,
      totalAmount: 50.0,
      isDelivered: false,
      isExtraMilk: false,
    ),
    DeliveryModel(
      id: 'del-5',
      vendorId: 'vendor-1',
      customerId: 'c-5',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'morning',
      quantity: 0.5,
      pricePerLiter: 50.0,
      totalAmount: 25.0,
      isDelivered: false,
      isExtraMilk: false,
    ),
    DeliveryModel(
      id: 'del-6',
      vendorId: 'vendor-1',
      customerId: 'c-1',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'evening',
      quantity: 0.5,
      pricePerLiter: 50.0,
      totalAmount: 25.0,
      isDelivered: false,
      isExtraMilk: false,
    ),
    DeliveryModel(
      id: 'del-7',
      vendorId: 'vendor-1',
      customerId: 'c-3',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'evening',
      quantity: 1.0,
      pricePerLiter: 50.0,
      totalAmount: 50.0,
      isDelivered: false,
      isExtraMilk: false,
    ),
  ];

  // ── Monthly Bills ────────────────────────────────────────────────────────
  static final List<BillModel> bills = [
    BillModel(
      id: 'bill-1',
      vendorId: 'vendor-1',
      customerId: 'c-1',
      customerName: 'Ramesh Kumar',
      billingMonth: DateTime.now().month,
      billingYear: DateTime.now().year,
      totalLiters: 45.0,
      totalAmount: 2250.0,
      amountPaid: 0.0,
      amountDue: 2250.0,
      isPaid: false,
    ),
    BillModel(
      id: 'bill-2',
      vendorId: 'vendor-1',
      customerId: 'c-2',
      customerName: 'Priya Sharma',
      billingMonth: DateTime.now().month,
      billingYear: DateTime.now().year,
      totalLiters: 45.0,
      totalAmount: 2250.0,
      amountPaid: 2250.0,
      amountDue: 0.0,
      isPaid: true,
      paidAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BillModel(
      id: 'bill-3',
      vendorId: 'vendor-1',
      customerId: 'c-3',
      customerName: 'Anbu Selvan',
      billingMonth: DateTime.now().month,
      billingYear: DateTime.now().year,
      totalLiters: 90.0,
      totalAmount: 5400.0,
      amountPaid: 2000.0,
      amountDue: 3400.0,
      isPaid: false,
    ),
    BillModel(
      id: 'bill-4',
      vendorId: 'vendor-1',
      customerId: 'c-4',
      customerName: 'Deepa Patel',
      billingMonth: DateTime.now().month,
      billingYear: DateTime.now().year,
      totalLiters: 60.0,
      totalAmount: 4500.0,
      amountPaid: 0.0,
      amountDue: 4500.0,
      isPaid: false,
    ),
    BillModel(
      id: 'bill-5',
      vendorId: 'vendor-1',
      customerId: 'c-5',
      customerName: 'Murugan G',
      billingMonth: DateTime.now().month,
      billingYear: DateTime.now().year,
      totalLiters: 30.0,
      totalAmount: 1500.0,
      amountPaid: 1500.0,
      amountDue: 0.0,
      isPaid: true,
      paidAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // ── Staff / Delivery Boys ────────────────────────────────────────────────
  static final List<StaffModel> staff = [
    StaffModel(
      id: 's-1',
      vendorId: 'vendor-1',
      name: 'Karthi (Route 1)',
      phone: '9840999001',
      role: 'delivery',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
    StaffModel(
      id: 's-2',
      vendorId: 'vendor-1',
      name: 'Suresh (Route 2)',
      phone: '9840999002',
      role: 'delivery',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    StaffModel(
      id: 's-3',
      vendorId: 'vendor-1',
      name: 'Manikandan (Route 3)',
      phone: '9840999003',
      role: 'delivery',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
  ];

  // ── Helper Methods ───────────────────────────────────────────────────────
  static Map<String, dynamic> getDashboardStats() {
    double morningLiters = 0;
    double revenueToday = 0;
    int pendingDeliveries = 0;

    for (final d in deliveries) {
      if (d.session == 'morning') {
        if (d.isDelivered) {
          morningLiters += d.quantity;
          revenueToday += d.totalAmount;
        } else {
          pendingDeliveries++;
        }
      } else {
        if (d.isDelivered) {
          revenueToday += d.totalAmount;
        } else {
          pendingDeliveries++;
        }
      }
    }

    return {
      'morningLiters': morningLiters,
      'morningTarget': 120.0,
      'revenueToday': revenueToday > 0 ? revenueToday : 3250.0,
      'pendingDeliveries': pendingDeliveries,
    };
  }
}
