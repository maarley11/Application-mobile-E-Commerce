import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/baana_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'mobile_money'; // 'mobile_money' ou 'cash'

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: BaanaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Paiement',
          style: TextStyle(
            fontFamily: BaanaTypography.headlineFont,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: BaanaColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Adresse de livraison'),
            const SizedBox(height: 16),
            _buildAddressCard(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Méthode de paiement'),
            const SizedBox(height: 16),
            _buildPaymentMethodOption(
              id: 'mobile_money',
              title: 'Mobile Money (Wave, Orange, Free)',
              icon: Icons.phone_android,
              isSelected: _selectedPaymentMethod == 'mobile_money',
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodOption(
              id: 'cash',
              title: 'Paiement à la livraison',
              icon: Icons.money,
              isSelected: _selectedPaymentMethod == 'cash',
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Résumé de la commande'),
            const SizedBox(height: 16),
            _buildOrderSummary(cartProvider),
            
            const SizedBox(height: 48),
            BaanaButton(
              text: 'Confirmer & Payer',
              onPressed: () {
                if (_selectedPaymentMethod == 'mobile_money') {
                  context.push('/payment_mobile_money');
                } else {
                  // Directement à la confirmation
                  cartProvider.clear();
                  context.push('/confirmation');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: BaanaTypography.headlineFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: BaanaColors.textPrimary,
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BaanaColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BaanaColors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: BaanaColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Domicile',
                  style: TextStyle(
                    fontFamily: BaanaTypography.headlineFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BaanaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quartier Almadies, Rue 10, Dakar\nSénégal',
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    fontSize: 14,
                    color: BaanaColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: BaanaColors.primary),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? BaanaColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? BaanaColors.primary : BaanaColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? BaanaColors.primary : BaanaColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: BaanaTypography.headlineFont,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? BaanaColors.primary : BaanaColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: BaanaColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BaanaColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sous-total',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  color: BaanaColors.textSecondary,
                ),
              ),
              Text(
                '${provider.subtotalAmount} FCFA',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  fontWeight: FontWeight.w600,
                  color: BaanaColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Livraison',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  color: BaanaColors.textSecondary,
                ),
              ),
              Text(
                provider.deliveryFee == 0 ? 'Gratuite' : '${provider.deliveryFee} FCFA',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  fontWeight: FontWeight.w600,
                  color: provider.deliveryFee == 0 ? BaanaColors.primary : BaanaColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontFamily: BaanaTypography.headlineFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BaanaColors.textPrimary,
                ),
              ),
              Text(
                '${provider.totalAmount} FCFA',
                style: TextStyle(
                  fontFamily: BaanaTypography.headlineFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: BaanaColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
