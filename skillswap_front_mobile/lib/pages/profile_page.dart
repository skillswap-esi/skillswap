import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../core/app_colors.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'my_skills_page.dart';
import 'missions_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authState, _) {
        final user = authState.userProfile;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please login to view profile')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: user.avatar != null
                                  ? NetworkImage(user.avatar!)
                                  : null,
                              child: user.avatar == null
                                  ? Text(
                                      user.fullName[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Email
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Phone verification status
                          if (user.phoneNumber != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: user.phoneVerified
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: user.phoneVerified ? Colors.green : Colors.orange,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    user.phoneVerified ? Icons.verified : Icons.warning,
                                    size: 16,
                                    color: user.phoneVerified ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.phoneVerified ? 'Phone Verified' : 'Phone Not Verified',
                                    style: TextStyle(
                                      color: user.phoneVerified ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.monetization_on,
                          label: 'Credits',
                          value: user.creditsBalance.toString(),
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star,
                          label: 'Score',
                          value: user.helperScore.toStringAsFixed(1),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  subtitle: 'Update your information',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfilePage()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.school,
                  title: 'My Skills',
                  subtitle: 'Manage your skills',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MySkillsPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.assignment,
                  title: 'My Missions',
                  subtitle: 'View your missions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MissionsPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  color: Colors.red,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await authService.value.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/welcome');
                      }
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color ?? AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
