import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class BaanaTypography {
  // Comfortaa pour les titres (gros arrondis géométriques)
  static const String headlineFont = 'Comfortaa';

  // Nunito pour le corps (lisibilité)
  static final String bodyFont = GoogleFonts.nunito().fontFamily!;

  static TextTheme getTextTheme() {
    return TextTheme(
      // Titres (Splash, Onboarding, Titres de sections)
      displayLarge: const TextStyle(
        fontFamily: headlineFont,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: BaanaColors.textPrimary,
        height: 1.2,
      ),
      displayMedium: const TextStyle(
        fontFamily: headlineFont,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: BaanaColors.textPrimary,
        height: 1.2,
      ),
      headlineLarge: const TextStyle(
        fontFamily: headlineFont,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: BaanaColors.textPrimary,
      ),
      headlineMedium: const TextStyle(
        fontFamily: headlineFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: BaanaColors.textPrimary,
      ),
      titleLarge: const TextStyle(
        fontFamily: headlineFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: BaanaColors.textPrimary,
      ),
      
      // Corps de texte (Nunito)
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: BaanaColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: BaanaColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: BaanaColors.textSecondary,
      ),
    );
  }
}
