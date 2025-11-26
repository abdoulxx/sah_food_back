import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../modeles_vues/navigation_model_vue.dart';
import '../../modeles_vues/accueil_model_vue.dart';
import '../accueil/ecran_accueil.dart';
import '../menu/ecran_menu.dart';
import '../historique/ecran_historique.dart';
import '../avis/ecran_avis.dart';
import '../profil/ecran_profil.dart';


class NavigationPrincipale extends StatelessWidget {
  const NavigationPrincipale({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModelVue>(
      builder: (context, navigationModel, child) {
        // Initialiser l'AccueilModelVue au premier démarrage
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final accueilModel = context.read<AccueilModelVue>();
          if (accueilModel.utilisateurActuel == null) {
            accueilModel.initialiser();
          }
        });

        final pages = [
          const EcranAccueil(),
          const EcranMenu(),
          const EcranHistorique(),
          const EcranAvis(),
          const EcranProfil(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: navigationModel.indexActuel,
            children: pages,
          ),
          bottomNavigationBar: _construireBottomNavigation(navigationModel),
        );
      },
    );
  }

  Widget _construireBottomNavigation(NavigationModelVue navigationModel) {
    return Container(
      color: CouleursApp.blanc,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
      child: SafeArea(
        child: GNav(
          selectedIndex: navigationModel.indexActuel,
          onTabChange: navigationModel.changerOnglet,
          gap: 8,
          activeColor: CouleursApp.blanc,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: CouleursApp.bleuPrimaire,
          color: CouleursApp.gris,
          backgroundColor: CouleursApp.blanc,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CouleursApp.blanc,
          ),
          tabBorderRadius: 15,
          curve: Curves.easeInOut,
          tabs: const [
            GButton(
              icon: Icons.home_outlined,
              text: 'Accueil',
            ),
            GButton(
              icon: Icons.restaurant,
              text: 'Menu',
            ),
            GButton(
              icon: Icons.history_outlined,
              text: 'Historique',
            ),
            GButton(
              icon: Icons.star_outline,
              text: 'Avis',
            ),
            GButton(
              icon: Icons.person_outline,
              text: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}