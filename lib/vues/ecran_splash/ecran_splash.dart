import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles_vues/splash_model_vue.dart';
import '../../modeles_vues/authentification_model_vue.dart';
import '../onboarding/ecran_onboarding.dart';
import '../navigation/navigation_principale.dart';

class EcranSplash extends StatefulWidget {
  const EcranSplash({super.key});

  @override
  State<EcranSplash> createState() => _EtatEcranSplash();
}

class _EtatEcranSplash extends State<EcranSplash> {

  @override
  void initState() {
    super.initState();
    _demarrerChargement();
  }

  void _demarrerChargement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final splashModelVue = Provider.of<SplashModelVue>(context, listen: false);
      splashModelVue.initialiserApplication().then((_) {
        if (mounted) {
          _naviguerSelonEtatConnexion();
        }
      });
    });
  }

  void _naviguerSelonEtatConnexion() {
    final splashModelVue = Provider.of<SplashModelVue>(context, listen: false);

    if (splashModelVue.utilisateurConnecte) {
      // L'utilisateur est connecté → charger ses données et aller à la page principale
      final authModel = Provider.of<AuthentificationModelVue>(context, listen: false);
      authModel.chargerUtilisateurConnecte().then((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const NavigationPrincipale(),
            ),
          );
        }
      });
    } else {
      // Pas d'utilisateur connecté → aller à l'onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const EcranOnboarding(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.blanc,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: CouleursApp.bleuPrimaire,
                borderRadius: BorderRadius.circular(60),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/images/sah.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: TaillesApp.espacementTresGrand),

            const Text(
              'SAH FOOD',
              style: TextStyle(
                fontSize: TaillesApp.taillePoliceTitre,
                fontWeight: FontWeight.bold,
                color: CouleursApp.bleuPrimaire,
              ),
            ),
          ],
        ),
      ),
    );
  }
}