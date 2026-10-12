import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/supabase_service.dart';

class AuthRepository {
  final _auth = SupabaseService.auth;

  /// Sign in with email and password.
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  /// Send OTP to phone
  Future<void> signInWithPhone(String phone) async {
    await _auth.signInWithOtp(phone: phone);
  }

  /// Verify OTP
  Future<void> verifyOtp(String phone, String otp) async {
    await _auth.verifyOTP(phone: phone, token: otp, type: OtpType.sms);
  }

  /// Sign up with email, password, and user profile metadata (username, phone, role).
  Future<void> signUp(
    String email,
    String password, {
    String? username,
    String? phone,
    String? role,
  }) async {
    await _auth.signUp(
      email: email,
      password: password,
      data: {
        if (username != null && username.isNotEmpty) 'username': username,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (role != null && role.isNotEmpty) 'role': role,
      },
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns true if a session currently exists.
  bool get isAuthenticated => _auth.currentUser != null;

  /// Returns the current user's ID or null.
  String? get currentUserId => _auth.currentUser?.id;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
}
