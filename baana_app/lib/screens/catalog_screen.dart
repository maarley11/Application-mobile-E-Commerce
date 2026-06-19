import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../config/colors.dart';
import '../config/typography.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/animated_reactive_background.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'Tout';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Les données sont déjà fetchées par le constructeur de ProductProvider
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent pour voir le fond animé
      body: Stack(
        children: [
          // Background Animé
          AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              double offset = 0;
              if (_scrollController.hasClients) {
                offset = _scrollController.offset;
              }
              return Positioned.fill(
                child: AnimatedReactiveBackground(scrollOffset: offset),
              );
            },
          ),
          
          Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final categories = ['Tout', ...provider.categories.map((c) => c.name)];
          
          // Filtrage local
          var filteredProducts = provider.products;
          if (_selectedCategory != 'Tout') {
            final catObj = provider.categories.firstWhere((c) => c.name == _selectedCategory, orElse: () => provider.categories.first);
            filteredProducts = filteredProducts.where((p) => p.categoryId == catObj.id).toList();
          }
          if (_searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            filteredProducts = filteredProducts.where((p) => p.name.toLowerCase().contains(query)).toList();
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header premium
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: Colors.white.withOpacity(0.3), // Verre transparent
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: const FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(left: 24, bottom: 16),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image(
                            image: AssetImage('assets/images/logo/baana_logo.png'),
                            height: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Catalogue',
                            style: TextStyle(
                              fontFamily: BaanaTypography.headlineFont,
                              color: BaanaColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 24, 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
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
                          top: 8,
                          right: 8,
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
                    onPressed: () {},
                    icon: const Icon(Icons.tune_rounded, color: BaanaColors.textPrimary),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: BaanaColors.inputBackground,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un produit...',
                        hintStyle: TextStyle(
                          fontFamily: BaanaTypography.bodyFont,
                          color: BaanaColors.textSecondary,
                        ),
                        prefixIcon: const Icon(Icons.search, color: BaanaColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),

              // Categories Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: BaanaColors.primary,
                          labelStyle: TextStyle(
                            fontFamily: BaanaTypography.bodyFont,
                            color: isSelected ? Colors.white : BaanaColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? BaanaColors.primary : BaanaColors.border,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Product Grid
              if (provider.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: BaanaColors.primary),
                    ),
                  ),
                )
              else if (filteredProducts.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Aucun produit trouvé.',
                        style: TextStyle(fontFamily: BaanaTypography.bodyFont),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100), // Espace pour la bottom nav
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(
                          product: filteredProducts[index],
                          onTap: () {},
                        );
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
        ],
      ),
    );
  }
}
