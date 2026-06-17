import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/baana_button.dart';
import '../../providers/cart_provider.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Vider le panier s'il ne l'est pas déjà (sécurité)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().clear();
    });

    return Scaffold(
      backgroundColor: BaanaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation ou icône de succès
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: BaanaColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: BaanaColors.primary,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Commande confirmée !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: BaanaTypography.headlineFont,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: BaanaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Merci pour votre confiance. Votre commande a été enregistrée avec succès et sera traitée dans les plus brefs délais.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  fontSize: 16,
                  color: BaanaColors.textSecondary,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BaanaColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: BaanaColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Numéro de commande',
                            style: TextStyle(
                              fontFamily: BaanaTypography.bodyFont,
                              color: BaanaColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '#BAANA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                            style: TextStyle(
                              fontFamily: BaanaTypography.headlineFont,
                              color: BaanaColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              BaanaButton(
                text: 'Suivre ma commande',
                onPressed: () {
                  // TODO: Rediriger vers l'onglet Commandes (index 2 du MainLayout)
                  context.go('/home'); // En attendant, on retourne à l'accueil
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go('/home');
                },
                child: Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    fontFamily: BaanaTypography.headlineFont,
                    color: BaanaColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
