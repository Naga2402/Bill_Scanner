import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';
import 'login_unlock_screen.dart';

class WelcomeOnboardingScreen extends StatelessWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header with App Name
              _buildHeader(context, isDark),

              // Main Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration
                    _buildIllustration(isDark),

                    const SizedBox(height: 48),

                    // Heading
                    _buildHeading(context, isDark),

                    const SizedBox(height: 12),

                    // Description
                    _buildDescription(context, isDark),
                  ],
                ),
              ),

              // Footer with Buttons
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Text(
        'pramaan',
        style: TextStyle(
          fontFamily: 'Samarkan',
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: isDark ? AppTheme.textDark : AppTheme.textLight,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildIllustration(bool isDark) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
      child: Image.asset(
        'assets/images/welcome_illustration.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image fails to load
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.zinc800 : AppTheme.zinc100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.receipt_long,
                size: 120,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeading(BuildContext context, bool isDark) {
    return Text(
      'Track Your Bills, Effortlessly',
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? AppTheme.textDark : AppTheme.textLight,
        height: 1.2,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildDescription(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Manage, categorize, and stay on top of your expenses all in one place.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Create Account Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Text(
              'Create an Account',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Log In Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginUnlockScreen(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(
                color: isDark ? AppTheme.zinc700 : AppTheme.zinc200,
              ),
              backgroundColor: isDark ? AppTheme.zinc800 : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log In',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

