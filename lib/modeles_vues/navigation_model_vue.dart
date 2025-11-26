import 'package:flutter/material.dart';

class NavigationModelVue extends ChangeNotifier {
  int _indexActuel = 0;

  int get indexActuel => _indexActuel;

  static const List<String> nomsOnglets = [
    'Accueil',
    'Menu',
    'Historique',
    'Avis',
    'Profil',
  ];

  String get ongletActuel => nomsOnglets[_indexActuel];

  bool estOngletSelectionne(int index) => _indexActuel == index;

  void changerOnglet(int nouvelIndex) {
    if (nouvelIndex >= 0 && nouvelIndex < nomsOnglets.length) {
      _indexActuel = nouvelIndex;
      notifyListeners();
    }
  }

  void naviguerVersAccueil() => changerOnglet(0);

  void naviguerVersMenu() => changerOnglet(1);

  void naviguerVersHistorique() => changerOnglet(2);

  void naviguerVersAvis() => changerOnglet(3);

  void naviguerVersProfil() => changerOnglet(4);

  void reinitialiser() {
    _indexActuel = 0;
    notifyListeners();
  }
}