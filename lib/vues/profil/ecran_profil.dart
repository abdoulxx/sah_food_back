import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles_vues/profil_model_vue.dart';
import '../authentification/ecran_connexion.dart';
import 'ecran_mes_informations.dart';

class EcranProfil extends StatelessWidget {
  const EcranProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          decoration: const BoxDecoration(
            color: CouleursApp.bleuPrimaire,
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                'Profil',
                style: TextStyle(
                  color: CouleursApp.blanc,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: Container(
            color: CouleursApp.grisClair,
            child: Consumer<ProfilModelVue>(
              builder: (context, profilModel, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!profilModel.estConnecte) {
                    profilModel.initialiser();
                  }
                });

                if (profilModel.estEnChargement) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: CouleursApp.bleuPrimaire,
                    ),
                  );
                }

                if (profilModel.messageErreur != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: CouleursApp.erreur,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profilModel.messageErreur!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CouleursApp.erreur,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => profilModel.initialiser(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (!profilModel.estConnecte) {
                  return const Center(
                    child: Text(
                      'Aucun utilisateur connecté',
                      style: TextStyle(
                        fontSize: 16,
                        color: CouleursApp.gris,
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
                  children: [
                    _construireCarteUtilisateur(profilModel),
                    const SizedBox(height: TaillesApp.espacementMoyen),
                    _construireMenuOptions(context, profilModel),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _construireCarteUtilisateur(ProfilModelVue profilModel) {
    final utilisateur = profilModel.utilisateurConnecte!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: CouleursApp.bleuPrimaire,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.blanc,
                  ),
                ),
              ),
            ),
            const SizedBox(height: TaillesApp.espacementMin),

            Text(
              utilisateur.nomComplet,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CouleursApp.bleuFonce,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              utilisateur.email,
              style: const TextStyle(
                fontSize: 14,
                color: CouleursApp.gris,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: CouleursApp.orangePrimaire.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                utilisateur.site,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CouleursApp.orangePrimaire,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireMenuOptions(BuildContext context, ProfilModelVue profilModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.person,
              color: CouleursApp.bleuPrimaire,
            ),
            title: const Text('Mes Informations'),
            subtitle: const Text('Modifier profil et mot de passe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EcranMesInformations(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.chat_outlined,
              color: CouleursApp.bleuPrimaire,
            ),
            title: const Text('Nous Contacter'),
            subtitle: const Text('Support via WhatsApp'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('bientot')),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: CouleursApp.erreur,
            ),
            title: const Text(
              'Se Déconnecter',
              style: TextStyle(color: CouleursApp.erreur),
            ),
            onTap: () => _confirmerDeconnexion(context, profilModel),
          ),
        ],
      ),
    );
  }

  void _confirmerDeconnexion(BuildContext context, ProfilModelVue profilModel) {
    // Sauvegarder le context de l'écran principal (pas celui du dialogue)
    final screenContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Déconnecter l'utilisateur
              await profilModel.deconnecter();

              // Fermer le dialogue en utilisant son propre context
              Navigator.of(dialogContext).pop();

              // Rediriger vers la page de connexion en utilisant le context de l'écran
              if (screenContext.mounted) {
                Navigator.of(screenContext, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const EcranConnexion(),
                  ),
                  (route) => false, // Supprimer toutes les routes précédentes
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.erreur,
            ),
            child: const Text('Se Déconnecter'),
          ),
        ],
      ),
    );
  }

}