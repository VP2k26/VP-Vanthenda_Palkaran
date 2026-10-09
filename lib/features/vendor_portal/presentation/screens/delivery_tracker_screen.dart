import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/database/mock_data.dart';
import '../../../../core/widgets/manager_scaffold.dart';
import '../../../manager_portal/data/repositories/customer_repository.dart';
import '../../data/repositories/delivery_repository.dart';
import '../providers/delivery_provider.dart';

class DeliveryTrackerScreen extends ConsumerWidget {
  const DeliveryTrackerScreen({super.key});

  static const Color _darkBrown = Color(0xFF3D2314);
  static const Color _subText = Color(0xFF6E5647);
  static const Color _cardBg = Color(0xCCFAF6EE);
  static const Color _cardBorder = Color(0x334A2E18);

  static Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  static Future<void> _openWhatsApp(String phone, String name) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final text = Uri.encodeComponent(
      'Vanakkam $name! Vanthenda Paalkaran delivery report regarding your milk order.',
    );
    final Uri launchUri = Uri.parse('https://wa.me/91$clean?text=$text');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(deliveryNotifierProvider);
    final historyAsync = ref.watch(deliveryHistoryProvider);
    final now = DateTime.now();
    final dateFormatted = DateFormat('d MMMM yyyy').format(now);

