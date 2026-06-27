import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_client.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiClient.client.get('/orders/history');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _orders = data.map((json) => Order.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Erreur fetchOrders: $e');
      // Mocks en fallback
      _orders = [
        Order(
          id: 'CMD-8829',
          orderNumber: '#SDP-8829',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          totalAmount: 45000,
          status: OrderStatus.delivering,
          items: [
            OrderItem(productId: '1', title: 'Riz Parfumé 25kg', quantity: 1, price: 20000),
          ],
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(List<dynamic> items, double totalAmount, String paymentMethod) async {
    _isLoading = true;
    notifyListeners();

    try {
      await apiClient.client.post('/orders', data: {
        'items': items,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
      });
      // Optionally re-fetch history
      await fetchOrders();
    } catch (e) {
      debugPrint('Erreur createOrder: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }
}
