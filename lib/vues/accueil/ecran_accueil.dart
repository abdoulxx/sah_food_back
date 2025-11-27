import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constantes/couleurs_app.dart';
import '../../core/constantes/tailles_app.dart';
import '../../modeles_vues/accueil_model_vue.dart';
import '../../modeles_vues/authentification_model_vue.dart';
import '../../modeles_vues/navigation_model_vue.dart';
import '../../services/service_historique_notifications.dart';
import '../notifications/ecran_historique_notifications.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  int _nombreNotificationsNonLues = 0;
  StreamSubscription<int>? _notificationSubscription;
  int? _dernierIndexNavigation;

  @override
  void initState() {
    super.initState();

    // Écouter les changements de notifications en temps réel
    _notificationSubscription = ServiceHistoriqueNotifications.onNotificationChange.listen((nombre) {
      if (mounted) {
        setState(() {
          _nombreNotificationsNonLues = nombre;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _chargerDonnees();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Détecter le retour sur cet onglet
    final navigationModel = context.watch<NavigationModelVue>();
    if (navigationModel.indexActuel == 0 && _dernierIndexNavigation != 0) {
      // On vient de revenir sur l'onglet Accueil
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AccueilModelVue>().chargerCommandesSemaine();
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

    // Charger les commandes une fois que l'utilisateur est prêt
    if (mounted) {
      final accueilModel = context.read<AccueilModelVue>();
      accueilModel.chargerCommandesSemaine();
      _chargerNombreNotifications();
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _chargerNombreNotifications() async {
    final nombre = await ServiceHistoriqueNotifications.obtenirNombreNonLues();
    if (mounted) {
      setState(() {
        _nombreNotificationsNonLues = nombre;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccueilModelVue>(
      builder: (context, accueilModel, child) {
        return Column(
          children: [
            _construireAppBar(),
            Expanded(
              child: Container(
                color: CouleursApp.grisClair,
                child: accueilModel.estEnChargement
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => accueilModel.chargerCommandesSemaine(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              _construireHeaderUtilisateur(accueilModel),
                              _construireResumeSemaine(accueilModel),
                              _construireResumeHebdomadaire(accueilModel),
                            ],
                          ),
                        ),
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 48),
              const Expanded(
                child: Text(
                  'SAH FOOD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CouleursApp.blanc,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: CouleursApp.blanc,
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EcranHistoriqueNotifications(),
                        ),
                      );
                      _chargerNombreNotifications();
                    },
                  ),
                  if (_nombreNotificationsNonLues > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: CouleursApp.erreur,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _nombreNotificationsNonLues > 9
                              ? '9+'
                              : _nombreNotificationsNonLues.toString(),
                          style: const TextStyle(
                            color: CouleursApp.blanc,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireHeaderUtilisateur(AccueilModelVue accueilModel) {
    final utilisateur = accueilModel.utilisateurActuel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
      decoration: const BoxDecoration(
        color: CouleursApp.bleuPrimaire,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(TaillesApp.rayonGrand),
          bottomRight: Radius.circular(TaillesApp.rayonGrand),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour ${utilisateur?.prenom ?? 'Utilisateur'} !',
            style: const TextStyle(
              color: CouleursApp.blanc,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${utilisateur?.site ?? 'Site'} • Département ${utilisateur?.departement ?? 'N/A'}',
            style: const TextStyle(
              color: CouleursApp.orangeClair,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireResumeSemaine(AccueilModelVue accueilModel) {
    final int commandesPassees = accueilModel.nombreCommandesPassees;
    final int totalCommandes = accueilModel.nombreJoursTotal;
    final double progression = accueilModel.progressionSemaine;

    return Container(
      margin: const EdgeInsets.all(TaillesApp.espacementMoyen),
      padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
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
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: CouleursApp.bleuPrimaire,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _obtenirTexteSemaineCourante(),
                style: const TextStyle(
                  color: CouleursApp.bleuFonce,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: TaillesApp.espacementMoyen),
          Row(
            children: [
              const Text(
                'Progression des commandes',
                style: TextStyle(
                  color: CouleursApp.grisFonce,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$commandesPassees/$totalCommandes',
                style: const TextStyle(
                  color: CouleursApp.orangePrimaire,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: TaillesApp.espacementMin),

          Container(
            height: 8,
            decoration: BoxDecoration(
              color: CouleursApp.grisClair,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progression,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CouleursApp.orangePrimaire, CouleursApp.orangeClair],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: TaillesApp.espacementMin),
          if (accueilModel.toutesComandesPassees)
            const Text(
              '🎉 Félicitations ! Toutes vos commandes sont passées',
              style: TextStyle(
                color: CouleursApp.succes,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _construireResumeHebdomadaire(AccueilModelVue accueilModel) {
    return Container(
      margin: const EdgeInsets.all(TaillesApp.espacementMoyen),
      padding: const EdgeInsets.all(TaillesApp.espacementMoyen),
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
          // Titre
          const Row(
            children: [
              Icon(
                Icons.calendar_view_day,
                color: CouleursApp.bleuPrimaire,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Ma semaine',
                style: TextStyle(
                  color: CouleursApp.bleuFonce,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: TaillesApp.espacementMoyen),

          ...accueilModel.commandesParJour.entries.map((entry) {
            final jour = entry.key;
            final commande = entry.value;
            return _construireLigneJour(jour, commande?.plat?.nomPlat);
          }).toList(),

          const SizedBox(height: TaillesApp.espacementMoyen),

          SizedBox(
            width: double.infinity,
            child: Builder(
              builder: (context) {
                // Déterminer la couleur selon l'état
                Color couleurBouton;
                if (accueilModel.nombreCommandesPassees == 0) {
                  couleurBouton = CouleursApp.orangePrimaire;
                } else if (accueilModel.toutesComandesPassees) {
                  couleurBouton = CouleursApp.succes;
                } else {
                  couleurBouton = CouleursApp.bleuPrimaire;
                }

                // Déterminer l'icône selon l'état
                IconData icone;
                if (accueilModel.nombreCommandesPassees == 0) {
                  icone = Icons.play_arrow;
                } else if (accueilModel.toutesComandesPassees) {
                  icone = Icons.check_circle;
                } else {
                  icone = Icons.restaurant_menu;
                }


                return ElevatedButton(
                  onPressed: accueilModel.toutesComandesPassees
                      ? null
                      : () => _naviguerVersMenu(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: couleurBouton,
                    foregroundColor: CouleursApp.blanc,
                    disabledBackgroundColor: CouleursApp.succes.withValues(alpha: 0.7),
                    disabledForegroundColor: CouleursApp.blanc,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icone),
                      const SizedBox(width: 8),
                      Text(
                        accueilModel.texteBoutonCommande,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireLigneJour(String jour, String? plat) {
    final estCommande = plat != null;

    return Container(
      margin: const EdgeInsets.only(bottom: TaillesApp.espacementMin),
      padding: const EdgeInsets.symmetric(
        horizontal: TaillesApp.espacementMoyen,
        vertical: TaillesApp.espacementMin,
      ),
      decoration: BoxDecoration(
        color: estCommande
            ? CouleursApp.succes.withValues(alpha: 0.1)
            : CouleursApp.grisClair,
        borderRadius: BorderRadius.circular(TaillesApp.rayonMin),
        border: Border.all(
          color: estCommande ? CouleursApp.succes : CouleursApp.gris,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: estCommande ? CouleursApp.succes : CouleursApp.gris,
              shape: BoxShape.circle,
            ),
            child: Icon(
              estCommande ? Icons.check : Icons.add,
              color: CouleursApp.blanc,
              size: 16,
            ),
          ),

          const SizedBox(width: TaillesApp.espacementMin),

          SizedBox(
            width: 80,
            child: Text(
              jour,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: estCommande ? CouleursApp.succes : CouleursApp.grisFonce,
              ),
            ),
          ),

          const SizedBox(width: TaillesApp.espacementMoyen),

          Expanded(
            child: Text(
              plat ?? 'Pas encore commandé',
              style: TextStyle(
                fontSize: 14,
                color: estCommande ? CouleursApp.bleuFonce : CouleursApp.gris,
                fontStyle: estCommande ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _naviguerVersMenu(BuildContext context) {
    final navigationModel = context.read<NavigationModelVue>();
    navigationModel.naviguerVersMenu();
  }

  String _obtenirTexteSemaineCourante() {
    final maintenant = DateTime.now();

    // Calculer le lundi de la semaine courante
    final lundi = maintenant.subtract(Duration(days: maintenant.weekday - 1));

    // Calculer le dimanche (6 jours après le lundi)
    final dimanche = lundi.add(const Duration(days: 6));

    // Formatter les dates
    const mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];

    final jourDebut = lundi.day;
    final jourFin = dimanche.day;
    final nomMois = mois[lundi.month - 1];
    final annee = lundi.year;

    return 'Semaine du $jourDebut - $jourFin $nomMois $annee';
  }
}