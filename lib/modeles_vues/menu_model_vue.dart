import 'package:flutter/material.dart';
import '../modeles/menu_jour.dart';
import '../modeles/plat.dart';
import '../modeles/menu.dart';
import '../modeles/commande.dart';
import '../services/service_menu.dart';
import '../services/service_commande.dart';
import 'authentification_model_vue.dart';


class MenuModelVue extends ChangeNotifier {
  final AuthentificationModelVue _authModelVue;

  int _ongletSelectionne = 0;
  List<MenuJour> _menusHebdomadaires = [];
  bool _estEnChargement = false;
  String? _messageErreur;
  Menu? _menuSemaineCourante;
  Set<int> _joursCommandes = {}; // Set des jours de semaine déjà commandés (1-5)

  MenuModelVue(this._authModelVue);

  int get ongletSelectionne => _ongletSelectionne;
  List<MenuJour> get menusHebdomadaires => _menusHebdomadaires;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;

  static const List<String> joursSemaine = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
  ];

  String get jourSelectionne => joursSemaine[_ongletSelectionne];

  MenuJour? get menuJourSelectionne {
    if (_menusHebdomadaires.isEmpty) return null;
    try {
      return _menusHebdomadaires.firstWhere(
        (menu) => menu.jourSemaine == jourSelectionne,
      );
    } catch (e) {
      return null;
    }
  }

  List<Plat> get platsJourSelectionne {
    return menuJourSelectionne?.plats ?? [];
  }

  /// Vérifier si un jour (1-5) a déjà été commandé
  bool aCommandePourJour(int jourSemaine) {
    return _joursCommandes.contains(jourSemaine);
  }

  void changerOngletJour(int nouvelIndex) {
    if (nouvelIndex >= 0 && nouvelIndex < joursSemaine.length) {
      _ongletSelectionne = nouvelIndex;
      notifyListeners();
    }
  }

  Future<void> chargerMenusHebdomadaires() async {
    _estEnChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      // Récupérer le menu de la semaine courante
      _menuSemaineCourante = await ServiceMenu.obtenirMenuSemaineCourante();

      if (_menuSemaineCourante == null) {
        // Si pas de menu, afficher un message vide
        _menusHebdomadaires = [];
        _messageErreur = 'Aucun menu disponible pour cette semaine';
      } else {
        // Récupérer les plats du menu
        final plats = await ServiceMenu.obtenirPlatsDuMenu(_menuSemaineCourante!.idMenu);

        // Organiser les plats par jour de la semaine
        _menusHebdomadaires = _organiserPlatsParJour(plats);
      }

      // Charger les commandes de la semaine pour afficher les indicateurs
      await _chargerCommandesSemaine();

      _estEnChargement = false;
      notifyListeners();
    } catch (erreur) {
      _messageErreur = 'Erreur lors du chargement des menus: ${erreur.toString()}';
      _estEnChargement = false;
      notifyListeners();
    }
  }

  Future<void> _chargerCommandesSemaine() async {
    final utilisateur = _authModelVue.utilisateurConnecte;
    if (utilisateur == null) {
      _joursCommandes = {};
      return;
    }

    try {
      final commandesSemaine = await ServiceCommande.obtenirCommandesSemaineCourante(
        utilisateur.idUser,
      );

      // Extraire les jours de semaine des plats commandés (hors annulées)
      _joursCommandes = commandesSemaine
          .where((commande) =>
              commande.statut != StatutCommande.annulee &&
              commande.plat?.jourSemaine != null)
          .map((commande) => commande.plat!.jourSemaine!)
          .toSet();
    } catch (e) {
      _joursCommandes = {};
    }
  }

  List<MenuJour> _organiserPlatsParJour(List<Plat> plats) {
    final maintenant = DateTime.now();
    final lundi = maintenant.subtract(Duration(days: maintenant.weekday - 1));

    // Organiser les plats par jour_semaine (1=Lundi, 2=Mardi, etc.)
    return List.generate(5, (index) {
      final numeroJour = index + 1; // 1 = Lundi, 2 = Mardi, etc.

      // Filtrer les plats pour ce jour spécifique
      final platsJour = plats.where((plat) => plat.jourSemaine == numeroJour).toList();

      return MenuJour(
        id: 'menu_${joursSemaine[index].toLowerCase()}',
        date: lundi.add(Duration(days: index)),
        jourSemaine: joursSemaine[index],
        plats: platsJour,
      );
    });
  }

  Future<bool> commanderPlat(Plat plat) async {
    try {
      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        _messageErreur = 'Vous devez être connecté pour commander';
        notifyListeners();
        return false;
      }

      // Vérifier si le plat a un jour de semaine défini
      if (plat.jourSemaine == null) {
        _messageErreur = 'Ce plat n\'a pas de jour de semaine défini';
        notifyListeners();
        return false;
      }

      // Vérifier si l'utilisateur a déjà commandé pour ce jour de la semaine
      final aDejaCommande = await ServiceCommande.aDejaCommandePourJourSemaine(
        idUser: utilisateur.idUser,
        jourSemaine: plat.jourSemaine!,
      );

      if (aDejaCommande) {
        final jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
        final nomJour = jours[plat.jourSemaine! - 1];
        _messageErreur = 'Vous avez déjà passé une commande pour $nomJour';
        notifyListeners();
        return false;
      }

      // Créer la commande
      await ServiceCommande.creerCommande(
        idUser: utilisateur.idUser,
        idPlat: plat.idPlat,
      );

      // Ajouter le jour aux jours commandés
      _joursCommandes.add(plat.jourSemaine!);
      notifyListeners();

      return true;
    } catch (erreur) {
      _messageErreur = erreur.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }

  Future<void> initialiser() async {
    await chargerMenusHebdomadaires();
  }
}