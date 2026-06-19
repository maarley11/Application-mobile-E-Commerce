class OrderItem {
  final String productId;
  final String title;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

enum OrderStatus {
  pending,      // Commande validée
  preparing,    // En préparation
  shipping,     // En cours de livraison
  delivered,    // Livré
}

class Order {
  final String id;
  final DateTime date;
  final double totalAmount;
  final OrderStatus status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.status,
    required this.items,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Commande validée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.shipping:
        return 'En cours de livraison';
      case OrderStatus.delivered:
        return 'Livré';
    }
  }
}
