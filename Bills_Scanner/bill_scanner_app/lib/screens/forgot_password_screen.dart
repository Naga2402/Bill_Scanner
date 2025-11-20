import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import '../theme/app_theme.dart';
import '../services/database_service_factory.dart';
import 'login_unlock_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendInstructions() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseServiceFactory.getService();
      final token = await db.createPasswordResetToken(_emailController.text.trim());

      setState(() {
        _isLoading = false;
        _isEmailSent = true;
      });

      if (mounted) {
        if (token != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset token created. Token: $token\n(In production, this would be sent via email)'),
              backgroundColor: AppTheme.primaryColor,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not found or account is inactive'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Icon Container
                _buildIconContainer(isDark),

                const SizedBox(height: 24),

                // Title
                _buildTitle(isDark),

                const SizedBox(height: 8),

                // Subtitle
                _buildSubtitle(isDark),

                const SizedBox(height: 40),

                // Form or Success Message
                if (_isEmailSent)
                  _buildSuccessMessage(isDark)
                else
                  _buildForm(isDark),

                const SizedBox(height: 32),

                // Back to Sign In Link
                _buildBackToSignIn(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(bool isDark) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_reset,
        size: 36,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      'Forgot Password?',
      style: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? AppTheme.textDark : AppTheme.textLight,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      "No worries, we'll send you reset instructions.",
      style: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Label
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Email address',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
              ),
            ),
          ),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSendInstructions(),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: Icon(
                Icons.mail_outline,
                color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!EmailValidator.validate(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Send Instructions Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendInstructions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Send Instructions',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Instructions Sent!',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textDark : AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your email for password reset instructions.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBackToSignIn(BuildContext context, bool isDark) {
    return TextButton.icon(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginUnlockScreen(),
          ),
        );
      },
      icon: Icon(
        Icons.arrow_back,
        size: 18,
        color: AppTheme.primaryColor,
      ),
      label: Text(
        'Back to Sign In',
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

