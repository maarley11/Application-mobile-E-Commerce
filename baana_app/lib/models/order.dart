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

class OrderTimelineEntry {
  final String status;
  final String description;
  final DateTime timestamp;

  OrderTimelineEntry({
    required this.status,
    required this.description,
    required this.timestamp,
  });

  factory OrderTimelineEntry.fromJson(Map<String, dynamic> json) {
    return OrderTimelineEntry(
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
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
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final DateTime? estimatedDeliveryAt;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final List<OrderTimelineEntry> timeline;

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
    this.deliveryPersonName,
    this.deliveryPersonPhone,
    this.estimatedDeliveryAt,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.timeline = const [],
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
    var timelineList = json['timeline'] as List? ?? [];

    return Order(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] ?? '#SDP-????',
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: parsedStatus,
      paymentMethod: json['paymentMethod'] ?? 'À la livraison',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      items: itemsList.map((item) => OrderItem.fromJson(item)).toList(),
      deliveryPersonName: json['deliveryPersonName'],
      deliveryPersonPhone: json['deliveryPersonPhone'],
      estimatedDeliveryAt: json['estimatedDeliveryAt'] != null ? DateTime.parse(json['estimatedDeliveryAt']) : null,
      deliveryLatitude: json['deliveryLatitude'] != null ? double.tryParse(json['deliveryLatitude'].toString()) : null,
      deliveryLongitude: json['deliveryLongitude'] != null ? double.tryParse(json['deliveryLongitude'].toString()) : null,
      timeline: timelineList.map((t) => OrderTimelineEntry.fromJson(t)).toList(),
    );
  }
}
