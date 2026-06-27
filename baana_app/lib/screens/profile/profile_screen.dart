import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/manjak_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = context.watch<AuthProvider>();
    
    final String name = authProvider.currentName.isNotEmpty ? authProvider.currentName : 'Utilisateur';
    final String phone = authProvider.currentPhone.isNotEmpty ? authProvider.currentPhone : 'Numéro inconnu';
    
    // Génération des initiales
    String initials = 'U';
    if (name != 'Utilisateur' && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mon Espace',
          style: textTheme.headlineMedium?.copyWith(
            color: BaanaColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: BaanaColors.primary),
            onPressed: () {
              context.push('/cart');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Fond Artistique Premium
          Positioned.fill(
            child: CustomPaint(
              painter: ArtisticBackgroundPainter(),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Carte de Profil (Glassmorphism)
                  _buildProfileGlassCard(context, name, phone, initials, authProvider.isPro, authProvider.proPlan, authProvider.loyaltyPoints),
                  
                  const SizedBox(height: 32),

                  // Container Menu (Glassmorphism englobant tous les items)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1.5,
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
                          children: [
                            _buildMenuItem(context, Icons.dashboard_outlined, 'Tableau de bord', onTap: () {
                              context.push('/dashboard_pro');
                            }),
                            _buildMenuItem(context, Icons.receipt_long_outlined, 'Commandes', onTap: () {
                              context.push('/orders');
                            }),
                            _buildMenuItem(context, Icons.card_membership_outlined, 'Abonnement', onTap: () {
                              context.push('/subscription_compare');
                            }),
                            _buildMenuItem(context, Icons.location_on_outlined, 'Adresses'),
                            _buildMenuItem(context, Icons.payments_outlined, 'Factures'),
                            _buildMenuItem(context, Icons.chat_bubble_outline, 'Support & Aide', onTap: () {
                              context.push('/support');
                            }),
                            _buildMenuItem(context, Icons.settings_outlined, 'Paramètres', showDivider: false, onTap: () {
                              context.push('/settings');
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button (Glassmorphism Red)
                  _buildLogoutButton(context),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileGlassCard(BuildContext context, String name, String phone, String initials, bool isPro, String plan, int loyaltyPoints) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 1.5,
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
            children: [
              // Avatar avec aura lumineuse
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BaanaColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: BaanaColors.primary,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                name,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: BaanaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              
              Text(
                phone,
                style: textTheme.bodyLarge?.copyWith(
                  color: BaanaColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              
              // Points de fidélité
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: BaanaColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: BaanaColors.accent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$loyaltyPoints Points de fidélité',
                      style: textTheme.labelLarge?.copyWith(
                        color: BaanaColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Pro Badge (Dynamic)
              if (isPro)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        BaanaColors.primary.withOpacity(0.15),
                        BaanaColors.accent.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: BaanaColors.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium, color: BaanaColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Membre Pro ${plan.toUpperCase()}',
                        style: textTheme.labelLarge?.copyWith(
                          color: BaanaColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
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

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap, bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BaanaColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: BaanaColors.primary, size: 22),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BaanaColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: BaanaColors.textSecondary),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            color: BaanaColors.primary.withOpacity(0.1),
            height: 1,
            indent: 24,
            endIndent: 24,
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: BaanaColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BaanaColors.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BaanaColors.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: BaanaColors.error, size: 22),
            ),
            title: Text(
              'Déconnexion',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BaanaColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () {
              context.go('/login');
            },
          ),
        ),
      ),
    );
  }
}
