import 'package:flutter/material.dart';

/// StreamFlow OLED Color Palette
/// Matches the design tokens from Stitch designs
class AppColors {
  AppColors._();

  // Base Colors
  static const Color oledBlack = Color(0xFF000000); // Pure black for OLED
  static const Color primary = Color(0xFFD41142); // Crimson red
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceGlass = Color(0x99121212); // rgba(18,18,18,0.6)
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textTertiary = Color(0xFF606060);
  
  // Border Colors
  static const Color borderLight = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color borderMedium = Color(0x33FFFFFF); // rgba(255,255,255,0.2)
  
  // Ambient Shadow Colors (for hover effects)
  static const Color ambientOrange = Color(0xFFFF641E);
  static const Color ambientBlue = Color(0xFF285AFF);
  static const Color ambientPurple = Color(0xFFA028FF);
  static const Color ambientTeal = Color(0xFF28FFB4);
  static const Color ambientRed = Color(0xFFFF2828);
  static const Color ambientAmber = Color(0xFFFFAA28);
  static const Color ambientIndigo = Color(0xFF5A28FF);
  static const Color ambientCyan = Color(0xFF28D2FF);
  static const Color ambientRose = Color(0xFFFF288C);
  static const Color ambientGreen = Color(0xFF28FF5A);
}
