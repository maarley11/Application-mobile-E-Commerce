import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  Map<String, CartItem> _items = {};
  bool _isLoading = false;

  Map<String, CartItem> get items => {..._items};
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;

  int get totalItemQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double subtotalAmount(bool isPro) {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice(isPro);
    });
    return total;
  }

  double getDeliveryFee(bool isPro, int freeDeliveriesLeft) {
    if (_items.isEmpty) return 0.0;
    if (isPro && freeDeliveriesLeft > 0) return 0.0;
    return 1500.0; 
  }

  double getTotalAmount(bool isPro, int freeDeliveriesLeft) {
    return subtotalAmount(isPro) + getDeliveryFee(isPro, freeDeliveriesLeft);
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final cartItems = await cartService.getCart();
      _items.clear();
      for (var item in cartItems) {
        // La clé côté client peut être le productId pour faciliter les vérifications
        _items[item.product.id] = item; 
      }
    } catch (e) {
      print("Erreur fetchCart: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_items.containsKey(product.id)) {
        final existingItem = _items[product.id]!;
        final newQuantity = existingItem.quantity + quantity;
        await cartService.updateCartItem(existingItem.id, newQuantity);
      } else {
        await cartService.addToCart(product.id, quantity);
      }
      // Re-fetch pour avoir le bon ID de CartItem généré par la BDD
      await fetchCart();
    } catch (e) {
      print("Erreur addItem: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItem(String productId) async {
    if (!_items.containsKey(productId)) return;
    final cartItemId = _items[productId]!.id;
    _isLoading = true;
    notifyListeners();
    try {
      await cartService.removeFromCart(cartItemId);
      _items.remove(productId);
    } catch (e) {
      print("Erreur removeItem: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (!_items.containsKey(productId)) return;

    if (newQuantity <= 0) {
      await removeItem(productId);
      return;
    }

    final cartItemId = _items[productId]!.id;
    _isLoading = true;
    notifyListeners();
    try {
      await cartService.updateCartItem(cartItemId, newQuantity);
      _items[productId] = CartItem(
        id: cartItemId,
        product: _items[productId]!.product,
        quantity: newQuantity,
      );
    } catch (e) {
      print("Erreur updateQuantity: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
