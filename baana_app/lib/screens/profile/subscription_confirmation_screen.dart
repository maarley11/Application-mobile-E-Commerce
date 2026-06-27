import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../config/colors.dart';

class SubscriptionConfirmationScreen extends StatefulWidget {
  final String plan;

  const SubscriptionConfirmationScreen({Key? key, required this.plan}) : super(key: key);

  @override
  State<SubscriptionConfirmationScreen> createState() => _SubscriptionConfirmationScreenState();
}

class _SubscriptionConfirmationScreenState extends State<SubscriptionConfirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int get _amount {
    return widget.plan.toLowerCase() == 'hebdo' ? 2500 : 8000;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final String transactionId = '#PRO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    return Scaffold(
      backgroundColor: BaanaColors.background,
      body: Stack(
        children: [
          // Background organic decorations
          Positioned(
            top: 80,
            left: -24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 256,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFfd761a).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 128,
            left: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: const Color(0xFF006c49).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Abstract confetti
          Positioned(
            top: 160,
            left: 40,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: Opacity(
                opacity: 0.4,
                child: const Icon(Icons.star, color: Color(0xFF006c49), size: 32),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Success Icon with Halo
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 144,
                                    height: 144,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10b981).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: 96,
                              height: 96,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10b981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 56,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Headline
                        Text(
                          'Abonnement Pro Activé !',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFF181c1c),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Order Number
                        Text(
                          transactionId,
                          style: textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFffb875), // secondary-fixed-dim
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Compact Summary Section
                        Container(
                          padding: const EdgeInsets.only(top: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFFe0e3e1)), // surface-variant
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                'Plan sélectionné',
                                widget.plan.toUpperCase(),
                                textTheme,
                              ),
                              const SizedBox(height: 24),
                              _buildSummaryRow(
                                'Renouvellement',
                                widget.plan.toLowerCase() == 'hebdo' ? 'Dans 7 jours' : 'Dans 1 mois',
                                textTheme,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total payé',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: const Color(0xFF181c1c),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(_amount),
                                    style: textTheme.titleLarge?.copyWith(
                                      color: BaanaColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons Footer
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BaanaColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => context.go('/dashboard_pro'),
                          child: Text(
                            'Accéder à mon Dashboard',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: BaanaColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => context.go('/home'),
                          child: Text(
                            'Retour à l\'accueil',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: BaanaColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF3c4a42), // on-surface-variant
          ),
        ),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF181c1c),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
