import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryModel {
  final String id;
  final String vendorId;
  final String customerId;
  final String milkTypeId;
  final DateTime deliveryDate;
  final String session; // 'morning' | 'evening'
  final double quantity;
  final double pricePerLiter;
  final double totalAmount;
  final bool isDelivered;
  final bool isExtraMilk;
  final int routeSequence;
  final String? streetNote;
  final double extraMilkQty;
  final String? extraMilkReason;
  final bool isOnVacation;
  final String? vacationNote;
  final DateTime? deliveredAt;
  final String syncStatus; // 'Synced' | 'Pending' | 'Offline'

  const DeliveryModel({
    required this.id,
    required this.vendorId,
    required this.customerId,
    required this.milkTypeId,
    required this.deliveryDate,
    required this.session,
    required this.quantity,
    required this.pricePerLiter,
    required this.totalAmount,
    required this.isDelivered,
    required this.isExtraMilk,
    this.routeSequence = 1,
    this.streetNote,
    this.extraMilkQty = 0.0,
    this.extraMilkReason,
    this.isOnVacation = false,
    this.vacationNote,
    this.deliveredAt,
    this.syncStatus = 'Synced',
  });

  /// Total liters considering extra milk if requested and not on vacation
  double get effectiveQuantity {
    if (isOnVacation) return 0.0;
    return quantity + extraMilkQty;
  }

  /// Total calculated price
  double get effectiveAmount {
    return effectiveQuantity * pricePerLiter;
  }

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
    id: json['id'] as String,
    vendorId: json['vendor_id'] as String? ?? 'vendor-1',
    customerId: json['customer_id'] as String,
    milkTypeId: json['milk_type_id'] as String? ?? 'mt-1',
    deliveryDate: DateTime.parse(json['delivery_date'] as String),
    session: json['session'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    pricePerLiter: (json['price_per_liter'] as num).toDouble(),
    totalAmount: (json['total_amount'] as num).toDouble(),
    isDelivered: json['is_delivered'] as bool? ?? false,
    isExtraMilk: json['is_extra_milk'] as bool? ?? false,
    routeSequence: json['route_sequence'] as int? ?? 1,
    streetNote: json['street_note'] as String?,
    extraMilkQty: (json['extra_milk_qty'] as num?)?.toDouble() ?? 0.0,
    extraMilkReason: json['extra_milk_reason'] as String?,
    isOnVacation: json['is_on_vacation'] as bool? ?? false,
    vacationNote: json['vacation_note'] as String?,
    deliveredAt: json['delivered_at'] != null
        ? DateTime.parse(json['delivered_at'] as String)
        : null,
    syncStatus: json['sync_status'] as String? ?? 'Synced',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendor_id': vendorId,
    'customer_id': customerId,
    'milk_type_id': milkTypeId,
    'delivery_date': deliveryDate.toIso8601String().split('T')[0],
    'session': session,
    'quantity': quantity,
    'price_per_liter': pricePerLiter,
    'total_amount': totalAmount,
    'is_delivered': isDelivered,
    'is_extra_milk': isExtraMilk,
    'route_sequence': routeSequence,
    'street_note': streetNote,
    'extra_milk_qty': extraMilkQty,
    'extra_milk_reason': extraMilkReason,
    'is_on_vacation': isOnVacation,
    'vacation_note': vacationNote,
    'delivered_at': deliveredAt?.toIso8601String(),
    'sync_status': syncStatus,
  };

  DeliveryModel copyWith({
    String? id,
    String? vendorId,
    String? customerId,
    String? milkTypeId,
    DateTime? deliveryDate,
    String? session,
    double? quantity,
    double? pricePerLiter,
    double? totalAmount,
    bool? isDelivered,
    bool? isExtraMilk,
    int? routeSequence,
    String? streetNote,
    double? extraMilkQty,
    String? extraMilkReason,
    bool? isOnVacation,
    String? vacationNote,
    DateTime? deliveredAt,
    String? syncStatus,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      customerId: customerId ?? this.customerId,
      milkTypeId: milkTypeId ?? this.milkTypeId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      session: session ?? this.session,
      quantity: quantity ?? this.quantity,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalAmount: totalAmount ?? this.totalAmount,
      isDelivered: isDelivered ?? this.isDelivered,
      isExtraMilk: isExtraMilk ?? this.isExtraMilk,
      routeSequence: routeSequence ?? this.routeSequence,
      streetNote: streetNote ?? this.streetNote,
      extraMilkQty: extraMilkQty ?? this.extraMilkQty,
      extraMilkReason: extraMilkReason ?? this.extraMilkReason,
      isOnVacation: isOnVacation ?? this.isOnVacation,
      vacationNote: vacationNote ?? this.vacationNote,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

/// Historical fulfillment record for Tracker audit
class DailyHistoryRecord {
  final DateTime date;
  final int totalStops;
  final int completedStops;
  final double totalLitersDispatched;
  final double targetLiters;
  final double collectedAmount;
  final int vacationPausedCount;
  final int extraMilkOrdersCount;
  final bool isFullyCompleted;
  final List<DeliveryModel>? _stops;

  List<DeliveryModel> get stops {
    if (_stops != null && _stops.isNotEmpty) {
      return _stops;
    }
    return DeliveryRepository.generateStopsForDate(
      date: date,
      completedCount: completedStops,
      vacationCount: vacationPausedCount,
      extraCount: extraMilkOrdersCount,
    );
  }

  const DailyHistoryRecord({
    required this.date,
    required this.totalStops,
    required this.completedStops,
    required this.totalLitersDispatched,
    required this.targetLiters,
    required this.collectedAmount,
    required this.vacationPausedCount,
    required this.extraMilkOrdersCount,
    required this.isFullyCompleted,
    List<DeliveryModel>? stops,
  }) : _stops = stops;

  double get completionPercentage {
    if (totalStops == 0) return 100.0;
    return (completedStops / totalStops) * 100.0;
  }
}

final deliveryRepositoryProvider = Provider<DeliveryRepository>(
  (ref) => DeliveryRepository(),
);

class DeliveryRepository {
  // In-memory route path list pre-sorted sequentially for solo vendors
  static final List<DeliveryModel> _routeDeliveries = [
    DeliveryModel(
      id: 'del-1',
      vendorId: 'vendor-1',
      customerId: 'c-1',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'morning',
      quantity: 1.5,
      pricePerLiter: 50.0,
      totalAmount: 75.0,
      isDelivered: true,
      isExtraMilk: false,
      routeSequence: 1,
      streetNote: 'Start of 4th Main Road (Door 14/A)',
      deliveredAt: DateTime.now().subtract(const Duration(minutes: 42)),
      syncStatus: 'Synced',
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
      totalAmount: 125.0,
      isDelivered: false,
      isExtraMilk: true,
      extraMilkQty: 1.0,
      extraMilkReason: 'Festival & Relatives Visit',
      routeSequence: 2,
      streetNote: 'Next door on right (Door 14/B)',
      syncStatus: 'Synced',
    ),
    DeliveryModel(
      id: 'del-3',
      vendorId: 'vendor-1',
      customerId: 'c-3',
      milkTypeId: 'mt-2',
      deliveryDate: DateTime.now(),
      session: 'morning',
      quantity: 2.0,
      pricePerLiter: 60.0,
      totalAmount: 0.0,
      isDelivered: false,
      isExtraMilk: false,
      isOnVacation: true,
      vacationNote: 'Out of town (1 Oct – 5 Oct)',
      routeSequence: 3,
      streetNote: 'Opposite Corner House (Door 18)',
      syncStatus: 'Synced',
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
      routeSequence: 4,
      streetNote: 'Turn into 2nd Cross Street (Door 7)',
      syncStatus: 'Synced',
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
      totalAmount: 50.0,
      isDelivered: false,
      isExtraMilk: true,
      extraMilkQty: 0.5,
      extraMilkReason: 'Need extra 500ml for morning sweets',
      routeSequence: 5,
      streetNote: 'Near Ganesh Temple (Door 55)',
      syncStatus: 'Synced',
    ),
    DeliveryModel(
      id: 'del-6',
      vendorId: 'vendor-1',
      customerId: 'c-6',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'morning',
      quantity: 2.0,
      pricePerLiter: 50.0,
      totalAmount: 100.0,
      isDelivered: false,
      isExtraMilk: false,
      routeSequence: 6,
      streetNote: 'End of 2nd Cross (Door 108)',
      syncStatus: 'Synced',
    ),
    // Evening Shift
    DeliveryModel(
      id: 'del-7',
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
      routeSequence: 1,
      streetNote: '4th Main Road (Door 14/A)',
      syncStatus: 'Synced',
    ),
    DeliveryModel(
      id: 'del-8',
      vendorId: 'vendor-1',
      customerId: 'c-4',
      milkTypeId: 'mt-1',
      deliveryDate: DateTime.now(),
      session: 'evening',
      quantity: 1.0,
      pricePerLiter: 50.0,
      totalAmount: 50.0,
      isDelivered: false,
      isExtraMilk: false,
      routeSequence: 2,
      streetNote: '2nd Cross Street (Door 7)',
      syncStatus: 'Synced',
    ),
  ];

  /// Fetches today's delivery itinerary pre-sorted by physical route sequence
  Future<List<DeliveryModel>> fetchTodaysDeliveries() async {
    // Sort strictly by routeSequence so vendor rides in order
    final list = List<DeliveryModel>.from(_routeDeliveries);
    list.sort((a, b) => a.routeSequence.compareTo(b.routeSequence));
    return list;
  }

  /// Mark stop as delivered instantly (Offline-First + Auto Cloud Sync)
  Future<void> markDelivered(String deliveryId) async {
    final index = _routeDeliveries.indexWhere((d) => d.id == deliveryId);
    if (index != -1) {
      _routeDeliveries[index] = _routeDeliveries[index].copyWith(
        isDelivered: true,
        deliveredAt: DateTime.now(),
        syncStatus: 'Synced', // Simulated instant auto-sync
      );
    }
  }

  /// Undo or reset delivery status if tapped by mistake
  Future<void> toggleDeliveryStatus(String deliveryId) async {
    final index = _routeDeliveries.indexWhere((d) => d.id == deliveryId);
    if (index != -1) {
      final current = _routeDeliveries[index].isDelivered;
      _routeDeliveries[index] = _routeDeliveries[index].copyWith(
        isDelivered: !current,
        deliveredAt: !current ? DateTime.now() : null,
        syncStatus: 'Synced',
      );
    }
  }

  /// Automatically generates complete sequential road stops for any historical date
  static List<DeliveryModel> generateStopsForDate({
    required DateTime date,
    required int completedCount,
    required int vacationCount,
    required int extraCount,
  }) {
    return [
      DeliveryModel(
        id: 'hist-${date.day}-1',
        vendorId: 'vendor-1',
        customerId: 'c-1',
        milkTypeId: 'mt-1',
        deliveryDate: date,
        session: 'morning',
        quantity: 1.5,
        pricePerLiter: 50.0,
        totalAmount: 75.0,
        isDelivered: completedCount >= 1,
        isExtraMilk: false,
        routeSequence: 1,
        streetNote: '4th Main Road (Door 14/A)',
        deliveredAt: completedCount >= 1
            ? DateTime(date.year, date.month, date.day, 6, 15)
            : null,
      ),
      DeliveryModel(
        id: 'hist-${date.day}-2',
        vendorId: 'vendor-1',
        customerId: 'c-2',
        milkTypeId: 'mt-1',
        deliveryDate: date,
        session: 'morning',
        quantity: 1.5,
        pricePerLiter: 50.0,
        totalAmount: extraCount > 0 ? 125.0 : 75.0,
        isDelivered: completedCount >= 2,
        isExtraMilk: extraCount > 0,
        extraMilkQty: extraCount > 0 ? 1.0 : 0.0,
        extraMilkReason: extraCount > 0 ? 'Extra milk for cooking' : null,
        routeSequence: 2,
        streetNote: '4th Main Road (Door 14/B)',
        deliveredAt: completedCount >= 2
            ? DateTime(date.year, date.month, date.day, 6, 22)
            : null,
      ),
      DeliveryModel(
        id: 'hist-${date.day}-3',
        vendorId: 'vendor-1',
        customerId: 'c-3',
        milkTypeId: 'mt-2',
        deliveryDate: date,
        session: 'morning',
        quantity: 2.0,
        pricePerLiter: 60.0,
        totalAmount: vacationCount > 0 ? 0.0 : 120.0,
        isDelivered: vacationCount > 0 ? false : completedCount >= 3,
        isExtraMilk: false,
        isOnVacation: vacationCount > 0,
        vacationNote: vacationCount > 0 ? 'Out of town' : null,
        routeSequence: 3,
        streetNote: 'Corner House (Door 18)',
        deliveredAt: (vacationCount == 0 && completedCount >= 3)
            ? DateTime(date.year, date.month, date.day, 6, 30)
            : null,
      ),
      DeliveryModel(
        id: 'hist-${date.day}-4',
        vendorId: 'vendor-1',
        customerId: 'c-4',
        milkTypeId: 'mt-1',
        deliveryDate: date,
        session: 'morning',
        quantity: 1.0,
        pricePerLiter: 50.0,
        totalAmount: 50.0,
        isDelivered: completedCount >= 4,
        isExtraMilk: false,
        routeSequence: 4,
        streetNote: '2nd Cross Street (Door 7)',
        deliveredAt: completedCount >= 4
            ? DateTime(date.year, date.month, date.day, 6, 38)
            : null,
      ),
      DeliveryModel(
        id: 'hist-${date.day}-5',
        vendorId: 'vendor-1',
        customerId: 'c-5',
        milkTypeId: 'mt-1',
        deliveryDate: date,
        session: 'morning',
        quantity: 0.5,
        pricePerLiter: 50.0,
        totalAmount: extraCount > 1 ? 50.0 : 25.0,
        isDelivered: completedCount >= 5,
        isExtraMilk: extraCount > 1,
        extraMilkQty: extraCount > 1 ? 0.5 : 0.0,
        extraMilkReason: extraCount > 1 ? 'Extra milk requested' : null,
        routeSequence: 5,
        streetNote: 'Near Temple (Door 55)',
        deliveredAt: completedCount >= 5
            ? DateTime(date.year, date.month, date.day, 6, 45)
            : null,
      ),
      DeliveryModel(
        id: 'hist-${date.day}-6',
        vendorId: 'vendor-1',
        customerId: 'c-6',
        milkTypeId: 'mt-1',
        deliveryDate: date,
        session: 'morning',
        quantity: 2.0,
        pricePerLiter: 50.0,
        totalAmount: completedCount >= 6 ? 100.0 : 0.0,
        isDelivered: completedCount >= 6,
        isExtraMilk: false,
        routeSequence: 6,
        streetNote: 'End of 2nd Cross (Door 108)',
        deliveredAt: completedCount >= 6
            ? DateTime(date.year, date.month, date.day, 6, 52)
            : null,
      ),
    ];
  }

  /// Historical delivery fulfillment tracker records
  Future<List<DailyHistoryRecord>> fetchDeliveryHistory() async {
    final now = DateTime.now();
    return [
      DailyHistoryRecord(
        date: now.subtract(const Duration(days: 1)),
        totalStops: 6,
        completedStops: 6,
        totalLitersDispatched: 8.5,
        targetLiters: 8.5,
        collectedAmount: 425.0,
        vacationPausedCount: 1,
        extraMilkOrdersCount: 2,
        isFullyCompleted: true,
        stops: [
          DeliveryModel(
            id: 'hist-1-1',
            vendorId: 'vendor-1',
            customerId: 'c-1',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 1)),
            session: 'morning',
            quantity: 1.5,
            pricePerLiter: 50.0,
            totalAmount: 75.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 1,
            streetNote: '4th Main Road (Door 14/A)',
            deliveredAt: now.subtract(
              const Duration(days: 1, hours: 18, minutes: 15),
            ),
          ),
          DeliveryModel(
            id: 'hist-1-2',
            vendorId: 'vendor-1',
            customerId: 'c-2',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 1)),
            session: 'morning',
            quantity: 1.5,
            pricePerLiter: 50.0,
            totalAmount: 125.0,
            isDelivered: true,
            isExtraMilk: true,
            extraMilkQty: 1.0,
            extraMilkReason: 'Extra 1L for Guest Breakfast',
            routeSequence: 2,
            streetNote: '4th Main Road (Door 14/B)',
            deliveredAt: now.subtract(
              const Duration(days: 1, hours: 18, minutes: 22),
            ),
          ),
          DeliveryModel(
            id: 'hist-1-3',
            vendorId: 'vendor-1',
            customerId: 'c-3',
            milkTypeId: 'mt-2',
            deliveryDate: now.subtract(const Duration(days: 1)),
            session: 'morning',
            quantity: 2.0,
            pricePerLiter: 60.0,
            totalAmount: 0.0,
            isDelivered: false,
            isExtraMilk: false,
            isOnVacation: true,
            vacationNote: 'Out of town (1 Oct – 5 Oct)',
            routeSequence: 3,
            streetNote: 'Corner House (Door 18)',
          ),
          DeliveryModel(
            id: 'hist-1-4',
            vendorId: 'vendor-1',
            customerId: 'c-4',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 1)),
            session: 'morning',
            quantity: 1.0,
            pricePerLiter: 50.0,
            totalAmount: 50.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 4,
            streetNote: '2nd Cross Street (Door 7)',
            deliveredAt: now.subtract(
              const Duration(days: 1, hours: 18, minutes: 35),
            ),
          ),
          DeliveryModel(
            id: 'hist-1-5',
            vendorId: 'vendor-1',
            customerId: 'c-5',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 1)),
            session: 'morning',
            quantity: 0.5,
            pricePerLiter: 50.0,
            totalAmount: 50.0,
            isDelivered: true,
            isExtraMilk: true,
            extraMilkQty: 0.5,
            extraMilkReason: 'Extra milk requested',
            routeSequence: 5,
            streetNote: 'Near Temple (Door 55)',
            deliveredAt: now.subtract(
              const Duration(days: 1, hours: 18, minutes: 42),
            ),
          ),
          DeliveryModel(
            id: 'hist-1-6',
            vendorId: 'vendor-1',
            customerId: 'c-6',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 1)),
            session: 'morning',
            quantity: 2.0,
            pricePerLiter: 50.0,
            totalAmount: 100.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 6,
            streetNote: 'End of 2nd Cross (Door 108)',
            deliveredAt: now.subtract(
              const Duration(days: 1, hours: 18, minutes: 50),
            ),
          ),
        ],
      ),
      DailyHistoryRecord(
        date: now.subtract(const Duration(days: 2)),
        totalStops: 6,
        completedStops: 6,
        totalLitersDispatched: 8.0,
        targetLiters: 8.0,
        collectedAmount: 400.0,
        vacationPausedCount: 1,
        extraMilkOrdersCount: 1,
        isFullyCompleted: true,
        stops: [
          DeliveryModel(
            id: 'hist-2-1',
            vendorId: 'vendor-1',
            customerId: 'c-1',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 2)),
            session: 'morning',
            quantity: 1.5,
            pricePerLiter: 50.0,
            totalAmount: 75.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 1,
            streetNote: '4th Main Road (Door 14/A)',
            deliveredAt: now.subtract(
              const Duration(days: 2, hours: 18, minutes: 12),
            ),
          ),
          DeliveryModel(
            id: 'hist-2-2',
            vendorId: 'vendor-1',
            customerId: 'c-2',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 2)),
            session: 'morning',
            quantity: 1.5,
            pricePerLiter: 50.0,
            totalAmount: 75.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 2,
            streetNote: '4th Main Road (Door 14/B)',
            deliveredAt: now.subtract(
              const Duration(days: 2, hours: 18, minutes: 20),
            ),
          ),
          DeliveryModel(
            id: 'hist-2-3',
            vendorId: 'vendor-1',
            customerId: 'c-3',
            milkTypeId: 'mt-2',
            deliveryDate: now.subtract(const Duration(days: 2)),
            session: 'morning',
            quantity: 2.0,
            pricePerLiter: 60.0,
            totalAmount: 0.0,
            isDelivered: false,
            isExtraMilk: false,
            isOnVacation: true,
            vacationNote: 'Out of town',
            routeSequence: 3,
            streetNote: 'Corner House (Door 18)',
          ),
          DeliveryModel(
            id: 'hist-2-4',
            vendorId: 'vendor-1',
            customerId: 'c-4',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 2)),
            session: 'morning',
            quantity: 1.0,
            pricePerLiter: 50.0,
            totalAmount: 50.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 4,
            streetNote: '2nd Cross Street (Door 7)',
            deliveredAt: now.subtract(
              const Duration(days: 2, hours: 18, minutes: 32),
            ),
          ),
          DeliveryModel(
            id: 'hist-2-5',
            vendorId: 'vendor-1',
            customerId: 'c-5',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 2)),
            session: 'morning',
            quantity: 0.5,
            pricePerLiter: 50.0,
            totalAmount: 25.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 5,
            streetNote: 'Near Temple (Door 55)',
            deliveredAt: now.subtract(
              const Duration(days: 2, hours: 18, minutes: 40),
            ),
          ),
          DeliveryModel(
            id: 'hist-2-6',
            vendorId: 'vendor-1',
            customerId: 'c-6',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 2)),
            session: 'morning',
            quantity: 2.0,
            pricePerLiter: 50.0,
            totalAmount: 100.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 6,
            streetNote: 'End of 2nd Cross (Door 108)',
            deliveredAt: now.subtract(
              const Duration(days: 2, hours: 18, minutes: 48),
            ),
          ),
        ],
      ),
      DailyHistoryRecord(
        date: now.subtract(const Duration(days: 3)),
        totalStops: 6,
        completedStops: 5,
        totalLitersDispatched: 7.0,
        targetLiters: 8.5,
        collectedAmount: 350.0,
        vacationPausedCount: 0,
        extraMilkOrdersCount: 0,
        isFullyCompleted: false,
        stops: [
          DeliveryModel(
            id: 'hist-3-1',
            vendorId: 'vendor-1',
            customerId: 'c-1',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 3)),
            session: 'morning',
            quantity: 1.5,
            pricePerLiter: 50.0,
            totalAmount: 75.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 1,
            streetNote: '4th Main Road (Door 14/A)',
            deliveredAt: now.subtract(
              const Duration(days: 3, hours: 18, minutes: 10),
            ),
          ),
          DeliveryModel(
            id: 'hist-3-2',
            vendorId: 'vendor-1',
            customerId: 'c-2',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 3)),
            session: 'morning',
            quantity: 1.5,
            pricePerLiter: 50.0,
            totalAmount: 75.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 2,
            streetNote: '4th Main Road (Door 14/B)',
            deliveredAt: now.subtract(
              const Duration(days: 3, hours: 18, minutes: 19),
            ),
          ),
          DeliveryModel(
            id: 'hist-3-3',
            vendorId: 'vendor-1',
            customerId: 'c-3',
            milkTypeId: 'mt-2',
            deliveryDate: now.subtract(const Duration(days: 3)),
            session: 'morning',
            quantity: 2.0,
            pricePerLiter: 60.0,
            totalAmount: 120.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 3,
            streetNote: 'Corner House (Door 18)',
            deliveredAt: now.subtract(
              const Duration(days: 3, hours: 18, minutes: 27),
            ),
          ),
          DeliveryModel(
            id: 'hist-3-4',
            vendorId: 'vendor-1',
            customerId: 'c-4',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 3)),
            session: 'morning',
            quantity: 1.0,
            pricePerLiter: 50.0,
            totalAmount: 50.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 4,
            streetNote: '2nd Cross Street (Door 7)',
            deliveredAt: now.subtract(
              const Duration(days: 3, hours: 18, minutes: 35),
            ),
          ),
          DeliveryModel(
            id: 'hist-3-5',
            vendorId: 'vendor-1',
            customerId: 'c-5',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 3)),
            session: 'morning',
            quantity: 0.5,
            pricePerLiter: 50.0,
            totalAmount: 25.0,
            isDelivered: true,
            isExtraMilk: false,
            routeSequence: 5,
            streetNote: 'Near Temple (Door 55)',
            deliveredAt: now.subtract(
              const Duration(days: 3, hours: 18, minutes: 42),
            ),
          ),
          DeliveryModel(
            id: 'hist-3-6',
            vendorId: 'vendor-1',
            customerId: 'c-6',
            milkTypeId: 'mt-1',
            deliveryDate: now.subtract(const Duration(days: 3)),
            session: 'morning',
            quantity: 2.0,
            pricePerLiter: 50.0,
            totalAmount: 0.0,
            isDelivered: false,
            isExtraMilk: false,
            routeSequence: 6,
            streetNote: 'End of 2nd Cross (Door 108)',
          ),
        ],
      ),
    ];
  }

  Future<List<DeliveryModel>> fetchCustomerDeliveries({
    required String customerId,
    required DateTime from,
    required DateTime to,
  }) async {
    return _routeDeliveries.where((d) => d.customerId == customerId).toList();
  }

  Future<DeliveryModel> createDelivery(DeliveryModel delivery) async {
    final newDel = delivery.copyWith(
      id: 'del-${_routeDeliveries.length + 1}',
      vendorId: 'vendor-1',
    );
    _routeDeliveries.add(newDel);
    return newDel;
  }

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    double morningLiters = 0;
    double revenueToday = 0;
    int pendingDeliveries = 0;

    for (final d in _routeDeliveries) {
      if (d.session == 'morning') {
        if (d.isDelivered) {
          morningLiters += d.effectiveQuantity;
          revenueToday += d.effectiveAmount;
        } else {
          pendingDeliveries++;
        }
      } else {
        if (d.isDelivered) {
          revenueToday += d.effectiveAmount;
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
      'today_count': _routeDeliveries.length,
      'pending_amount': 38400,
    };
  }
}
