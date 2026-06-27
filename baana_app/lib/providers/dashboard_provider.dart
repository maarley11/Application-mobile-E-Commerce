import 'package:flutter/material.dart';
import '../services/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _stats;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get stats => _stats;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiClient.client.get('/dashboard/stats');
      _stats = response.data;
    } catch (e) {
      debugPrint('Erreur DashboardStats: $e');
      // Mock data if backend is not fully implemented
      _stats = {
        'totalSpentThisMonth': 0,
        'ordersCount': 0,
        'savingsRealized': 12500, // as shown in mock UI
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
