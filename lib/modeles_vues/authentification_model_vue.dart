import 'package:flutter/material.dart';
import '../services/service_authentification.dart';
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
    } catch (e) {
      _utilisateurEnCoursDeChargement = false;
      notifyListeners();
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

  Future<bool> sInscrire() async {
    _estEnChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      _utilisateurConnecte = await ServiceAuthentification.inscrire(
        email: controleurEmail.text.trim(),
        motDePasse: controleurMotDePasse.text,
        qid: controleurQid.text.trim(),
        prenom: controleurPrenom.text.trim(),
        nom: controleurNom.text.trim(),
        role: _roleSelectionne,
        site: _siteSelectionne,
        departement: _departementSelectionne,
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