class Product {
  final String id;
  final String name;
  final String description;
  final double publicPrice;
  final double proPrice;
  final String imageUrl;
  final String categoryId;
  final String? badge;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.publicPrice,
    required this.proPrice,
    required this.imageUrl,
    required this.categoryId,
    this.badge,
    this.stock = 100,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      publicPrice: (json['publicPrice'] ?? 0).toDouble(),
      proPrice: (json['proPrice'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      categoryId: json['categoryId']?.toString() ?? '1',
      badge: json['badge'],
      stock: json['stock'] ?? 100,
    );
  }
}
