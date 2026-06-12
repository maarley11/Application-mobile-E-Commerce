import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'config/router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      ],
      child: MaterialApp.router(
        title: 'Baana',
        debugShowCheckedModeBanner: false,
        theme: BaanaTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
