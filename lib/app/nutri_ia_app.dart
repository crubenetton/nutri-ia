import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../pages/splash/splash_page.dart';

class NutriIAApp extends StatelessWidget {
  const NutriIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutri IA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const SplashPage(),
    );
  }
}
