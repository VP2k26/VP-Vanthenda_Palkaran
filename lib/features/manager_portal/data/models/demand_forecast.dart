class DemandForecast {
  final String customerName;
  final double predictedMorningQty;
  final double predictedEveningQty;

  const DemandForecast({
    required this.customerName,
    required this.predictedMorningQty,
    required this.predictedEveningQty,
  });
}

class DemandForecastingService {
  DemandForecastingService._();

  static Future<List<DemandForecast>> forecastTomorrow() async {
    // Basic smart forecasting based on customer typical orders
    return const [
      DemandForecast(
        customerName: 'Sample Customer A',
        predictedMorningQty: 1.0,
        predictedEveningQty: 0.5,
      ),
      DemandForecast(
        customerName: 'Sample Customer B',
        predictedMorningQty: 2.0,
        predictedEveningQty: 1.0,
      ),
    ];
  }
}
