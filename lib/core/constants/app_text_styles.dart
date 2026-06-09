import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Splash
  static TextStyle splashTitle = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static TextStyle splashSubtitle = GoogleFonts.lato(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight.withValues(alpha: 0.85),
    letterSpacing: 2.5,
  );

  // Onboarding
  static TextStyle onboardingTitle = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.25,
  );

  static TextStyle onboardingBody = GoogleFonts.lato(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.6,
  );

  static TextStyle buttonLabel = GoogleFonts.lato(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );
}
