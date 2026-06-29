import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_client.dart';

class ProductProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Category> _categories = [];
  List<Product> _products = [];
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  String _sortMode = ''; // price_asc, price_desc, name_asc

  bool get isLoading => _isLoading;
  List<Category> get categories => _categories;
  List<Product> get products {
    List<Product> filtered = _products;
    
    if (_selectedCategoryId != 'all') {
      filtered = filtered.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    if (_sortMode == 'price_asc') {
      filtered.sort((a, b) => a.publicPrice.compareTo(b.publicPrice));
    } else if (_sortMode == 'price_desc') {
      filtered.sort((a, b) => b.publicPrice.compareTo(a.publicPrice));
    } else if (_sortMode == 'name_asc') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return filtered;
  }
  
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String get sortMode => _sortMode;

  ProductProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Charger les catégories depuis le backend
      try {
        final catResponse = await apiClient.client.get('/categories');
        if (catResponse.statusCode == 200) {
          final List<dynamic> catData = catResponse.data;
          _categories = catData.map((json) => Category(
            id: json['id']?.toString() ?? '',
            name: json['name'] ?? '',
          )).toList();
        }
      } catch (e) {
        debugPrint('Erreur lors du chargement des catégories: $e');
        _categories = [
          Category(id: 'all', name: 'Alimentaire'),
          Category(id: 'c2', name: 'Ménager'),
          Category(id: 'c3', name: 'Cosmétique'),
          Category(id: 'c4', name: 'Textile'),
        ];
      }

      final response = await apiClient.client.get('/products');
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List<dynamic> productList = [];
        
        if (responseData is List) {
          productList = responseData;
        } else if (responseData is Map && responseData['products'] is List) {
          productList = responseData['products'];
        }
        
        _products = productList.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Erreur fetchData products: $e');
      // Garder quelques mocks en fallback pour le développement
      if (_products.isEmpty) {
        _products = [
          Product(
            id: 'p1',
            name: 'Riz Parfumé 50kg (Fallback)',
            description: 'Sac de 50kg de riz brisé parfumé de qualité supérieure.',
            publicPrice: 22500,
            proPrice: 20500,
            imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&q=80&w=500',
            categoryId: 'c1',
            badge: 'promo',
          ),
        ];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void sortProducts(String mode) {
    _sortMode = mode;
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
