import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/database/mock_data.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/manager_scaffold.dart';
import '../../../manager_portal/data/repositories/customer_repository.dart';
import '../../data/repositories/delivery_repository.dart';
import '../providers/delivery_provider.dart';

class DeliveryRoutesScreen extends ConsumerStatefulWidget {
  const DeliveryRoutesScreen({super.key});

  @override
  ConsumerState<DeliveryRoutesScreen> createState() =>
      _DeliveryRoutesScreenState();
}

class _DeliveryRoutesScreenState extends ConsumerState<DeliveryRoutesScreen> {
  static const Color _darkBrown = Color(0xFF3D2314);
  static const Color _mediumBrown = Color(0xFF5A3E2B);
  static const Color _subText = Color(0xFF6E5647);

  String _selectedSession = 'all'; // 'all', 'morning', 'evening'

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(deliveryNotifierProvider.notifier).loadTodaysDeliveries(),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phone, String name) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final text = Uri.encodeComponent(
      'Vanakkam $name! Vanthenda Paalkaran delivery is approaching your door now.',
    );
    final Uri launchUri = Uri.parse('https://wa.me/91$clean?text=$text');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveriesState = ref.watch(deliveryNotifierProvider);
    final now = DateTime.now();
    final dateFormatted = DateFormat('d MMM yyyy').format(now);

    return deliveriesState.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: _darkBrown)),
      ),
      error: (e, _) => ManagerScaffold(
        title: "Today's Route",
        subtitle: dateFormatted,
        currentNavIndex: 1,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 44,
                  color: Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load delivery route',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _darkBrown,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _darkBrown, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => ref
                    .read(deliveryNotifierProvider.notifier)
                    .loadTodaysDeliveries(),
                child: Text(
                  'Retry Sync',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: _darkBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (deliveries) {
        final totalStops = deliveries.length;
        final completedStops = deliveries.where((d) => d.isDelivered).length;
        final totalLiters = deliveries.fold<double>(
          0.0,
          (sum, d) => sum + d.effectiveQuantity,
        );
        final deliveredLiters = deliveries
            .where((d) => d.isDelivered)
            .fold<double>(0.0, (sum, d) => sum + d.effectiveQuantity);

        final filteredList = _selectedSession == 'all'
            ? deliveries
            : deliveries.where((d) => d.session == _selectedSession).toList();

        // Sort strictly by route sequence for stop-by-stop road path
        filteredList.sort((a, b) => a.routeSequence.compareTo(b.routeSequence));

        return ManagerScaffold(
          title: "Today's Route",
          subtitle:
              '$dateFormatted • $completedStops/$totalStops Done (${deliveredLiters.toStringAsFixed(1)}L / ${totalLiters.toStringAsFixed(1)}L)',
          currentNavIndex: 1,
          actions: [
            // ── Auto-Sync Live Status Pill ───────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF81C784), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done_rounded,
                    size: 13,
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Synced',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Top Right: Navigate to Dedicated Tracker Screen ─────
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                context.push(AppRoutes.deliveryTracker);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _darkBrown,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _darkBrown.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.analytics_outlined,
                      size: 15,
                      color: Color(0xFFFFF3AB),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Tracker',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFF3AB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              const SizedBox(height: 10),

              // ── Active Path Road Navigation Header ─────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3AB).withValues(alpha: 0.45),
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
                              'PHYSICAL ROUTE PATH (ZERO SEARCH)',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _mediumBrown,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '4th Main Road ➔ 2nd Cross Street (Sequential)',
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
              ),
              const SizedBox(height: 10),

              // ── Shift Selector Filter Chips (Morning / Evening / All) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildSessionChip(
                      label: 'All Stops (${deliveries.length})',
                      value: 'all',
                    ),
                    const SizedBox(width: 8),
                    _buildSessionChip(
                      label:
                          '☀️ Morning (${deliveries.where((d) => d.session == 'morning').length})',
                      value: 'morning',
                    ),
                    const SizedBox(width: 8),
                    _buildSessionChip(
                      label:
                          '🌙 Evening (${deliveries.where((d) => d.session == 'evening').length})',
                      value: 'evening',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Connected Timeline Route List ────────────────────────
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Text(
                          'No deliveries in this shift',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _subText,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final delivery = filteredList[index];
                          final isFirst = index == 0;
                          final isLast = index == filteredList.length - 1;

                          return _SequentialRouteItem(
                            delivery: delivery,
                            isFirst: isFirst,
                            isLast: isLast,
                            onToggleDone: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(deliveryNotifierProvider.notifier)
                                  .toggleDelivery(delivery.id);
                            },
                            onCall: (phone) => _makePhoneCall(phone),
                            onWhatsApp: (phone, name) =>
                                _openWhatsApp(phone, name),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionChip({required String label, required String value}) {
    final isSelected = _selectedSession == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSession = value),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? _darkBrown
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _darkBrown : const Color(0x334A2E18),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? const Color(0xFFFFF3AB) : _darkBrown,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

// ── Connected Timeline Route Item (Stop-by-Stop Line) ──────────────────────
class _SequentialRouteItem extends StatelessWidget {
  final DeliveryModel delivery;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onToggleDone;
  final Function(String phone) onCall;
  final Function(String phone, String name) onWhatsApp;

  static const Color _darkBrown = Color(0xFF3D2314);
  static const Color _cardBg = Color(0xCCFAF6EE);
  static const Color _cardBorder = Color(0x334A2E18);

  const _SequentialRouteItem({
    required this.delivery,
    required this.isFirst,
    required this.isLast,
    required this.onToggleDone,
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

    // Node color state
    Color nodeColor;

    if (isDelivered) {
      nodeColor = const Color(0xFF2E7D32); // Green
    } else if (isOnVacation) {
      nodeColor = const Color(0xFF7B1FA2); // Purple
    } else if (isExtraMilk) {
      nodeColor = const Color(0xFFD97706); // Amber
    } else {
      nodeColor = _darkBrown; // Dark Brown pending
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
                              '🏖️ ON VACATION: ${delivery.vacationNote ?? "Delivery Paused"} (Drive Past)',
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
                              '⚡ EXTRA MILK: +${delivery.extraMilkQty}L Requested (${delivery.extraMilkReason ?? "Extra"})',
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

                  // ── Row 1: Stop #, Customer Name, and Shift Badge ─────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: GoogleFonts.fraunces(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: _darkBrown,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: delivery.session == 'morning'
                              ? const Color(0xFFFFF3AB)
                              : const Color(0xFFEADBCE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          delivery.session.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: _darkBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ── Row 2: Sequential Street Landmark / Note ──────────
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

                  // ── Row 3: Milk Quantity Breakdown & Total Cost ────────
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
                                  ? '0.0L (Paused)'
                                  : isExtraMilk
                                  ? '${delivery.effectiveQuantity}L (Base ${delivery.quantity}L + Extra ${delivery.extraMilkQty}L)'
                                  : '${delivery.quantity}L Milk',
                              style: const TextStyle(
                                fontSize: 12,
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

                  // ── Row 4: Action Buttons (Call, WhatsApp, Done) ────────
                  Row(
                    children: [
                      // Direct Call
                      InkWell(
                        onTap: () => onCall(customer.phone),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x334A2E18)),
                          ),
                          child: const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: _darkBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Direct WhatsApp
                      InkWell(
                        onTap: () => onWhatsApp(customer.phone, customer.name),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF81C784)),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // One-Tap Done / Completed Action Button
                      if (isOnVacation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1BEE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Paused',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A148C),
                            ),
                          ),
                        )
                      else if (isDelivered)
                        InkWell(
                          onTap: onToggleDone,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 15,
                                  color: Color(0xFF2E7D32),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: onToggleDone,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _darkBrown,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _darkBrown.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'DONE',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
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
