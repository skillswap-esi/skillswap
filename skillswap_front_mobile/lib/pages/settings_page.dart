import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../auth_service.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'delete_account_page.dart';
import 'phone_verification_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Account',
            children: [
              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: authService,
                builder: (context, auth, _) {
                  final isVerified = auth.isPhoneVerified;
                  return _buildSettingTile(
                    icon: isVerified ? Icons.verified : Icons.phone_outlined,
                    title: 'Phone Verification',
                    subtitle: isVerified 
                        ? 'Phone verified ✓' 
                        : 'Verify phone to earn bonus credits',
                    onTap: isVerified ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PhoneVerificationPage()),
                      );
                    },
                    isVerified: isVerified,
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeleteAccountPage()),
                  );
                },
                isDestructive: true,
              ),
              _buildSettingTile(
                icon: Icons.email_outlined,
                title: 'Email Preferences',
                subtitle: 'Manage email notifications',
                onTap: () {
                  // TODO: Navigate to email preferences
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Preferences',
            children: [
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage push notifications',
                onTap: () {
                  // TODO: Navigate to notifications settings
                },
              ),
              _buildSettingTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  // TODO: Navigate to language settings
                },
              ),
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'Light mode',
                onTap: () {
                  // TODO: Navigate to theme settings
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'About',
            children: [
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About SkillSwap',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
              _buildSettingTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms',
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: AppColors.accent),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isVerified = false,
  }) {
    final color = isDestructive ? AppColors.accent : (isVerified ? Colors.green : AppColors.primary);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isVerified ? Colors.green : AppColors.textSecondary,
        ),
      ),
      trailing: onTap != null ? const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ) : null,
      onTap: onTap,
      enabled: onTap != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.value.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
