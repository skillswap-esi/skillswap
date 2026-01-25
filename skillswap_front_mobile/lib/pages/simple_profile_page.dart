import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../core/app_colors.dart';

class SimpleProfilePage extends StatelessWidget {
  const SimpleProfilePage({super.key});

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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.fullName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(user.email),
                const SizedBox(height: 24),
                Text('Credits: ${user.creditsBalance}'),
                Text('Score: ${user.helperScore.toStringAsFixed(1)}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
