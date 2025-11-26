import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles_vues/authentification_model_vue.dart';
import '../navigation/navigation_principale.dart';

class EcranInscription extends StatefulWidget {
  const EcranInscription({super.key});

  @override
  State<EcranInscription> createState() => _EtatEcranInscription();
}

class _EtatEcranInscription extends State<EcranInscription> {
  final _cleFormulaire = GlobalKey<FormState>();

  /// Liste des départements disponibles
  static const List<String> _departements = [
    'MCP',
    'COMMERCE',
    'DOMAIN ARCHITECT',
    'CYBER SECURITE',
    'INFRASTRUCTURE',
    'COMPTABILITE',
    'RH',
    'MOYENS GENERAUX',
    'JURIDIQUE',
    'COORDINATION DES PROJETS',
    'DEVELOPPEMENT',
    'SIG',
    'DATA',
    'SGO',
    'ETUDE ET STATISTIQUE',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.blanc,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CouleursApp.grisFonce),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'inscription',
          style: TextStyle(
            color: CouleursApp.grisFonce,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
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

                    // Message de bienvenue
                    const Column(
                      children: [
                        Text(
                          'Bienvenue !',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.bleuPrimaire,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Créer un compte',
                          style: TextStyle(
                            fontSize: 16,
                            color: CouleursApp.bleuPrimaire,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: TaillesApp.espacementTresGrand),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CouleursApp.gris),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: modelVue.controleurNom,
                        validator: (value) => modelVue.validerChampRequis(value, 'Le nom'),
                        decoration: const InputDecoration(
                          hintText: 'Nom',
                          hintStyle: TextStyle(color: CouleursApp.gris),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CouleursApp.gris),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: modelVue.controleurPrenom,
                        validator: (value) => modelVue.validerChampRequis(value, 'Le prénom'),
                        decoration: const InputDecoration(
                          hintText: 'Prénom',
                          hintStyle: TextStyle(color: CouleursApp.gris),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

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

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CouleursApp.gris),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: modelVue.controleurConfirmationMotDePasse,
                        obscureText: !modelVue.confirmationMotDePasseVisible,
                        validator: modelVue.validerConfirmationMotDePasse,
                        decoration: InputDecoration(
                          hintText: 'Confirmez le mot de passe',
                          hintStyle: const TextStyle(color: CouleursApp.gris),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              modelVue.confirmationMotDePasseVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: CouleursApp.gris,
                            ),
                            onPressed: modelVue.basculerVisibiliteConfirmationMotDePasse,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CouleursApp.gris),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: modelVue.controleurQid,
                        validator: (value) => modelVue.validerChampRequis(value, 'Le QID'),
                        decoration: const InputDecoration(
                          hintText: 'QID (Identifiant employé)',
                          hintStyle: TextStyle(color: CouleursApp.gris),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    // Sélection du département
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CouleursApp.gris),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: modelVue.departementSelectionne,
                        onChanged: (String? nouveauDepartement) {
                          if (nouveauDepartement != null) {
                            modelVue.changerDepartement(nouveauDepartement);
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Département/Service',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        items: _departements.map((String departement) {
                          return DropdownMenuItem<String>(
                            value: departement,
                            child: Text(departement),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    // Sélection du site
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CouleursApp.gris),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: modelVue.siteSelectionne,
                        onChanged: (String? nouveauSite) {
                          if (nouveauSite != null) {
                            modelVue.changerSite(nouveauSite);
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Site de travail',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'CAMPUS',
                            child: Text('Campus'),
                          ),
                          DropdownMenuItem(
                            value: 'DANGA',
                            child: Text('Danga'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementTresGrand),

                    // Bouton d'inscription
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: modelVue.estEnChargement
                            ? null
                            : () => _gererInscription(context, modelVue),
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
                                'Créer mon compte',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacementMoyen),

                    // Lien "J'ai déjà un compte"
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'J\'ai déjà un compte',
                        style: TextStyle(
                          color: CouleursApp.bleuPrimaire,
                          fontSize: 14,
                        ),
                      ),
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

  /// Gérer l'inscription
  Future<void> _gererInscription(
    BuildContext context,
    AuthentificationModelVue modelVue,
  ) async {
    if (_cleFormulaire.currentState!.validate()) {
      final succes = await modelVue.sInscrire();
      if (succes && context.mounted) {
        // Rediriger vers l'application après inscription réussie
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NavigationPrincipale(),
          ),
          (route) => false,
        );

        // Afficher message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Bienvenue sur SAH Food 🎉'),
            backgroundColor: CouleursApp.succes,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}