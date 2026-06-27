import 'product.dart';

class CartItem {
  final String id; // ID unique du panier (peut être différent du product ID si variations)
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double totalPrice(bool isPro) => (isPro ? product.proPrice : product.publicPrice) * quantity;
}
