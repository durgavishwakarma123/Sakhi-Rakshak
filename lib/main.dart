import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/auth_controller.dart';
import 'controller/complaint_controller.dart';
import 'controller/sos_controller.dart';
import 'controller/location_controller.dart';
import 'controller/notification_controller.dart';
import 'controller/profile_controller.dart';
import 'view/splash/splash_screen.dart';
import 'utils/colors.dart';
import 'utils/constants.dart';

import 'services/firebase_service.dart';
import 'services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService().initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ComplaintController()),
        ChangeNotifierProvider(create: (_) => SosController()),
        ChangeNotifierProvider(create: (_) => LocationController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: const SmartSakhiApp(),
    ),
  );
}

class SmartSakhiApp extends StatelessWidget {
  const SmartSakhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [AnalyticsService.observer],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}