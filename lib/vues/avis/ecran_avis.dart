import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modeles_vues/avis_model_vue.dart';
import '../../modeles_vues/authentification_model_vue.dart';
import '../../modeles/avis.dart';
import '../../modeles/commande.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';

class EcranAvis extends StatefulWidget {
  const EcranAvis({super.key});

  @override
  State<EcranAvis> createState() => _EcranAvisState();
}

class _EcranAvisState extends State<EcranAvis> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Attendre que l'utilisateur soit chargé
      final authModel = context.read<AuthentificationModelVue>();
      while (authModel.utilisateurEnCoursDeChargement) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Charger les avis une fois que l'utilisateur est prêt
      if (mounted) {
        final avisModel = context.read<AvisModelVue>();
        await avisModel.chargerMesAvis();
      }
    });
  }

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
                'Mes Avis',
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
            child: Consumer<AvisModelVue>(
              builder: (context, model, child) {
                if (model.estEnChargement) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (model.messageErreur != null) {
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
                          model.messageErreur!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CouleursApp.erreur,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => model.chargerMesAvis(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                return _construireListeMesCommandes(model);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _construireListeMesCommandes(AvisModelVue model) {
    final commandesValidees = model.commandesValidees;

    return RefreshIndicator(
      onRefresh: () => model.actualiserMesAvis(),
      child: commandesValidees.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_outlined,
                        size: 64,
                        color: CouleursApp.gris,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucune commande validée',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CouleursApp.bleuFonce,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vos plats livrés apparaîtront ici\npour que vous puissiez les évaluer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: CouleursApp.gris,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
              itemCount: commandesValidees.length,
              itemBuilder: (context, index) {
                final commande = commandesValidees[index];
                final avisExistant = model.obtenirAvisPourCommande(commande.idCommande);

                return _construireCarteCommande(commande, avisExistant, model);
              },
            ),
    );
  }

  Widget _construireCarteCommande(Commande commande, Avis? avisExistant, AvisModelVue model) {
    return Card(
      margin: const EdgeInsets.only(bottom: TaillesApp.espacementMoyen),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                  child: commande.plat?.photoUrl != null
                      ? Image.asset(
                          commande.plat!.photoUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                                color: CouleursApp.grisClair,
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                size: 30,
                                color: CouleursApp.gris,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                            color: CouleursApp.grisClair,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            size: 30,
                            color: CouleursApp.gris,
                          ),
                        ),
                ),

                const SizedBox(width: TaillesApp.espacementMoyen),

                // Informations du plat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commande.plat?.nomPlat ?? 'Plat inconnu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CouleursApp.bleuFonce,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _obtenirJourCommande(commande.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          color: CouleursApp.gris,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: TaillesApp.espacementMoyen),

            // Section d'évaluation
            if (avisExistant != null) ...[
              // Avis déjà donné
              Container(
                padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
                decoration: BoxDecoration(
                  color: CouleursApp.succes.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                  border: Border.all(color: CouleursApp.succes.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: CouleursApp.succes, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Votre évaluation :',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.succes,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _afficherDialogueModifierAvis(commande, avisExistant),
                          child: const Icon(Icons.edit, color: CouleursApp.bleuPrimaire, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          avisExistant.affichageEtoiles,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CouleursApp.orangePrimaire,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${avisExistant.note}/5',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.bleuFonce,
                          ),
                        ),
                      ],
                    ),
                    if (avisExistant.aUnCommentaire) ...[
                      const SizedBox(height: 8),
                      Text(
                        avisExistant.commentaire!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CouleursApp.bleuFonce,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Pas encore d'avis - bouton pour évaluer
              Container(
                padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
                decoration: BoxDecoration(
                  color: CouleursApp.orangePrimaire.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                  border: Border.all(color: CouleursApp.orangePrimaire.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_border, color: CouleursApp.orangePrimaire),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Donnez votre avis sur ce plat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CouleursApp.orangePrimaire,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _afficherDialogueAjoutAvis(commande),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CouleursApp.orangePrimaire,
                        foregroundColor: CouleursApp.blanc,
                        padding: const EdgeInsets.symmetric(
                          horizontal: TaillesApp.espacementMoyen,
                          vertical: TaillesApp.espacementMin,
                        ),
                      ),
                      child: const Text(
                        'Évaluer',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _obtenirJourCommande(DateTime dateCommande) {
    const List<String> jours = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];

    const List<String> mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];

    final nomJour = jours[dateCommande.weekday - 1];
    final jour = dateCommande.day;
    final nomMois = mois[dateCommande.month - 1];

    return '$nomJour $jour $nomMois';
  }

  void _afficherDialogueAjoutAvis(Commande commande) {
    showDialog(
      context: context,
      builder: (context) => _DialogueAjoutAvis(commande: commande),
    );
  }

  void _afficherDialogueModifierAvis(Commande commande, Avis avisExistant) {
    showDialog(
      context: context,
      builder: (context) => _DialogueAjoutAvis(
        commande: commande,
        avisExistant: avisExistant,
      ),
    );
  }
}

class _DialogueAjoutAvis extends StatefulWidget {
  final Commande commande;
  final Avis? avisExistant;

  const _DialogueAjoutAvis({
    required this.commande,
    this.avisExistant,
  });

  @override
  State<_DialogueAjoutAvis> createState() => _DialogueAjoutAvisState();
}

class _DialogueAjoutAvisState extends State<_DialogueAjoutAvis> {
  int _noteSelectionnee = 0;
  final _controleurCommentaire = TextEditingController();

  bool get _estModification => widget.avisExistant != null;

  @override
  void initState() {
    super.initState();
    if (_estModification) {
      _noteSelectionnee = widget.avisExistant!.note ?? 0;
      _controleurCommentaire.text = widget.avisExistant!.commentaire ?? '';
    }
  }

  @override
  void dispose() {
    _controleurCommentaire.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_estModification ? 'Modifier votre avis' : 'Donner votre avis'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du plat
            Container(
              padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
              decoration: BoxDecoration(
                color: CouleursApp.grisClair,
                borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                    child: widget.commande.plat?.photoUrl != null
                        ? Image.asset(
                            widget.commande.plat!.photoUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                                  color: CouleursApp.gris,
                                ),
                                child: const Icon(Icons.restaurant, color: CouleursApp.blanc),
                              );
                            },
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                              color: CouleursApp.gris,
                            ),
                            child: const Icon(Icons.restaurant, color: CouleursApp.blanc),
                          ),
                  ),
                  const SizedBox(width: TaillesApp.espacementMoyen),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.commande.plat?.nomPlat ?? 'Plat inconnu',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Votre note :',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _noteSelectionnee = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _noteSelectionnee ? Icons.star : Icons.star_border,
                      color: CouleursApp.orangePrimaire,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            if (_noteSelectionnee > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${_noteSelectionnee}/5 étoiles',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.bleuPrimaire,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Votre commentaire (optionnel) :',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controleurCommentaire,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Partagez votre expérience avec ce plat...',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _noteSelectionnee > 0 ? _soumettreAvis : null,
          child: Text(_estModification ? 'Modifier' : 'Publier'),
        ),
      ],
    );
  }

  Future<void> _soumettreAvis() async {
    final model = context.read<AvisModelVue>();

    final succes = await model.ajouterOuModifierAvis(
      idCommande: widget.commande.idCommande,
      idPlat: widget.commande.plat?.idPlat ?? widget.commande.idPlat,
      note: _noteSelectionnee,
      commentaire: _controleurCommentaire.text.trim().isEmpty
          ? null
          : _controleurCommentaire.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();

      if (succes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_estModification
                ? 'Avis modifié avec succès !'
                : 'Avis publié avec succès !'),
            backgroundColor: CouleursApp.succes,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_estModification
                ? 'Erreur lors de la modification de l\'avis'
                : 'Erreur lors de la publication de l\'avis'),
            backgroundColor: CouleursApp.erreur,
          ),
        );
      }
    }
  }
}