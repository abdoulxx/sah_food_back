import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../modeles/utilisateur.dart';

/// Service de stockage local pour la persistance des données
class ServiceStockageLocal {
  static const String _cleUtilisateur = 'utilisateur_connecte';
  static const String _cleTokenAuth = 'token_auth';
  static const String _cleEstConnecte = 'est_connecte';

  /// Sauvegarder l'utilisateur connecté
  static Future<void> sauvegarderUtilisateur(Utilisateur utilisateur) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final utilisateurJson = jsonEncode(utilisateur.toJson());
      await prefs.setString(_cleUtilisateur, utilisateurJson);
      await prefs.setBool(_cleEstConnecte, true);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'utilisateur: $e');
    }
  }

  /// Récupérer l'utilisateur connecté
  static Future<Utilisateur?> recupererUtilisateur() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final utilisateurJson = prefs.getString(_cleUtilisateur);

      if (utilisateurJson == null) return null;

      final utilisateurMap = jsonDecode(utilisateurJson) as Map<String, dynamic>;
      return Utilisateur.fromJson(utilisateurMap);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarder le token d'authentification (pour future API Django)
  static Future<void> sauvegarderToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cleTokenAuth, token);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du token: $e');
    }
  }

  /// Récupérer le token d'authentification
  static Future<String?> recupererToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_cleTokenAuth);
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si un utilisateur est connecté
  static Future<bool> estConnecte() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cleEstConnecte) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Supprimer toutes les données de session (déconnexion)
  static Future<void> effacerSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cleUtilisateur);
      await prefs.remove(_cleTokenAuth);
      await prefs.setBool(_cleEstConnecte, false);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la session: $e');
    }
  }

  /// Effacer toutes les données stockées localement
  static Future<void> effacerTout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Erreur lors de l\'effacement des données: $e');
    }
  }
}
