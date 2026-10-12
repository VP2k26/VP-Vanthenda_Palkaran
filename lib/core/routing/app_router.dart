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
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.milkCard,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const CustomersListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customers,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const CustomersListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerProfile,
        pageBuilder: (context, state) {
          final customer =
              state.extra as CustomerModel? ?? MockDataStore.customers.first;
          return _buildSmoothDissolvePage(
            state: state,
            child: ManagerCustomerProfileScreen(customer: customer),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.billing,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const BillingDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.payments,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const PaymentsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vacation,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const VacationModeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.emergency,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const EmergencyRequestsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.milkTypes,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const MilkTypesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const AnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.demandForecast,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const DemandForecastScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const AiAssistantScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.staff,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const StaffListScreen(),
        ),
      ),

      // ── Vendor / Delivery Portal ──
      GoRoute(
        path: AppRoutes.delivery,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const DeliveryRoutesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.deliveryTracker,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const DeliveryTrackerScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffHome,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const StaffHomeScreen(),
        ),
      ),

      // ── Customer Portal ──
      GoRoute(
        path: AppRoutes.customerHome,
        pageBuilder: (context, state) => _buildSmoothDissolvePage(
          state: state,
          child: const CustomerHomeScreen(),
        ),
      ),
    ],
  );
});
