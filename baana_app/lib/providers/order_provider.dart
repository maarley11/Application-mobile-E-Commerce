import 'package:flutter/foundation.dart';
import '../models/order.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    _loadMockOrders();
  }

  void _loadMockOrders() {
    _isLoading = true;
    notifyListeners();

    // Simuler une requête réseau
    Future.delayed(const Duration(milliseconds: 800), () {
      _orders = [
        Order(
          id: 'CMD-8829',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          totalAmount: 45000,
          status: OrderStatus.shipping,
          items: [
            OrderItem(productId: '1', title: 'Riz Parfumé 25kg', quantity: 1, price: 20000),
            OrderItem(productId: '2', title: 'Huile Végétale 5L', quantity: 2, price: 12500),
          ],
        ),
        Order(
          id: 'CMD-8828',
          date: DateTime.now().subtract(const Duration(days: 4)),
          totalAmount: 12500,
          status: OrderStatus.delivered,
          items: [
            OrderItem(productId: '3', title: 'Sucre en Poudre 5kg', quantity: 1, price: 3500),
            OrderItem(productId: '4', title: 'Lait Concentré (Pack)', quantity: 1, price: 9000),
          ],
        ),
        Order(
          id: 'CMD-8825',
          date: DateTime.now().subtract(const Duration(days: 15)),
          totalAmount: 85000,
          status: OrderStatus.delivered,
          items: [
            OrderItem(productId: '1', title: 'Achat en gros (Divers)', quantity: 10, price: 8500),
          ],
        ),
      ];
      _isLoading = false;
      notifyListeners();
    });
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }
}
