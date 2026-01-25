import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SimpleChatsPage extends StatelessWidget {
  const SimpleChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chats',
              style: TextStyle(fontSize: 24, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Chat feature coming soon',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