    return ManagerScaffold(
      title: 'Fulfillment Tracker',
      subtitle: '$dateFormatted • Daily Audit',
      showBackButton: true,
      currentNavIndex: 1,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card 1: Today's Real-time Fulfillment Gauge ─────────
            deliveriesAsync.when(
              loading: () => Container(
                height: 180,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: _darkBrown),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (deliveries) {
                final totalStops = deliveries.length;
                final completedStops = deliveries
                    .where((d) => d.isDelivered)
                    .length;
                final totalLiters = deliveries.fold<double>(
                  0.0,
                  (sum, d) => sum + d.effectiveQuantity,
                );
                final deliveredLiters = deliveries
                    .where((d) => d.isDelivered)
                    .fold<double>(0.0, (sum, d) => sum + d.effectiveQuantity);
                final completionPct = totalStops > 0
                    ? (completedStops / totalStops * 100).toInt()
                    : 100;
                final vacationCount = deliveries
                    .where((d) => d.isOnVacation)
                    .length;
                final extraMilkCount = deliveries
                    .where((d) => d.isExtraMilk)
                    .length;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _cardBorder, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF3AB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.speed_rounded,
                                    color: _darkBrown,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Today's Live Dispatch",
                                    style: GoogleFonts.fraunces(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _darkBrown,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: completionPct == 100
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFF3AB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$completionPct% Done',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: completionPct == 100
                                    ? const Color(0xFF1B5E20)
                                    : _darkBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalStops > 0
                              ? completedStops / totalStops
                              : 1.0,
                          minHeight: 11,
                          backgroundColor: const Color(0xFFE0D5C3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            _darkBrown,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Two Column Stat Boxes
                      Row(
                        children: [
                          _buildMetricBox(
                            title: 'Drops Done',
                            value: '$completedStops / $totalStops',
                            icon: Icons.check_circle_outline_rounded,
                            color: const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 10),
                          _buildMetricBox(
                            title: 'Volume Dispatched',
                            value:
                                '${deliveredLiters.toStringAsFixed(1)}L / ${totalLiters.toStringAsFixed(1)}L',
                            icon: Icons.water_drop_outlined,
                            color: const Color(0xFF1565C0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Event Summary Row
                      Row(
                        children: [
                          _buildMetricBox(
                            title: 'Vacation Paused',
                            value: '$vacationCount Stops',
                            icon: Icons.beach_access_rounded,
                            color: const Color(0xFF6A1B9A),
                          ),
                          const SizedBox(width: 10),
                          _buildMetricBox(
                            title: 'Extra Milk Added',
                            value: '$extraMilkCount Orders',
                            icon: Icons.bolt_rounded,
                            color: const Color(0xFFD97706),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Section 2: Historical Delivery Audit Log ────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        color: _darkBrown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Past Days Delivery Audit',
                          style: GoogleFonts.fraunces(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _darkBrown,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tap any past day below to view its full route path',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _subText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            historyAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: _darkBrown),
                ),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Could not load historical records',
                  style: GoogleFonts.outfit(color: _subText),
                ),
              ),
              data: (records) {
                if (records.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No past delivery logs available',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _subText,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _HistoryCard(
                    record: records[i],
                    onTap: () => _showDayRouteAuditSheet(context, records[i]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x224A2E18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: _subText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: _darkBrown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayRouteAuditSheet(
    BuildContext context,
    DailyHistoryRecord record,
  ) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DayRouteAuditModalSheet(record: record),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DailyHistoryRecord record;
  final VoidCallback onTap;

  static const Color _darkBrown = Color(0xFF3D2314);
  static const Color _cardBg = Color(0xCCFAF6EE);
  static const Color _cardBorder = Color(0x334A2E18);

  const _HistoryCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM yyyy').format(record.date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cardBorder, width: 1.1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: record.isFullyCompleted
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3AB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  record.isFullyCompleted
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                  color: record.isFullyCompleted
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.fraunces(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _darkBrown,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record.completedStops}/${record.totalStops} Stops • ${record.totalLitersDispatched}L • ₹${record.collectedAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6E5647),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: record.isFullyCompleted
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${record.completionPercentage.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8D6E53),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Full Historical Day Route Audit Breakdown Modal ─────────────────────────
class _DayRouteAuditModalSheet extends StatelessWidget {
  final DailyHistoryRecord record;

  static const Color _darkBrown = Color(0xFF3D2314);
  static const Color _mediumBrown = Color(0xFF5A3E2B);
  static const Color _subText = Color(0xFF6E5647);
  static const Color _sheetBg = Color(0xFFF9F5EE);

  const _DayRouteAuditModalSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEEE, d MMMM yyyy').format(record.date);
    final stops = record.stops;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _sheetBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag Handle ─────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBB8A2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // ── Header Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: record.isFullyCompleted
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFFF3AB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  record.isFullyCompleted
                                      ? '✅ 100% COMPLETED'
                                      : '⚠️ PARTIAL DISPATCH',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: record.isFullyCompleted
                                        ? const Color(0xFF1B5E20)
                                        : _darkBrown,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Historical Audit',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _subText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatted,
                            style: GoogleFonts.fraunces(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _darkBrown,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: _darkBrown),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0x224A2E18)),

              // ── Scrollable Route Content ────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                  children: [
                    // ── Summary Cards Grid ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0x334A2E18),
                          width: 1.1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildMetricItem(
                                label: 'Completed Drops',
                                value:
                                    '${record.completedStops} / ${record.totalStops}',
                                icon: Icons.check_circle_outline_rounded,
                                color: const Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 10),
                              _buildMetricItem(
                                label: 'Volume Delivered',
                                value: '${record.totalLitersDispatched} Liters',
                                icon: Icons.water_drop_outlined,
                                color: const Color(0xFF1565C0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMetricItem(
                                label: 'Amount Collected',
                                value:
                                    '₹${record.collectedAmount.toStringAsFixed(0)}',
                                icon: Icons.currency_rupee_rounded,
                                color: _darkBrown,
                              ),
                              const SizedBox(width: 10),
                              _buildMetricItem(
                                label: 'Vacation / Extra',
                                value:
                                    '${record.vacationPausedCount} Paused • ${record.extraMilkOrdersCount} Extra',
                                icon: Icons.info_outline_rounded,
                                color: const Color(0xFFD97706),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Physical Route Path Banner ──────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3AB).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE0CA92),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.alt_route_rounded,
                            size: 20,
                            color: _darkBrown,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DISTRIBUTION ROUTE ROAD PATH (TRACKED)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: _mediumBrown,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  '4th Main Road ➔ 2nd Cross Street (Stop Sequence)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _darkBrown,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Stop-by-Stop Connected Route Items ──────────────
                    if (stops.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No stop breakdown details available for this day.',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _subText,
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(stops.length, (index) {
                        final stop = stops[index];
                        final isFirst = index == 0;
                        final isLast = index == stops.length - 1;

                        return _SequentialHistoryRouteItem(
                          delivery: stop,
                          isFirst: isFirst,
                          isLast: isLast,
                          onCall: (phone) =>
                              DeliveryTrackerScreen._makePhoneCall(phone),
                          onWhatsApp: (phone, name) =>
                              DeliveryTrackerScreen._openWhatsApp(phone, name),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x224A2E18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _subText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: _darkBrown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Connected Timeline Route Item for Historical Audit ───────────────────────
class _SequentialHistoryRouteItem extends StatelessWidget {
  final DeliveryModel delivery;
  final bool isFirst;
  final bool isLast;
  final Function(String phone) onCall;
  final Function(String phone, String name) onWhatsApp;

  static const Color _darkBrown = Color(0xFF3D2314);
  static const Color _mediumBrown = Color(0xFF5A3E2B);
  static const Color _cardBg = Color(0xCCFAF6EE);
  static const Color _cardBorder = Color(0x334A2E18);

  const _SequentialHistoryRouteItem({
    required this.delivery,
    required this.isFirst,
    required this.isLast,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final customer = MockDataStore.customers.firstWhere(
      (c) => c.id == delivery.customerId,
      orElse: () => CustomerModel(
        id: delivery.customerId,
        vendorId: delivery.vendorId,
        name: 'Customer #${delivery.customerId}',
        phone: '9840123456',
        address: 'Main Road',
        area: 'Anna Nagar',
        defaultMorningQty: 1.0,
        defaultEveningQty: 0.0,
        milkTypeId: 'mt-1',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );

    final isDelivered = delivery.isDelivered;
    final isOnVacation = delivery.isOnVacation;
    final isExtraMilk = delivery.isExtraMilk;

    Color nodeColor;
    if (isDelivered) {
      nodeColor = const Color(0xFF2E7D32); // Green
    } else if (isOnVacation) {
      nodeColor = const Color(0xFF7B1FA2); // Purple
    } else if (isExtraMilk) {
      nodeColor = const Color(0xFFD97706); // Amber
    } else {
      nodeColor = const Color(0xFFC62828); // Red (Missed)
    }

    String? deliveryTimeText;
    if (delivery.deliveredAt != null) {
      deliveryTimeText = DateFormat('h:mm a').format(delivery.deliveredAt!);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── The Left Connected Route Path Line ────────────────────
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // Top vertical connecting line
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 2.5,
                    color: isFirst
                        ? Colors.transparent
                        : const Color(0xFFC7B79E),
                  ),
                ),
                // Sequential Stop Node Circle Badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: nodeColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isDelivered
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '#${delivery.routeSequence}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                // Bottom vertical connecting line
                Expanded(
                  flex: 2,
                  child: Container(
                    width: 2.5,
                    color: isLast
                        ? Colors.transparent
                        : const Color(0xFFC7B79E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // ── Right Main Card ──────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isOnVacation
                    ? const Color(0xFFF7F2FA)
                    : isDelivered
                    ? const Color(0xFFF3F8F4)
                    : _cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDelivered
                      ? const Color(0xFF81C784)
                      : isOnVacation
                      ? const Color(0xFFCE93D8)
                      : _cardBorder,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _darkBrown.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Real-time Alert Banners (Vacation or Extra Milk) ──
                  if (isOnVacation) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCE93D8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.beach_access_rounded,
                            size: 14,
                            color: Color(0xFF7B1FA2),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '🏖️ ON VACATION: ${delivery.vacationNote ?? "Delivery Paused"}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6A1B9A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (isExtraMilk && !isOnVacation) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFD54F)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 15,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '⚡ EXTRA MILK: +${delivery.extraMilkQty}L (${delivery.extraMilkReason ?? "Extra"})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Row 1: Customer Name & Status Badge ─────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: GoogleFonts.fraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _darkBrown,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isDelivered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF81C784),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                deliveryTimeText != null
                                    ? 'Delivered $deliveryTimeText'
                                    : 'Delivered',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isOnVacation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFCE93D8),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            '🏖️ Paused',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFEF9A9A),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Missed',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFC62828),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ── Row 2: Street Landmark / Location ──────────────
                  if (delivery.streetNote != null ||
                      customer.address.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Color(0xFF7C5329),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            delivery.streetNote ?? customer.address,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6E5647),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // ── Row 3: Milk Quantity Breakdown & Amount ────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBE5D6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.water_drop_outlined,
                              size: 14,
                              color: _darkBrown,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isOnVacation
                                  ? '0.0L (Vacation Paused)'
                                  : isExtraMilk
                                  ? '${delivery.effectiveQuantity}L (${delivery.quantity}L Base + ${delivery.extraMilkQty}L Extra)'
                                  : '${delivery.quantity}L Milk',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: _darkBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isOnVacation
                            ? '₹0'
                            : '₹${delivery.effectiveAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _darkBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Row 4: Contact Action Buttons ──────────────────
                  Row(
                    children: [
                      InkWell(
                        onTap: () => onCall(customer.phone),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x334A2E18)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: _darkBrown,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Call',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _darkBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => onWhatsApp(customer.phone, customer.name),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF81C784)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 14,
                                color: Color(0xFF2E7D32),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'WhatsApp',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Stop #${delivery.routeSequence}',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _mediumBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
