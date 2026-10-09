import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/manager_portal/data/repositories/billing_repository.dart';
import '../upi/upi_helper.dart';

/// Helper for generating formatted bill invoices and sending direct WhatsApp & SMS reminders
class WhatsAppReminderHelper {
  WhatsAppReminderHelper._();

  static const String defaultUpiId = 'paalkaran@oksbi';
  static const String defaultBusinessName = 'Vanthenda Paalkaran';

  /// Builds a formatted, professional WhatsApp text invoice
  static String buildBillInvoiceMessage({
    required String customerName,
    required double totalLiters,
    required double ratePerLiter,
    required double totalAmount,
    required String billingMonth,
    required String dueDate,
    String? billReference,
    String upiId = defaultUpiId,
  }) {
    final upiUri = UpiPaymentHelper.buildUpiUri(
      upiId: upiId,
      payeeName: defaultBusinessName,
      amount: totalAmount,
      billReference: billReference ?? 'BILL-DIRECT',
    );

    return '''
🥛 *VANTHENDA PAALKARAN - MONTHLY MILK BILL* 🥛
━━━━━━━━━━━━━━━━━━━━
👤 *Customer:* $customerName
📅 *Billing Period:* $billingMonth
🥛 *Total Milk Consumed:* ${totalLiters.toStringAsFixed(1)} Liters
💰 *Milk Rate:* ₹${ratePerLiter.toStringAsFixed(0)} / Liter
━━━━━━━━━━━━━━━━━━━━
💵 *TOTAL AMOUNT DUE: ₹${totalAmount.toStringAsFixed(0)}*
⏰ *Payment Due Date:* $dueDate
━━━━━━━━━━━━━━━━━━━━
📲 *Pay Easily via UPI (GPay / PhonePe / Paytm):*
• *UPI ID:* `$upiId`
• *Direct Pay Link:* $upiUri

_Please transfer the dues and reply with payment screenshot._
🙏 *Thank you for choosing Vanthenda Paalkaran!*
''';
  }

  /// Sends bill invoice reminder to a customer via WhatsApp
  static Future<bool> sendWhatsAppReminder({
    required String phone,
    required BillModel bill,
    double ratePerLiter = 50.0,
    String? customDueDate,
  }) async {
    // Format Phone
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }

    final dueDate = customDueDate ??
        '25th ${DateFormat('MMMM yyyy').format(DateTime.now())}';
    final monthName = DateFormat('MMMM yyyy').format(DateTime.now());

    final message = buildBillInvoiceMessage(
      customerName: bill.customerName,
      totalLiters: bill.totalLiters,
      ratePerLiter: ratePerLiter,
      totalAmount: bill.amountDue,
      billingMonth: monthName,
      dueDate: dueDate,
      billReference: bill.id,
    );

    final encodedMessage = Uri.encodeComponent(message);
    final waUrl = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback to standard SMS
        final smsUrl = Uri.parse('sms:$cleanPhone?body=$encodedMessage');
        if (await canLaunchUrl(smsUrl)) {
          await launchUrl(smsUrl);
          return true;
        }
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
