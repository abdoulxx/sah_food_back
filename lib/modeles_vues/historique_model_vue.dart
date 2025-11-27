import 'package:flutter/foundation.dart';
import '../modeles/commande.dart';
import '../modeles/menu.dart';
import '../services/service_commande.dart';
import '../services/service_menu.dart';
import 'authentification_model_vue.dart';

class HistoriqueModelVue extends ChangeNotifier {
  final AuthentificationModelVue _authModelVue;

  Map<String, List<Commande>> _commandesParSemaine = {};
  List<Menu> _menusDuMois = [];
  bool _estEnChargement = false;
  String? _messageErreur;
  int _semainerSelectionne = 0;

  HistoriqueModelVue(this._authModelVue);

  List<String> get semainesDisponibles => _menusDuMois.map((menu) => _formaterSemaine(menu)).toList();

  String _formaterSemaine(Menu menu) {
    const List<String> nomsMois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];

    final jourDebut = menu.dateDebut.day;
    final moisDebut = menu.dateDebut.month;

    final jourFin = menu.dateFin.day;
    final moisFin = menu.dateFin.month;

    // Formater selon si la semaine est sur un ou deux mois
    if (moisDebut == moisFin) {
      return '${jourDebut.toString().padLeft(2, '0')}-${jourFin.toString().padLeft(2, '0')} ${nomsMois[moisDebut - 1]}';
    } else {
      return '${jourDebut.toString().padLeft(2, '0')} ${nomsMois[moisDebut - 1]} - ${jourFin.toString().padLeft(2, '0')} ${nomsMois[moisFin - 1]}';
    }
  }

  Map<String, List<Commande>> get commandesParSemaine => _commandesParSemaine;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;
  int get semainerSelectionne => _semainerSelectionne;
  String get semainerActuelle => semainesDisponibles[_semainerSelectionne];

  List<Commande> get commandesSemainerActuelle =>
      _commandesParSemaine[semainerActuelle] ?? [];
  bool get aDesCommandes => commandesSemainerActuelle.isNotEmpty;

  void changerOngletSemaine(int index) {
    if (index >= 0 && index < semainesDisponibles.length) {
      _semainerSelectionne = index;
      notifyListeners();
    }
  }

  void _definirEtatChargement(bool chargement, String? erreur) {
    _estEnChargement = chargement;
    _messageErreur = erreur;
    notifyListeners();
  }

  Future<void> chargerHistorique() async {
    _definirEtatChargement(true, null);

    try {
      // Charger les menus du mois courant depuis la BDD
      _menusDuMois = await ServiceMenu.obtenirMenusDuMoisCourant();

      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        _commandesParSemaine = {};
        _definirEtatChargement(false, null);
        return;
      }

      // Charger toutes les commandes de l'utilisateur
      final toutesCommandes = await ServiceCommande.obtenirCommandesUtilisateur(
        utilisateur.idUser,
      );

      // Organiser les commandes par semaine selon les menus
      _commandesParSemaine = _organiserCommandesParSemaine(toutesCommandes);

      _definirEtatChargement(false, null);
    } catch (e) {
      _definirEtatChargement(false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Map<String, List<Commande>> _organiserCommandesParSemaine(List<Commande> commandes) {
    final Map<String, List<Commande>> commandesParSemaine = {};

    // Initialiser toutes les semaines disponibles depuis les menus
    for (var menu in _menusDuMois) {
      final labelSemaine = _formaterSemaine(menu);
      commandesParSemaine[labelSemaine] = [];
    }

    // Organiser les commandes par semaine selon le menu du plat
    for (var commande in commandes) {
      // Trouver le menu correspondant au plat de la commande
      if (commande.plat != null) {
        final menuCommande = _menusDuMois.firstWhere(
          (menu) => menu.idMenu == commande.plat!.idMenu,
          orElse: () => Menu(
            idMenu: -1,
            semaine: 0,
            dateDebut: DateTime.now(),
            dateFin: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );

        // Si le menu existe dans notre liste du mois courant
        if (menuCommande.idMenu != -1) {
          final labelSemaine = _formaterSemaine(menuCommande);
          if (commandesParSemaine.containsKey(labelSemaine)) {
            commandesParSemaine[labelSemaine]!.add(commande);
          }
        }
      }
    }

    return commandesParSemaine;
  }

  Future<void> actualiserHistorique() async {
    await chargerHistorique();
  }

  /// Modifier le plat d'une commande
  Future<bool> modifierPlat({
    required int idCommande,
    required int nouveauIdPlat,
  }) async {
    _definirEtatChargement(true, null);

    try {
      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        throw Exception('Utilisateur non connecté');
      }

      await ServiceCommande.modifierCommande(
        idCommandeAnnulee: idCommande,
        idUser: utilisateur.idUser,
        nouveauIdPlat: nouveauIdPlat,
      );

      // Recharger l'historique
      await chargerHistorique();

      _definirEtatChargement(false, null);
      return true;
    } catch (e) {
      _definirEtatChargement(false, e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Annuler une commande
  Future<bool> annulerCommande(int idCommande) async {
    _definirEtatChargement(true, null);

    try {
      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        throw Exception('Utilisateur non connecté');
      }

      await ServiceCommande.annulerCommande(
        idCommande: idCommande,
        idUser: utilisateur.idUser,
      );

      // Recharger l'historique
      await chargerHistorique();

      _definirEtatChargement(false, null);
      return true;
    } catch (e) {
      _definirEtatChargement(false, e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Modifier le site de livraison d'une commande
  Future<bool> modifierSiteCommande({
    required int idCommande,
    required String nouveauSite,
  }) async {
    _definirEtatChargement(true, null);

    try {
      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        throw Exception('Utilisateur non connecté');
      }

      await ServiceCommande.modifierSiteLivraison(
        idCommande: idCommande,
        nouveauSite: nouveauSite,
        modifiePar: utilisateur.idUser,
      );

      // Recharger l'historique
      await chargerHistorique();

      _definirEtatChargement(false, null);
      return true;
    } catch (e) {
      _definirEtatChargement(false, e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Modifier les notes spéciales d'une commande
  Future<bool> modifierNotesCommande({
    required int idCommande,
    required String nouvellesNotes,
  }) async {
    _definirEtatChargement(true, null);

    try {
      final utilisateur = _authModelVue.utilisateurConnecte;
      if (utilisateur == null) {
        throw Exception('Utilisateur non connecté');
      }

      await ServiceCommande.modifierNotesSpeciales(
        idCommande: idCommande,
        nouvellesNotes: nouvellesNotes.isNotEmpty ? nouvellesNotes : null,
        modifiePar: utilisateur.idUser,
      );

      // Recharger l'historique
      await chargerHistorique();

      _definirEtatChargement(false, null);
      return true;
    } catch (e) {
      _definirEtatChargement(false, e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
}