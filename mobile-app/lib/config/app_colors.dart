import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFEB7624);
  static const Color secondary = Color(0xFFEF8E37);
  static const Color accent = Color(0xFFF1A95F);
  
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

