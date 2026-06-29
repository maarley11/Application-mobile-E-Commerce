import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart';
import 'dart:ui';

class LearnToSellScreen extends StatelessWidget {
  const LearnToSellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final List<Map<String, dynamic>> sections = [
      {
        'icon': Icons.storefront_outlined,
        'title': 'Comment vendre sur Baana',
        'items': [
          '1. Créez votre compte professionnel en renseignant votre NINEA et le nom de votre entreprise.',
          '2. Souscrivez à un abonnement Pro (Mensuel ou Annuel) pour accéder aux prix grossiste.',
          '3. Passez vos commandes en gros à prix réduit et revendez à prix public.',
          '4. Utilisez le tableau de bord Pro pour suivre vos performances.',
        ],
      },
      {
        'icon': Icons.trending_up_outlined,
        'title': 'Optimiser vos ventes',
        'items': [
          '• Commandez en quantité pour bénéficier des meilleurs prix Pro.',
          '• Profitez des Ventes Flash pour des réductions supplémentaires.',
          '• Diversifiez votre catalogue en explorant toutes les catégories.',
          '• Fidélisez vos clients avec des prix compétitifs grâce à vos marges Pro.',
        ],
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Gérer vos commandes',
        'items': [
          '• Suivez chaque commande en temps réel depuis l\'écran "Mes Commandes".',
          '• Utilisez le suivi GPS pour savoir exactement où en est votre livraison.',
          '• Téléchargez vos factures PDF depuis la section "Factures" de votre profil.',
          '• Contactez le support en cas de problème via WhatsApp ou téléphone.',
        ],
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'title': 'Conseils pour les Pros',
        'items': [
          '• L\'abonnement annuel est plus économique que le mensuel (économie de 2 mois).',
          '• Cumulez des points de fidélité à chaque commande livrée.',
          '• Les livraisons gratuites sont incluses dans l\'abonnement Pro (3/semaine).',
          '• Recommandez Baana à d\'autres commerçants pour agrandir le réseau.',
        ],
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Apprendre à vendre',
          style: textTheme.headlineSmall?.copyWith(color: BaanaColors.primary, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: ArtisticBackgroundPainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [BaanaColors.primary.withOpacity(0.15), BaanaColors.accent.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.school_outlined, size: 48, color: BaanaColors.primary),
                            const SizedBox(height: 12),
                            Text(
                              'Devenez un expert de la vente en gros',
                              textAlign: TextAlign.center,
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: BaanaColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Découvrez comment maximiser vos profits avec Baana.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(color: BaanaColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sections
                  ...sections.map((section) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: BaanaColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(section['icon'] as IconData, color: BaanaColors.primary),
                            ),
                            title: Text(
                              section['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: BaanaColors.textPrimary),
                            ),
                            iconColor: BaanaColors.primary,
                            collapsedIconColor: BaanaColors.textSecondary,
                            children: (section['items'] as List<String>).map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(item, style: TextStyle(color: BaanaColors.textSecondary, fontSize: 14, height: 1.4)),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
