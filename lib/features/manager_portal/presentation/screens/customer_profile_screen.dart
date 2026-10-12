import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/services/whatsapp_reminder_helper.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/billing_repository.dart';
import '../providers/customers_provider.dart';

class ManagerCustomerProfileScreen extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const ManagerCustomerProfileScreen({
    super.key,
    required this.customer,
  });

  @override
  ConsumerState<ManagerCustomerProfileScreen> createState() =>
      _ManagerCustomerProfileScreenState();
}

class _ManagerCustomerProfileScreenState
    extends ConsumerState<ManagerCustomerProfileScreen> {
  late CustomerModel _customer;
  late DateTime _selectedMonth;
  // Delivery status cache for month days: 1 -> 'delivered', 2 -> 'extra', 3 -> 'vacation', etc.
  final Map<int, String> _deliveryDayStatus = {};
  bool _showInvoicesList = false;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _selectedMonth = DateTime.now();
    _initMonthMockDeliveryStatus();
  }

  void _initMonthMockDeliveryStatus() {
    _deliveryDayStatus.clear();
    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    for (int day = 1; day <= daysInMonth; day++) {
      if (day == 3 || day == 4 || day == 5) {
        _deliveryDayStatus[day] = 'extra'; // +1L or special dot
      } else if (day == 24 || day == 25 || day == 28) {
        _deliveryDayStatus[day] = 'vacation'; // slashed / skipped
      } else if (day <= DateTime.now().day && _selectedMonth.month == DateTime.now().month) {
        _deliveryDayStatus[day] = 'delivered'; // checkmark
      } else {
        _deliveryDayStatus[day] = 'scheduled'; // upcoming date
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendWhatsAppReminder(
    CustomerModel customer,
    double totalDue,
  ) async {
    final dueDate = DateFormat('dd MMM yyyy').format(
      DateTime.now().add(const Duration(days: 5)),
    );
    final totalLiters =
        (customer.defaultMorningQty + customer.defaultEveningQty) * 30;

    final mockBill = BillModel(
      id: 'BILL-${customer.id}',
      vendorId: customer.vendorId,
      customerId: customer.id,
      customerName: customer.name,
      billingMonth: _selectedMonth.month,
      billingYear: _selectedMonth.year,
      totalLiters: totalLiters,
      totalAmount: totalDue > 0 ? totalDue : 1500.0,
      amountPaid: 0.0,
      amountDue: totalDue > 0 ? totalDue : 1500.0,
      isPaid: false,
    );

    await WhatsAppReminderHelper.sendWhatsAppReminder(
      phone: customer.phone,
      bill: mockBill,
      customDueDate: dueDate,
    );
  }

  void _showEditQuotaSheet() {
    double morningQty = _customer.defaultMorningQty;
    double eveningQty = _customer.defaultEveningQty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF6EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x444A2E18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Delivery Quotas',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2E18),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Adjust daily morning and evening volumes for ${_customer.name}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7C5329),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Morning Quota Stepper
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8DB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x334A2E18)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined, size: 20, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Text(
                          'Morning Delivery',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF4A2E18)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF4A2E18)),
                          onPressed: morningQty > 0 ? () => setModalState(() => morningQty = (morningQty - 0.5).clamp(0.0, 10.0)) : null,
                        ),
                        Text(
                          '${morningQty.toStringAsFixed(1)} L',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2E1C0E)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4A2E18)),
                          onPressed: () => setModalState(() => morningQty = (morningQty + 0.5).clamp(0.0, 10.0)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Evening Quota Stepper
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8DB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x334A2E18)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.nights_stay_outlined, size: 20, color: Color(0xFF1976D2)),
                        SizedBox(width: 8),
                        Text(
                          'Evening Delivery',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF4A2E18)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF4A2E18)),
                          onPressed: eveningQty > 0 ? () => setModalState(() => eveningQty = (eveningQty - 0.5).clamp(0.0, 10.0)) : null,
                        ),
                        Text(
                          '${eveningQty.toStringAsFixed(1)} L',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2E1C0E)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4A2E18)),
                          onPressed: () => setModalState(() => eveningQty = (eveningQty + 0.5).clamp(0.0, 10.0)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2E18),
                    foregroundColor: const Color(0xFFFAF6EE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final updated = _customer.copyWith(
                      defaultMorningQty: morningQty,
                      defaultEveningQty: eveningQty,
                    );
                    ref.read(customerNotifierProvider.notifier).updateCustomer(updated);
                    setState(() => _customer = updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Subscription quotas updated successfully!'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  },
                  child: const Text('Save Quota Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleVacationSheet() {
    DateTime? startDate = _customer.vacationStartDate ?? DateTime.now().add(const Duration(days: 1));
    DateTime? endDate = _customer.vacationEndDate ?? DateTime.now().add(const Duration(days: 4));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF6EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x444A2E18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Schedule Vacation / Delivery Pause',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2E18),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Deliveries will be paused automatically during this date range',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7C5329),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Dates selector row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 120)),
                        );
                        if (picked != null) {
                          setModalState(() => startDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFE8DB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x334A2E18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date', style: TextStyle(fontSize: 11, color: Color(0xFF7C5329), fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              startDate != null ? DateFormat('dd MMM yyyy').format(startDate!) : 'Select Date',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF3D2314)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? (startDate?.add(const Duration(days: 3)) ?? DateTime.now()),
                          firstDate: startDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 180)),
                        );
                        if (picked != null) {
                          setModalState(() => endDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFE8DB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x334A2E18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date', style: TextStyle(fontSize: 11, color: Color(0xFF7C5329), fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : 'Select Date',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF3D2314)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_customer.vacationStartDate != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(color: Color(0xFFC62828)),
                        ),
                        onPressed: () {
                          final updated = _customer.copyWith(
                            vacationStartDate: null,
                            vacationEndDate: null,
                          );
                          ref.read(customerNotifierProvider.notifier).updateCustomer(updated);
                          setState(() => _customer = updated);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vacation schedule cleared. Deliveries resumed.'),
                              backgroundColor: Color(0xFF4A2E18),
                            ),
                          );
                        },
                        child: const Text('Cancel Pause', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2E18),
                        foregroundColor: const Color(0xFFFAF6EE),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (startDate == null || endDate == null) return;
                        final updated = _customer.copyWith(
                          vacationStartDate: startDate,
                          vacationEndDate: endDate,
                        );
                        ref.read(customerNotifierProvider.notifier).updateCustomer(updated);
                        setState(() => _customer = updated);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Vacation scheduled: ${DateFormat('dd MMM').format(startDate!)} to ${DateFormat('dd MMM').format(endDate!)}',
                            ),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                      },
                      child: const Text('Save Vacation', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;
    final dailyTotal = customer.defaultMorningQty + customer.defaultEveningQty;
    final totalBilled = dailyTotal * customer.unitPrice * 30;
    const totalPaid = 2000.0;
    final currentDue = (totalBilled - totalPaid).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Header with Back Navigation ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF4A2E18),
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Customer Profile: ${customer.name}',
                        style: GoogleFonts.fraunces(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4A2E18),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Profile Content ─────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Card 1: Customer Details Box ───────────────────────
                      _buildProfileCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    customer.name,
                                    style: GoogleFonts.fraunces(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF4A2E18),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (customer.routeSequence != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A2E18),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Drop #${customer.routeSequence}',
                                      style: const TextStyle(
                                        color: Color(0xFFFAF6EE),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Phone Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 16,
                                  color: Color(0xFF5C4033),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    customer.phone.startsWith('+91')
                                        ? customer.phone
                                        : '+91 ${customer.phone}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3D2314),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(
                                    Icons.call_outlined,
                                    size: 20,
                                    color: Color(0xFF4A2E18),
                                  ),
                                  onPressed: () => _makePhoneCall(customer.phone),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Address Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Color(0xFF5C4033),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    customer.address.isNotEmpty
                                        ? '${customer.address}, ${customer.area}'
                                        : 'No. 14, 4th Street, ${customer.area}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5C4033),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Assigned Delivery Staff Partner & Registration Date
                            Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  size: 16,
                                  color: Color(0xFF5C4033),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Staff: ${customer.assignedStaffName ?? "Murugan (Route 1)"} • Joined ${DateFormat("dd MMM yyyy").format(customer.createdAt)}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7C5329),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Delivery Instructions Row
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                  color: Color(0xFF5C4033),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Leave bag on front door handle',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF7C5329),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Vacation Banner if Active
                            if (customer.isOnVacation &&
                                customer.vacationStartDate != null &&
                                customer.vacationEndDate != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFFB74D)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.beach_access_rounded, size: 16, color: Color(0xFFD97706)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'On Scheduled Vacation: ${DateFormat("dd MMM").format(customer.vacationStartDate!)} - ${DateFormat("dd MMM").format(customer.vacationEndDate!)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 2: Subscription Quota Box ─────────────────────
                      _buildProfileCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subscription Quota Box',
                                  style: GoogleFonts.fraunces(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4A2E18),
                                  ),
                                ),
                                Text(
                                  '₹${customer.unitPrice.toStringAsFixed(0)}/L',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    color: Color(0xFF4A2E18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Baseline Quota: ${customer.defaultMorningQty}L Morning / ${customer.defaultEveningQty}L Evening',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3D2314),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '(Pure Cow Milk • Est. ₹${(dailyTotal * customer.unitPrice * 30).toStringAsFixed(0)}/month)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7C5329),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Action Buttons: Edit Quota & Pause Milk
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: const Text('Edit Quotas'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: const BorderSide(color: Color(0xFF4A2E18)),
                                      foregroundColor: const Color(0xFF4A2E18),
                                    ),
                                    onPressed: _showEditQuotaSheet,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.beach_access_outlined, size: 16),
                                    label: Text(customer.isOnVacation ? 'Edit Vacation' : 'Schedule Pause'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A2E18),
                                      foregroundColor: const Color(0xFFFAF6EE),
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _showScheduleVacationSheet,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 3: Digital Milk Card Calendar ─────────────────
                      _buildProfileCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Digital Milk Card Calendar',
                                    style: GoogleFonts.fraunces(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF4A2E18),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF4A2E18), size: 22),
                                  onPressed: () {
                                    setState(() {
                                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
                                      _initMonthMockDeliveryStatus();
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: _showMonthPicker,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Row(
                                      children: [
                                        Text(
                                          DateFormat('MMM yyyy').format(_selectedMonth),
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF7C5329),
                                            decoration: TextDecoration.underline,
                                            decorationStyle: TextDecorationStyle.dotted,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF7C5329)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF4A2E18), size: 22),
                                  onPressed: () {
                                    setState(() {
                                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
                                      _initMonthMockDeliveryStatus();
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Calendar Days Header (Su Mo Tu We Th Fr Sa)
                            const Row(
                              children: [
                                _DayHeader('Su'),
                                _DayHeader('Mo'),
                                _DayHeader('Tu'),
                                _DayHeader('We'),
                                _DayHeader('Th'),
                                _DayHeader('Fr'),
                                _DayHeader('Sa'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Color(0x224A2E18), height: 1),
                            const SizedBox(height: 10),

                            // Calendar Grid
                            _buildMonthGrid(),
                            const SizedBox(height: 10),

                            // Status Legend
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFE8DB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _LegendItem(color: Color(0xFF2E7D32), label: 'Delivered', icon: Icons.check_circle_outline),
                                  _LegendItem(color: Color(0xFF1976D2), label: '+1L Extra', icon: Icons.add_circle_outline),
                                  _LegendItem(color: Color(0xFFD97706), label: 'Vacation', icon: Icons.beach_access_outlined),
                                  _LegendItem(color: Color(0xFF8C7355), label: 'Scheduled', icon: Icons.circle_outlined),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 4: Financial Summary ──────────────────────────
                      _buildProfileCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Financial Summary',
                                  style: GoogleFonts.fraunces(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4A2E18),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() => _showInvoicesList = !_showInvoicesList),
                                  child: Row(
                                    children: [
                                      Text(
                                        _showInvoicesList ? 'Hide Ledgers' : 'Ledgers',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7C5329),
                                        ),
                                      ),
                                      Icon(
                                        _showInvoicesList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: const Color(0xFF7C5329),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFinancialStatBox(
                                    label: 'Total Billed:',
                                    amount: '₹${totalBilled.toStringAsFixed(0)}',
                                    color: const Color(0xFF4A2E18),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildFinancialStatBox(
                                    label: 'Paid:',
                                    amount: '₹${totalPaid.toStringAsFixed(0)}',
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildFinancialStatBox(
                                    label: 'Current Due:',
                                    amount: '₹${currentDue.toStringAsFixed(0)}',
                                    color: currentDue > 0
                                        ? const Color(0xFFC62828)
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Payment method breakdown pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFE8DB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0x224A2E18)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Settled via UPI: ₹1,400 (70%)',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                                  ),
                                  Text(
                                    'Cash: ₹600 (30%)',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5C4033)),
                                  ),
                                ],
                              ),
                            ),
                            if (_showInvoicesList) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Color(0x224A2E18)),
                              const SizedBox(height: 6),
                              const Text('Recent Billing Cycles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A2E18))),
                              const SizedBox(height: 6),
                              _buildInvoiceRow('August 2026', '60 Liters', '₹3,000', 'Paid', const Color(0xFF2E7D32)),
                              _buildInvoiceRow('July 2026', '60 Liters', '₹3,000', 'Paid', const Color(0xFF2E7D32)),
                              _buildInvoiceRow('June 2026', '58 Liters', '₹2,900', 'Paid', const Color(0xFF2E7D32)),
                            ],
                            const SizedBox(height: 16),
                            // Quick Action: WhatsApp reminder trigger
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.chat_outlined, size: 18),
                                label: const Text(
                                  'Send WhatsApp Bill & Reminder',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                onPressed: () =>
                                    _sendWhatsAppReminder(customer, currentDue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String month, String qty, String amount, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(month, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3D2314))),
          Text(qty, style: const TextStyle(fontSize: 11.5, color: Color(0xFF7C5329))),
          Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A2E18))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCCFAF6EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0x334A2E18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2E18).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFinancialStatBox({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0x40FAF6EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x334A2E18),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C5329),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid() {
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    // Sunday is index 0
    final startOffset = firstDayOfMonth.weekday % 7;
    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 38));
              }

              final status = _deliveryDayStatus[dayNum] ?? 'delivered';
              return _buildDayCell(dayNum, status);
            }),
          ),
        );
      }),
    );
  }

  void _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2030, 12),
      helpText: 'Select Month & Year',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
        _initMonthMockDeliveryStatus();
      });
    }
  }

  void _showDayDetailsSheet(int day) {
    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    final dateFormatted = DateFormat('d MMM yyyy').format(date);
    final monthName = DateFormat('MMMM').format(date);
    final cardNo = _customer.routeSequence ?? 42;

    String currentStatus = _deliveryDayStatus[day] ?? 'delivered';
    double initialQty = currentStatus == 'vacation'
        ? 0.0
        : (currentStatus == 'extra' ? _customer.defaultMorningQty + 1.0 : _customer.defaultMorningQty);
    if (initialQty == 0.0 && _customer.defaultMorningQty > 0) {
      initialQty = _customer.defaultMorningQty;
    }

    double adjustedQty = initialQty;
    final double oldQty = currentStatus == 'vacation'
        ? 0.0
        : (currentStatus == 'extra' ? _customer.defaultMorningQty + 1.0 : _customer.defaultMorningQty);
    final double oldTotal = oldQty * _customer.unitPrice;
    String selectedSession = 'Morning';
    String selectedReason = 'Corrected Liter Mistake';
    final noteController = TextEditingController();

    final reasons = [
      'Corrected Liter Mistake',
      'Festival / Event Extra Milk',
      'Spillage / Replacement',
      'Marked as Absent / Skipped (0L)',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF6EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final adjustedTotal = adjustedQty * _customer.unitPrice;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 18,
              right: 18,
              top: 10,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0x444A2E18),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header with Title & Close Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Past Delivery Record',
                              style: GoogleFonts.fraunces(
                                fontSize: 18.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4A2E18),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Customer: ${_customer.name} • Card #$cardNo • Date: $dateFormatted',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7C5329),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF4A2E18), size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Original Entry Logged Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x334A2E18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Original Entry Logged:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A2E18),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recorded on ${DateFormat('d MMM').format(date)}, 06:14 AM – ${_customer.defaultMorningQty.toStringAsFixed(1)}L Cow Milk (Standard Quota)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5C4033),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF90CAF9)),
                          ),
                          child: Text(
                            'Extra Milk Delivered Previously: ${currentStatus == "extra" ? "1.0L" : "0.0L"}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Session Selector Pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFE8DB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x334A2E18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedSession == 'Morning' ? '🌤️ Morning Session' : '🌙 Evening Session',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A2E18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quantity Stepper [-] [ 2.0 L ] [+]
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if (adjustedQty >= 0.5) {
                            setModalState(() {
                              adjustedQty = (adjustedQty - 0.5);
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE8DB),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x334A2E18)),
                          ),
                          child: const Icon(Icons.remove_rounded, color: Color(0xFF4A2E18), size: 22),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '[ ${adjustedQty.toStringAsFixed(1)} L ]',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A2E18),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setModalState(() {
                            adjustedQty = (adjustedQty + 0.5);
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE8DB),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x334A2E18)),
                          ),
                          child: const Icon(Icons.add_rounded, color: Color(0xFF4A2E18), size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Reason Radio Selection Options
                  ...reasons.map((reason) {
                    final isSelected = selectedReason == reason;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedReason = reason;
                          if (reason == 'Marked as Absent / Skipped (0L)') {
                            adjustedQty = 0.0;
                          } else if (adjustedQty == 0.0) {
                            adjustedQty = _customer.defaultMorningQty;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: isSelected ? const Color(0xFF1976D2) : const Color(0xFF8C7355),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF1976D2) : const Color(0xFF3D2314),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // Note for transparency
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3D2314)),
                    decoration: InputDecoration(
                      hintText: 'Add note for customer transparency...\n(e.g., customer took +0.5L extra for tea stall)',
                      hintStyle: const TextStyle(color: Color(0xFF8C7355), fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.6),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0x334A2E18)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A2E18), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Old Total vs Adjusted Total Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE8DB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x334A2E18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Old Total:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7C5329)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${oldTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4A2E18),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA5D6A7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Adjusted Total:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${adjustedTotal.toStringAsFixed(2)} (₹${_customer.unitPrice.toStringAsFixed(0)}/L)',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Warning Notice
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This adjustment automatically updates the customer\'s $monthName month-end bill.',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C5329),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      // Save & Update Ledger
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              setState(() {
                                if (adjustedQty == 0) {
                                  _deliveryDayStatus[day] = 'vacation';
                                } else if (adjustedQty > _customer.defaultMorningQty) {
                                  _deliveryDayStatus[day] = 'extra';
                                } else {
                                  _deliveryDayStatus[day] = 'delivered';
                                }
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Delivery record for Day $day adjusted to ${adjustedQty.toStringAsFixed(1)}L and ledger updated.',
                                  ),
                                  backgroundColor: const Color(0xFF2E7D32),
                                ),
                              );
                            },
                            child: const Text(
                              'Save & Update Ledger',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Delete Record (Mark Skipped)
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFEBEE),
                              foregroundColor: const Color(0xFFC62828),
                              side: const BorderSide(color: Color(0xFFFFCDD2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _deliveryDayStatus[day] = 'vacation';
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Delivery on Day $day marked as skipped (0L).'),
                                  backgroundColor: const Color(0xFFD97706),
                                ),
                              );
                            },
                            child: const Text(
                              'Delete Record\n(Mark Skipped)',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, height: 1.1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCell(int day, String status) {
    Widget iconBadge;
    if (status == 'extra') {
      iconBadge = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 5,
            height: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Text(
            '+1L',
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1976D2),
              height: 1.0,
            ),
          ),
        ],
      );
    } else if (status == 'vacation') {
      iconBadge = const Icon(
        Icons.block_rounded,
        size: 13,
        color: Color(0xFF9E9E9E),
      );
    } else if (status == 'delivered') {
      iconBadge = const Icon(
        Icons.check_rounded,
        size: 13,
        color: Color(0xFF2E7D32),
      );
    } else {
      iconBadge = Text(
        '$day',
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8C7355),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () => _showDayDetailsSheet(day),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0x30FAF6EE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0x224A2E18),
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5C4033),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                iconBadge,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;

  const _DayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A2E18),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

