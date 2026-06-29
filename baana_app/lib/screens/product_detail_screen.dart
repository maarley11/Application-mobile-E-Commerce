import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/baana_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();
    final isPro = context.watch<AuthProvider>().isPro;
    final product = provider.getProductById(widget.productId);

    if (product == null) {
      return Scaffold(
        backgroundColor: BaanaColors.background,
        appBar: AppBar(title: Text('Produit introuvable')),
        body: Center(child: Text('Le produit sélectionné n\'existe pas.')),
      );
    }

    // Récupération de la catégorie (sécurisée)
    final categoryName = provider.categories.firstWhere(
      (c) => c.id == product.categoryId || (c.id == 'all' && product.categoryId == 'c1'),
      orElse: () => provider.categories.first,
    ).name;

    return Scaffold(
      backgroundColor: BaanaColors.background,
      body: Stack(
        children: [
          // 1. Fond Parallax & Contenu Scrollable
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 450,
                pinned: true,
                stretch: true,
                backgroundColor: BaanaColors.background,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.3),
                        child: IconButton(
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Icon(Icons.arrow_back_ios, color: BaanaColors.primary, size: 20),
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.white.withOpacity(0.3),
                          child: IconButton(
                            icon: const Icon(Icons.favorite_border, color: BaanaColors.primary, size: 22),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      BaanaImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      // Overlay dégradé pour la transition douce avec le contenu en dessous
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                BaanaColors.background,
                                BaanaColors.background.withOpacity(0.8),
                                BaanaColors.background.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Contenu de la page (Premium Card Layout)
              SliverToBoxAdapter(
                child: Container(
                  color: BaanaColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Catégorie
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: BaanaColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          categoryName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: BaanaTypography.bodyFont,
                            color: BaanaColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Titre
                      Text(
                        product.name,
                        style: TextStyle(
                          fontFamily: BaanaTypography.headlineFont,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: BaanaColors.textPrimary,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Prix
                      Row(
                        children: [
                          if (isPro) ...[
                            Text(
                              '${product.publicPrice.toInt()} FCFA',
                              style: TextStyle(
                                fontFamily: BaanaTypography.bodyFont,
                                fontSize: 18,
                                color: BaanaColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${isPro ? product.proPrice.toInt() : product.publicPrice.toInt()} FCFA',
                            style: TextStyle(
                              fontFamily: BaanaTypography.bodyFont,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: BaanaColors.primary,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Informations Rapides (Caractéristiques)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildProFeatureBadge(Icons.star_rounded, '4.9 (128)'),
                          _buildProFeatureBadge(Icons.inventory_2_outlined, 'En Stock'),
                          _buildProFeatureBadge(Icons.local_shipping_outlined, '24H-48H'),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Section Quantité
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: BaanaColors.primary.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Quantité',
                              style: TextStyle(
                                fontFamily: BaanaTypography.headlineFont,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: BaanaColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            // Stepper de Luxe
                            Container(
                              decoration: BoxDecoration(
                                color: BaanaColors.background,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: BaanaColors.textSecondary),
                                    onPressed: _decrement,
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '$_quantity',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: BaanaTypography.bodyFont,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: BaanaColors.primary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: BaanaColors.primary),
                                    onPressed: _increment,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Description
                      Text(
                        'Détails du produit',
                        style: TextStyle(
                          fontFamily: BaanaTypography.headlineFont,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: BaanaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontFamily: BaanaTypography.bodyFont,
                          fontSize: 16,
                          height: 1.7,
                          color: BaanaColors.textSecondary,
                        ),
                      ),
                      
                      // Padding généreux pour ne pas bloquer le texte sous la bottom bar
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // 3. Barre "Ajouter au Panier" en Verre Dépoli (Sticky Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 24, 
                    right: 24, 
                    top: 20, 
                    bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Prix Total Dynamique
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontFamily: BaanaTypography.bodyFont,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: BaanaColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${((isPro ? product.proPrice : product.publicPrice) * _quantity).toInt()} FCFA',
                              style: TextStyle(
                                fontFamily: BaanaTypography.headlineFont,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: BaanaColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Bouton
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 56, // Bouton légèrement plus grand pour la fiche produit
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<CartProvider>().addItem(product, quantity: _quantity);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} ajouté au panier'),
                                  backgroundColor: BaanaColors.primary,
                                  behavior: SnackBarBehavior.floating, // INDISPENSABLE quand on met un margin
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BaanaColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Ajouter au panier',
                              style: TextStyle(
                                fontFamily: BaanaTypography.headlineFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProFeatureBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: BaanaColors.accent, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontFamily: BaanaTypography.bodyFont,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: BaanaColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
