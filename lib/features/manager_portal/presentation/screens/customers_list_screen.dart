import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/database/mock_data.dart';
import '../../../../core/routing/app_routes.dart';
import '../providers/customers_provider.dart';
import '../../data/repositories/customer_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/manager_scaffold.dart';
import '../../../../core/widgets/premium_button.dart';

/// Model representing a new customer connection request submitted upon signup
class CustomerSignupRequest {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String area;
  final double morningQty;
  final double eveningQty;
  final String milkType;
  final String deliveryNote;
  final String requestedTime;

  const CustomerSignupRequest({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.area,
    required this.morningQty,
    required this.eveningQty,
    this.milkType = 'Pure Cow Milk',
    this.deliveryNote = 'Leave bag on front door handle',
    required this.requestedTime,
  });
}

class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() =>
      _CustomersListScreenState();
}

class _CustomersListScreenState extends ConsumerState<CustomersListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedArea = 'All';
  String _selectedStatus = 'All';
  bool _isBroadcastExpanded = false;

  /// Pending signup connection requests sent by customers after onboarding
  final List<CustomerSignupRequest> _pendingRequests = [
    const CustomerSignupRequest(
      id: 'req-1',
      name: 'Karthik Raja',
      phone: '98765 43210',
      address: 'No. 14, 4th Street',
      area: 'Anna Nagar',
      morningQty: 1.5,
      eveningQty: 0.5,
      milkType: 'Pure Cow Milk',
      deliveryNote: 'Leave bag on front door handle',
      requestedTime: '5m ago',
    ),
    const CustomerSignupRequest(
      id: 'req-2',
      name: 'Sneha Raman',
      phone: '98402 34567',
      address: 'Flat 4A, Green Meadows Apt',
      area: 'Kilpauk',
      morningQty: 1.0,
      eveningQty: 1.0,
      milkType: 'Pure Buffalo Milk',
      deliveryNote: 'Ring bell upon morning delivery',
      requestedTime: '22m ago',
    ),
    const CustomerSignupRequest(
      id: 'req-3',
      name: 'Arun Kumar',
      phone: '98403 45678',
      address: 'No. 8, Gandhi Road',
      area: 'Shenoy Nagar',
      morningQty: 2.0,
      eveningQty: 0.0,
      milkType: 'Pure Cow Milk',
      deliveryNote: 'Call if gate is locked',
      requestedTime: '1h ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(customerNotifierProvider.notifier).loadCustomers(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _acceptCustomerRequest(CustomerSignupRequest req) {
    int routeSeq = 1;
    String assignedStaff = 'Murugan (Route 1)';

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
                'Assign Route & Approve Household',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2E18),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enroll ${req.name} (${req.area}) into daily delivery roster',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7C5329),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Route Sequence Selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8DB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x334A2E18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route Drop Sequence Number',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A2E18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Color(0xFF4A2E18),
                          ),
                          onPressed: routeSeq > 1
                              ? () => setModalState(() => routeSeq--)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A2E18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Drop #$routeSeq',
                            style: const TextStyle(
                              color: Color(0xFFFAF6EE),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF4A2E18),
                          ),
                          onPressed: () => setModalState(() => routeSeq++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Assigned Staff Selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8DB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x334A2E18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Delivery Staff Partner',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A2E18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: assignedStaff,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAF6EE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0x334A2E18),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0x334A2E18),
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Murugan (Route 1)',
                          child: Text('Murugan (Route 1 - Morning)'),
                        ),
                        DropdownMenuItem(
                          value: 'Suresh (Route 2)',
                          child: Text('Suresh (Route 2 - Morning/Evening)'),
                        ),
                        DropdownMenuItem(
                          value: 'Venkatesh (Route 3)',
                          child: Text('Venkatesh (Route 3 - Express)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => assignedStaff = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Confirm Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    'Confirm & Add to Active Route',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final newCustomer = CustomerModel(
                      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
                      vendorId: 'vendor-1',
                      name: req.name,
                      phone: req.phone,
                      address: req.address,
                      area: req.area,
                      defaultMorningQty: req.morningQty,
                      defaultEveningQty: req.eveningQty,
                      milkTypeId: 'mt-1',
                      isActive: true,
                      createdAt: DateTime.now(),
                      routeSequence: routeSeq,
                      assignedStaffName: assignedStaff,
                      paymentStatus: 'Paid',
                      unitPrice: 50.0,
                    );

                    ref
                        .read(customerNotifierProvider.notifier)
                        .addCustomer(newCustomer);

                    setState(() {
                      _pendingRequests.removeWhere((r) => r.id == req.id);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${req.name} enrolled into Route Sequence #$routeSeq (${req.area})!',
                        ),
                        backgroundColor: const Color(0xFF2E7D32),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _declineCustomerRequest(CustomerSignupRequest req) {
    String selectedReason = 'Outside delivery route coverage';
    final reasons = [
      'Outside delivery route coverage',
      'Delivery slot / capacity full',
      'Duplicate request',
      'Customer requested cancellation',
    ];

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
                'Decline Connection Request',
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2E18),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reason for declining ${req.name}\'s subscription request:',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7C5329),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              ...reasons.map(
                (r) => RadioListTile<String>(
                  dense: true,
                  value: r,
                  groupValue: selectedReason,
                  title: Text(
                    r,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D2314),
                    ),
                  ),
                  activeColor: const Color(0xFF4A2E18),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedReason = val);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _pendingRequests.removeWhere((r) => r.id == req.id);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Request from ${req.name} declined ($selectedReason).',
                        ),
                        backgroundColor: const Color(0xFF4A2E18),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirm Decline',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(customerNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      extendBody: true,
      bottomNavigationBar: const ManagerBottomNavBar(currentIndex: 2),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: customersState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A2E18)),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.warningGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.wifi_tethering_error_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Connection Interrupted',
                    style: AppTypography.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to sync customers at the moment.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PremiumButton(
                    text: 'Try Again',
                    onPressed: () => ref
                        .read(customerNotifierProvider.notifier)
                        .loadCustomers(),
                  ),
                ],
              ),
            ),
            data: (customers) {
              // Extract unique areas
              final Set<String> areaSet = {'All'};
              for (final c in customers) {
                if (c.area.trim().isNotEmpty) {
                  areaSet.add(c.area.trim());
                }
              }
              final areas = areaSet.toList();

              // Active count & Vacation count
              final activeCount = customers
                  .where((c) => c.isActive && !c.isOnVacation)
                  .length;
              final vacationCount = customers
                  .where((c) => c.isOnVacation)
                  .length;

              // Filter by query, area, and status
              final filtered = customers.where((c) {
                final matchesSearch =
                    _searchQuery.isEmpty ||
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    c.phone.contains(_searchQuery) ||
                    c.address.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    c.area.toLowerCase().contains(_searchQuery.toLowerCase());

                final matchesArea =
                    _selectedArea == 'All' ||
                    c.area.toLowerCase() == _selectedArea.toLowerCase();

                final matchesStatus = switch (_selectedStatus) {
                  'Active' => c.isActive && !c.isOnVacation,
                  'On Vacation' => c.isOnVacation,
                  'Overdue' => c.paymentStatus == 'Due',
                  _ => true,
                };

                return matchesSearch && matchesArea && matchesStatus;
              }).toList();

              return Column(
                children: [
                  // ── Top Header ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: Row(
                      children: [
                        if (context.canPop()) ...[
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
                        ],
                        Expanded(
                          child: Text(
                            'Customer CRM',
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF4A2E18),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            '$activeCount Active',
                            style: const TextStyle(
                              color: Color(0xFF4A2E18),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Search Bar & Status Dropdown Filter Row ──────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Search Bar (Translucent white container)
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0x1F4A2E18),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4A2E18,
                                  ).withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (q) =>
                                  setState(() => _searchQuery = q),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF3D2314),
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search customers...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF6B4226),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF6B4226),
                                  size: 22,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Color(0xFF6B4226),
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Filter Dropdown (Compact)
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: _selectedStatus == 'All'
                                ? Colors.white.withValues(alpha: 0.5)
                                : const Color(0xFF4A2E18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0x1F4A2E18),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4A2E18,
                                ).withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              isDense: true,
                              icon: Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 20,
                                color: _selectedStatus == 'All'
                                    ? const Color(0xFF4A2E18)
                                    : const Color(0xFFFAF6EE),
                              ),
                              dropdownColor: const Color(0xFFFAF6EE),
                              borderRadius: BorderRadius.circular(16),
                              selectedItemBuilder: (BuildContext context) {
                                return [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        size: 15,
                                        color: _selectedStatus == 'All'
                                            ? const Color(0xFF4A2E18)
                                            : const Color(0xFFFAF6EE),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'All',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4A2E18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 15,
                                        color: Color(0xFFFAF6EE),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Active',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFFAF6EE),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.beach_access_rounded,
                                        size: 15,
                                        color: Color(0xFFFAF6EE),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Vacation',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFFAF6EE),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 15,
                                        color: Color(0xFFFAF6EE),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Due',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFFAF6EE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ];
                              },
                              items: [
                                DropdownMenuItem(
                                  value: 'All',
                                  child: Text(
                                    'All (${customers.length})',
                                    style: const TextStyle(
                                      color: Color(0xFF4A2E18),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Active',
                                  child: Text(
                                    'Active ($activeCount)',
                                    style: const TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'On Vacation',
                                  child: Text(
                                    'On Vacation ($vacationCount)',
                                    style: const TextStyle(
                                      color: Color(0xFFD97706),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Overdue',
                                  child: Text(
                                    'Overdue (${customers.where((c) => c.paymentStatus == "Due").length})',
                                    style: const TextStyle(
                                      color: Color(0xFFC62828),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedStatus = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Standalone Area Filter Chips Row ─────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: areas.map((area) {
                        final isSelected = _selectedArea == area;
                        final count = area == 'All'
                            ? customers.length
                            : customers
                                  .where(
                                    (c) =>
                                        c.area.toLowerCase() ==
                                        area.toLowerCase(),
                                  )
                                  .length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedArea = area),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4A2E18)
                                    : const Color(0x1F4A2E18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF4A2E18),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                '$area ($count)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFFFAF6EE)
                                      : const Color(0xFF3D2314),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Standalone Customer Request / Notification Bar with Red Badge ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            _isBroadcastExpanded = !_isBroadcastExpanded;
                          });
                        },
                        child: Ink(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A2E18),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4A2E18,
                                ).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Bell with subtle red alert dot
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.notifications_active_rounded,
                                    color: Color(0xFFFAF6EE),
                                    size: 20,
                                  ),
                                  if (_pendingRequests.isNotEmpty)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE53935),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'New Customer Requests',
                                  style: TextStyle(
                                    color: Color(0xFFFAF6EE),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              // Red Action Button / Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _pendingRequests.isNotEmpty
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF7C5329),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    if (_pendingRequests.isNotEmpty)
                                      BoxShadow(
                                        color: const Color(
                                          0xFFE53935,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_pendingRequests.length} New',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      _isBroadcastExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Scrollable Dropdown Customer Requests Panel ───────────────
                  if (_isBroadcastExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 360),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0x334A2E18),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF4A2E18,
                              ).withValues(alpha: 0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _pendingRequests.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8F5E9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Color(0xFF2E7D32),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'All customer requests handled!',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4A2E18),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'New customer signup requests will appear here.',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF5C4033),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Pending Customer Connection Requests',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF4A2E18),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        Text(
                                          '${_pendingRequests.length} Waiting',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFE53935),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...List.generate(_pendingRequests.length, (
                                      index,
                                    ) {
                                      final req = _pendingRequests[index];
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAF6EE),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: const Color(0x2E4A2E18),
                                            width: 1.1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF4A2E18,
                                              ).withValues(alpha: 0.04),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Top Row: Name, Time, Area Badge
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: const Color(
                                                    0xFF4A2E18,
                                                  ),
                                                  child: Text(
                                                    req.name.isNotEmpty
                                                        ? req.name[0]
                                                              .toUpperCase()
                                                        : 'C',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        req.name,
                                                        style: const TextStyle(
                                                          fontSize: 13.5,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                            0xFF3D2314,
                                                          ),
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        'Signed up • ${req.requestedTime}',
                                                        style: const TextStyle(
                                                          fontSize: 10.5,
                                                          color: Color(
                                                            0xFF8C7355,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF4A2E18,
                                                    ).withValues(alpha: 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    req.area,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF4A2E18),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            // Details Box: Address, Quota, Milk Type
                                            Container(
                                              padding: const EdgeInsets.all(9),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFE8DB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(
                                                    0x1F4A2E18,
                                                  ),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        size: 13,
                                                        color: Color(
                                                          0xFF7C5329,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          req.address,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 11.5,
                                                                color: Color(
                                                                  0xFF3D2314,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .water_drop_outlined,
                                                        size: 13,
                                                        color: Color(
                                                          0xFF1976D2,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          '${req.milkType} (@ ₹50/L) • Morning: ${req.morningQty}L | Evening: ${req.eveningQty}L • ~₹${((req.morningQty + req.eveningQty) * 50).toStringAsFixed(0)}/day',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 11.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Color(
                                                                  0xFF2E1C0E,
                                                                ),
                                                              ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (req
                                                      .deliveryNote
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .sticky_note_2_outlined,
                                                          size: 13,
                                                          color: Color(
                                                            0xFFD97706,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'Note: ${req.deliveryNote}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 11,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  color: Color(
                                                                    0xFF7C5329,
                                                                  ),
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  const SizedBox(height: 6),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: InkWell(
                                                      onTap: () =>
                                                          _makePhoneCall(
                                                            req.phone,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 3.5,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFE8F5E9,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color: const Color(
                                                              0xFFA5D6A7,
                                                            ),
                                                            width: 0.9,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons.phone,
                                                              size: 12,
                                                              color: Color(
                                                                0xFF1B5E20,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              req.phone,
                                                              style: const TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Color(
                                                                  0xFF1B5E20,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            // Action Buttons: Decline & Accept (Below Details Box)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () =>
                                                      _declineCustomerRequest(
                                                        req,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 11,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0x0D4A2E18,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0x334A2E18,
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Decline',
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF5C4033,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                InkWell(
                                                  onTap: () =>
                                                      _acceptCustomerRequest(
                                                        req,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF2E7D32,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              const Color(
                                                                0xFF2E7D32,
                                                              ).withValues(
                                                                alpha: 0.3,
                                                              ),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.check,
                                                          size: 13,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Accept & Add',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                      ),
                    ),

                  const SizedBox(height: 4),

                  // ── Customer List View ───────────────────────────────────────
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0x40FAF6EE),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0x334A2E18),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_search_outlined,
                                    size: 42,
                                    color: Color(0xFF8C7355),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No Customers in this area'
                                      : 'No results for "$_searchQuery"',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5C4033),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFF4A2E18),
                            onRefresh: () async => ref
                                .read(customerNotifierProvider.notifier)
                                .loadCustomers(),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) => _CustomerCard(
                                customer: filtered[i],
                                onTap: () => context.push(
                                  AppRoutes.customerProfile,
                                  extra: filtered[i],
                                ),
                                onLongPress: () => _showCustomerDetailsSheet(
                                  context,
                                  filtered[i],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCustomerDetailsSheet(BuildContext context, CustomerModel customer) {
    final dailyTotal = customer.defaultMorningQty + customer.defaultEveningQty;
    final dailyCost = dailyTotal * 50.0;
    final monthlyCost = dailyCost * 30;
    final assignedVendor = MockDataStore.getVendorForArea(customer.area);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header: Avatar, Name, and Status Badge
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : '?',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: customer.isActive
                                  ? AppColors.secondary
                                  : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            customer.isActive ? 'Active Customer' : 'Inactive',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: customer.isActive
                                  ? AppColors.secondary
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Tappable Assigned Vendor Tile ─────────────────────
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _showVendorDetailsSheet(context, assignedVendor);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ASSIGNED VENDOR (TAP FOR DETAILS)',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            assignedVendor.businessName,
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact & Address Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.phone_outlined,
                    'Phone Number',
                    customer.phone.isNotEmpty
                        ? '+91 ${customer.phone}'
                        : 'Not Provided',
                  ),
                  const Divider(height: 16),
                  _detailRow(
                    Icons.location_on_outlined,
                    'Delivery Area',
                    customer.area.isNotEmpty
                        ? customer.area
                        : 'Unassigned Area',
                  ),
                  if (customer.address.isNotEmpty) ...[
                    const Divider(height: 16),
                    _detailRow(
                      Icons.home_outlined,
                      'Full Address',
                      customer.address,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Daily Milk Quotas & Cost Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _quotaBox(
                        'Morning Delivery',
                        '${customer.defaultMorningQty} L',
                        Icons.wb_sunny_outlined,
                        AppColors.warning,
                      ),
                      _quotaBox(
                        'Evening Delivery',
                        '${customer.defaultEveningQty} L',
                        Icons.nights_stay_outlined,
                        AppColors.primaryLight,
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily: ${dailyTotal.toStringAsFixed(1)}L (₹${dailyCost.toStringAsFixed(0)}/day)',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Est. Monthly: ${(dailyTotal * 30).toStringAsFixed(0)}L (₹${monthlyCost.toStringAsFixed(0)}/mo)',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '₹50 / Liter',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── View Milk Card & Delivery Log Button ─────────────
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _showCustomerMilkCardSheet(context, customer);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VIEW MILK CARD & BILLING LOGS',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Daily Deliveries, Volumes & Monthly Bill',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons: Pause, Edit Quota
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.beach_access_outlined, size: 18),
                    label: const Text('Pause Milk'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(AppRoutes.vacation);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Quota'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Edit quota for ${customer.name} opened',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Customer Individual Milk Card & Monthly Ledger Modal ────────────────
  void _showCustomerMilkCardSheet(
    BuildContext context,
    CustomerModel customer,
  ) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);
    final dailyTotal = customer.defaultMorningQty + customer.defaultEveningQty;
    final totalMonthLiters = dailyTotal * now.day;
    final totalBill = totalMonthLiters * 50.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header: Customer + Month
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${customer.name}\'s Milk Card',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$monthName • ${customer.area}',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Active Ledger',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 4 Stats Grid ──────────────────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _ledgerStatCard(
                    'Delivered to Date',
                    '${totalMonthLiters.toStringAsFixed(1)} L',
                    Icons.water_drop_outlined,
                    AppColors.primary,
                  ),
                  _ledgerStatCard(
                    'Current Bill',
                    '₹${totalBill.toStringAsFixed(0)}',
                    Icons.receipt_outlined,
                    AppColors.warning,
                  ),
                  _ledgerStatCard(
                    'Morning Quota',
                    '${customer.defaultMorningQty} L / day',
                    Icons.wb_sunny_outlined,
                    AppColors.warning,
                  ),
                  _ledgerStatCard(
                    'Evening Quota',
                    '${customer.defaultEveningQty} L / day',
                    Icons.nights_stay_outlined,
                    AppColors.primaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Daily Deliveries Log Header ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Daily Log',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Rate: ₹50 / Liter',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Day-by-Day Log List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final dayDate = now.subtract(Duration(days: index));
                  final formattedDate = DateFormat(
                    'EEE, d MMM',
                  ).format(dayDate);
                  final isToday = index == 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${dayDate.day}',
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isToday
                                    ? 'Today ($formattedDate)'
                                    : formattedDate,
                                style: AppTypography.textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '☀️ ${customer.defaultMorningQty}L  •  🌙 ${customer.defaultEveningQty}L',
                                    style: AppTypography.textTheme.labelSmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 10.5,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${dailyTotal.toStringAsFixed(1)} L',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                            ),
                            Text(
                              '₹${(dailyTotal * 50).toStringAsFixed(0)}',
                              style: AppTypography.textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.qr_code_2, size: 18),
                      label: const Text('View Bill & UPI'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(AppRoutes.billing);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
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

  Widget _ledgerStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vendor Full Details Bottom Sheet Modal ──────────────────────────────
  void _showVendorDetailsSheet(BuildContext context, VendorModel vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Vendor Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.businessName,
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Owner: ${vendor.ownerName}',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${vendor.rating}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Vendor Stats Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Supply',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vendor.dailyCapacityLiters.toStringAsFixed(0)} L/day',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Buyers',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vendor.activeCustomersCount} Customers',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact & Payment Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.phone_outlined,
                    'Contact Phone',
                    '+91 ${vendor.phone}',
                  ),
                  const Divider(height: 16),
                  _detailRow(Icons.qr_code_2, 'Direct UPI ID', vendor.upiId),
                  const Divider(height: 16),
                  _detailRow(
                    Icons.map_outlined,
                    'Covered Areas',
                    vendor.assignedAreas.join(', '),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action: Close
            PremiumButton(
              text: 'Close Vendor Details',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quotaBox(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.5,
              ),
            ),
            Text(
              value,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CustomerCard({
    required this.customer,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final displayAddress = customer.address.trim().isNotEmpty
        ? (customer.address.contains(customer.area)
              ? customer.address
              : '${customer.address}, ${customer.area}')
        : customer.area;

    final List<String> quotaParts = [];
    if (customer.defaultMorningQty > 0) {
      quotaParts.add('Morning: ${customer.defaultMorningQty}L');
    }
    if (customer.defaultEveningQty > 0) {
      quotaParts.add('Evening: ${customer.defaultEveningQty}L');
    }
    final quotaText = quotaParts.isNotEmpty
        ? quotaParts.join('  |  ')
        : 'No Active Quota';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xCCFAF6EE),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x334A2E18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A2E18).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Name & Route Sequence Badge + Arrow ───────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (customer.routeSequence != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A2E18),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '#${customer.routeSequence}',
                              style: const TextStyle(
                                color: Color(0xFFFAF6EE),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E1C0E),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF7C5329),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Row 2: Phone Number & Staff Name ────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Color(0xFF5C4033),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    customer.phone.startsWith('+91')
                        ? customer.phone
                        : '+91 ${customer.phone}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D2314),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('•', style: TextStyle(color: Color(0xFF8C7355))),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.person_pin_circle_outlined,
                    size: 14,
                    color: Color(0xFF7C5329),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Staff: ${customer.assignedStaffName ?? "Murugan"}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C5329),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Row 3: Address ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF5C4033),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      displayAddress,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5C4033),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Row 4: Quantity of Milk (Only Active Shifts Shown) ──────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE5D6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.water_drop_outlined,
                      size: 14,
                      color: Color(0xFF4A2E18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      quotaText,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A2E18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
