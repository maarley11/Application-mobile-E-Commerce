import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/colors.dart';
import '../config/typography.dart';
import 'home_screen.dart';
import 'catalog_screen.dart';
import 'profile/profile_screen.dart';
import 'order/order_history_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const CatalogScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3), // Plus transparent pour le vrai Glassmorphism
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: BaanaColors.primary.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home, 'Accueil'),
                    _buildNavItem(1, Icons.grid_view_outlined, Icons.grid_view, 'Catalogue'),
                    _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long, 'Commandes'),
                    _buildNavItem(3, Icons.person_outline, Icons.person, 'Profil'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconData, IconData activeIconData, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? BaanaColors.primary : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(32),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIconData : iconData,
              color: isSelected ? Colors.white : const Color(0xFF00422B), // Vert forêt très foncé et saturé
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: BaanaTypography.bodyFont,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, // Légèrement plus épais pour bien lire la couleur
                color: isSelected ? Colors.white : const Color(0xFF00422B), // Vert forêt très foncé
              ),
            ),
          ],
        ),
      ),
    );
  }
}
