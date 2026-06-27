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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId']?.toString() ?? json['Product']?['id']?.toString() ?? '',
      title: json['Product']?['name'] ?? json['title'] ?? 'Produit',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

enum OrderStatus {
  confirmed,    // Commande validée
  preparing,    // En préparation
  delivering,   // En cours de livraison
  delivered,    // Livré
  cancelled,    // Annulé
}

class Order {
  final String id;
  final String orderNumber; // Format: #SDP-XXXXX
  final DateTime date;
  final double totalAmount;
  final OrderStatus status;
  final List<OrderItem> items;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryAddress;

  Order({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.paymentMethod = 'À la livraison',
    this.paymentStatus = 'pending',
    this.deliveryAddress = 'Adresse non renseignée',
  });

  String get statusText {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Commande validée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.delivering:
        return 'En cours de livraison';
      case OrderStatus.delivered:
        return 'Livré';
      case OrderStatus.cancelled:
        return 'Annulé';
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    OrderStatus parsedStatus = OrderStatus.confirmed;
    final String statusStr = (json['status'] ?? '').toString().toLowerCase();
    switch (statusStr) {
      case 'preparing':
        parsedStatus = OrderStatus.preparing;
        break;
      case 'delivering':
      case 'shipping':
        parsedStatus = OrderStatus.delivering;
        break;
      case 'delivered':
        parsedStatus = OrderStatus.delivered;
        break;
      case 'cancelled':
      case 'failed':
        parsedStatus = OrderStatus.cancelled;
        break;
    }

    var itemsList = json['OrderItems'] as List? ?? [];

    return Order(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] ?? '#SDP-????',
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: parsedStatus,
      paymentMethod: json['paymentMethod'] ?? 'À la livraison',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      items: itemsList.map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}
