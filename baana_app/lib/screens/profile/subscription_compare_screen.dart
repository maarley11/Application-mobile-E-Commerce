import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../widgets/manjak_pattern.dart';

class SubscriptionCompareScreen extends StatelessWidget {
  const SubscriptionCompareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: BaanaColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BaanaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Devenez Membre Pro',
          style: textTheme.titleLarge?.copyWith(
            color: BaanaColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Effect
          Positioned.fill(
            child: CustomPaint(
              painter: ArtisticBackgroundPainter(),
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(textTheme),
                  
                  const SizedBox(height: 32),
                  
                  // Pricing Cards
                  _buildHebdoCard(context, textTheme),
                  const SizedBox(height: 24),
                  _buildMensuelCard(context, textTheme),
                  
                  const SizedBox(height: 48),
                  
                  // Pods Comparison Section
                  Text(
                    'L\'évolution de votre boutique',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF181c1c),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Grid of pods
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildPodCard(
                        context,
                        title: 'Catalogue Illimité',
                        subtitle: 'Ajoutez autant de produits que vous voulez.',
                        icon: Icons.eco,
                        iconColor: BaanaColors.primary,
                      ),
                      _buildPodCard(
                        context,
                        title: 'Analyses Détaillées',
                        subtitle: 'Comprenez vos clients en profondeur.',
                        icon: Icons.energy_savings_leaf,
                        iconColor: const Color(0xFF8c4f00), // secondary
                      ),
                      _buildPodCard(
                        context,
                        title: 'Outils Marketing',
                        subtitle: 'Boostez vos ventes avec des promos ciblées.',
                        icon: Icons.spa,
                        iconColor: const Color(0xFF9d4300), // tertiary
                      ),
                      _buildPodCard(
                        context,
                        title: 'Support Premium',
                        subtitle: 'Accès direct à nos experts commerce.',
                        icon: Icons.psychology,
                        iconColor: const Color(0xFF00422b), // on-primary-container
                        bgColor: const Color(0xFF10b981), // primary-container
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              'L\'Élite Baana Pro',
              style: textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF181c1c),
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const Positioned(
              top: -12,
              right: -32,
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFff7e2d), // tertiary-container
                size: 32,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Cultivez votre commerce avec l\'énergie de la graine. Abondance et croissance garantie.',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF6B7D75), // text-secondary
          ),
        ),
      ],
    );
  }

  Widget _buildHebdoCard(BuildContext context, TextTheme textTheme) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: BaanaColors.primary.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HEBDO',
                        style: textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF3c4a42), // on-surface-variant
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '2500',
                            style: textTheme.headlineLarge?.copyWith(
                              color: const Color(0xFF181c1c),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'FCFA',
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF6B7D75),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFffac5b).withOpacity(0.2), // secondary-container
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.spa,
                      color: Color(0xFF8c4f00), // secondary
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.check, color: Color(0xFF6B7D75), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Accès de base',
                    style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF6B7D75)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: BaanaColors.primary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.push('/subscription_payment', extra: 'hebdo'),
                  child: Text(
                    'S\'abonner',
                    style: textTheme.titleMedium?.copyWith(
                      color: BaanaColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMensuelCard(BuildContext context, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10b981), Color(0xFF006c49)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(48),
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33006c49),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommandé badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFff7e2d), // tertiary-container
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'RECOMMANDÉ',
              style: textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mensuel',
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '7500',
                style: textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FCFA',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildCheckItem('Croissance maximale', textTheme),
          const SizedBox(height: 16),
          _buildCheckItem('Support prioritaire', textTheme),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              onPressed: () => context.push('/subscription_payment', extra: 'mensuel'),
              icon: const Icon(Icons.bolt, size: 28),
              label: Text(
                'Activer Pro',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, TextTheme textTheme) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPodCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Color? bgColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final isPremium = bgColor != null;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPremium ? bgColor : Colors.white.withOpacity(0.65),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: BaanaColors.primary.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPremium ? Colors.white.withOpacity(0.2) : const Color(0xFFebefed),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isPremium ? Colors.white : iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: isPremium ? Colors.white : const Color(0xFF181c1c),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: isPremium ? Colors.white.withOpacity(0.9) : const Color(0xFF6B7D75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
