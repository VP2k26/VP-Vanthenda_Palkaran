import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Auth Cluster ───────────────────────────────────────────────────
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/language_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';

// ── Manager / Admin Portal Cluster ─────────────────────────────────
import '../../features/manager_portal/presentation/screens/dashboard_screen.dart';
import '../../features/manager_portal/presentation/screens/vendor_setup_screen.dart';
import '../../features/manager_portal/presentation/screens/customers_list_screen.dart';
import '../../features/manager_portal/presentation/screens/customer_profile_screen.dart';
import '../../features/manager_portal/data/repositories/customer_repository.dart';
import '../../core/database/mock_data.dart';
import '../../features/manager_portal/presentation/screens/billing_dashboard_screen.dart';
import '../../features/manager_portal/presentation/screens/payments_screen.dart';
import '../../features/manager_portal/presentation/screens/vacation_mode_screen.dart';
import '../../features/manager_portal/presentation/screens/emergency_requests_screen.dart';
import '../../features/manager_portal/presentation/screens/settings_screen.dart';
import '../../features/manager_portal/presentation/screens/milk_types_screen.dart';
import '../../features/manager_portal/presentation/screens/analytics_screen.dart';
import '../../features/manager_portal/presentation/screens/demand_forecast_screen.dart';
import '../../features/manager_portal/presentation/screens/ai_assistant_screen.dart';
import '../../features/manager_portal/presentation/screens/staff_list_screen.dart';

// ── Vendor / Delivery Portal Cluster ───────────────────────────────
import '../../features/vendor_portal/presentation/screens/delivery_routes_screen.dart';
import '../../features/vendor_portal/presentation/screens/delivery_tracker_screen.dart';
import '../../features/vendor_portal/presentation/screens/staff_home_screen.dart';

// ── Customer Portal Cluster ────────────────────────────────────────
import '../../features/customer_portal/presentation/screens/customer_home_screen.dart';

import '../transitions/transitions.dart';
import 'app_routes.dart';

/// Helper for silky-smooth dissolve & subtle glide transitions
CustomTransitionPage<void> _buildSmoothDissolvePage({
  required GoRouterState state,
  required Widget child,
}) {
  return AppPageTransitions.slideAndFade<void>(
    state: state,
    child: child,
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      // ── Auth ──
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const LanguageSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            _buildSmoothDissolvePage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) =>
            _buildSmoothDissolvePage(state: state, child: const SignupScreen()),
      ),

      // ── Manager / Admin Portal ──
      GoRoute(
        path: AppRoutes.setupProfile,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const VendorSetupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.milkCard,
        builder: (context, state) => const CustomersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.customers,
        builder: (context, state) => const CustomersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerProfile,
        builder: (context, state) {
          final customer =
              state.extra as CustomerModel? ?? MockDataStore.customers.first;
          return ManagerCustomerProfileScreen(customer: customer);
        },
      ),
      GoRoute(
        path: AppRoutes.billing,
        builder: (context, state) => const BillingDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vacation,
        builder: (context, state) => const VacationModeScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergency,
        builder: (context, state) => const EmergencyRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.milkTypes,
        builder: (context, state) => const MilkTypesScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.demandForecast,
        builder: (context, state) => const DemandForecastScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.staff,
        builder: (context, state) => const StaffListScreen(),
      ),

      // ── Vendor / Delivery Portal ──
      GoRoute(
        path: AppRoutes.delivery,
        builder: (context, state) => const DeliveryRoutesScreen(),
      ),
      GoRoute(
        path: AppRoutes.deliveryTracker,
        builder: (context, state) => const DeliveryTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffHome,
        builder: (context, state) => const StaffHomeScreen(),
      ),

      // ── Customer Portal ──
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
    ],
  );
});
