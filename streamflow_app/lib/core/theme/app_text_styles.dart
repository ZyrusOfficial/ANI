import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// StreamFlow Typography System - 5 Core Styles Only
/// Font: Spline Sans (single font family for consistency)
class AppTextStyles {
  AppTextStyles._();

  // Base text theme using Spline Sans
  static TextTheme get baseTextTheme => GoogleFonts.splineSansTextTheme(
        ThemeData.dark().textTheme,
      );

  // 1. HERO - Large titles, hero sections (48-96px)
  static TextStyle get hero => GoogleFonts.splineSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
      );

  // 2. HEADING - Section titles, page headers (20-28px)
  static TextStyle get heading => GoogleFonts.splineSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  // 3. BODY - Main content text (14-16px)
  static TextStyle get body => GoogleFonts.splineSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  // 4. LABEL - Buttons, chips, small labels (12-13px)
  static TextStyle get label => GoogleFonts.splineSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.3,
        color: AppColors.textPrimary,
      );

  // 5. CAPTION - Metadata, timestamps, tertiary info (10-11px)
  static TextStyle get caption => GoogleFonts.splineSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.2,
        color: AppColors.textTertiary,
      );

  // ============ Backwards Compatibility Aliases ============
  // Map old names to new 5-style system

  static TextStyle get heroTitle => hero.copyWith(fontSize: 56, fontWeight: FontWeight.w900);
  static TextStyle get displayLarge => hero.copyWith(fontSize: 40);
  static TextStyle get displayMedium => heading.copyWith(fontSize: 28, fontWeight: FontWeight.w700);
  
  static TextStyle get titleLarge => heading.copyWith(fontSize: 24);
  static TextStyle get titleMedium => heading.copyWith(fontSize: 18);
  static TextStyle get titleSmall => heading.copyWith(fontSize: 15);
  
  static TextStyle get bodyLarge => body.copyWith(fontSize: 16);
  static TextStyle get bodyMedium => body;
  static TextStyle get bodySmall => body.copyWith(fontSize: 13);
  
  static TextStyle get labelLarge => label.copyWith(fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle get labelMedium => label;
  static TextStyle get labelSmall => caption;
  
  static TextStyle get button => label.copyWith(fontWeight: FontWeight.w600);
}
