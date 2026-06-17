import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Category> _categories = [];
  List<Product> _products = [];
  String _selectedCategoryId = 'all';

  bool get isLoading => _isLoading;
  List<Category> get categories => _categories;
  List<Product> get products => _selectedCategoryId == 'all'
      ? _products
      : _products.where((p) => p.categoryId == _selectedCategoryId).toList();
  String get selectedCategoryId => _selectedCategoryId;

  ProductProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    // Simulation d'un appel réseau (2 secondes pour voir le Shimmer)
    await Future.delayed(const Duration(seconds: 2));

    _categories = [
      Category(id: 'all', name: 'Alimentaire'),
      Category(id: 'c2', name: 'Ménager'),
      Category(id: 'c3', name: 'Cosmétique'),
      Category(id: 'c4', name: 'Textile'),
    ];

    _products = [
      Product(
        id: 'p1',
        name: 'Riz Parfumé 50kg',
        description: 'Sac de 50kg de riz brisé parfumé de qualité supérieure.',
        price: 22000,
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&q=80&w=500',
        categoryId: 'c1',
      ),
      Product(
        id: 'p2',
        name: 'Huile d\'Arachide 20L',
        description: 'Bidon de 20 litres d\'huile locale 100% arachide.',
        price: 25000,
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&q=80&w=500',
        categoryId: 'c1',
      ),
      Product(
        id: 'p3',
        name: 'Savon de Marseille',
        description: 'Carton de 50 morceaux de savon.',
        price: 12000,
        imageUrl: 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?auto=format&fit=crop&q=80&w=500',
        categoryId: 'c2',
      ),
      Product(
        id: 'p4',
        name: 'Tissu Wax 6 Yards',
        description: 'Pièce complète de tissu Wax haut de gamme.',
        price: 15000,
        imageUrl: 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&q=80&w=500',
        categoryId: 'c3',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
