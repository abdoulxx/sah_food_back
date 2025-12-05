import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_authentification.dart';
import '../services/service_notifications.dart';
import '../services/service_utilisateur.dart';
import '../modeles/utilisateur.dart';

class AuthentificationModelVue extends ChangeNotifier {
  Utilisateur? _utilisateurConnecte;

  Utilisateur? get utilisateurConnecte => _utilisateurConnecte;
  bool _estEnChargement = false;
  bool _utilisateurEnCoursDeChargement = true;
  String? _messageErreur;
  bool _motDePasseVisible = false;
  bool _confirmationMotDePasseVisible = false;

  AuthentificationModelVue() {
    // Charger l'utilisateur depuis la session Supabase au démarrage
    chargerUtilisateurConnecte();
  }

  Future<void> chargerUtilisateurConnecte() async {
    _utilisateurEnCoursDeChargement = true;

    try {
      _utilisateurConnecte = await ServiceAuthentification.obtenirUtilisateurConnecte();
      _utilisateurEnCoursDeChargement = false;
      notifyListeners();

      // Réenregistrer le token FCM si l'utilisateur est connecté et notifications activées
      if (_utilisateurConnecte != null && !kIsWeb) {
        await _reEnregistrerTokenFCM();
      }
    } catch (e) {
      _utilisateurEnCoursDeChargement = false;
      notifyListeners();
    }
  }

  /// Réenregistrer le token FCM au démarrage de l'app
  Future<void> _reEnregistrerTokenFCM() async {
    try {
      // Vérifier si les notifications sont activées
      final prefs = await SharedPreferences.getInstance();
      final notificationsActivees = prefs.getBool('notifications_activees') ?? true;

      if (!notificationsActivees) {
        print('🔕 Notifications désactivées - pas de réenregistrement du token');
        return;
      }

      // Obtenir et sauvegarder le token FCM
      final token = await ServiceNotifications.obtenirTokenFCM();
      if (token != null && _utilisateurConnecte != null) {
        await ServiceUtilisateur.sauvegarderTokenFCM(
          idUser: _utilisateurConnecte!.idUser,
          tokenFCM: token,
        );
        print('🔔 Token FCM réenregistré au démarrage');
      }
    } catch (e) {
      print('❌ Erreur réenregistrement token FCM: $e');
    }
  }

  bool get estEnChargement => _estEnChargement;
  bool get utilisateurEnCoursDeChargement => _utilisateurEnCoursDeChargement;
  String? get messageErreur => _messageErreur;
  bool get motDePasseVisible => _motDePasseVisible;
  bool get confirmationMotDePasseVisible => _confirmationMotDePasseVisible;

  final TextEditingController controleurEmail = TextEditingController(text: '@sahanalytics.com');
  final TextEditingController controleurMotDePasse = TextEditingController();
  final TextEditingController controleurPrenom = TextEditingController();
  final TextEditingController controleurNom = TextEditingController();
  final TextEditingController controleurConfirmationMotDePasse = TextEditingController();
  final TextEditingController controleurQid = TextEditingController();

  String _siteSelectionne = 'CAMPUS';
  String get siteSelectionne => _siteSelectionne;

  String _roleSelectionne = 'COLLAB';
  String get roleSelectionne => _roleSelectionne;

  String? _departementSelectionne;
  String? get departementSelectionne => _departementSelectionne;

  void basculerVisibiliteMotDePasse() {
    _motDePasseVisible = !_motDePasseVisible;
    notifyListeners();
  }

  void basculerVisibiliteConfirmationMotDePasse() {
    _confirmationMotDePasseVisible = !_confirmationMotDePasseVisible;
    notifyListeners();
  }

  void changerSite(String nouveauSite) {
    _siteSelectionne = nouveauSite;
    notifyListeners();
  }

  void changerRole(String nouveauRole) {
    _roleSelectionne = nouveauRole;
    notifyListeners();
  }

  void changerDepartement(String nouveauDepartement) {
    _departementSelectionne = nouveauDepartement;
    notifyListeners();
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }

  String? validerEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'L\'email est requis';
    }
    if (!email.contains('@sahanalytics.com') || !email.contains('.')) {
      return 'Veuillez entrer votre email pro @sahanalytics.com';
    }
    return null;
  }

  String? validerMotDePasse(String? motDePasse) {
    if (motDePasse == null || motDePasse.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (motDePasse.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  String? validerConfirmationMotDePasse(String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    if (confirmation != controleurMotDePasse.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? validerChampRequis(String? valeur, String nomChamp) {
    if (valeur == null || valeur.isEmpty) {
      return '$nomChamp est requis';
    }
    return null;
  }

  Future<bool> seConnecter() async {
    _estEnChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      _utilisateurConnecte = await ServiceAuthentification.seConnecter(
        email: controleurEmail.text.trim(),
        motDePasse: controleurMotDePasse.text,
      );

      _estEnChargement = false;
      notifyListeners();
      return _utilisateurConnecte != null;
    } catch (erreur) {
      _messageErreur = erreur.toString().replaceAll('Exception: ', '');
      _estEnChargement = false;
      notifyListeners();
      return false;
    }
  }

  String? _messageSuccesInscription;
  String? get messageSuccesInscription => _messageSuccesInscription;

  Future<bool> sInscrire() async {
    _estEnChargement = true;
    _messageErreur = null;
    _messageSuccesInscription = null;
    notifyListeners();

    try {
      final resultat = await ServiceAuthentification.inscrire(
        email: controleurEmail.text.trim(),
        motDePasse: controleurMotDePasse.text,
        qid: controleurQid.text.trim(),
        prenom: controleurPrenom.text.trim(),
        nom: controleurNom.text.trim(),
        role: _roleSelectionne,
        site: _siteSelectionne,
        departement: _departementSelectionne,
      );

      // L'utilisateur n'est PAS connecté automatiquement
      _utilisateurConnecte = null;
      _messageSuccesInscription = resultat['message'];

      _estEnChargement = false;
      notifyListeners();
      return true; // Inscription réussie
    } catch (erreur) {
      _messageErreur = erreur.toString().replaceAll('Exception: ', '');
      _estEnChargement = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    controleurEmail.dispose();
    controleurMotDePasse.dispose();
    controleurPrenom.dispose();
    controleurNom.dispose();
    controleurConfirmationMotDePasse.dispose();
    controleurQid.dispose();
    super.dispose();
  }

  /// Recharger les données de l'utilisateur connecté depuis la base de données
  Future<void> rechargerUtilisateur() async {
    try {
      _utilisateurConnecte = await ServiceAuthentification.obtenirUtilisateurConnecte(forcerRechargement: true);
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs de rechargement
    }
  }

  /// Vérifier si l'utilisateur est connecté
  bool get estConnecte => _utilisateurConnecte != null;

  /// Réinitialiser l'utilisateur (après déconnexion)
  void reinitialiserUtilisateur() {
    _utilisateurConnecte = null;
    notifyListeners();
  }
}