import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../modeles_vues/historique_model_vue.dart';
import '../../modeles_vues/authentification_model_vue.dart';
import '../../modeles_vues/navigation_model_vue.dart';
import '../../modeles/commande.dart';
import '../../services/service_menu.dart';
import '../../services/service_interactions.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../widgets/skeleton_loader.dart';

class EcranHistorique extends StatefulWidget {
  const EcranHistorique({super.key});

  @override
  State<EcranHistorique> createState() => _EcranHistoriqueState();
}

class _EcranHistoriqueState extends State<EcranHistorique> {
  final PageController _controleurPage = PageController();
  int? _dernierIndexNavigation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _chargerDonnees();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Détecter le retour sur cet onglet
    final navigationModel = context.watch<NavigationModelVue>();
    if (navigationModel.indexActuel == 2 && _dernierIndexNavigation != 2) {
      // On vient de revenir sur l'onglet Historique
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HistoriqueModelVue>().chargerHistorique();
        }
      });
    }
    _dernierIndexNavigation = navigationModel.indexActuel;
  }

  Future<void> _chargerDonnees() async {
    // Attendre que l'utilisateur soit chargé
    final authModel = context.read<AuthentificationModelVue>();
    while (authModel.utilisateurEnCoursDeChargement) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Charger l'historique une fois que l'utilisateur est prêt
    if (mounted) {
      context.read<HistoriqueModelVue>().chargerHistorique();
    }
  }

  @override
  void dispose() {
    _controleurPage.dispose();
    super.dispose();
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
                'Historique',
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
            child: Consumer<HistoriqueModelVue>(
              builder: (context, model, child) {
                if (model.estEnChargement) {
                  return const Padding(
                    padding: EdgeInsets.all(TaillesApp.espacementMoyen),
                    child: Column(
                      children: [
                        SkeletonListItem(),
                        SizedBox(height: TaillesApp.espacementMoyen),
                        SkeletonListItem(),
                        SizedBox(height: TaillesApp.espacementMoyen),
                        SkeletonListItem(),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    _construireOngletsSemaines(model),
                    Expanded(
                      child: PageView.builder(
                        controller: _controleurPage,
                        onPageChanged: (index) {
                          model.changerOngletSemaine(index);
                        },
                        itemCount: model.semainesDisponibles.length,
                        itemBuilder: (context, index) {
                          final semaine = model.semainesDisponibles[index];
                          return _construirePageSemaine(model, semaine);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _construireOngletsSemaines(HistoriqueModelVue model) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(TaillesApp.espacementMoyen),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.semainesDisponibles.length,
        itemBuilder: (context, index) {
          final semaine = model.semainesDisponibles[index];
          final estSelectionne = model.semainerSelectionne == index;

          return GestureDetector(
            onTap: () {
              model.changerOngletSemaine(index);
              _controleurPage.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: TaillesApp.espacementMoyen),
              padding: const EdgeInsets.symmetric(
                horizontal: TaillesApp.espacementMoyen,
                vertical: TaillesApp.espacementMin,
              ),
              decoration: BoxDecoration(
                color: estSelectionne ? CouleursApp.orangePrimaire : CouleursApp.blanc,
                borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                boxShadow: [
                  BoxShadow(
                    color: CouleursApp.gris.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  semaine,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: estSelectionne ? CouleursApp.blanc : CouleursApp.bleuFonce,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construirePageSemaine(HistoriqueModelVue model, String semaine) {
    final commandes = model.commandesParSemaine[semaine] ?? [];

    if (commandes.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => model.chargerHistorique(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 64,
                    color: CouleursApp.gris,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune commande pour $semaine',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.bleuFonce,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Grouper les commandes par jour
    final commandesParJour = <String, List<Commande>>{};
    for (final commande in commandes) {
      final jour = commande.jourSemaine;
      commandesParJour[jour] = commandesParJour[jour] ?? [];
      commandesParJour[jour]!.add(commande);
    }

    // Ordre des jours de la semaine
    const ordreJours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

    // Trier les jours selon l'ordre défini
    final joursTries = commandesParJour.keys.toList()
      ..sort((a, b) => ordreJours.indexOf(a).compareTo(ordreJours.indexOf(b)));

    return RefreshIndicator(
      onRefresh: () => model.chargerHistorique(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: joursTries.asMap().entries.map((entry) {
            final index = entry.key;
            final jour = entry.value;
            return _construireGroupeJour(jour, commandesParJour[jour]!)
                .animate()
                .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: (index * 100).ms, curve: Curves.easeOutQuad);
          }).toList(),
        ),
      ),
    );
  }

  Widget _construireGroupeJour(String jour, List<Commande> commandes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: TaillesApp.espacementMoyen),
          child: Text(
            jour,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CouleursApp.bleuPrimaire,
            ),
          ),
        ),
        ...commandes.map((commande) => _construireCarteCommande(commande)),
        const SizedBox(height: TaillesApp.espacementMoyen),
      ],
    );
  }

  Widget _construireCarteCommande(Commande commande) {
    return Card(
      margin: const EdgeInsets.only(bottom: TaillesApp.espacementMoyen),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
              child: commande.plat?.photoUrl != null
                  ? Image.asset(
                      commande.plat!.photoUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
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
                      width: 60,
                      height: 60,
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
                    ),
                  ),
                  const SizedBox(height: TaillesApp.espacementMin / 2),
                  _construireBadgeStatut(commande.statut),
                ],
              ),
            ),

            // Bouton modifier si en attente
            if (commande.statut == StatutCommande.enAttente)
              ElevatedButton(
                onPressed: () async {
                  await ServiceInteractions.vibrationLegere();
                  _afficherOptionsModification(commande);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.bleuPrimaire,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TaillesApp.espacementMoyen,
                    vertical: TaillesApp.espacementMin,
                  ),
                ),
                child: const Text(
                  'Modifier',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construireBadgeStatut(StatutCommande statut) {
    Color couleur;
    String texte;

    switch (statut) {
      case StatutCommande.enAttente:
        couleur = CouleursApp.orangePrimaire;
        texte = 'En attente';
        break;
      case StatutCommande.validee:
        couleur = CouleursApp.succes;
        texte = 'Validée';
        break;
      case StatutCommande.annulee:
        couleur = CouleursApp.erreur;
        texte = 'Annulée';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TaillesApp.espacementMin,
        vertical: TaillesApp.espacementMin / 2,
      ),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
        border: Border.all(color: couleur, width: 1),
      ),
      child: Text(
        texte,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: couleur,
        ),
      ),
    );
  }

  /// Afficher le dialog avec les options de modification
  void _afficherOptionsModification(Commande commande) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        ),
        title: const Text(
          'Modifier la commande',
          style: TextStyle(
            color: CouleursApp.bleuFonce,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: CouleursApp.bleuPrimaire),
              title: const Text('Changer de plat'),
              subtitle: const Text('Choisir un autre plat pour ce jour'),
              onTap: () {
                Navigator.of(context).pop();
                _afficherBottomSheetChangementPlat(commande);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on, color: CouleursApp.orangePrimaire),
              title: const Text('Modifier le site de livraison'),
              subtitle: Text('Actuellement: ${commande.siteLivraison ?? "Non défini"}'),
              onTap: () {
                Navigator.of(context).pop();
                _afficherDialogueModifierSite(commande);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_note, color: CouleursApp.bleuPrimaire),
              title: const Text('Modifier les notes spéciales'),
              subtitle: Text(
                commande.notesSpeciales?.isNotEmpty == true
                    ? commande.notesSpeciales!
                    : 'Aucune note',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _afficherDialogueModifierNotes(commande);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel, color: CouleursApp.erreur),
              title: const Text('Annuler la commande'),
              subtitle: const Text('Supprimer cette commande'),
              onTap: () {
                Navigator.of(context).pop();
                _confirmerAnnulation(commande);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Afficher le bottom sheet pour changer de plat
  void _afficherBottomSheetChangementPlat(Commande commande) async {
    final model = context.read<HistoriqueModelVue>();

    // Récupérer les plats du même jour
    final jourSemaine = commande.plat?.jourSemaine;
    if (jourSemaine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de déterminer le jour de la commande'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
      return;
    }

    // Charger les plats du menu de cette semaine pour ce jour
    final menuId = commande.plat?.idMenu;
    if (menuId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de trouver le menu'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
      return;
    }

    try {
      final plats = await ServiceMenu.obtenirPlatsDuMenu(menuId);
      final platsJour = plats.where((p) => p.jourSemaine == jourSemaine && p.idPlat != commande.idPlat).toList();

      if (!mounted) return;

      if (platsJour.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun autre plat disponible pour ce jour'),
            backgroundColor: CouleursApp.avertissement,
          ),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(TaillesApp.rayonMoyen)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisir un autre plat pour ${commande.jourSemaine}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.bleuFonce,
                ),
              ),
              const SizedBox(height: TaillesApp.espacementMoyen),
              ...platsJour.map((plat) => Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                    child: plat.photoUrl != null
                        ? Image.asset(
                            plat.photoUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: CouleursApp.grisClair,
                                child: const Icon(Icons.restaurant),
                              );
                            },
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: CouleursApp.grisClair,
                            child: const Icon(Icons.restaurant),
                          ),
                  ),
                  title: Text(plat.nomPlat),
                  subtitle: Text(plat.description ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _modifierPlat(commande.idCommande, plat.idPlat, plat.nomPlat);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CouleursApp.bleuPrimaire,
                    ),
                    child: const Text('Choisir'),
                  ),
                ),
              )),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  /// Confirmer l'annulation d'une commande
  void _confirmerAnnulation(Commande commande) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        ),
        title: const Text(
          'Annuler la commande ?',
          style: TextStyle(
            color: CouleursApp.bleuFonce,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Voulez-vous vraiment annuler "${commande.plat?.nomPlat ?? 'ce plat'}" ?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Non',
              style: TextStyle(color: CouleursApp.gris),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _annulerCommande(commande.idCommande);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.erreur,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  /// Modifier le plat d'une commande
  Future<void> _modifierPlat(int idCommande, int nouveauIdPlat, String nomPlat) async {
    final model = context.read<HistoriqueModelVue>();
    final succes = await model.modifierPlat(
      idCommande: idCommande,
      nouveauIdPlat: nouveauIdPlat,
    );

    if (!mounted) return;

    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plat modifié avec succès : $nomPlat'),
          backgroundColor: CouleursApp.succes,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${model.messageErreur ?? "Échec de la modification"}'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  /// Annuler une commande
  Future<void> _annulerCommande(int idCommande) async {
    final model = context.read<HistoriqueModelVue>();
    final succes = await model.annulerCommande(idCommande);

    if (!mounted) return;

    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande annulée avec succès'),
          backgroundColor: CouleursApp.succes,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${model.messageErreur ?? "Échec de l\'annulation"}'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  /// Afficher le dialogue pour modifier le site de livraison
  void _afficherDialogueModifierSite(Commande commande) {
    String siteSelectionne = commande.siteLivraison ?? 'CAMPUS';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          ),
          title: const Text(
            'Modifier le site de livraison',
            style: TextStyle(
              color: CouleursApp.bleuFonce,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Plat: ${commande.plat?.nomPlat ?? "Inconnu"}',
                style: const TextStyle(
                  fontSize: 14,
                  color: CouleursApp.grisFonce,
                ),
              ),
              const SizedBox(height: TaillesApp.espacementMoyen),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: CouleursApp.gris),
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                ),
                child: DropdownButton<String>(
                  value: siteSelectionne,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['CAMPUS', 'DANGA'].map((String site) {
                    return DropdownMenuItem<String>(
                      value: site,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: CouleursApp.orangePrimaire,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(site),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        siteSelectionne = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: CouleursApp.gris),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _modifierSiteCommande(commande.idCommande, siteSelectionne);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.bleuPrimaire,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Afficher le dialogue pour modifier les notes spéciales
  void _afficherDialogueModifierNotes(Commande commande) {
    final controleurNotes = TextEditingController(text: commande.notesSpeciales ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        ),
        title: const Text(
          'Modifier les notes spéciales',
          style: TextStyle(
            color: CouleursApp.bleuFonce,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Plat: ${commande.plat?.nomPlat ?? "Inconnu"}',
              style: const TextStyle(
                fontSize: 14,
                color: CouleursApp.grisFonce,
              ),
            ),
            const SizedBox(height: TaillesApp.espacementMoyen),
            TextField(
              controller: controleurNotes,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Ex: Je veux du piment svp, Sans oignons...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: CouleursApp.gris,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controleurNotes.dispose();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Annuler',
              style: TextStyle(color: CouleursApp.gris),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _modifierNotesCommande(commande.idCommande, controleurNotes.text.trim());
              controleurNotes.dispose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.bleuPrimaire,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  /// Modifier le site de livraison d'une commande
  Future<void> _modifierSiteCommande(int idCommande, String nouveauSite) async {
    final model = context.read<HistoriqueModelVue>();
    final succes = await model.modifierSiteCommande(
      idCommande: idCommande,
      nouveauSite: nouveauSite,
    );

    if (!mounted) return;

    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Site de livraison modifié: $nouveauSite'),
          backgroundColor: CouleursApp.succes,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${model.messageErreur ?? "Échec de la modification"}'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  /// Modifier les notes spéciales d'une commande
  Future<void> _modifierNotesCommande(int idCommande, String nouvelles_notes) async {
    final model = context.read<HistoriqueModelVue>();
    final succes = await model.modifierNotesCommande(
      idCommande: idCommande,
      nouvellesNotes: nouvelles_notes,
    );

    if (!mounted) return;

    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes spéciales modifiées avec succès'),
          backgroundColor: CouleursApp.succes,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${model.messageErreur ?? "Échec de la modification"}'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }
}