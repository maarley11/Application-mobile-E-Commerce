import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: BaanaColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: textTheme.headlineMedium?.copyWith(
            color: BaanaColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: BaanaColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Toutes les notifications marquées comme lues')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Effect
          Positioned.fill(
            child: CustomPaint(
              painter: ArtisticBackgroundPainter(),
            ),
          ),
          
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionTitle(context, 'Aujourd\'hui'),
                const SizedBox(height: 16),
                _buildNotificationItem(
                  context,
                  title: 'Commande expédiée',
                  description: 'Votre commande #CMD-8829 est en route et arrivera sous peu.',
                  time: 'Il y a 1h',
                  icon: Icons.local_shipping_outlined,
                  iconColor: BaanaColors.primary,
                  isUnread: true,
                ),
                const SizedBox(height: 12),
                _buildNotificationItem(
                  context,
                  title: 'Alerte Promo Pro',
                  description: 'En tant que Membre Pro, profitez de -20% sur les mangues.',
                  time: 'Il y a 3h',
                  icon: Icons.workspace_premium_outlined,
                  iconColor: BaanaColors.accent,
                  isUnread: true,
                ),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Cette semaine'),
                const SizedBox(height: 16),
                _buildNotificationItem(
                  context,
                  title: 'Paiement confirmé',
                  description: 'Le paiement de 14 500 FCFA pour la commande #CMD-8828 a été reçu.',
                  time: 'Mar. 14 Sept.',
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                  isUnread: false,
                ),
                const SizedBox(height: 12),
                _buildNotificationItem(
                  context,
                  title: 'Points Fidélité ajoutés',
                  description: 'Vous avez gagné 150 points fidélité suite à votre dernière commande.',
                  time: 'Lun. 13 Sept.',
                  icon: Icons.stars_outlined,
                  iconColor: BaanaColors.accent,
                  isUnread: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: BaanaColors.textSecondary,
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isUnread,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnread ? iconColor.withOpacity(0.5) : Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              if (isUnread)
                BoxShadow(
                  color: iconColor.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                              color: BaanaColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: textTheme.labelSmall?.copyWith(
                            color: isUnread ? BaanaColors.primary : BaanaColors.textSecondary,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: BaanaColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
