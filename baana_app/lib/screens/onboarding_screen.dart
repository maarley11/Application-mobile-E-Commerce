import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/typography.dart';
import '../widgets/baana_button.dart';

class _OnboardingSlide {
  final Widget title;
  final String subtitle;
  final String imagePng;
  final bool showPaymentLogos;
  final Alignment baanaLogoAlignment;
  final double imageTop;
  final double imageBottom;
  final double imageScale;
  final double imageOffsetX;
  final double imageOffsetY;

  _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.imagePng,
    this.showPaymentLogos = false,
    required this.baanaLogoAlignment,
    this.imageTop = 80,
    this.imageBottom = 260,
    this.imageScale = 1.0,
    this.imageOffsetX = 0,
    this.imageOffsetY = 0,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<_OnboardingSlide> _slides;

  @override
  void initState() {
    super.initState();
    _slides = [
      _OnboardingSlide(
        title: _buildTitle([
          const TextSpan(text: 'Achetez ', style: TextStyle(color: Color(0xFF1F2937))),
          const TextSpan(text: 'en gros,\n', style: TextStyle(color: Color(0xFFED7345))),
          const TextSpan(text: 'payez ', style: TextStyle(color: Color(0xFF1F2937))),
          const TextSpan(text: 'moins', style: TextStyle(color: Color(0xFF67C293))),
        ]),
        subtitle: 'Accédez aux prix de gros\nréservés aux membres Pro',
        imagePng: 'assets/images/onboarding/carton_onboarding.png',
        baanaLogoAlignment: Alignment.topRight,
        imageTop: 80,
        imageBottom: 150,      // Base plus basse
        imageScale: 1.4,       // Bien grand
        imageOffsetX: -60,     // Collé à gauche
        imageOffsetY: 180,     // Descente MASSIVE pour boucher le trou en bas et libérer le haut
      ),
      _OnboardingSlide(
        title: _buildTitle([
          const TextSpan(text: 'Livraison ', style: TextStyle(color: Color(0xFF1F2937))),
          const TextSpan(text: 'gratuite\n', style: TextStyle(color: Color(0xFFED7345))),
          const TextSpan(text: 'à ', style: TextStyle(color: Color(0xFF1F2937))),
          const TextSpan(text: 'Dakar', style: TextStyle(color: Color(0xFF67C293))),
        ]),
        subtitle: '3 livraisons gratuites par\nsemaine pour les membres Pro',
        imagePng: 'assets/images/onboarding/livreur.png',
        baanaLogoAlignment: Alignment.topLeft,
        imageTop: 60,
        imageBottom: 120,      // Base encore plus basse
        imageScale: 1.25,      // Je remets un poil de zoom vu qu'il est redescendu
        imageOffsetX: 30,
        imageOffsetY: 140,     // Descente maximale vers le bas
      ),
      _OnboardingSlide(
        title: _buildTitle([
          const TextSpan(text: 'Payez avec ', style: TextStyle(color: Color(0xFF1F2937))),
          const TextSpan(text: 'Mobile\n', style: TextStyle(color: Color(0xFF67C293))),
          const TextSpan(text: 'Money', style: TextStyle(color: Color(0xFFED7345))),
        ]),
        subtitle: 'Wave, Orange Money, Free\nMoney — en un seul clic.',
        imagePng: 'assets/images/onboarding/main_mobile_money.png',
        showPaymentLogos: true,
        baanaLogoAlignment: Alignment.topLeft,
        imageTop: 60,          // On redescend le haut pour s'aligner
        imageBottom: 20,       // On ancre encore plus bas
        imageScale: 1.4,       // On garde la même échelle
        imageOffsetX: -5,      // Décalage vers la gauche
        imageOffsetY: 150,     // On descend encore plus la main
      ),
    ];
  }

  static Widget _buildTitle(List<TextSpan> spans) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: BaanaTypography.headlineFont,
          fontSize: 34, // Revenu à 34 pour matcher la maquette
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        children: spans,
      ),
    );
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToRegister();
    }
  }

  void _goToRegister() => context.go('/register');

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── 1) FOND COMMUN ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding/fondonboarding.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── 2) CAROUSEL (Image + Texte) ──
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return _buildSlide(_slides[index]);
              },
            ),
          ),

          // ── 3) LOGO BAANA DYNAMIQUE ──
          Positioned(
            top: topPadding + 20,
            left: slide.baanaLogoAlignment == Alignment.topLeft ? 24 : null,
            right: slide.baanaLogoAlignment == Alignment.topRight ? 24 : null,
            child: Image.asset(
              'assets/images/logo/baana_logo.png',
              height: 55, // Logo plus grand pour matcher la maquette
            ),
          ),

          // ── 4) CONTRÔLES FLOTTANTS EN BAS (Dots + Bouton) ──
          Positioned(
            bottom: bottomPadding + 24,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Dots animés ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final bool active = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFED7345)
                            : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // ── Bouton CTA ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: BaanaButton(
                    text: _currentPage == _slides.length - 1 ? 'Commencer' : 'Suivant',
                    onPressed: _onNext,
                    variant: BaanaButtonVariant.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide) {
    return Stack(
      children: [
        // ── IMAGE DE LA SLIDE ──
        Positioned(
          top: slide.imageTop,
          left: 0,
          right: 0,
          bottom: slide.imageBottom,
          child: Transform.translate(
            offset: Offset(slide.imageOffsetX, slide.imageOffsetY),
            child: Transform.scale(
              scale: slide.imageScale,
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                slide.imagePng,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // ── Textes et Logos en bas ──
        Positioned(
          bottom: 160, // Espace pour les contrôles flottants
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Logos paiement (slide 3 uniquement) ──
              if (slide.showPaymentLogos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/logos/badge_wave.png', height: 50),
                          const SizedBox(width: 10),
                          Image.asset('assets/images/logos/badge_om.png', height: 50),
                          const SizedBox(width: 10),
                          Image.asset('assets/images/logos/badge_mixx.png', height: 50),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Titre ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: slide.title,
              ),

              const SizedBox(height: 16),

              // ── Sous-titre ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    fontSize: 17, // Légèrement augmenté aussi pour s'équilibrer avec le titre
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
