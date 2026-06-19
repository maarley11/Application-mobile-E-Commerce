import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service singleton pour les notifications push via Firebase Cloud Messaging.
///
/// **Configuration requise** :
/// 1. Exécuter `firebase login` puis `dart run flutterfire_cli:flutterfire configure`
/// 2. Importer le fichier `firebase_options.dart` généré
/// 3. Passer `DefaultFirebaseOptions.currentPlatform` dans `initializeApp()`
///
/// En attendant, le service est désactivé sur Web pour éviter le crash
/// `FirebaseOptions cannot be null`.
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  /// Token FCM actuel, disponible après [initialize].
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // ──────────────────────────────────────────────────────────
    // GARDE WEB : Firebase n'a pas de firebase_options.dart configuré,
    // donc on skip l'initialisation sur Web pour éviter le crash.
    // Quand tu auras lancé `flutterfire configure`, tu pourras
    // retirer cette garde et passer les options générées.
    // ──────────────────────────────────────────────────────────
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ [FCM] Skipped sur Web — firebase_options.dart non configuré.');
        print('💡 [FCM] Lance "flutterfire configure" pour activer FCM sur Web.');
      }
      return;
    }

    try {
      // Initialisation Firebase (Android/iOS utilisent google-services.json / GoogleService-Info.plist)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        // TODO: Quand firebase_options.dart sera généré, utiliser :
        // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }

      // Demander la permission
      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('🔔 [FCM] Permission accordée');
        }

        // Récupérer le token (à envoyer au backend)
        _fcmToken = await FirebaseMessaging.instance.getToken();
        if (kDebugMode) {
          print('🔔 [FCM] Token FCM : $_fcmToken');
        }

        // TODO: Envoyer ce token au backend via apiClient.post('/users/fcm-token', { token: _fcmToken })

        // Écouter les messages en premier plan
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            print(
                '🔔 [FCM] Message reçu : ${message.notification?.title}');
          }
        });

        // Clic sur la notification (app en arrière-plan)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          if (kDebugMode) {
            print('🔔 [FCM] Notification cliquée !');
          }
          // TODO: Router vers l'écran de notifications via GoRouter
        });
      } else {
        if (kDebugMode) {
          print('🔕 [FCM] Permission refusée par l\'utilisateur.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [FCM] Erreur d\'initialisation : $e');
        print(
            '⚠️ [FCM] Lancez "flutterfire configure" pour configurer Firebase.');
      }
    }
  }
}

final pushNotificationService = PushNotificationService();
