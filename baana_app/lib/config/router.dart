import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/register_screen.dart';
import '../screens/otp_screen.dart';
import '../config/colors.dart';
import '../config/typography.dart';

/// Configuration du routeur GoRouter pour l'application Baana.
/// Routes initiales : Splash → Onboarding → Register (placeholder)
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash Screen — route initiale, non-popable
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding — 3 slides, non-popable (pas de retour vers splash)
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Register
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // OTP
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),
  ],
);
