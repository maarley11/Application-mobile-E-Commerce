// Test de base — vérifie que l'app Baana se lance correctement.

import 'package:flutter_test/flutter_test.dart';

import 'package:baana_app/main.dart';

void main() {
  testWidgets('BaanaApp se lance sans erreur', (WidgetTester tester) async {
    await tester.pumpWidget(const BaanaApp());
    // Le splash screen devrait s'afficher
    expect(find.text('LE CONFORT PAR LE DIGITAL'), findsOneWidget);
  });
}
