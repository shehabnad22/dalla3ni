import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Orange theme matching splash screen
  static const Color primary = Color(0xFFFF6B35); // Vibrant orange from splash
  static const Color secondary = Color(0xFFFF8C42); // Lighter orange
  static const Color accent = Color(0xFFFFA366); // Light orange accent
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFEFDFB);
  static const Color backgroundDark = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color textOnOrange = Color(0xFFFEFDFB);
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF666666);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, secondary, accent],
  );
  
  static const LinearGradient horizontalGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primary, secondary, accent],
  );
}

