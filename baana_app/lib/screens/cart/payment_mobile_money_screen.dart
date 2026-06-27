import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/baana_input.dart';
import '../../widgets/baana_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/cart_provider.dart';

class PaymentMobileMoneyScreen extends StatefulWidget {
  const PaymentMobileMoneyScreen({super.key});

  @override
  State<PaymentMobileMoneyScreen> createState() => _PaymentMobileMoneyScreenState();
}

class _PaymentMobileMoneyScreenState extends State<PaymentMobileMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      FocusScope.of(context).unfocus();
      
      // Simulation d'un appel API vers PayDunya / Wave / Orange Money
      await Future.delayed(const Duration(seconds: 2));
      
      // Redirection URL vers une page de paiement mobile (ex: PayDunya)
      final Uri url = Uri.parse('https://paydunya.com/checkout/invoice/mock');
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Erreur url_launcher: $e');
      }

      if (mounted) {
        setState(() => _isLoading = false);
        // On va vers la confirmation
        context.read<CartProvider>().clear();
        context.push('/confirmation');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: BaanaColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Paiement',
            style: TextStyle(
              fontFamily: BaanaTypography.headlineFont,
              color: BaanaColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Carte Premium Mobile Money
                _buildPremiumPaymentCard(),
                
                const SizedBox(height: 48),
                
                Text(
                  'Numéro Mobile Money',
                  style: TextStyle(
                    fontFamily: BaanaTypography.headlineFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BaanaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saisissez le numéro associé à votre compte Wave ou Orange Money.',
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    color: BaanaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                
                BaanaInput(
                  controller: _phoneController,
                  labelText: 'Numéro de téléphone',
                  hintText: '77 123 45 67',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_android, color: BaanaColors.textSecondary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Requis';
                    if (val.trim().length < 9) return 'Numéro invalide';
                    return null;
                  },
                ),

                const SizedBox(height: 48),

                BaanaButton(
                  text: 'Valider le paiement',
                  isLoading: _isLoading,
                  onPressed: _processPayment,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 16, color: BaanaColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Paiement 100% sécurisé',
                      style: TextStyle(
                        fontFamily: BaanaTypography.bodyFont,
                        color: BaanaColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPaymentCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // Bleu profond
            Color(0xFF3B82F6), // Bleu vif (Rappel Wave/Orange)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Effets visuels (Cercles)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.nfc, color: Colors.white, size: 32),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'MOBILE MONEY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Baana Pay',
                  style: TextStyle(
                    fontFamily: BaanaTypography.headlineFont,
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Paiement rapide et sécurisé via Wave & Orange Money',
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
