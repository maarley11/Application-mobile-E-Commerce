import 'api_client.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  Future<List<CartItem>> getCart() async {
    final response = await apiClient.client.get('/cart');
    final data = response.data;
    if (data == null || data['items'] == null) {
      return [];
    }
    
    final itemsList = data['items'] as List;
    return itemsList.map((item) {
      final productJson = item['Product'];
      final product = Product(
        id: productJson['id'].toString(),
        name: productJson['name'],
        description: productJson['description'] ?? '',
        publicPrice: productJson['publicPrice'].toDouble(),
        proPrice: productJson['proPrice']?.toDouble() ?? productJson['publicPrice'].toDouble(),
        stock: productJson['stock'],
        categoryId: productJson['categoryId']?.toString() ?? '',
        imageUrl: productJson['imageUrl'],
        badge: productJson['badge'],
      );

      return CartItem(
        id: item['id'].toString(), // c'est l'ID du CartItem, important pour PUT/DELETE
        product: product,
        quantity: item['quantity'],
      );
    }).toList();
  }

  Future<void> addToCart(String productId, int quantity) async {
    await apiClient.client.post('/cart', data: {
      'productId': int.parse(productId),
      'quantity': quantity,
    });
  }

  Future<void> updateCartItem(String itemId, int quantity) async {
    await apiClient.client.put('/cart/$itemId', data: {
      'quantity': quantity,
    });
  }

  Future<void> removeFromCart(String itemId) async {
    await apiClient.client.delete('/cart/$itemId');
  }
}

final cartService = CartService();
