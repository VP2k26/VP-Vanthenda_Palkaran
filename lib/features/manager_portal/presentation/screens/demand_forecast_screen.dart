import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/demand_forecast.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/manager_scaffold.dart';

part 'demand_forecast_screen.g.dart';

@riverpod
Future<List<DemandForecast>> demandForecast(DemandForecastRef ref) async {
  return DemandForecastingService.forecastTomorrow();
}

class DemandForecastScreen extends ConsumerWidget {
  const DemandForecastScreen({super.key});

  // Brand palette
  static const _dark = Color(0xFF4A2E18);
  static const _mid = Color(0xFF7C5329);
  static const _cream = Color(0xFFEFE8DB);
  static const _border = Color(0x334A2E18);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(demandForecastProvider);

    return ManagerScaffold(
      title: 'Demand Forecast',
      subtitle: "Tomorrow's predicted delivery needs",
      titleIcon: Icons.trending_up_rounded,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: _dark),
          onPressed: () => ref.invalidate(demandForecastProvider),
        ),
      ],
      body: forecastAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _dark)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text('Could not load forecast',
                  style: AppTypography.textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(demandForecastProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (forecasts) {
          if (forecasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up_outlined,
                      size: 64, color: Color(0xFFD4B896)),
                  const SizedBox(height: 16),
                  Text('No delivery data to forecast from',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(color: _mid)),
                ],
              ),
            );
          }

          double totalMorning = 0;
          double totalEvening = 0;
          for (final f in forecasts) {
            totalMorning += f.predictedMorningQty;
            totalEvening += f.predictedEveningQty;
          }

          return Column(
            children: [
              // ── Summary Banner ─────────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _cream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryCol(
                      label: 'Tomorrow Total',
                      value: '${(totalMorning + totalEvening).toStringAsFixed(1)}L',
                      color: _dark,
                      fontSize: 26,
                    ),
                    Container(width: 1, height: 40, color: _border),
                    _SummaryCol(
                      label: 'Morning',
                      value: '${totalMorning.toStringAsFixed(1)}L',
                      color: const Color(0xFFD97706),
                      fontSize: 20,
                    ),
                    Container(width: 1, height: 40, color: _border),
                    _SummaryCol(
                      label: 'Evening',
                      value: '${totalEvening.toStringAsFixed(1)}L',
                      color: const Color(0xFF3B82F6),
                      fontSize: 20,
                    ),
                  ],
                ),
              ),

              // ── Per-Customer Forecast List ─────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: forecasts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final f = forecasts[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _cream,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _dark.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                f.customerName.isNotEmpty
                                    ? f.customerName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.fraunces(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _dark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(f.customerName,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _dark,
                                )),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFD97706)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'M: ${f.predictedMorningQty.toStringAsFixed(1)}L',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'E: ${f.predictedEveningQty.toStringAsFixed(1)}L',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double fontSize;

  const _SummaryCol({
    required this.label,
    required this.value,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.fraunces(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF7C5329),
          ),
        ),
      ],
    );
  }
}
