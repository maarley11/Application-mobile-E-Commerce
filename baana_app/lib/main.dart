import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'config/router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/push_notification_service.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  
  // Initialisation du service de notifications Push
  await pushNotificationService.initialize();

  // Initialisation du cache HTTP
  await apiClient.init();

  // Barre de statut transparente pour le splash en plein écran
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const BaanaApp());
}

/// Point d'entrée de l'application Baana.
/// Utilise MaterialApp.router avec GoRouter pour la navigation
/// et le BaanaTheme pour le design system complet.
class BaanaApp extends StatelessWidget {
  const BaanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Baana',
            debugShowCheckedModeBanner: false,
            theme: BaanaTheme.lightTheme,
            darkTheme: ThemeData.dark(), // fallback dark theme if not in BaanaTheme
            themeMode: themeProvider.themeMode,
            locale: themeProvider.locale,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
