import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles_vues/menu_model_vue.dart';
import '../../modeles_vues/navigation_model_vue.dart';
import '../../services/service_interactions.dart';
import '../../widgets/skeleton_loader.dart';

class EcranMenu extends StatefulWidget {
  const EcranMenu({super.key});

  @override
  State<EcranMenu> createState() => _EtatEcranMenu();
}

class _EtatEcranMenu extends State<EcranMenu> {
  final PageController _controleurPage = PageController();
  int? _dernierIndexNavigation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuModel = context.read<MenuModelVue>();
      if (menuModel.menusHebdomadaires.isEmpty) {
        menuModel.initialiser();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Détecter le retour sur cet onglet
    final navigationModel = context.watch<NavigationModelVue>();
    if (navigationModel.indexActuel == 1 && _dernierIndexNavigation != 1) {
      // On vient de revenir sur l'onglet Menu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MenuModelVue>().initialiser();
        }
      });
    }
    _dernierIndexNavigation = navigationModel.indexActuel;
  }

  @override
  void dispose() {
    _controleurPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuModelVue>(
      builder: (context, menuModel, child) {
        return Column(
          children: [
            _construireAppBar(),
            Expanded(
              child: Container(
                color: CouleursApp.grisClair,
                child: menuModel.estEnChargement
                    ? const SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(TaillesApp.espacementMoyen),
                          child: Column(
                            children: [
                              SkeletonPlatCard(),
                              SizedBox(height: TaillesApp.espacementMoyen),
                              SkeletonPlatCard(),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          _construireOnglets(menuModel),
                          Expanded(
                            child: PageView.builder(
                              controller: _controleurPage,
                              onPageChanged: (index) {
                                menuModel.changerOngletJour(index);
                              },
                              itemCount: MenuModelVue.joursSemaine.length,
                              itemBuilder: (context, index) {
                                return _construirePageMenu(menuModel, MenuModelVue.joursSemaine[index]);
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _construireAppBar() {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: CouleursApp.bleuPrimaire,
      ),
      child: const SafeArea(
        child: Center(
          child: Text(
            'Menus de la semaine',
            style: TextStyle(
              color: CouleursApp.blanc,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }


  Widget _construireOnglets(MenuModelVue menuModel) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(TaillesApp.espacementMoyen),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: MenuModelVue.joursSemaine.length,
        itemBuilder: (context, index) {
          final estSelectionne = index == menuModel.ongletSelectionne;
          return GestureDetector(
            onTap: () {
              menuModel.changerOngletJour(index);
              _controleurPage.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: TaillesApp.espacementMin),
              padding: const EdgeInsets.symmetric(
                horizontal: TaillesApp.espacementMoyen,
                vertical: TaillesApp.espacementMin,
              ),
              decoration: BoxDecoration(
                color: estSelectionne ? CouleursApp.orangePrimaire : CouleursApp.blanc,
                borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                boxShadow: [
                  if (estSelectionne)
                    BoxShadow(
                      color: CouleursApp.orangePrimaire.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    MenuModelVue.joursSemaine[index],
                    style: TextStyle(
                      color: estSelectionne ? CouleursApp.blanc : CouleursApp.grisFonce,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: estSelectionne
                          ? CouleursApp.blanc
                          : (menuModel.aCommandePourJour(index + 1)
                              ? CouleursApp.succes
                              : CouleursApp.erreur),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construirePageMenu(MenuModelVue menuModel, String jour) {
    final plats = menuModel.platsJourSelectionne;
    return RefreshIndicator(
      onRefresh: () => menuModel.chargerMenusHebdomadaires(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: TaillesApp.espacementMoyen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Menu du $jour',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CouleursApp.bleuFonce,
            ),
          ),
          const SizedBox(height: TaillesApp.espacementMoyen),

          if (plats.isEmpty)
            const Center(
              child: Text(
                'Aucun plat disponible pour ce jour',
                style: TextStyle(
                  color: CouleursApp.gris,
                  fontSize: 16,
                ),
              ),
            )
          else
            ...plats.asMap().entries.map((entry) {
              final index = entry.key;
              final plat = entry.value;
              return _construirePlatDuJour(
                menuModel,
                plat: plat,
              ).animate().fadeIn(
                duration: 300.ms,
                delay: (index * 100).ms,
              ).slideY(
                begin: 0.2,
                end: 0,
                duration: 300.ms,
                delay: (index * 100).ms,
                curve: Curves.easeOutQuad,
              );
            }).toList(),

          const SizedBox(height: TaillesApp.espacementTresGrand),
        ],
        ),
      ),
    );
  }

  Widget _construirePlatDuJour(
    MenuModelVue menuModel, {
    required plat,
  }) {
    // Vérifier si ce jour a déjà été commandé
    final dejaCommande = plat.jourSemaine != null &&
                         menuModel.aCommandePourJour(plat.jourSemaine!);

    return Container(
      margin: const EdgeInsets.only(bottom: TaillesApp.espacementMoyen),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.gris.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(TaillesApp.rayonMoyen),
                  topRight: Radius.circular(TaillesApp.rayonMoyen),
                ),
                child: plat.photoUrl != null
                    ? Image.asset(
                        plat.photoUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            width: double.infinity,
                            color: CouleursApp.grisClair,
                            child: const Icon(
                              Icons.restaurant,
                              size: 40,
                              color: CouleursApp.gris,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 150,
                        width: double.infinity,
                        color: CouleursApp.grisClair,
                        child: const Icon(
                          Icons.restaurant,
                          size: 40,
                          color: CouleursApp.gris,
                        ),
                      ),
              ),

              // Badge note moyenne avec étoiles
              if (menuModel.platADesAvis(plat.idPlat))
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CouleursApp.orangePrimaire,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: CouleursApp.blanc,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          menuModel.obtenirNoteMoyennePlat(plat.idPlat).toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: CouleursApp.blanc,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plat.nom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.bleuFonce,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  plat.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CouleursApp.grisFonce,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: TaillesApp.espacementMoyen),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (plat.estDisponible && !dejaCommande)
                        ? () => _afficherDialogueCommande(menuModel, plat)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dejaCommande
                          ? CouleursApp.succes
                          : CouleursApp.bleuPrimaire,
                      foregroundColor: CouleursApp.blanc,
                      disabledBackgroundColor: dejaCommande
                          ? CouleursApp.succes.withValues(alpha: 0.6)
                          : CouleursApp.gris.withValues(alpha: 0.3),
                      disabledForegroundColor: CouleursApp.blanc.withValues(alpha: 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (dejaCommande) ...[
                          const Icon(Icons.check_circle, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          dejaCommande
                              ? 'Déjà commandé'
                              : (plat.estDisponible ? 'Commander' : 'Indisponible'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _afficherDialogueCommande(MenuModelVue menuModel, plat) {
    // Variables pour stocker les choix de l'utilisateur
    String siteSelectionne = menuModel.utilisateurConnecte?.site ?? 'CAMPUS';
    final controleurNotes = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          ),
          title: const Text(
            'Confirmer la commande',
            style: TextStyle(
              color: CouleursApp.bleuFonce,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plat sélectionné
                Text(
                  'Vous commandez "${plat.nom}" pour ${menuModel.jourSelectionne.toLowerCase()}',
                  style: const TextStyle(
                    color: CouleursApp.grisFonce,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: TaillesApp.espacementMoyen),
                const Divider(),
                const SizedBox(height: TaillesApp.espacementMoyen),

                // Site de livraison
                const Text(
                  'Site de livraison',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: CouleursApp.bleuFonce,
                  ),
                ),
                const SizedBox(height: TaillesApp.espacementMin),
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
                              color: CouleursApp.bleuPrimaire,
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

                const SizedBox(height: TaillesApp.espacementMoyen),

                // Notes spéciales
                const Text(
                  'Notes spéciales (optionnel)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: CouleursApp.bleuFonce,
                  ),
                ),
                const SizedBox(height: TaillesApp.espacementMin),
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
                await _confirmerCommande(
                  menuModel,
                  plat,
                  siteSelectionne,
                  controleurNotes.text.trim(),
                );
                controleurNotes.dispose();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.bleuFonce,
                foregroundColor: CouleursApp.blanc,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerCommande(
    MenuModelVue menuModel,
    plat,
    String siteLivraison,
    String notesSpeciales,
  ) async {
    final succes = await menuModel.commanderPlat(
      plat,
      siteLivraison: siteLivraison,
      notesSpeciales: notesSpeciales,
    );

    if (succes && mounted) {
      // 🎉 HAPTIC FEEDBACK
      await ServiceInteractions.vibrationSucces();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: CouleursApp.blanc),
              const SizedBox(width: 8),
              Expanded(child: Text('Commande confirmée: ${plat.nom}')),
            ],
          ),
          backgroundColor: CouleursApp.succes,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (!succes && mounted) {
      // ❌ HAPTIC FEEDBACK D'ERREUR
      await ServiceInteractions.vibrationErreur();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: CouleursApp.blanc),
              const SizedBox(width: 8),
              Expanded(child: Text('Erreur lors de la commande: ${menuModel.messageErreur}')),
            ],
          ),
          backgroundColor: CouleursApp.erreur,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          ),
        ),
      );
    }
  }
}