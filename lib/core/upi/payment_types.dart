enum PaymentMethod {
  upiQr,
  upiIntent,
  cashInHand,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
}

class UpiPaymentDetails {
  final String upiId;
  final String payeeName;
  final double amount;
  final String transactionNote;
  final String? transactionRef;

  const UpiPaymentDetails({
    required this.upiId,
    required this.payeeName,
    required this.amount,
    this.transactionNote = 'Milk Bill Payment',
    this.transactionRef,
  });

  /// Generates the standard NPCI UPI URI string
  String toUriString() {
    final encodedPayee = Uri.encodeComponent(payeeName);
    final encodedNote = Uri.encodeComponent(transactionNote);
    final amountStr = amount.toStringAsFixed(2);
    
    var uri = 'upi://pay?pa=$upiId&pn=$encodedPayee&am=$amountStr&cu=INR&tn=$encodedNote';
    if (transactionRef != null && transactionRef!.isNotEmpty) {
      uri += '&tr=$transactionRef';
    }
    return uri;
  }
}
