import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart'; // Import for the artistic background
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class DashboardProScreen extends StatefulWidget {
  const DashboardProScreen({Key? key}) : super(key: key);

  @override
  State<DashboardProScreen> createState() => _DashboardProScreenState();
}

class _DashboardProScreenState extends State<DashboardProScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final stats = dashboardProvider.stats ?? {};
    
    final String name = authProvider.currentName.isNotEmpty ? authProvider.currentName : 'Pro';
    final String planName = authProvider.isPro ? authProvider.proPlan.toUpperCase() : 'AUCUN PLAN';
    final String expiration = authProvider.proExpirationDate != null 
        ? 'Expire le ${authProvider.proExpirationDate!.day.toString().padLeft(2, '0')}/${authProvider.proExpirationDate!.month.toString().padLeft(2, '0')}/${authProvider.proExpirationDate!.year}'
        : 'Abonnez-vous pour profiter de Pro';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Baana Pro',
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
          
          // 2. Contenu principal avec SafeArea
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    'Espace de $name',
                    style: textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BaanaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active Subscription Card (Premium Style)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          BaanaColors.primary,
                          const Color(0xFF003322), // Darker emerald
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: BaanaColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: BaanaColors.accent.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Filigrane abstrait en arrière plan de la carte
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Icon(
                            Icons.workspace_premium,
                            size: 150,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: BaanaColors.accent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'ABONNEMENT ACTIF',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: BaanaColors.accent,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              authProvider.isPro ? 'PREMIUM $planName' : 'NON ABONNÉ',
                              style: textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              expiration,
                              style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: BaanaColors.cta.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!authProvider.isPro) {
                                      context.push('/subscription_compare');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: BaanaColors.cta,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    authProvider.isPro ? 'Renouveler' : 'S\'abonner',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // 2x2 Grid for KPIs (Glassmorphism style)
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassKpiCard(
                          context,
                          title: '${stats['savingsRealized'] ?? 12500} FCFA',
                          subtitle: 'Économies',
                          icon: Icons.savings_rounded,
                          iconColor: BaanaColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGlassKpiCard(
                          context,
                          title: '${stats['ordersCount'] ?? 8}',
                          subtitle: 'Commandes',
                          icon: Icons.inventory_2_rounded,
                          iconColor: BaanaColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassKpiCard(
                          context,
                          title: '${authProvider.freeDeliveriesLeft}/3',
                          subtitle: 'Livraisons gratuites',
                          icon: Icons.two_wheeler_rounded,
                          iconColor: BaanaColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGlassKpiCard(
                          context,
                          title: '${authProvider.loyaltyPoints}',
                          subtitle: 'Points fidélité',
                          icon: Icons.stars_rounded,
                          iconColor: BaanaColors.accent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Last Orders Section
                  Text(
                    'Dernières commandes',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BaanaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Item (Glassmorphism)
                  _buildGlassOrderItem(context),
                  const SizedBox(height: 12),
                  _buildGlassOrderItem(context, orderId: 'CMD-8828', date: '10 Sept. 2023', status: 'LIVRÉ'),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassKpiCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: BaanaColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: BaanaColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassOrderItem(BuildContext context, {String orderId = 'CMD-8829', String date = '14 Sept. 2023', String status = 'LIVRÉ'}) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.receipt_long_rounded, color: BaanaColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderId,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: textTheme.bodyMedium?.copyWith(color: BaanaColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: BaanaColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: BaanaColors.primary.withOpacity(0.2)),
                ),
                child: Text(
                  status,
                  style: textTheme.labelMedium?.copyWith(
                    color: BaanaColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
