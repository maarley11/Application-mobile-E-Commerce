import 'package:flutter/material.dart';
import '../services/api_client.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<String> _favoriteIds = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> loadFavorites() async {
    try {
      final response = await apiClient.client.get('/favorites');
      if (response.statusCode == 200) {
        final List<dynamic> products = response.data;
        _favoriteIds = products.map((p) => p['id'].toString()).toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur loadFavorites: $e');
    }
  }

  Future<void> toggleFavorite(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_favoriteIds.contains(productId)) {
        await apiClient.client.delete('/favorites/$productId');
        _favoriteIds.remove(productId);
      } else {
        await apiClient.client.post('/favorites', data: {
          'productId': int.parse(productId),
        });
        _favoriteIds.add(productId);
      }
    } catch (e) {
      debugPrint('Erreur toggleFavorite: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
