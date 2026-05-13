import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await StorageService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AA Fans',
      theme: AppTheme.darkTheme, // Dark theme only
      darkTheme: AppTheme.darkTheme, // Ensure dark theme is used
      themeMode: ThemeMode.dark, // Force dark mode
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
