import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase and Hive in parallel for fast launch
  await Future.wait([
    Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    ),
    () async {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox(AppConfig.hiveDeliveriesBox),
        Hive.openBox(AppConfig.hiveCustomersBox),
        Hive.openBox(AppConfig.hiveSettingsBox),
      ]);
    }(),
  ]);

  // Initialize Firebase in background so it never freezes main UI startup
  Firebase.initializeApp().catchError((e) {
    debugPrint('Firebase init error: $e');
    return null as dynamic;
  });

  runApp(const ProviderScope(child: VanthendaPaalkaranApp()));
}

class VanthendaPaalkaranApp extends ConsumerWidget {
  const VanthendaPaalkaranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
