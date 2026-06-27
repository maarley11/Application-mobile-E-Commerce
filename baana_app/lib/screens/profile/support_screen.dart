import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart';
import 'dart:ui';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchUrl(String urlString, BuildContext context) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action impossible sur cet appareil')),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: BaanaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Besoin d'aide ?",
          style: textTheme.headlineSmall?.copyWith(
            color: BaanaColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // 1. Fond premium
          const Positioned.fill(
            child: ColoredBox(color: BaanaColors.background),
          ),
          
          // 2. Motif Manjak subtil (Dotted pattern from mockup)
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPatternPainter(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text.rich(
                      TextSpan(
                        text: "L'Artisanat ",
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: BaanaColors.textPrimary,
                          height: 1.1,
                        ),
                        children: [
                          TextSpan(
                            text: "Digital\n",
                            style: TextStyle(
                              color: BaanaColors.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const TextSpan(text: "au service de votre succès."),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Advisor Profile (Asymmetrical)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Transform.rotate(
                        angle: -0.05, // ~ -2 degrees
                        child: Container(
                          width: 150,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(60),
                            ),
                            border: Border.all(color: BaanaColors.primary, width: 2),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCGJM6KcLU1KIP9Xe7lUqto6gDUdB1hCyZPJ093aZi1QLngd3Ywttaz9ESPqx2srm3HwG5egxNWTBmU1K3bVNIRD9d057Hh7Rj9lQOHA_KhUHUftxNVX3Hu7w0OcSvzH1B9dYAR-IqqgbLdHUJc2j53X0cKKpGa1IZ_BrlM8Oal0BCqLB-A8yxEHrMMeR55M5XWleiRRxc0b8AlT41QEb_YcHdLmSJdK71kIYa_IeKNsilDKtYFYqLmjlRBgxZ5s7v7HDH3XoemEKQ',
                              ),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BaanaColors.primary.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(4, 8),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOTRE CONSEILLER',
                              style: textTheme.labelSmall?.copyWith(
                                color: BaanaColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Abdoulaye',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: BaanaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: BaanaColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: BaanaColors.primary.withOpacity(0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'EN LIGNE',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: BaanaColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Bento Categories Grid
                  SizedBox(
                    height: 320,
                    child: Row(
                      children: [
                        // Left Column
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildBentoBox(
                                  context: context,
                                  icon: Icons.support_agent_outlined,
                                  title: 'Support Direct',
                                  subtitle: 'Discutez avec nous',
                                  color: BaanaColors.inputBackground,
                                  iconColor: BaanaColors.primary,
                                  titleColor: BaanaColors.textPrimary,
                                  subtitleColor: BaanaColors.textSecondary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(28),
                                    bottomLeft: Radius.circular(32),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  onTap: () => _launchUrl("https://wa.me/221770000000", context),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                flex: 2,
                                child: _buildBentoBox(
                                  context: context,
                                  icon: Icons.menu_book_outlined,
                                  title: 'Guides',
                                  subtitle: 'Apprendre à vendre',
                                  color: BaanaColors.primary.withOpacity(0.1),
                                  iconColor: BaanaColors.primary,
                                  titleColor: BaanaColors.primary,
                                  subtitleColor: BaanaColors.primary.withOpacity(0.7),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(28),
                                    topRight: Radius.circular(14),
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(32),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right Column
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Transform.rotate(
                                  angle: 0.05,
                                  child: _buildBentoBox(
                                    context: context,
                                    icon: Icons.chat_bubble_outline,
                                    title: 'CHAT',
                                    color: BaanaColors.accent.withOpacity(0.2),
                                    iconColor: BaanaColors.accent,
                                    titleColor: BaanaColors.accent,
                                    centerTitle: true,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(28),
                                      bottomLeft: Radius.circular(32),
                                      bottomRight: Radius.circular(12),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                flex: 3,
                                child: _buildBentoBox(
                                  context: context,
                                  icon: Icons.local_shipping_outlined,
                                  title: 'Livraisons',
                                  color: BaanaColors.inputBackground,
                                  iconColor: BaanaColors.accent,
                                  titleColor: BaanaColors.textPrimary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(14),
                                    bottomRight: Radius.circular(28),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(28),
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(color: BaanaColors.textSecondary.withOpacity(0.2), width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Rechercher une solution...',
                              border: InputBorder.none,
                              hintStyle: textTheme.bodyLarge?.copyWith(color: BaanaColors.textSecondary),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: BaanaColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.search, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // FAQ Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FAQ POPULAIRES',
                        style: textTheme.labelSmall?.copyWith(
                          color: BaanaColors.accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 40,
                        height: 2,
                        color: BaanaColors.accent.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // FAQs
                  _buildFaqItem(
                    context,
                    question: 'Comment activer Baana Pro ?',
                    answer: "L'activation se fait directement depuis votre tableau de bord. Il suffit de sélectionner le forfait 'Artisan' et de suivre les étapes de vérification.",
                  ),
                  _buildFaqItem(
                    context,
                    question: 'Délais de paiement',
                    answer: "Les fonds sont transférés sur votre compte Wave ou Orange Money sous 24h ouvrées après validation de la livraison.",
                  ),
                  _buildFaqItem(
                    context,
                    question: 'Gestion des stocks',
                    answer: "Vous pouvez mettre à jour vos stocks en temps réel via l'application mobile Baana.",
                  ),

                  const SizedBox(height: 40),
                  // CTA Call
                  InkWell(
                    onTap: () => _launchUrl("tel:+221770000000", context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(28),
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: BaanaColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(28),
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: BaanaColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.call, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'NOUS APPELER DIRECTEMENT',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Disponible du Lundi au Samedi, 9h - 19h',
                      style: textTheme.bodySmall?.copyWith(color: BaanaColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoBox({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required Color iconColor,
    required Color titleColor,
    Color? subtitleColor,
    required BorderRadius borderRadius,
    bool centerTitle = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          border: Border.all(color: BaanaColors.textSecondary.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor, size: 32),
            if (centerTitle) const SizedBox(height: 8),
            Column(
              crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, {required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: BaanaColors.textSecondary.withOpacity(0.2), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w700, color: BaanaColors.textPrimary),
          ),
          iconColor: BaanaColors.primary,
          collapsedIconColor: BaanaColors.primary,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(
              answer,
              style: const TextStyle(color: BaanaColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4DDD8).withOpacity(0.5) // Couleur des points subtils
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    const double radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
