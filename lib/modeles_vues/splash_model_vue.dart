import 'package:flutter/material.dart';
import '../services/service_stockage_local.dart';
import '../services/service_authentification.dart';

class SplashModelVue extends ChangeNotifier {
  bool _estChargementTermine = false;
  bool _estInitialise = false;
  bool _utilisateurConnecte = false;

  bool get estChargementTermine => _estChargementTermine;
  bool get estInitialise => _estInitialise;
  bool get utilisateurConnecte => _utilisateurConnecte;

  Future<void> initialiserApplication() async {
    try {
      // Vérifier s'il existe une session sauvegardée
      final estConnecte = await ServiceStockageLocal.estConnecte();

      if (estConnecte) {
        // Vérifier que l'utilisateur existe vraiment
        final utilisateur = await ServiceAuthentification.obtenirUtilisateurConnecte();
        _utilisateurConnecte = utilisateur != null;
      } else {
        _utilisateurConnecte = false;
      }

      await Future.delayed(const Duration(milliseconds: 200));

      _estInitialise = true;
      _estChargementTermine = true;
      notifyListeners();
    } catch (erreur) {
      debugPrint('Erreur lors de l\'initialisation: $erreur');
      _utilisateurConnecte = false;
      _estChargementTermine = true;
      notifyListeners();
    }
  }

  void reinitialiser() {
    _estChargementTermine = false;
    _estInitialise = false;
    notifyListeners();
  }
}