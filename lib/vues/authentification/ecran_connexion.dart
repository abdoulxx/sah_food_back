import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles_vues/authentification_model_vue.dart';
import 'ecran_inscription.dart';
import 'ecran_mot_de_passe_oublie.dart';
import '../navigation/navigation_principale.dart';

class EcranConnexion extends StatefulWidget {
  const EcranConnexion({super.key});

  @override
  State<EcranConnexion> createState() => _EtatEcranConnexion();
}

class _EtatEcranConnexion extends State<EcranConnexion> {
  final _cleFormulaire = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.blanc,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'login',
            style: TextStyle(
              color: CouleursApp.grisFonce,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        leadingWidth: 80,
      ),
      body: Consumer<AuthentificationModelVue>(
        builder: (context, modelVue, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
              child: Form(
                key: _cleFormulaire,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: TaillesApp.espacementMoyen),

                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: CouleursApp.bleuPrimaire,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/images/sah.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    const Text(
                      'SAH FOOD',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.orangePrimaire,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementTresGrand),

                    const Column(
                      children: [
                        Text(
                          'Hello !',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.bleuPrimaire,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Heureux de vous revoir',
                          style: TextStyle(
                            fontSize: 16,
                            color: CouleursApp.bleuPrimaire,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: TaillesApp.espacementTresGrand),

                    // Champ email
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CouleursApp.gris),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: modelVue.controleurEmail,
                        keyboardType: TextInputType.emailAddress,
                        validator: modelVue.validerEmail,
                        decoration: const InputDecoration(
                          hintText: 'exemple.test@sahanalytics.com',
                          hintStyle: TextStyle(color: CouleursApp.gris),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    // Champ mot de passe
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CouleursApp.gris),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: modelVue.controleurMotDePasse,
                        obscureText: !modelVue.motDePasseVisible,
                        validator: modelVue.validerMotDePasse,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          hintStyle: const TextStyle(color: CouleursApp.gris),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              modelVue.motDePasseVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: CouleursApp.gris,
                            ),
                            onPressed: modelVue.basculerVisibiliteMotDePasse,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementTresGrand),

                    // Bouton de connexion
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: modelVue.estEnChargement
                            ? null
                            : () => _gererConnexion(context, modelVue),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CouleursApp.bleuPrimaire,
                          foregroundColor: CouleursApp.blanc,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: modelVue.estEnChargement
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    CouleursApp.blanc,
                                  ),
                                ),
                              )
                            : const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    // Liens en bas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EcranInscription(),
                              ),
                            );
                          },
                          child: const Text(
                            'Créer un compte',
                            style: TextStyle(
                              color: CouleursApp.bleuPrimaire,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EcranMotDePasseOublie(),
                              ),
                            );
                          },
                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              color: CouleursApp.bleuPrimaire,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Message d'erreur
                    if (modelVue.messageErreur != null) ...[
                      const SizedBox(height: TaillesApp.espacementMoyen),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(TaillesApp.espacementMin),
                        decoration: BoxDecoration(
                          color: CouleursApp.erreur.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                          border: Border.all(color: CouleursApp.erreur),
                        ),
                        child: Text(
                          modelVue.messageErreur!,
                          style: const TextStyle(
                            color: CouleursApp.erreur,
                            fontSize: TaillesApp.taillePoliceMin,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
        },
      ),
    );
  }

  Future<void> _gererConnexion(
    BuildContext context,
    AuthentificationModelVue modelVue,
  ) async {
    if (_cleFormulaire.currentState!.validate()) {
      final succes = await modelVue.seConnecter();
      if (succes && context.mounted) {
        // Utiliser pushAndRemoveUntil pour supprimer toutes les routes précédentes
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NavigationPrincipale(),
          ),
          (route) => false, // Supprimer toutes les routes
        );
      }
    }
  }
}