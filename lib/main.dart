import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/controllers/auth_controller.dart';
import 'core/controllers/user_controller.dart';
import 'core/controllers/campaign_controller.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    
    // Initialize Stripe
    Stripe.publishableKey = AppConfig.stripePublishableKey;
  } catch (e) {
    // If initialization fails, we'll still run the app but with limited functionality
    print('Initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize GetX controllers
    Get.put(AuthController());
    Get.put(UserController());
    Get.put(CampaignController());

    return MaterialApp.router(
      title: 'CrowdFund',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
