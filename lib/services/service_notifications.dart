import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modeles/notification_model.dart';
import 'service_historique_notifications.dart';

/// Handler pour les notifications reçues en arrière-plan ou quand l'app est fermée
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(' Notification reçue en background: ${message.notification?.title}');

  // Sauvegarder la notification dans l'historique
  if (message.notification != null) {
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titre: message.notification!.title ?? 'Notification',
      corps: message.notification!.body ?? '',
      dateReception: message.sentTime ?? DateTime.now(),
      estLue: false,
      data: message.data.isNotEmpty ? message.data : null,
    );

    await ServiceHistoriqueNotifications.sauvegarderNotification(notification);
    print('Notification background sauvegardée');
  }
}

/// Service de gestion des notifications Firebase Cloud Messaging
class ServiceNotifications {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Clé globale pour accéder au Navigator
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Flag pour suivre si un dialog est déjà affiché
  static bool _dialogAffiche = false;

  /// Initialiser le service de notifications Firebase
  static Future<void> initialiser() async {
    // Demander les permissions
    await _demanderPermissions();

    // Configurer Firebase Cloud Messaging
    await _configurerFirebaseMessaging();

    // Récupérer le token FCM (pour envoyer depuis le backend)
    final token = await obtenirTokenFCM();
    print('Token FCM: $token');
  }

  /// Demander les permissions de notifications
  static Future<void> _demanderPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Permissions notifications: ${settings.authorizationStatus}');
  }

  /// Configurer Firebase Cloud Messaging
  static Future<void> _configurerFirebaseMessaging() async {
    // Gérer les notifications quand l'app est en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Notification reçue en foreground: ${message.notification?.title}');

      // Vérifier si les notifications sont activées
      final notificationsActivees = await _verifierNotificationsActivees();
      if (!notificationsActivees) {
        print('🔕 Notifications désactivées - notification ignorée');
        return;
      }

      // Sauvegarder dans l'historique
      if (message.notification != null) {
        _sauvegarderNotification(message);

        // Afficher la notification dans l'app
        _afficherNotificationForeground(
          titre: message.notification!.title ?? 'Notification',
          corps: message.notification!.body ?? '',
        );
      }
    });

    // Gérer le clic sur notification quand l'app est en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification cliquée (background): ${message.notification?.title}');
      _sauvegarderNotification(message);
      _gererClicNotificationFirebase(message);
    });

    // Vérifier si l'app a été ouverte via une notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App ouverte via notification: ${initialMessage.notification?.title}');
      _sauvegarderNotification(initialMessage);
      _gererClicNotificationFirebase(initialMessage);
    }
  }

  /// Sauvegarder une notification dans l'historique
  static Future<void> _sauvegarderNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titre: message.notification!.title ?? 'Notification',
      corps: message.notification!.body ?? '',
      dateReception: message.sentTime ?? DateTime.now(),
      estLue: false,
      data: message.data.isNotEmpty ? message.data : null,
    );

    await ServiceHistoriqueNotifications.sauvegarderNotification(notification);
    print('💾 Notification sauvegardée dans l\'historique');
  }

  /// Afficher une notification en foreground
  static void _afficherNotificationForeground({
    required String titre,
    required String corps,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Si un dialog est déjà affiché, fermer le précédent
    if (_dialogAffiche) {
      Navigator.of(context).pop();
      _dialogAffiche = false;
    }

    // Marquer qu'un dialog est maintenant affiché
    _dialogAffiche = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async {
          _dialogAffiche = false;
          return true;
        },
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E5984).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFF2E5984),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Titre
                  Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5984),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Corps du message
                  Text(
                    corps,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),

                  // Bouton OK
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _dialogAffiche = false;
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5984),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      // Marquer comme non affiché quand le dialog se ferme
      _dialogAffiche = false;
    });

    // Fermer automatiquement après 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      if (_dialogAffiche && navigatorKey.currentContext != null) {
        _dialogAffiche = false;
        Navigator.of(navigatorKey.currentContext!).pop();
      }
    });
  }

  // Gérer le clic sur une notification Firebase
  static void _gererClicNotificationFirebase(RemoteMessage message) {
    print('Notification Firebase cliquée: ${message.data}');
    // ici je vais rediriger selon le messages
    // message.data['type'] == 'nouveau_plat' -> Naviguer vers page Menu
  }

  /// Récupérer le token FCM pour l'envoyer au backend
  static Future<String?> obtenirTokenFCM() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      print('Erreur récupération token FCM: $e');
      return null;
    }
  }

  /// Rafraîchir le token FCM (appelé automatiquement par Firebase)
  static void ecouterRafraichissementToken(Function(String) onTokenRefresh) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('Token FCM rafraîchi: $newToken');
      onTokenRefresh(newToken);
    });
  }

  /// Vérifier si les notifications sont activées dans les préférences
  static Future<bool> _verifierNotificationsActivees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notifications_activees') ?? true;
    } catch (e) {
      return true; // Par défaut, activées
    }
  }
}
