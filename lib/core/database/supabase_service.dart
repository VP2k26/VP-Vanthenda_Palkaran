import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/user_role.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;

  static String? get currentUserId => auth.currentUser?.id;
  static bool get isAuthenticated => auth.currentUser != null;

  /// Detects the authenticated user's role via user metadata or Supabase RPC.
  /// Returns [UserRole.unknown] if the user has no role yet.
  static Future<UserRole> getUserRole() async {
    if (!isAuthenticated) return UserRole.unknown;
    
    // First check user metadata
    final metadata = auth.currentUser?.userMetadata;
    if (metadata != null && metadata.containsKey('role')) {
      final roleStr = metadata['role'] as String?;
      switch (roleStr) {
        case 'manager':
        case 'admin':
          return UserRole.manager;
        case 'vendor':
        case 'staff':
          return UserRole.vendor;
        case 'customer':
          return UserRole.customer;
      }
    }

    try {
      final dynamic result = await client.rpc('get_user_role');
      switch (result as String?) {
        case 'manager':
        case 'admin':
          return UserRole.manager;
        case 'vendor':
        case 'staff':
          return UserRole.vendor;
        case 'customer':
          return UserRole.customer;
        default:
          return UserRole.unknown;
      }
    } catch (_) {
      return UserRole.unknown;
    }
  }
}
