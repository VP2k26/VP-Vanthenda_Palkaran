import 'package:url_launcher/url_launcher.dart';

/// Zero-Commission Direct UPI Payment Helper
/// Builds standard UPI URI strings and launches UPI apps (GPay, PhonePe, Paytm, BHIM)
class UpiPaymentHelper {
  UpiPaymentHelper._();

  /// Builds a standard UPI pay URI with dynamic parameters
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

  /// Launches installed UPI application via external application intent
  static Future<bool> launchUpiIntent(String upiUri) async {
    final uri = Uri.parse(upiUri);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
