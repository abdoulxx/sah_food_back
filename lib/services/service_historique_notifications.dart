import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modeles/notification_model.dart';

/// Service de gestion de l'historique des notifications
class ServiceHistoriqueNotifications {
  static const String _cleHistorique = 'notifications_historique';
  static const int _limiteMaxNotifications = 50;

  // Stream pour notifier les changements et incrementer le badge
  static final StreamController<int> _notificationController =
      StreamController<int>.broadcast();

  static Stream<int> get onNotificationChange => _notificationController.stream;

  /// Sauvegarder une nouvelle notification
  static Future<void> sauvegarderNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<NotificationModel> notifications = await obtenirNotifications();

      // Ajouter au début de la liste
      notifications.insert(0, notification);

      // Limiter à 50 notifications
      if (notifications.length > _limiteMaxNotifications) {
        notifications.removeRange(_limiteMaxNotifications, notifications.length);
      }

      // Sauvegarder
      final listeJson = notifications.map((n) => n.versJson()).toList();
      await prefs.setString(_cleHistorique, jsonEncode(listeJson));

      // Notifier les écouteurs du changement
      final nombreNonLues = notifications.where((n) => !n.estLue).length;
      _notificationController.add(nombreNonLues);
    } catch (e) {
      print('Erreur sauvegarde notification: $e');
    }
  }

  /// Récupérer toutes les notifications
  static Future<List<NotificationModel>> obtenirNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_cleHistorique);

      if (jsonString == null) {
        return [];
      }

      final List<dynamic> listeJson = jsonDecode(jsonString) as List;
      return listeJson
          .map((json) => NotificationModel.depuisJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur récupération notifications: $e');
      return [];
    }
  }

  /// Marquer une notification comme lue
  static Future<void> marquerCommeLue(String idNotification) async {
    try {
      final List<NotificationModel> notifications = await obtenirNotifications();

      final index = notifications.indexWhere((n) => n.id == idNotification);
      if (index != -1) {
        notifications[index] = notifications[index].copierAvec(estLue: true);

        // Sauvegarder
        final prefs = await SharedPreferences.getInstance();
        final listeJson = notifications.map((n) => n.versJson()).toList();
        await prefs.setString(_cleHistorique, jsonEncode(listeJson));
      }
    } catch (e) {
      print('Erreur marquage notification: $e');
    }
  }

  /// Marquer toutes les notifications comme lues
  static Future<void> marquerToutesCommeLues() async {
    try {
      final List<NotificationModel> notifications = await obtenirNotifications();

      final notificationsLues = notifications
          .map((n) => n.copierAvec(estLue: true))
          .toList();

      // Sauvegarder
      final prefs = await SharedPreferences.getInstance();
      final listeJson = notificationsLues.map((n) => n.versJson()).toList();
      await prefs.setString(_cleHistorique, jsonEncode(listeJson));

      // Notifier que toutes sont lues (0)
      _notificationController.add(0);
    } catch (e) {
      print('Erreur marquage toutes notifications: $e');
    }
  }

  /// Supprimer une notification
  static Future<void> supprimerNotification(String idNotification) async {
    try {
      final List<NotificationModel> notifications = await obtenirNotifications();

      notifications.removeWhere((n) => n.id == idNotification);

      // Sauvegarder
      final prefs = await SharedPreferences.getInstance();
      final listeJson = notifications.map((n) => n.versJson()).toList();
      await prefs.setString(_cleHistorique, jsonEncode(listeJson));
    } catch (e) {
      print('❌ Erreur suppression notification: $e');
    }
  }

  /// Supprimer toutes les notifications
  static Future<void> supprimerToutesNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cleHistorique);

      // Notifier que tout est supprimé (0)
      _notificationController.add(0);
    } catch (e) {
      print('Erreur suppression toutes notifications: $e');
    }
  }

  /// Obtenir le nombre de notifications non lues
  static Future<int> obtenirNombreNonLues() async {
    try {
      final notifications = await obtenirNotifications();
      return notifications.where((n) => !n.estLue).length;
    } catch (e) {
      print(' Erreur comptage notifications non lues: $e');
      return 0;
    }
  }
}
