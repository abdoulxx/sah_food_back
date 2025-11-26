import 'package:flutter/foundation.dart';
import '../modeles/avis.dart';
import '../modeles/commande.dart';
import '../services/service_avis.dart';
import '../services/service_commande.dart';
import 'authentification_model_vue.dart';

class AvisModelVue extends ChangeNotifier {
  final AuthentificationModelVue _authModelVue;

  List<Avis> _mesAvis = [];
  List<Commande> _commandesValidees = [];
  bool _estEnChargement = false;
  String? _messageErreur;

  AvisModelVue(this._authModelVue);

  List<Avis> get mesAvis => _mesAvis;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;
  List<Commande> get commandesValidees => _commandesValidees;

  /// Obtenir l'avis pour un plat donné
  Avis? obtenirAvisPourPlat(int idPlat) {
    try {
      return _mesAvis.firstWhere((avis) => avis.idPlat == idPlat);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir l'avis pour une commande donnée
  Avis? obtenirAvisPourCommande(int idCommande) {
    final commande = _commandesValidees
        .where((cmd) => cmd.idCommande == idCommande)
        .firstOrNull;

    if (commande == null) return null;
    return obtenirAvisPourPlat(commande.idPlat);
  }

  /// Vérifier si un avis existe pour une commande
  bool aUnAvisPourCommande(int idCommande) {
    return obtenirAvisPourCommande(idCommande) != null;
  }

  void _definirEtatChargement(bool chargement, String? erreur) {
    _estEnChargement = chargement;
    _messageErreur = erreur;
    notifyListeners();
  }

  Future<void> chargerMesAvis() async {
    _definirEtatChargement(true, null);

    try {
      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        _mesAvis = [];
        _commandesValidees = [];
        _definirEtatChargement(false, null);
        return;
      }

      // Charger les avis de l'utilisateur
      _mesAvis = await ServiceAvis.obtenirAvisUtilisateur(utilisateur.idUser);

      // Charger les commandes validées
      final toutesCommandes = await ServiceCommande.obtenirCommandesUtilisateur(
        utilisateur.idUser,
      );
      _commandesValidees = toutesCommandes
          .where((cmd) => cmd.statut == StatutCommande.validee)
          .toList();

      _definirEtatChargement(false, null);
    } catch (e) {
      _definirEtatChargement(false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> ajouterOuModifierAvis({
    required int idCommande,
    required int idPlat,
    required int note,
    String? commentaire,
  }) async {
    try {
      _definirEtatChargement(true, null);

      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        _definirEtatChargement(false, 'Vous devez être connecté pour donner un avis');
        return false;
      }

      // Créer ou mettre à jour l'avis
      final avisEnregistre = await ServiceAvis.creerOuMettreAJourAvis(
        idUser: utilisateur.idUser,
        idPlat: idPlat,
        note: note,
        commentaire: commentaire,
      );

      // Mettre à jour la liste locale
      _mesAvis.removeWhere((avis) => avis.idPlat == idPlat);
      _mesAvis.add(avisEnregistre);

      _definirEtatChargement(false, null);
      return true;
    } catch (e) {
      _definirEtatChargement(false, e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> actualiserMesAvis() async {
    await chargerMesAvis();
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}