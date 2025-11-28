import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modeles/utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_utilisateur.dart';
import '../services/service_stockage_local.dart';
import '../services/service_notifications.dart';
import 'authentification_model_vue.dart';

class ProfilModelVue extends ChangeNotifier {
  final AuthentificationModelVue _authModelVue;

  bool _estEnChargement = false;
  String? _messageErreur;
  bool _estEnModeEdition = false;
  bool _notificationsActivees = true;
  BuildContext? context;

  ProfilModelVue(this._authModelVue);

  Utilisateur? get utilisateurConnecte => _authModelVue.utilisateurConnecte;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;
  bool get estEnModeEdition => _estEnModeEdition;
  bool get estConnecte => _authModelVue.estConnecte;
  bool get notificationsActivees => _notificationsActivees;

  void definirContext(BuildContext ctx) {
    context = ctx;
  }

  Future<void> initialiser() async {
    // Les données sont déjà chargées par AuthentificationModelVue
    // Charger l'état des notifications depuis SharedPreferences
    await _chargerEtatNotifications();
    notifyListeners();
  }

  Future<void> _chargerEtatNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsActivees = prefs.getBool('notifications_activees') ?? true;
    } catch (e) {
      _notificationsActivees = true;
    }
  }

  Future<void> mettreAJourProfil({
    String? nom,
    String? prenom,
    String? departement,
    String? site,
  }) async {
    final utilisateur = _authModelVue.utilisateurConnecte;
    if (utilisateur == null) return;

    _definirEtatChargement(true, null);

    try {
      final utilisateurMisAJour = await ServiceAuthentification.mettreAJourProfil(
        idUser: utilisateur.idUser,
        prenom: prenom,
        nom: nom,
        departement: departement,
        site: site,
      );

      // Mettre à jour l'utilisateur dans AuthentificationModelVue
      await _authModelVue.rechargerUtilisateur();

      _estEnModeEdition = false;
      _definirEtatChargement(false, null);

    } catch (e) {
      _definirEtatChargement(false, 'Erreur lors de la mise à jour: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> deconnecter() async {
    try {
      await ServiceAuthentification.seDeconnecter();

      // Réinitialiser l'utilisateur dans AuthentificationModelVue
      _authModelVue.reinitialiserUtilisateur();
    } catch (e) {
      _definirEtatChargement(false, 'Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  Future<bool> changerMotDePasse({
    required String nouveauMotDePasse,
  }) async {
    _definirEtatChargement(true, null);

    try {
      if (nouveauMotDePasse.length < 6) {
        throw Exception('Le mot de passe doit contenir au moins 6 caractères');
      }

      // Supabase Auth gère la sécurité (nécessite une session authentifiée)
      await ServiceAuthentification.changerMotDePasse(
        nouveauMotDePasse: nouveauMotDePasse,
      );

      _definirEtatChargement(false, null);
      return true;

    } catch (e) {
      _definirEtatChargement(false, e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> supprimerPhoto() async {
    final utilisateur = _authModelVue.utilisateurConnecte;
    if (utilisateur == null) return;

    _definirEtatChargement(true, null);

    try {
      // Mettre à jour avec une photo null
      await ServiceUtilisateur.mettreAJourPhoto(
        idUser: utilisateur.idUser,
        photoUrl: '',  // Chaîne vide pour supprimer
      );

      // Recharger l'utilisateur
      await _authModelVue.rechargerUtilisateur();

      _definirEtatChargement(false, null);
    } catch (e) {
      _definirEtatChargement(false, 'Erreur lors de la suppression: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> mettreAJourPhoto(String photoUrl) async {
    final utilisateur = _authModelVue.utilisateurConnecte;
    if (utilisateur == null) return;

    _definirEtatChargement(true, null);

    try {
      await ServiceUtilisateur.mettreAJourPhoto(
        idUser: utilisateur.idUser,
        photoUrl: photoUrl,
      );

      // Recharger l'utilisateur
      await _authModelVue.rechargerUtilisateur();

      _definirEtatChargement(false, null);
    } catch (e) {
      _definirEtatChargement(false, 'Erreur lors de la mise à jour: ${e.toString()}');
      rethrow;
    }
  }

  /// Basculer l'état des notifications
  Future<void> basculerNotifications(bool valeur) async {
    final utilisateur = _authModelVue.utilisateurConnecte;
    if (utilisateur == null) return;

    _notificationsActivees = valeur;
    notifyListeners();

    try {
      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_activees', valeur);

      // Si désactivées, supprimer le token FCM
      if (!valeur) {
        await ServiceUtilisateur.supprimerTokenFCM(utilisateur.idUser);
        print('🔕 Token FCM supprimé - notifications désactivées');
      } else {
        // Si activées, réenregistrer le token FCM immédiatement
        final token = await ServiceNotifications.obtenirTokenFCM();
        if (token != null) {
          await ServiceUtilisateur.sauvegarderTokenFCM(
            idUser: utilisateur.idUser,
            tokenFCM: token,
          );
          print('🔔 Token FCM réenregistré - notifications activées');
        }
      }
    } catch (e) {
      _definirEtatChargement(false, 'Erreur: ${e.toString()}');
    }
  }

  /// Supprimer le compte de l'utilisateur (soft delete)
  Future<bool> supprimerCompte(String motDePasse) async {
    final utilisateur = _authModelVue.utilisateurConnecte;
    if (utilisateur == null) {
      _definirEtatChargement(false, 'Utilisateur non connecté');
      return false;
    }

    _definirEtatChargement(true, null);

    try {
      // Vérifier le mot de passe
      final motDePasseValide = await ServiceAuthentification.verifierMotDePasse(
        utilisateur.email,
        motDePasse,
      );

      if (!motDePasseValide) {
        _definirEtatChargement(false, 'Mot de passe incorrect');
        return false;
      }

      // Supprimer le compte (soft delete)
      await ServiceUtilisateur.supprimerCompte(utilisateur.idUser);

      // Déconnecter l'utilisateur
      await deconnecter();

      _definirEtatChargement(false, null);
      return true;
    } catch (e) {
      print('❌ Erreur suppression compte: $e');
      String messageErreur = 'Erreur lors de la suppression du compte';

      final erreurStr = e.toString().toLowerCase();
      if (erreurStr.contains('password') || erreurStr.contains('incorrect') || erreurStr.contains('invalid')) {
        messageErreur = 'Mot de passe incorrect';
      } else if (erreurStr.contains('network')) {
        messageErreur = 'Erreur de connexion. Vérifiez votre internet.';
      }

      _definirEtatChargement(false, messageErreur);
      return false;
    }
  }

  void _definirEtatChargement(bool chargement, String? erreur) {
    _estEnChargement = chargement;
    _messageErreur = erreur;
    notifyListeners();
  }
}