import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item.dart';
import '../../widgets/baana_button.dart';
import '../../widgets/baana_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isPro = authProvider.isPro;
    final freeDeliveriesLeft = authProvider.freeDeliveriesLeft;
    final items = cartProvider.items.values.toList();

    return Scaffold(
      backgroundColor: BaanaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mon Panier',
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
      body: items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCartItem(context, items[index], cartProvider);
                    },
                  ),
                ),
                _buildBottomSummary(context, cartProvider, isPro, freeDeliveriesLeft),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: BaanaColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Votre panier est vide',
            style: TextStyle(
              fontFamily: BaanaTypography.headlineFont,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: BaanaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Découvrez nos produits et remplissez-le !',
            style: TextStyle(
              fontFamily: BaanaTypography.bodyFont,
              fontSize: 14,
              color: BaanaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: BaanaButton(
              text: 'Voir le catalogue',
              onPressed: () {
                // Naviguer vers le catalogue
                context.go('/catalog');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider provider) {
    final isPro = context.watch<AuthProvider>().isPro;
    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.removeItem(item.product.id);
      },
      background: Container(
        decoration: BoxDecoration(
          color: BaanaColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BaanaImage(
                imageUrl: item.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: BaanaColors.inputBackground,
                  child: const Icon(Icons.shopping_bag, color: BaanaColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: BaanaTypography.headlineFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BaanaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isPro ? item.product.proPrice : item.product.publicPrice} FCFA',
                    style: TextStyle(
                      fontFamily: BaanaTypography.bodyFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: BaanaColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Quantité
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: BaanaColors.textSecondary,
                  onPressed: () {
                    provider.updateQuantity(item.product.id, item.quantity - 1);
                  },
                ),
                Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BaanaColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: BaanaColors.primary,
                  onPressed: () {
                    provider.updateQuantity(item.product.id, item.quantity + 1);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, CartProvider provider, bool isPro, int freeDeliveriesLeft) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sous-total',
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    fontSize: 16,
                    color: BaanaColors.textSecondary,
                  ),
                ),
                Text(
                  '${provider.subtotalAmount(isPro).toInt()} FCFA',
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    fontSize: 16,
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
                    fontSize: 16,
                    color: BaanaColors.textSecondary,
                  ),
                ),
                Text(
                  provider.getDeliveryFee(isPro, freeDeliveriesLeft) == 0 ? 'Gratuite' : '${provider.getDeliveryFee(isPro, freeDeliveriesLeft)} FCFA',
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: provider.getDeliveryFee(isPro, freeDeliveriesLeft) == 0 ? BaanaColors.primary : BaanaColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontFamily: BaanaTypography.headlineFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: BaanaColors.textPrimary,
                  ),
                ),
                Text(
                  '${provider.getTotalAmount(isPro, freeDeliveriesLeft)} FCFA',
                  style: TextStyle(
                    fontFamily: BaanaTypography.headlineFont,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: BaanaColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            BaanaButton(
              text: 'Passer la commande',
              onPressed: () {
                context.push('/checkout');
              },
            ),
          ],
        ),
      ),
    );
  }
}
