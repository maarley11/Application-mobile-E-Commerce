import 'package:flutter/material.dart';
import '../models/product.dart';
import '../config/colors.dart';
import '../config/typography.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isPro;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Sans fond
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(60),
                          bottomLeft: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: BaanaColors.primary.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(60),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: BaanaColors.inputBackground,
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: BaanaColors.textSecondary),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // PRO badge
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: BaanaColors.accent, // Secondary Container / Orange
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.badge!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // "+" Button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: BaanaColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: BaanaTypography.headlineFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BaanaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            if (isPro)
              Text(
                '${product.publicPrice.toInt()} FCFA',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  fontSize: 12,
                  color: BaanaColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Text(
              '${isPro ? product.proPrice.toInt() : product.publicPrice.toInt()} FCFA',
              style: TextStyle(
                fontFamily: BaanaTypography.headlineFont,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: BaanaColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
