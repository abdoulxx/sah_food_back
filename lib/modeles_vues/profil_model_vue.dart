import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../modeles/utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_utilisateur.dart';
import 'authentification_model_vue.dart';

class ProfilModelVue extends ChangeNotifier {
  final AuthentificationModelVue _authModelVue;

  bool _estEnChargement = false;
  String? _messageErreur;
  bool _estEnModeEdition = false;
  BuildContext? context;

  ProfilModelVue(this._authModelVue);

  Utilisateur? get utilisateurConnecte => _authModelVue.utilisateurConnecte;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;
  bool get estEnModeEdition => _estEnModeEdition;
  bool get estConnecte => _authModelVue.estConnecte;

  void definirContext(BuildContext ctx) {
    context = ctx;
  }

  Future<void> initialiser() async {
    // Les données sont déjà chargées par AuthentificationModelVue
    // Pas besoin de recharger ici
    notifyListeners();
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

  void _definirEtatChargement(bool chargement, String? erreur) {
    _estEnChargement = chargement;
    _messageErreur = erreur;
    notifyListeners();
  }
}