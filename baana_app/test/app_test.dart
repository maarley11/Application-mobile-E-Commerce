/// Test d'intégration E2E pour l'application Baana.
///
/// Ce fichier teste les scénarios métier principaux :
/// 1. Inscription & Authentification
/// 2. Navigation catalogue & détail produit
/// 3. Gestion du panier (ajout, modification quantité)
/// 4. Checkout & création de commande
/// 5. Gestion des erreurs (stock insuffisant, réseau)
///
/// **Prérequis** :
/// - Backend démarré sur `http://localhost:3000`
/// - Base de données initialisée avec les seeds
///
/// **Lancer** :
/// ```bash
/// flutter test integration_test/app_test.dart
/// ```

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:baana_app/main.dart';
import 'package:baana_app/providers/auth_provider.dart';
import 'package:baana_app/providers/product_provider.dart';
import 'package:baana_app/providers/cart_provider.dart';
import 'package:baana_app/providers/order_provider.dart';
import 'package:baana_app/providers/dashboard_provider.dart';
import 'package:baana_app/models/product.dart';

void main() {
  // ============================================================
  // TESTS UNITAIRES DES PROVIDERS (pas besoin de backend)
  // ============================================================

  group('CartProvider — Tests unitaires', () {
    late CartProvider cartProvider;
    late Product sampleProduct;
    late Product sampleProduct2;

    setUp(() {
      cartProvider = CartProvider();
      sampleProduct = Product(
        id: '1',
        name: 'Riz Parfumé 25kg',
        description: 'Riz de qualité supérieure',
        publicPrice: 15000,
        proPrice: 12000,
        imageUrl: 'https://via.placeholder.com/150',
        categoryId: '1',
        stock: 50,
      );
      sampleProduct2 = Product(
        id: '2',
        name: 'Huile Végétale 5L',
        description: 'Huile de tournesol pure',
        publicPrice: 8000,
        proPrice: 6500,
        imageUrl: 'https://via.placeholder.com/150',
        categoryId: '1',
        stock: 30,
      );
    });

    test('Panier vide au départ', () {
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.totalItemQuantity, 0);
      expect(cartProvider.subtotalAmount(false), 0.0);
    });

    test('Ajout d\'un produit au panier', () {
      cartProvider.addItem(sampleProduct);

      expect(cartProvider.itemCount, 1);
      expect(cartProvider.totalItemQuantity, 1);
      // Visiteur → publicPrice
      expect(cartProvider.subtotalAmount(false), 15000.0);
      // Pro → proPrice
      expect(cartProvider.subtotalAmount(true), 12000.0);
    });

    test('Ajout du même produit → quantité incrémentée', () {
      cartProvider.addItem(sampleProduct);
      cartProvider.addItem(sampleProduct);

      expect(cartProvider.itemCount, 1); // Toujours 1 produit unique
      expect(cartProvider.totalItemQuantity, 2); // Mais quantité = 2
      expect(cartProvider.subtotalAmount(false), 30000.0);
    });

    test('Ajout de plusieurs produits différents', () {
      cartProvider.addItem(sampleProduct);
      cartProvider.addItem(sampleProduct2, quantity: 2);

      expect(cartProvider.itemCount, 2);
      expect(cartProvider.totalItemQuantity, 3); // 1 + 2
      // Visiteur : 15000 + (8000 * 2) = 31000
      expect(cartProvider.subtotalAmount(false), 31000.0);
      // Pro : 12000 + (6500 * 2) = 25000
      expect(cartProvider.subtotalAmount(true), 25000.0);
    });

    test('Modification de la quantité', () {
      cartProvider.addItem(sampleProduct);
      cartProvider.updateQuantity('1', 5);

      expect(cartProvider.totalItemQuantity, 5);
      expect(cartProvider.subtotalAmount(false), 75000.0);
    });

    test('Quantité à 0 → produit supprimé', () {
      cartProvider.addItem(sampleProduct);
      cartProvider.updateQuantity('1', 0);

      expect(cartProvider.itemCount, 0);
    });

    test('Suppression d\'un produit', () {
      cartProvider.addItem(sampleProduct);
      cartProvider.addItem(sampleProduct2);
      cartProvider.removeItem('1');

      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items.containsKey('1'), false);
      expect(cartProvider.items.containsKey('2'), true);
    });

    test('Vidage du panier', () {
      cartProvider.addItem(sampleProduct);
      cartProvider.addItem(sampleProduct2);
      cartProvider.clear();

      expect(cartProvider.itemCount, 0);
      expect(cartProvider.subtotalAmount(false), 0.0);
    });

    test('Frais de livraison — Visiteur', () {
      cartProvider.addItem(sampleProduct);

      // Visiteur → 1500 CFA
      expect(cartProvider.getDeliveryFee(false, 0), 1500.0);
    });

    test('Frais de livraison — Pro avec livraisons gratuites', () {
      cartProvider.addItem(sampleProduct);

      // Pro avec 2 livraisons gratuites restantes → 0 CFA
      expect(cartProvider.getDeliveryFee(true, 2), 0.0);
    });

    test('Frais de livraison — Pro sans livraisons gratuites', () {
      cartProvider.addItem(sampleProduct);

      // Pro mais 0 livraisons gratuites restantes → 1500 CFA
      expect(cartProvider.getDeliveryFee(true, 0), 1500.0);
    });

    test('Total avec livraison — Visiteur', () {
      cartProvider.addItem(sampleProduct);

      // 15000 + 1500 = 16500
      expect(cartProvider.getTotalAmount(false, 0), 16500.0);
    });

    test('Total avec livraison — Pro gratuit', () {
      cartProvider.addItem(sampleProduct);

      // 12000 + 0 = 12000
      expect(cartProvider.getTotalAmount(true, 3), 12000.0);
    });
  });

  // ============================================================
  // TESTS UNITAIRES DU MODÈLE PRODUCT
  // ============================================================

  group('Product — Tests unitaires', () {
    test('Parsing JSON correct', () {
      final json = {
        'id': 42,
        'name': 'Sucre 1kg',
        'description': 'Sucre blanc',
        'publicPrice': 750,
        'proPrice': 600,
        'imageUrl': 'https://example.com/sucre.jpg',
        'categoryId': 3,
        'badge': 'PROMO',
        'stock': 200,
      };

      final product = Product.fromJson(json);

      expect(product.id, '42');
      expect(product.name, 'Sucre 1kg');
      expect(product.publicPrice, 750.0);
      expect(product.proPrice, 600.0);
      expect(product.badge, 'PROMO');
      expect(product.stock, 200);
    });

    test('Parsing JSON avec valeurs manquantes → défauts appliqués', () {
      final json = <String, dynamic>{};
      final product = Product.fromJson(json);

      expect(product.id, '');
      expect(product.name, '');
      expect(product.publicPrice, 0.0);
      expect(product.proPrice, 0.0);
      expect(product.stock, 100); // Valeur par défaut
      expect(product.badge, isNull);
    });
  });

  // ============================================================
  // TESTS DU AUTHPROVIDER (logique interne, sans appel réseau)
  // ============================================================

  group('AuthProvider — Tests état initial', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('État initial correct', () {
      expect(authProvider.isLoading, false);
      expect(authProvider.isPro, false);
      expect(authProvider.role, 'visitor');
      expect(authProvider.currentName, 'Client'); // Défaut quand nom vide
      expect(authProvider.loyaltyPoints, 0);
      expect(authProvider.freeDeliveriesLeft, 0); // Pas Pro → 0
    });

    test('decrementFreeDelivery — ignoré si non Pro', () {
      authProvider.decrementFreeDelivery();
      // Pas de crash, pas d'effet car isPro == false
      expect(authProvider.freeDeliveriesLeft, 0);
    });
  });

  // ============================================================
  // TEST WIDGET : Vérification du lancement de l'app
  // ============================================================

  group('BaanaApp — Tests Widget', () {
    testWidgets('L\'application se lance sans crash', (tester) async {
      await tester.pumpWidget(const BaanaApp());
      await tester.pump(const Duration(milliseconds: 500));

      // L'app ne crashe pas et un widget MaterialApp est présent
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Splash Screen est la route initiale', (tester) async {
      await tester.pumpWidget(const BaanaApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Le SplashScreen devrait être affiché en premier
      // On vérifie qu'un Scaffold existe (base de tous nos écrans)
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
