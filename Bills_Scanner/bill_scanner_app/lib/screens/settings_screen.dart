import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/database_service_factory.dart';
import '../models/user_model.dart';
import 'login_unlock_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;
  
  const SettingsScreen({super.key, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _db = DatabaseServiceFactory.getService();
  final _scrollController = ScrollController();
  
  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _billReminders = true;

  // User data
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _currency = 'USD';
  String _appearance = 'system';
  String _defaultCategory = 'Uncategorized';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data
      final user = await _db.getUserById(widget.userId);
      if (user != null) {
        setState(() {
          _userName = user.fullName ?? 'User';
          _userEmail = user.email;
        });
      }

      // Load settings
      final settings = await _db.getUserSettings(widget.userId);
      if (settings != null) {
        setState(() {
          _currency = settings['currency'] as String? ?? 'USD';
          _appearance = settings['appearance_mode'] as String? ?? 'system';
          _defaultCategory = settings['default_category'] as String? ?? 'Uncategorized';
          _pushNotifications = settings['push_notifications_enabled'] as bool? ?? true;
          _emailNotifications = settings['email_notifications_enabled'] as bool? ?? false;
          _billReminders = settings['bill_reminders_enabled'] as bool? ?? true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      await _db.updateUserSettings(
        userId: widget.userId,
        pushNotificationsEnabled: _pushNotifications,
        emailNotificationsEnabled: _emailNotifications,
        billRemindersEnabled: _billReminders,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log Out',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginUnlockScreen(),
                ),
                (route) => false,
              );
            },
            child: Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            // Content
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(3),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbColor: MaterialStateProperty.all(
                        isDark 
                          ? AppTheme.zinc500.withOpacity(0) // Lighter grey for dark mode
                          : AppTheme.zinc400.withOpacity(0.5), // For light mode
                      ),
                      thickness: MaterialStateProperty.all(6),
                      radius: const Radius.circular(3),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                      // Profile Header
                      _buildProfileHeader(isDark),

                      const SizedBox(height: 16),

                      // Account Management Section
                      _buildAccountManagementSection(isDark),

                      const SizedBox(height: 16),

                      // App Preferences Section
                      _buildAppPreferencesSection(isDark),

                      const SizedBox(height: 16),

                      // Notifications Section
                      _buildNotificationsSection(isDark),

                      const SizedBox(height: 16),

                      // Support & Legal Section
                      _buildSupportLegalSection(isDark),

                      const SizedBox(height: 16),

                      // Log Out Button
                      _buildLogoutButton(context, isDark),

                      const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.zinc700 : AppTheme.zinc200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
            color: isDark ? AppTheme.textDark : AppTheme.textLight,
          ),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDark : AppTheme.textLight,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            backgroundImage: const NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuD1YFBUqbXTpZHfRPsMCdH7R5wxDNHQnxU28ZCUl01QXVOaIO7r2b_jlZApyzOqr0R2eizRUbmfQDe8_BSklVyiMgQzKqt1fGwYwn1M4OrhdpStwQAUNAlhBlshto2-8JZGWnVGz7PnNA2BiBToqWxK6gUUg93a7noXnHppGRlGcGvWfAVcrIRbryIiBKHP5loN6fK-gFlWb1teEf25SnyFIkn5yXiCC5XvQIe8JsBCY1aM7F6WJON0jJPEUrskejqAtalugJbT6bQ',
            ),
          ),
          const SizedBox(width: 16),
          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textDark : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagementSection(bool isDark) {
    return _buildSection(
      isDark: isDark,
      title: 'Account Management',
      children: [
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.person,
          title: 'Manage Account',
          onTap: () {
            // TODO: Navigate to manage account screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Manage Account - Coming soon')),
            );
          },
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.credit_card,
          title: 'Subscription',
          onTap: () {
            // TODO: Navigate to subscription screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subscription - Coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection(bool isDark) {
    return _buildSection(
      isDark: isDark,
      title: 'App Preferences',
      children: [
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.attach_money,
          title: 'Currency',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currency,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                size: 20,
              ),
            ],
          ),
          onTap: () {
            // TODO: Show currency picker
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Currency selection - Coming soon')),
            );
          },
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.contrast,
          title: 'Appearance',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _appearance,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                size: 20,
              ),
            ],
          ),
          onTap: () {
            // TODO: Show appearance picker
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appearance selection - Coming soon')),
            );
          },
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.label,
          title: 'Default Category',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _defaultCategory,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                size: 20,
              ),
            ],
          ),
          onTap: () {
            // TODO: Show category picker
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category selection - Coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(bool isDark) {
    return _buildSection(
      isDark: isDark,
      title: 'Notifications',
      children: [
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.notifications,
          title: 'Push Notifications',
          trailing: Switch(
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
              _saveNotificationSettings();
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.mail,
          title: 'Email Notifications',
          trailing: Switch(
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
              _saveNotificationSettings();
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.calendar_month,
          title: 'Bill Reminders',
          trailing: Switch(
            value: _billReminders,
            onChanged: (value) {
              setState(() {
                _billReminders = value;
              });
              _saveNotificationSettings();
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportLegalSection(bool isDark) {
    return _buildSection(
      isDark: isDark,
      title: 'Support & Legal',
      children: [
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.help_center,
          title: 'Help Center',
          onTap: () {
            // TODO: Navigate to help center
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help Center - Coming soon')),
            );
          },
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.support_agent,
          title: 'Contact Support',
          onTap: () {
            // TODO: Navigate to contact support
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact Support - Coming soon')),
            );
          },
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () {
            // TODO: Navigate to privacy policy
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy Policy - Coming soon')),
            );
          },
        ),
        _buildDivider(isDark),
        _buildSettingsItem(
          isDark: isDark,
          icon: Icons.gavel,
          title: 'Terms of Service',
          onTap: () {
            // TODO: Navigate to terms of service
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of Service - Coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.zinc800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppTheme.zinc700)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDark : AppTheme.textLight,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required bool isDark,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppTheme.textDark : AppTheme.textLight,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right,
                color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: isDark ? AppTheme.zinc700 : AppTheme.zinc200,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? Colors.red.withOpacity(0.4)
              : Colors.red.withOpacity(0.1),
          foregroundColor: isDark ? Colors.red.shade300 : Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Log Out',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

