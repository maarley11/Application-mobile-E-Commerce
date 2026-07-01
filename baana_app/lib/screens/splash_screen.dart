import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../providers/auth_provider.dart';

/// Écran Splash — Premier écran visible au lancement de l'app.
/// Affiche le logo Baana sur un dégradé émeraude, puis redirige
/// automatiquement vers l'onboarding après 2.5 secondes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Animation d'entrée du logo : fade + scale
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    // Lancer l'animation immédiatement
    _animController.forward();

    // Navigation automatique après 4.5 secondes
    _navigationTimer = Timer(const Duration(milliseconds: 4500), () async {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        final isLoggedIn = await authProvider.checkAuthStatus();
        
        if (mounted) {
          if (isLoggedIn) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Dégradé émeraude fidèle à la maquette splash
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2ECC71), // Vert émeraude clair en haut
              BaanaColors.primary, // #10B981 au milieu
              Color(0xFF065F46), // Vert profond en bas
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Zone principale — logo centré dans la partie supérieure
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo Baana (trèfle + texte intégrés dans l'image)
                          Image.asset(
                            'assets/images/logo/baana_logo.png',
                            width: 220,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),

                          // Slogan — "LE CONFORT PAR LE DIGITAL"
                          Text(
                            'LE CONFORT PAR LE DIGITAL',
                            style: TextStyle(
                              fontFamily: BaanaTypography.bodyFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 3.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Barre de chargement
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ligne blanche fine en bas (comme sur la maquette)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
