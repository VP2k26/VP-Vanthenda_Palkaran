import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'payment_types.dart';

class UpiService {
  UpiService._();

  /// Launches installed UPI app (GPay, PhonePe, Paytm, BHIM) with pre-filled details
  static Future<bool> launchUpiIntent(UpiPaymentDetails details) async {
    final uriString = details.toUriString();
    final uri = Uri.parse(uriString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Cannot launch UPI URL: $uriString');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching UPI: $e');
      return false;
    }
  }

  /// Builds a standard UPI QR code data string
  static String buildQrData({
    required String upiId,
    required String payeeName,
    required double amount,
    String note = 'Milk Bill Payment',
  }) {
    final details = UpiPaymentDetails(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: note,
    );
    return details.toUriString();
  }
}
