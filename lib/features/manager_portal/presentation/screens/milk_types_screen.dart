import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/manager_scaffold.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_card.dart';

// ─── Model ──────────────────────────────────────────────────────────────────

class MilkTypeModel {
  final String id;
  final String vendorId;
  final String name;
  final double pricePerLiter;
  final bool isActive;

  const MilkTypeModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.pricePerLiter,
    required this.isActive,
  });

  factory MilkTypeModel.fromJson(Map<String, dynamic> json) => MilkTypeModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String? ?? 'vendor-1',
        name: json['name'] as String? ?? 'Milk',
        pricePerLiter: (json['price_per_liter'] as num).toDouble(),
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'vendor_id': vendorId,
        'name': name,
        'price_per_liter': pricePerLiter,
        'is_active': isActive,
      };
}

// ─── Provider ────────────────────────────────────────────────────────────────

class MilkTypesNotifier extends Notifier<AsyncValue<List<MilkTypeModel>>> {
  @override
  AsyncValue<List<MilkTypeModel>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    state = AsyncData(
      List<MilkTypeModel>.from(MockDataStore.milkTypes.where((m) => m.isActive)),
    );
  }

  Future<void> updatePrice(double price) async {
    MockDataStore.milkPricePerLiter = price;
    if (MockDataStore.milkTypes.isNotEmpty) {
      final item = MockDataStore.milkTypes.first;
      MockDataStore.milkTypes[0] = MilkTypeModel(
        id: item.id,
        vendorId: item.vendorId,
        name: 'Milk',
        pricePerLiter: price,
        isActive: true,
      );
    }
    await _load();
  }
}

final milkTypesNotifierProvider =
    NotifierProvider<MilkTypesNotifier, AsyncValue<List<MilkTypeModel>>>(
  MilkTypesNotifier.new,
);

// ─── Screen ──────────────────────────────────────────────────────────────────

class MilkTypesScreen extends ConsumerStatefulWidget {
  const MilkTypesScreen({super.key});

  @override
  ConsumerState<MilkTypesScreen> createState() => _MilkTypesScreenState();
}

class _MilkTypesScreenState extends ConsumerState<MilkTypesScreen> {
  final _priceCtrl = TextEditingController(text: '50.0');

  @override
  void initState() {
    super.initState();
    _priceCtrl.text = MockDataStore.milkPricePerLiter.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(milkTypesNotifierProvider);

    return ManagerScaffold(
      title: 'Milk Price Settings',
      subtitle: 'Manage milk types & rates',
      titleIcon: Icons.water_drop_rounded,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.error)),
        ),
        data: (types) {
          final currentPrice = types.isNotEmpty
              ? types.first.pricePerLiter
              : MockDataStore.milkPricePerLiter;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Active Rate Card ─────────────────────────────────
                PremiumCard(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.water_drop,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Milk Rate',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${currentPrice.toStringAsFixed(2)} / Liter',
                              style: AppTypography.textTheme.headlineMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Edit Milk Rate ────────────────────────────────────
                Text(
                  'Update Milk Price',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This standard rate applies to daily milk card records, morning/evening quota calculations, and customer billing.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price per Liter (₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                    suffixText: 'per liter',
                  ),
                ),
                const SizedBox(height: 24),

                PremiumButton(
                  text: 'Save Milk Price',
                  icon: Icons.check,
                  onPressed: () {
                    final newPrice =
                        double.tryParse(_priceCtrl.text.trim()) ?? 0;
                    if (newPrice > 0) {
                      ref
                          .read(milkTypesNotifierProvider.notifier)
                          .updatePrice(newPrice);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Milk price updated to ₹${newPrice.toStringAsFixed(2)}/L!'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
