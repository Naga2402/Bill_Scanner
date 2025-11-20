import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pramaan - Bill Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force light mode for testing (change to ThemeMode.system for auto)
      home: const WelcomeOnboardingScreen(),
    );
  }
}

