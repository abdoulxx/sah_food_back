import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles_vues/profil_model_vue.dart';
import '../../services/service_upload.dart';
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
                // Définir le context pour le ProfilModelVue
                profilModel.definirContext(context);

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
            GestureDetector(
              onTap: () => _changerPhotoProfil(profilModel),
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: CouleursApp.bleuPrimaire,
                      shape: BoxShape.circle,
                      image: utilisateur.photo != null
                          ? DecorationImage(
                              image: NetworkImage(utilisateur.photo!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: utilisateur.photo == null
                        ? Center(
                            child: Text(
                              '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: CouleursApp.blanc,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: CouleursApp.orangePrimaire,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: CouleursApp.blanc,
                        size: 16,
                      ),
                    ),
                  ),
                ],
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

  void _changerPhotoProfil(ProfilModelVue profilModel) {
    // Pour l'instant, on affiche juste une dialogue avec les options
    // L'implémentation complète nécessitera image_picker
    if (profilModel.context == null) return;

    showDialog(
      context: profilModel.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        ),
        title: const Text(
          'Photo de profil',
          style: TextStyle(
            color: CouleursApp.bleuFonce,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: CouleursApp.bleuPrimaire),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.of(context).pop();
                _prendrePhoto(profilModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: CouleursApp.bleuPrimaire),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.of(context).pop();
                _choisirGalerie(profilModel);
              },
            ),
            if (profilModel.utilisateurConnecte?.photo != null)
              ListTile(
                leading: const Icon(Icons.delete, color: CouleursApp.erreur),
                title: const Text(
                  'Supprimer la photo',
                  style: TextStyle(color: CouleursApp.erreur),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _supprimerPhoto(profilModel);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _prendrePhoto(ProfilModelVue profilModel) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploaderEtEnregistrerPhoto(File(image.path), profilModel);
      }
    } catch (e) {
      if (profilModel.context != null && profilModel.context!.mounted) {
        ScaffoldMessenger.of(profilModel.context!).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la prise de photo: $e'),
            backgroundColor: CouleursApp.erreur,
          ),
        );
      }
    }
  }

  Future<void> _choisirGalerie(ProfilModelVue profilModel) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploaderEtEnregistrerPhoto(File(image.path), profilModel);
      }
    } catch (e) {
      if (profilModel.context != null && profilModel.context!.mounted) {
        ScaffoldMessenger.of(profilModel.context!).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du choix de la photo: $e'),
            backgroundColor: CouleursApp.erreur,
          ),
        );
      }
    }
  }

  Future<void> _uploaderEtEnregistrerPhoto(File fichierImage, ProfilModelVue profilModel) async {
    final utilisateur = profilModel.utilisateurConnecte;
    if (utilisateur == null) return;

    if (profilModel.context != null && profilModel.context!.mounted) {
      // Afficher un indicateur de chargement
      showDialog(
        context: profilModel.context!,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: CouleursApp.bleuPrimaire,
          ),
        ),
      );
    }

    try {
      // Upload vers Supabase Storage
      final urlPhoto = await ServiceUpload.uploaderPhotoProfil(
        fichierImage: fichierImage,
        idUser: utilisateur.idUser,
      );

      // Mettre à jour le profil avec la nouvelle URL
      await profilModel.mettreAJourPhoto(urlPhoto);

      // Fermer l'indicateur de chargement
      if (profilModel.context != null && profilModel.context!.mounted) {
        Navigator.of(profilModel.context!).pop();

        // Afficher un message de succès
        ScaffoldMessenger.of(profilModel.context!).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour avec succès'),
            backgroundColor: CouleursApp.succes,
          ),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (profilModel.context != null && profilModel.context!.mounted) {
        Navigator.of(profilModel.context!).pop();

        // Afficher un message d'erreur
        ScaffoldMessenger.of(profilModel.context!).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload: $e'),
            backgroundColor: CouleursApp.erreur,
          ),
        );
      }
    }
  }

  Future<void> _supprimerPhoto(ProfilModelVue profilModel) async {
    try {
      await profilModel.supprimerPhoto();
      if (profilModel.context != null && profilModel.context!.mounted) {
        ScaffoldMessenger.of(profilModel.context!).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil supprimée'),
            backgroundColor: CouleursApp.succes,
          ),
        );
      }
    } catch (e) {
      if (profilModel.context != null && profilModel.context!.mounted) {
        ScaffoldMessenger.of(profilModel.context!).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: CouleursApp.erreur,
          ),
        );
      }
    }
  }

}