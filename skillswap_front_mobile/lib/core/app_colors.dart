import 'package:flutter/material.dart';

class AppColors {
  // Primary colors inspired by SkillSwap identity
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8B85FF);
  
  // Secondary accent
  static const Color accent = Color(0xFFFF6584);
  
  // Background colors
  static const Color background = Color(0xFFF8F9FE);
  static const Color cardBackground = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9094A6);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6C63FF), Color(0xFF5A52D5), Color(0xFF4840B0)],
  );
}
