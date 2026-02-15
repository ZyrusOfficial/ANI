import 'package:flutter/material.dart';
import 'app_colors.dart';

/// StreamFlow Shadow Definitions
/// Ambient colored shadows for cards and interactive elements
class AppShadows {
  AppShadows._();

  // Ambient Shadows (default state)
  static List<BoxShadow> get ambientOrange => [
        BoxShadow(
          color: AppColors.ambientOrange.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientBlue => [
        BoxShadow(
          color: AppColors.ambientBlue.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientPurple => [
        BoxShadow(
          color: AppColors.ambientPurple.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientTeal => [
        BoxShadow(
          color: AppColors.ambientTeal.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientRed => [
        BoxShadow(
          color: AppColors.ambientRed.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientAmber => [
        BoxShadow(
          color: AppColors.ambientAmber.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientIndigo => [
        BoxShadow(
          color: AppColors.ambientIndigo.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientCyan => [
        BoxShadow(
          color: AppColors.ambientCyan.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientRose => [
        BoxShadow(
          color: AppColors.ambientRose.withValues(alpha: 0.5),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  static List<BoxShadow> get ambientGreen => [
        BoxShadow(
          color: AppColors.ambientGreen.withValues(alpha: 0.4),
          blurRadius: 100,
          spreadRadius: -10,
          offset: const Offset(0, 40),
        ),
      ];

  // Hover Shadows (intensified)
  static List<BoxShadow> get ambientOrangeHover => [
        BoxShadow(
          color: AppColors.ambientOrange.withValues(alpha: 0.8),
          blurRadius: 120,
          spreadRadius: -5,
          offset: const Offset(0, 50),
        ),
      ];

  static List<BoxShadow> get ambientBlueHover => [
        BoxShadow(
          color: AppColors.ambientBlue.withValues(alpha: 0.8),
          blurRadius: 120,
          spreadRadius: -5,
          offset: const Offset(0, 50),
        ),
      ];

  static List<BoxShadow> get ambientPurpleHover => [
        BoxShadow(
          color: AppColors.ambientPurple.withValues(alpha: 0.8),
          blurRadius: 120,
          spreadRadius: -5,
          offset: const Offset(0, 50),
        ),
      ];

  static List<BoxShadow> get ambientTealHover => [
        BoxShadow(
          color: AppColors.ambientTeal.withValues(alpha: 0.8),
          blurRadius: 120,
          spreadRadius: -5,
          offset: const Offset(0, 50),
        ),
      ];

  static List<BoxShadow> get ambientRedHover => [
        BoxShadow(
          color: AppColors.ambientRed.withValues(alpha: 0.8),
          blurRadius: 120,
          spreadRadius: -5,
          offset: const Offset(0, 50),
        ),
      ];

  // Glass Card Shadow
  static List<BoxShadow> get glassCard => [
        const BoxShadow(
          color: Color(0x80000000), // rgba(0,0,0,0.5)
          blurRadius: 32,
          spreadRadius: 0,
          offset: Offset(0, 8),
        ),
      ];

  // Nav Icon Glow
  static List<BoxShadow> get navIconGlow => [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.6),
          blurRadius: 15,
          spreadRadius: 0,
        ),
      ];

  // Primary Glow (for primary buttons, progress bars)
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.8),
          blurRadius: 15,
          spreadRadius: 0,
        ),
      ];
}
