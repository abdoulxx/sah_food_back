import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../authentification/ecran_connexion.dart';

class EcranOnboarding extends StatelessWidget {
  const EcranOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: _obtenirPagesIntroduction(),
      onDone: () => _terminerOnboarding(context),
      onSkip: () => _terminerOnboarding(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(
        Icons.arrow_back,
        color: CouleursApp.blanc,
      ),
      skip: const Text(
        'Passer',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: CouleursApp.blanc,
        ),
      ),
      next: const Icon(
        Icons.arrow_forward,
        color: CouleursApp.blanc,
      ),
      done: const Text(
        'Commencer',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: CouleursApp.blanc,
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(TaillesApp.espacementMoyen),
      controlsPadding: const EdgeInsets.fromLTRB(
        TaillesApp.espacementMin,
        TaillesApp.espacementMin,
        TaillesApp.espacementMin,
        TaillesApp.espacementMin,
      ),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: CouleursApp.gris,
        activeSize: Size(22.0, 10.0),
        activeColor: CouleursApp.orangePrimaire,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(TaillesApp.rayonGrand),
          ),
        ),
      ),
      globalBackgroundColor: CouleursApp.blanc,
      baseBtnStyle: TextButton.styleFrom(
        backgroundColor: CouleursApp.bleuPrimaire,
        padding: const EdgeInsets.symmetric(
          horizontal: TaillesApp.espacementMoyen,
          vertical: TaillesApp.espacementMin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        ),
      ),
    );
  }
  List<PageViewModel> _obtenirPagesIntroduction() {
    return [
      PageViewModel(
        title: "Bienvenue chez SAH Food",
        body: "Découvrez votre nouvelle plateforme de commandes "
              "de repas pour l'entreprise SAH Analytics."
              "Simplifiez vos pauses déjeuner !",
        image: _construireImagePage(
          icone: Icons.restaurant,
          couleurFond: CouleursApp.orangePrimaire,
        ),
        decoration: _obtenirDecorationPage(),
      ),
      PageViewModel(
        title: "Commandez facilement",
        body: "Consultez les menus hebdomadaires,"
              "choisissez vos plats préférés et passez vos commandes "
              "en quelques clics depuis votre bureau.",
        image: _construireImagePage(
          icone: Icons.shopping_bag_outlined,
          couleurFond: CouleursApp.bleuPrimaire,
        ),
        decoration: _obtenirDecorationPage(),
      ),

      PageViewModel(
        title: "Campus et Danga",
        body: "Chaque collaborateur commande selon "
              "son site de travail pour une gestion optimisée.",
        image: _construireImagePage(
          icone: Icons.business,
          couleurFond: CouleursApp.orangePrimaire,
        ),
        decoration: _obtenirDecorationPage(),
      ),
      PageViewModel(
        title: "Partagez votre avis",
        body: "Évaluez vos plats avec des étoiles et laissez des commentaires "
              "pour aider à améliorer la qualité des repas proposés.",
        image: _construireImagePage(
          icone: Icons.star_rate,
          couleurFond: CouleursApp.bleuPrimaire,
        ),
        decoration: _obtenirDecorationPage(),
      ),
    ];
  }

  Widget _construireImagePage({
    required IconData icone,
    required Color couleurFond,
  }) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: couleurFond,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: couleurFond.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          icone,
          size: 100,
          color: CouleursApp.blanc,
        ),
      ),
    );
  }

  PageDecoration _obtenirDecorationPage() {
    return const PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: TaillesApp.taillePoliceTitre,
        fontWeight: FontWeight.bold,
        color: CouleursApp.bleuFonce,
      ),

      bodyTextStyle: TextStyle(
        fontSize: TaillesApp.taillePoliceGrande,
        color: CouleursApp.grisFonce,
        height: 1.5,
      ),
      imagePadding: EdgeInsets.only(top: TaillesApp.espacementTresGrand * 2),
      contentMargin: EdgeInsets.symmetric(
        horizontal: TaillesApp.espacementMoyen,
      ),
      pageColor: CouleursApp.blanc,
    );
  }

  void _terminerOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const EcranConnexion(),
      ),
    );
  }
}