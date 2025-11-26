import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles/utilisateur.dart';
import '../../modeles_vues/profil_model_vue.dart';

/// Écran de modification des informations personnelles
class EcranMesInformations extends StatefulWidget {
  const EcranMesInformations({super.key});

  @override
  State<EcranMesInformations> createState() => _EtatEcranMesInformations();
}

class _EtatEcranMesInformations extends State<EcranMesInformations> {
  late TextEditingController _controleurNom;
  late TextEditingController _controleurPrenom;
  late TextEditingController _controleurDepartement;
  late TextEditingController _controleurSite;
  late TextEditingController _controleurNouveauMotDePasse;
  late TextEditingController _controleurConfirmationMotDePasse;

  bool _masquerNouveauMotDePasse = true;
  bool _masquerConfirmationMotDePasse = true;

  @override
  void initState() {
    super.initState();
    _controleurNom = TextEditingController();
    _controleurPrenom = TextEditingController();
    _controleurDepartement = TextEditingController();
    _controleurSite = TextEditingController();
    _controleurNouveauMotDePasse = TextEditingController();
    _controleurConfirmationMotDePasse = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profilModel = context.read<ProfilModelVue>();
      _mettreAJourControleurs(profilModel);
    });
  }

  @override
  void dispose() {
    _controleurNom.dispose();
    _controleurPrenom.dispose();
    _controleurDepartement.dispose();
    _controleurSite.dispose();
    _controleurNouveauMotDePasse.dispose();
    _controleurConfirmationMotDePasse.dispose();
    super.dispose();
  }

  void _mettreAJourControleurs(ProfilModelVue profilModel) {
    if (profilModel.utilisateurConnecte != null) {
      final utilisateur = profilModel.utilisateurConnecte!;
      _controleurNom.text = utilisateur.nom;
      _controleurPrenom.text = utilisateur.prenom;
      _controleurDepartement.text = utilisateur.departement ?? '';
      _controleurSite.text = utilisateur.site;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.grisClair,
      appBar: AppBar(
        title: const Text('Mes Informations'),
        backgroundColor: CouleursApp.bleuPrimaire,
        foregroundColor: CouleursApp.blanc,
        elevation: 0,
      ),
      body: Consumer<ProfilModelVue>(
        builder: (context, profilModel, child) {
          if (profilModel.estEnChargement) {
            return const Center(
              child: CircularProgressIndicator(
                color: CouleursApp.bleuPrimaire,
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
              _construireSectionInformationsPersonnelles(profilModel),
              const SizedBox(height: TaillesApp.espacementGrand),
              _construireSectionMotDePasse(profilModel),
              const SizedBox(height: TaillesApp.espacementGrand),
              _construireBoutonsSauvegarde(profilModel),
            ],
          );
        },
      ),
    );
  }

  Widget _construireSectionInformationsPersonnelles(ProfilModelVue profilModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations Personnelles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CouleursApp.bleuFonce,
              ),
            ),
            const SizedBox(height: TaillesApp.espacementMoyen),

            _construireChampTexte(
              label: 'Prénom',
              controleur: _controleurPrenom,
              icone: Icons.person_outline,
            ),

            const SizedBox(height: TaillesApp.espacementMoyen),

            _construireChampTexte(
              label: 'Nom',
              controleur: _controleurNom,
              icone: Icons.person,
            ),

            const SizedBox(height: TaillesApp.espacementMoyen),

            _construireChampTexte(
              label: 'Département',
              controleur: _controleurDepartement,
              icone: Icons.business_outlined,
            ),

            const SizedBox(height: TaillesApp.espacementMoyen),

            _construireChampTexte(
              label: 'Site',
              controleur: _controleurSite,
              icone: Icons.location_on_outlined,
            ),

            const SizedBox(height: TaillesApp.espacementMoyen),
            TextFormField(
              initialValue: profilModel.utilisateurConnecte?.email ?? '',
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                ),
                filled: true,
                fillColor: CouleursApp.grisClair,
              ),
            ),
            const SizedBox(height: TaillesApp.espacementMoyen),

            TextFormField(
              initialValue: profilModel.utilisateurConnecte?.qid ?? '',
              enabled: false,
              decoration: InputDecoration(
                labelText: 'QID',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                ),
                filled: true,
                fillColor: CouleursApp.grisClair,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireSectionMotDePasse(ProfilModelVue profilModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Changer le Mot de Passe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CouleursApp.bleuFonce,
              ),
            ),
            const SizedBox(height: TaillesApp.espacementMin),
            TextFormField(
              controller: _controleurNouveauMotDePasse,
              obscureText: _masquerNouveauMotDePasse,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _masquerNouveauMotDePasse ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _masquerNouveauMotDePasse = !_masquerNouveauMotDePasse;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                  borderSide: const BorderSide(color: CouleursApp.bleuPrimaire),
                ),
                helperText: 'Minimum 6 caractères',
              ),
            ),

            const SizedBox(height: TaillesApp.espacementMoyen),

            TextFormField(
              controller: _controleurConfirmationMotDePasse,
              obscureText: _masquerConfirmationMotDePasse,
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                prefixIcon: const Icon(Icons.lock_clock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _masquerConfirmationMotDePasse ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _masquerConfirmationMotDePasse = !_masquerConfirmationMotDePasse;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                  borderSide: const BorderSide(color: CouleursApp.bleuPrimaire),
                ),
              ),
            ),

            const SizedBox(height: TaillesApp.espacementMin),
          ],
        ),
      ),
    );
  }


  Widget _construireChampTexte({
    required String label,
    required TextEditingController controleur,
    required IconData icone,
    TextInputType? typeClavier,
  }) {
    return TextFormField(
      controller: controleur,
      keyboardType: typeClavier,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
          borderSide: const BorderSide(color: CouleursApp.bleuPrimaire),
        ),
      ),
    );
  }

  Widget _construireBoutonsSauvegarde(ProfilModelVue profilModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: profilModel.estEnChargement
                ? null
                : () async {
                    await _sauvegarderInformations(profilModel);
                  },
            icon: profilModel.estEnChargement
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CouleursApp.blanc,
                    ),
                  )
                : const Icon(Icons.save),
            label: const Text('Sauvegarder les Informations'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: CouleursApp.bleuPrimaire,
              foregroundColor: CouleursApp.blanc,
            ),
          ),
        ),

        const SizedBox(height: TaillesApp.espacementMoyen),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: profilModel.estEnChargement
                ? null
                : () async {
                    await _changerMotDePasse(profilModel);
                  },
            icon: const Icon(Icons.security),
            label: const Text('Changer le Mot de Passe'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: CouleursApp.orangePrimaire),
              foregroundColor: CouleursApp.orangePrimaire,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sauvegarderInformations(ProfilModelVue profilModel) async {
    try {
      await profilModel.mettreAJourProfil(
        nom: _controleurNom.text.trim(),
        prenom: _controleurPrenom.text.trim(),
        departement: _controleurDepartement.text.trim(),
        site: _controleurSite.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations mises à jour avec succès !'),
            backgroundColor: CouleursApp.succes,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: CouleursApp.erreur,
          ),
        );
      }
    }
  }

  Future<void> _changerMotDePasse(ProfilModelVue profilModel) async {
    if (_controleurNouveauMotDePasse.text.isEmpty ||
        _controleurConfirmationMotDePasse.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs de mot de passe'),
          backgroundColor: CouleursApp.avertissement,
        ),
      );
      return;
    }

    if (_controleurNouveauMotDePasse.text != _controleurConfirmationMotDePasse.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
      return;
    }

    if (_controleurNouveauMotDePasse.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit contenir au moins 6 caractères'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
      return;
    }

    try {
      final succes = await profilModel.changerMotDePasse(
        nouveauMotDePasse: _controleurNouveauMotDePasse.text,
      );

      if (mounted) {
        if (succes) {
          _controleurNouveauMotDePasse.clear();
          _controleurConfirmationMotDePasse.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe modifié avec succès !'),
              backgroundColor: CouleursApp.succes,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profilModel.messageErreur ?? 'Erreur inconnue'),
              backgroundColor: CouleursApp.erreur,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: CouleursApp.erreur,
          ),
        );
      }
    }
  }
}