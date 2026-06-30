import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/baana_input.dart';
import '../widgets/baana_input.dart';
import '../models/product.dart';
import 'dart:ui';
import '../widgets/baana_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context, ProductProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trier par', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Prix : Croissant'),
              trailing: provider.sortMode == 'price_asc' ? const Icon(Icons.check, color: BaanaColors.primary) : null,
              onTap: () {
                provider.sortProducts('price_asc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Prix : Décroissant'),
              trailing: provider.sortMode == 'price_desc' ? const Icon(Icons.check, color: BaanaColors.primary) : null,
              onTap: () {
                provider.sortProducts('price_desc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Nom : A-Z'),
              trailing: provider.sortMode == 'name_asc' ? const Icon(Icons.check, color: BaanaColors.primary) : null,
              onTap: () {
                provider.sortProducts('name_asc');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaanaColors.background,
      body: Stack(
        children: [
          // Fond uni
          const Positioned.fill(
            child: ColoredBox(color: BaanaColors.background),
          ),
          
          // Le SafeArea est retiré pour que le scroll aille jusqu'aux bords de l'écran (derrière le menu et le header)
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                await provider.fetchData();
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Glassmorphism Header (Pinned)
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    backgroundColor: Colors.white.withOpacity(0.3), // Verre beaucoup plus transparent
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    collapsedHeight: 80,
                    toolbarHeight: 80,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo/baana_logo.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, color: BaanaColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bonjour, ${context.watch<AuthProvider>().currentName.split(' ').first}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: BaanaTypography.headlineFont,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: BaanaColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 16),
                      child: Row(
                        children: [
                          // Cart Icon with Badge
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shopping_cart_outlined, color: BaanaColors.textPrimary),
                                onPressed: () => context.push('/cart'),
                              ),
                              if (context.watch<CartProvider>().itemCount > 0)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: BaanaColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${context.watch<CartProvider>().itemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: BaanaColors.textPrimary),
                            onPressed: () => context.push('/notifications'),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: BaanaColors.inputBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.shopping_bag_outlined, color: BaanaColors.textPrimary),
                                  onPressed: () => context.push('/orders'),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: BaanaColors.cta, // Orange
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: BaanaColors.primary,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(28),
                          bottomRight: Radius.circular(12),
                          bottomLeft: Radius.circular(32),
                        ),
                      ),
                      child: BaanaInput(
                        controller: _searchController,
                        onChanged: (val) => provider.searchProducts(val),
                        hintText: 'Rechercher un produit...',
                        prefixIcon: const Icon(Icons.search, color: BaanaColors.textSecondary),
                        suffixIcon: PopupMenuButton<String>(
                          onSelected: (value) => provider.sortProducts(value),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          offset: const Offset(0, 50),
                          icon: Container(
                            decoration: const BoxDecoration(
                              color: BaanaColors.primary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(24),
                                bottomRight: Radius.circular(8),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.tune, color: Colors.white, size: 20),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'price_asc',
                              child: Text('Prix : Croissant'),
                            ),
                            const PopupMenuItem(
                              value: 'price_desc',
                              child: Text('Prix : Décroissant'),
                            ),
                            const PopupMenuItem(
                              value: 'name_asc',
                              child: Text('Nom : A-Z'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Promo Banner
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPromoBanner(),
                        const SizedBox(width: 16),
                        _buildPromoBanner(color: BaanaColors.accent), // Another banner partly visible
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Categories Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Catégories',
                          style: TextStyle(
                            fontFamily: BaanaTypography.headlineFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: BaanaColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => provider.selectCategory('all'),
                          child: Text(
                            'Voir tout',
                            style: TextStyle(
                              fontFamily: BaanaTypography.bodyFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: BaanaColors.primary, // Green text
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Categories Icons
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: provider.isLoading
                        ? _buildShimmerCategories()
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 20),
                            itemBuilder: (context, index) {
                              final category = provider.categories[index];
                              final isSelected = category.id == provider.selectedCategoryId || (index == 0 && provider.selectedCategoryId == 'all');
                              return GestureDetector(
                                onTap: () => provider.selectCategory(category.id),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: isSelected ? BaanaColors.primary : BaanaColors.inputBackground,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(32),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: BaanaColors.primary.withOpacity(0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(category.name),
                                        color: isSelected ? BaanaColors.textPrimary : BaanaColors.textSecondary,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontFamily: BaanaTypography.bodyFont,
                                        fontSize: 14,
                                        color: BaanaColors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Flash Sales Section (Nouveau)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              'Ventes Flash',
                              style: TextStyle(
                                fontFamily: BaanaTypography.headlineFont,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: BaanaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: BaanaColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.timer_outlined, color: BaanaColors.error, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '02:15:30',
                                    style: TextStyle(
                                      color: BaanaColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: provider.isLoading 
                          ? _buildShimmerCategories() // Placeholder temporaire
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.products.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final product = provider.products.reversed.toList()[index];
                                final isPro = context.watch<AuthProvider>().isPro;
                                return _buildFlashSaleCard(product, isPro);
                              },
                            ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Produits Vedettes Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pour vous',
                          style: TextStyle(
                            fontFamily: BaanaTypography.headlineFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: BaanaColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Filtres',
                          style: TextStyle(
                            fontFamily: BaanaTypography.bodyFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: BaanaColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Grille de Produits
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: provider.isLoading
                      ? _buildShimmerGrid()
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.58, // Ajusté pour éviter l'overflow
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = provider.products[index];
                              final isPro = context.watch<AuthProvider>().isPro;
                              return ProductCard(
                                product: product,
                                isPro: isPro,
                                onTap: () => context.push('/product/${product.id}'),
                              );
                            },
                            childCount: provider.products.length,
                          ),
                        ),
                ),

                // Espace supplémentaire en bas pour que le dernier produit puisse défiler AU-DESSUS du menu flottant
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            );
          },
        ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner({Color? color}) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF0D5C3A), // Dark green background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(32),
          bottomLeft: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? const Color(0xFF0D5C3A)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=600'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(BaanaColors.primary.withOpacity(0.3), BlendMode.srcATop),
        ),
      ),
      child: Stack(
        children: [
          // Adinkra Watermark (Touche Africaine)
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.15,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBZtXMVu9JoIVPR-6TMrJfUM_25GS-q7VbBXukBuJYii-GuN2dxcFZZK0U23O6YrAiTw5VSEIf0_N4Lpe_8WRkR_lMOpsmuzTZNZlQam8XJcepJd-Gx56t9YLPxUu4y4zJn55djoH2pCMwyd6EOSGRVX_oBVxbLETS3pwlsX5R1SWYL-151TJ2Wcvwwj50l99yKhldY_Jawc6hkEmEpO7LCswiO51CIZcoU0ZEq4dQbwe4QxRzNbwL02KQ7bCOAKQ7TxqhK-2TAbAM',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: BaanaColors.cta, // Orange
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(2),
                    ),
                  ),
                  child: const Text(
                    'PROMO DU JOUR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Arrivages Fruits Frais\nde Casamance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    if (name.toLowerCase().contains('aliment')) return Icons.local_grocery_store_outlined;
    if (name.toLowerCase().contains('ménag')) return Icons.cleaning_services_outlined;
    if (name.toLowerCase().contains('cosm')) return Icons.face_outlined;
    if (name.toLowerCase().contains('textil')) return Icons.checkroom_outlined;
    return Icons.category_outlined;
  }

  Widget _buildFlashSaleCard(Product product, bool isPro) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(4),
                    ),
                    child: BaanaImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: const BoxDecoration(
                      color: BaanaColors.error,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '-20%',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${((isPro ? product.proPrice : product.publicPrice) * 0.8).toInt()} FCFA',
                  style: const TextStyle(
                    color: BaanaColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCategories() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(width: 20),
      itemBuilder: (context, index) {
        return const ShimmerLoading(
          child: Column(
            children: [
              ShimmerPlaceholder(width: 64, height: 64, borderRadius: 32),
              SizedBox(height: 8),
              ShimmerPlaceholder(width: 60, height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const ShimmerLoading(
            child: ShimmerPlaceholder(width: double.infinity, height: double.infinity, borderRadius: 12),
          );
        },
        childCount: 4,
      ),
    );
  }
}
