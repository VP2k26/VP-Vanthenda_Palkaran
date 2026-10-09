================================================================================
VANTHENDA PAALKARAN — MANAGER PORTAL & CORE ARCHITECTURE SPECIFICATION
================================================================================

1. PROJECT STRUCTURE & FILE LOCATIONS
--------------------------------------------------------------------------------
lib/
 ├── main.dart
 ├── core/
 │    ├── theme/
 │    │    └── app_theme.dart                # Design tokens, AppColors, AntigravityCard
 │    ├── upi/
 │    │    └── upi_helper.dart               # Zero-commission dynamic UPI QR string builder
 │    └── routing/
 │         └── app_router.dart               # Complete GoRouter configuration
 └── features/
      └── manager_portal/
           ├── data/
           │    ├── models/
           │    │    ├── customer_model.dart  # Customer schema & serialization
           │    │    └── bill_model.dart      # Billing schema & aggregations
           │    └── repositories/
           │         ├── customer_repository.dart
           │         └── billing_repository.dart
           └── presentation/
                ├── providers/
                │    ├── customers_provider.dart
                │    └── billing_provider.dart
                └── screens/
                     ├── dashboard_screen.dart
                     ├── customers_list_screen.dart
                     ├── milk_card_screen.dart
                     ├── billing_dashboard_screen.dart
                     └── payments_screen.dart


2. CORE DESIGN SYSTEM & TOKENS
File: lib/core/theme/app_theme.dart
--------------------------------------------------------------------------------
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A56DB);
  static const Color gradientStart = Color(0xFF0F172A);
  static const Color gradientEnd = Color(0xFF1E3A8A);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
}

class AntigravityCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AntigravityCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}


3. DATA MODELS
File: lib/features/manager_portal/data/models/customer_model.dart
--------------------------------------------------------------------------------
class CustomerModel {
  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String area;
  final double morningQty;
  final double eveningQty;
  final String milkTypeId;
  final bool isActive;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    required this.area,
    required this.morningQty,
    required this.eveningQty,
    required this.milkTypeId,
    this.isActive = true,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String? ?? '',
        name: json['name'] as String,
        phone: json['phone'] as String,
        area: json['area'] as String? ?? 'General',
        morningQty: (json['morning_qty'] as num).toDouble(),
        eveningQty: (json['evening_qty'] as num).toDouble(),
        milkTypeId: json['milk_type_id'] as String,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendor_id': vendorId,
        'name': name,
        'phone': phone,
        'area': area,
        'morning_qty': morningQty,
        'evening_qty': eveningQty,
        'milk_type_id': milkTypeId,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}

File: lib/features/manager_portal/data/models/bill_model.dart
--------------------------------------------------------------------------------
class BillModel {
  final String id;
  final String customerId;
  final String customerName;
  final int month;
  final int year;
  final double totalLiters;
  final double totalAmount;
  final double amountPaid;
  final double amountDue;
  final bool isPaid;
  final DateTime? paidAt;

  BillModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.month,
    required this.year,
    required this.totalLiters,
    required this.totalAmount,
    this.amountPaid = 0.0,
    required this.amountDue,
    this.isPaid = false,
    this.paidAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        customerName: json['customer_name'] as String? ?? 'Customer',
        month: json['month'] as int,
        year: json['year'] as int,
        totalLiters: (json['total_liters'] as num).toDouble(),
        totalAmount: (json['total_amount'] as num).toDouble(),
        amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
        amountDue: (json['amount_due'] as num).toDouble(),
        isPaid: json['is_paid'] as bool? ?? false,
        paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'customer_name': customerName,
        'month': month,
        'year': year,
        'total_liters': totalLiters,
        'total_amount': totalAmount,
        'amount_paid': amountPaid,
        'amount_due': amountDue,
        'is_paid': isPaid,
        'paid_at': paidAt?.toIso8601String(),
      };
}


4. ZERO-COMMISSION UPI ENGINE
File: lib/core/upi/upi_helper.dart
--------------------------------------------------------------------------------
import 'package:url_launcher/url_launcher.dart';

class UpiPaymentHelper {
  static String buildUpiUri({
    required String upiId,
    required String payeeName,
    required double amount,
    required String billReference,
  }) {
    final encodedName = Uri.encodeComponent(payeeName);
    final encodedNote = Uri.encodeComponent('Milk Bill #$billReference');
    return 'upi://pay?pa=$upiId&pn=$encodedName&am=${amount.toStringAsFixed(2)}&cu=INR&tn=$encodedNote';
  }

  static Future<bool> launchUpiIntent(String upiUri) async {
    final uri = Uri.parse(upiUri);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}


5. STATE NOTIFIERS & PROVIDERS
File: lib/features/manager_portal/presentation/providers/customers_provider.dart
--------------------------------------------------------------------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/customer_model.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final customersProvider = StateNotifierProvider<CustomersNotifier, AsyncValue<List<CustomerModel>>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CustomersNotifier(supabase);
});

class CustomersNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  final SupabaseClient _supabase;
  List<CustomerModel> _allCustomers = [];

  CustomersNotifier(this._supabase) : super(const AsyncValue.loading()) {
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      state = const AsyncValue.loading();
      final data = await _supabase.from('customers').select().order('name');
      _allCustomers = (data as List).map((e) => CustomerModel.fromJson(e)).toList();
      state = AsyncValue.data(_allCustomers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void filterCustomers(String query, {String? area}) {
    final filtered = _allCustomers.where((c) {
      final matchesQuery = c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.phone.contains(query);
      final matchesArea = area == null || area.isEmpty || c.area == area;
      return matchesQuery && matchesArea;
    }).toList();
    state = AsyncValue.data(filtered);
  }
}


6. UI SCREENS
File: lib/features/manager_portal/presentation/screens/dashboard_screen.dart
--------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/customers_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vanthenda Paalkaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('வந்தேந்த பால்காரன் • Manager Hub', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AntigravityCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Today's Dispatch Target", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Chip(label: Text('Morning 45L / 120L', style: TextStyle(fontSize: 12, color: AppColors.primary)), backgroundColor: Color(0xFFEFF6FF)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 0.375,
                      minHeight: 10,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Operations Grid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionTile(context, Icons.people_outline, 'Customer CRM', '/customers', AppColors.primary),
                _buildActionTile(context, Icons.edit_calendar_outlined, 'Daily Milk Card', '/milk-card', AppColors.warning),
                _buildActionTile(context, Icons.receipt_long_outlined, 'Monthly Bills', '/billing', AppColors.success),
                _buildActionTile(context, Icons.qr_code_2, 'Collect UPI', '/payments', Colors.purple),
                _buildActionTile(context, Icons.beach_access_outlined, 'Vacation Mode', '/vacation-mode', Colors.teal),
                _buildActionTile(context, Icons.electric_bolt_outlined, 'Emergency Orders', '/emergency-requests', AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String route, Color accentColor) {
    return AntigravityCard(
      onTap: () => context.push(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: accentColor.withValues(alpha: 0.12),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}


7. ROUTING
File: lib/core/routing/app_router.dart
--------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/manager_portal/presentation/screens/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Customers Screen'))),
    ),
    GoRoute(
      path: '/milk-card',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Milk Card Screen'))),
    ),
    GoRoute(
      path: '/billing',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Billing Dashboard'))),
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Payments Screen'))),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Settings Screen'))),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Path not found: ${state.uri.path}'),
    ),
  ),
);


8. DATABASE SCHEMA (POSTGRESQL / SUPABASE)
--------------------------------------------------------------------------------
-- 1. Customers Table
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES auth.users(id),
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    area TEXT DEFAULT 'General',
    morning_qty NUMERIC(4,2) DEFAULT 0.0,
    evening_qty NUMERIC(4,2) DEFAULT 0.0,
    milk_type_id UUID,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Deliveries Table (Daily Milk Card)
CREATE TABLE deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES auth.users(id),
    customer_id UUID REFERENCES customers(id),
    milk_type_id UUID,
    date DATE NOT NULL,
    session VARCHAR(10) CHECK (session IN ('morning', 'evening')),
    quantity NUMERIC(4,2) NOT NULL,
    price_applied NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'delivered',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Monthly Bills Table
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES auth.users(id),
    customer_id UUID REFERENCES customers(id),
    month INT NOT NULL,
    year INT NOT NULL,
    total_liters NUMERIC(6,2) NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    amount_paid NUMERIC(10,2) DEFAULT 0.0,
    amount_due NUMERIC(10,2) NOT NULL,
    is_paid BOOLEAN DEFAULT false,
    paid_at TIMESTAMPTZ,
    UNIQUE(vendor_id, customer_id, month, year)
);

-- 4. Monthly Bill Generation RPC
CREATE OR REPLACE FUNCTION generate_monthly_bills(p_month INT, p_year INT)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO bills (vendor_id, customer_id, month, year, total_liters, total_amount, amount_due)
  SELECT 
    d.vendor_id,
    d.customer_id,
    p_month,
    p_year,
    SUM(d.quantity) AS total_liters,
    SUM(d.quantity * d.price_applied) AS total_amount,
    SUM(d.quantity * d.price_applied) AS amount_due
  FROM deliveries d
  WHERE EXTRACT(MONTH FROM d.date) = p_month 
    AND EXTRACT(YEAR FROM d.date) = p_year
    AND d.status = 'delivered'
  GROUP BY d.vendor_id, d.customer_id
  ON CONFLICT (vendor_id, customer_id, month, year) 
  DO UPDATE SET 
    total_liters = EXCLUDED.total_liters,
    total_amount = EXCLUDED.total_amount,
    amount_due = EXCLUDED.total_amount - bills.amount_paid;
END;
$$;
================================================================================