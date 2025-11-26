import 'package:flutter/material.dart';
import '../modeles/utilisateur.dart';
import '../modeles/commande.dart';
import '../services/service_commande.dart';
import 'authentification_model_vue.dart';


class AccueilModelVue extends ChangeNotifier {
  final AuthentificationModelVue _authModelVue;

  List<Commande> _commandesSemaine = [];
  bool _estEnChargement = false;
  String? _messageErreur;

  AccueilModelVue(this._authModelVue);

  Utilisateur? get utilisateurActuel => _authModelVue.utilisateurConnecte;
  List<Commande> get commandesSemaine => _commandesSemaine;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;

  double get progressionSemaine {
    final commandesActives = _commandesSemaine.where((c) => c.statut != StatutCommande.annulee).length;
    if (commandesActives == 0) return 0.0;
    const totalJours = 5;
    return commandesActives / totalJours;
  }

  int get nombreCommandesPassees => _commandesSemaine.where((c) => c.statut != StatutCommande.annulee).length;

  int get nombreJoursTotal => 5;

  bool get toutesComandesPassees => nombreCommandesPassees >= nombreJoursTotal;

  String get texteBoutonCommande {
    if (nombreCommandesPassees == 0) {
      return 'Commencer à commander';
    } else if (nombreCommandesPassees >= nombreJoursTotal) {
      return 'Semaine complète';
    } else {
      return 'Complétez ma semaine';
    }
  }

  String get iconeBoutonCommande {
    if (nombreCommandesPassees == 0) {
      return 'start';
    } else if (nombreCommandesPassees >= nombreJoursTotal) {
      return 'check';
    } else {
      return 'menu';
    }
  }

  Map<String, Commande?> get commandesParJour {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
    final Map<String, Commande?> result = {};

    // Filtrer les commandes non annulées
    final commandesActives = _commandesSemaine.where((c) => c.statut != StatutCommande.annulee).toList();

    for (final jour in jours) {
      try {
        result[jour] = commandesActives.firstWhere(
          (commande) => commande.jourSemaine == jour,
        );
      } catch (e) {
        result[jour] = null;
      }
    }

    return result;
  }

  Future<void> chargerCommandesSemaine() async {
    _estEnChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        _commandesSemaine = [];
        _estEnChargement = false;
        notifyListeners();
        return;
      }

      // Charger les commandes de la semaine courante
      _commandesSemaine = await ServiceCommande.obtenirCommandesSemaineCourante(
        utilisateur.idUser,
      );

      _estEnChargement = false;
      notifyListeners();
    } catch (erreur) {
      _messageErreur = erreur.toString().replaceAll('Exception: ', '');
      _estEnChargement = false;
      notifyListeners();
    }
  }

  void ajouterCommande(Commande commande) {
    _commandesSemaine.add(commande);
    notifyListeners();
  }

  Future<void> supprimerCommande(int commandeId) async {
    try {
      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) return;

      await ServiceCommande.annulerCommande(
        idCommande: commandeId,
        idUser: utilisateur.idUser,
      );

      _commandesSemaine.removeWhere((c) => c.idCommande == commandeId);
      notifyListeners();
    } catch (erreur) {
      _messageErreur = erreur.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }

  Future<void> initialiser() async {
    await chargerCommandesSemaine();
  }
}