import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalItemQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get subtotalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  double get deliveryFee {
    // Logique basique: Livraison gratuite si plus de 50000 FCFA, sinon 2000 FCFA
    // TODO: À lier avec le profil de l'utilisateur (Membre Pro = Livraison Gratuite)
    if (subtotalAmount >= 50000 || _items.isEmpty) {
      return 0.0;
    }
    return 2000.0; 
  }

  double get totalAmount {
    return subtotalAmount + deliveryFee;
  }

  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      // Met à jour la quantité si le produit est déjà dans le panier
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      // Ajoute le nouveau produit
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(),
          product: product,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    _items.update(
      productId,
      (existingCartItem) => CartItem(
        id: existingCartItem.id,
        product: existingCartItem.product,
        quantity: newQuantity,
      ),
    );
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
