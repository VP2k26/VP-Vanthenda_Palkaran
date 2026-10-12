import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';

class HiveService {
  HiveService._();

  static late Box _deliveriesBox;
  static late Box _customersBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    _deliveriesBox = await Hive.openBox(AppConfig.hiveDeliveriesBox);
    _customersBox = await Hive.openBox(AppConfig.hiveCustomersBox);
    _settingsBox = await Hive.openBox(AppConfig.hiveSettingsBox);
  }

  static Box get deliveriesBox => _deliveriesBox;
  static Box get customersBox => _customersBox;
  static Box get settingsBox => _settingsBox;

  static Future<void> clearAll() async {
    await _deliveriesBox.clear();
    await _customersBox.clear();
    await _settingsBox.clear();
  }
}
