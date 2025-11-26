import '../modeles/commande.dart';
import '../modeles/plat.dart';
import 'supabase_service.dart';

/// Service pour gérer les commandes
class ServiceCommande {
  /// Récupérer toutes les commandes d'un utilisateur
  static Future<List<Commande>> obtenirCommandesUtilisateur(int idUser) async {
    try {
      final reponse = await ServiceSupabase.commandes
          .select('*, plats(*)')
          .eq('id_user', idUser)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (reponse as List).map((json) {
        return Commande.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer les commandes d'un utilisateur pour une période
  static Future<List<Commande>> obtenirCommandesParPeriode({
    required int idUser,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    try {
      final reponse = await ServiceSupabase.commandes
          .select('*, plats(*)')
          .eq('id_user', idUser)
          .gte('created_at', dateDebut.toIso8601String())
          .lte('created_at', dateFin.toIso8601String())
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (reponse as List).map((json) {
        return Commande.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer une commande par ID
  static Future<Commande?> obtenirCommandeParId(int idCommande) async {
    try {
      final reponse = await ServiceSupabase.commandes
          .select('*, plats(*)')
          .eq('id_commande', idCommande)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (reponse == null) return null;
      return Commande.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Créer une nouvelle commande
  static Future<Commande> creerCommande({
    required int idUser,
    required int idPlat,
    String? commentaire,
  }) async {
    try {
      final donnees = {
        'id_user': idUser,
        'id_plat': idPlat,
        'statut': 'EN_ATTENTE',
        'created_by': idUser,
      };

      final reponse = await ServiceSupabase.commandes
          .insert(donnees)
          .select('*, plats(*)')
          .single();

      return Commande.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Mettre à jour le statut d'une commande
  static Future<Commande> mettreAJourStatut({
    required int idCommande,
    required String statut,
    required int modifiePar,
  }) async {
    try {
      final donnees = {
        'statut': statut,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': modifiePar,
      };

      final reponse = await ServiceSupabase.commandes
          .update(donnees)
          .eq('id_commande', idCommande)
          .select('*, plats(*)')
          .single();

      return Commande.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Annuler une commande
  static Future<Commande> annulerCommande({
    required int idCommande,
    required int idUser,
  }) async {
    try {
      return await mettreAJourStatut(
        idCommande: idCommande,
        statut: 'ANNULEE',
        modifiePar: idUser,
      );
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Valider une commande (pour les admins)
  static Future<Commande> validerCommande({
    required int idCommande,
    required int idAdmin,
  }) async {
    try {
      return await mettreAJourStatut(
        idCommande: idCommande,
        statut: 'VALIDEE',
        modifiePar: idAdmin,
      );
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Supprimer une commande (soft delete)
  static Future<void> supprimerCommande({
    required int idCommande,
    required int supprimePar,
  }) async {
    try {
      await ServiceSupabase.commandes
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'deleted_by': supprimePar,
          })
          .eq('id_commande', idCommande);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Vérifier si un utilisateur a déjà commandé pour un jour donné
  static Future<bool> aDejaCommandePourJour({
    required int idUser,
    required DateTime jour,
  }) async {
    try {
      final debutJour = DateTime(jour.year, jour.month, jour.day);
      final finJour = debutJour.add(const Duration(days: 1));

      final reponse = await ServiceSupabase.commandes
          .select('id_commande')
          .eq('id_user', idUser)
          .gte('created_at', debutJour.toIso8601String())
          .lt('created_at', finJour.toIso8601String())
          .isFilter('deleted_at', null)
          .maybeSingle();

      return reponse != null;
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer les commandes de la semaine courante pour un utilisateur
  /// Utilise le menu de la semaine courante depuis la BDD
  static Future<List<Commande>> obtenirCommandesSemaineCourante(int idUser) async {
    try {
      // Charger toutes les commandes de l'utilisateur avec les plats
      final toutesCommandes = await obtenirCommandesUtilisateur(idUser);

      // Charger le menu de la semaine courante
      final menuSemaineCourante = await ServiceSupabase.menus
          .select()
          .lte('date_debut', DateTime.now().toIso8601String())
          .gte('date_fin', DateTime.now().toIso8601String())
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (menuSemaineCourante == null) {
        return [];
      }

      final idMenuCourant = menuSemaineCourante['id_menu'];

      // Filtrer les commandes dont le plat appartient au menu courant
      return toutesCommandes.where((commande) {
        return commande.plat != null && commande.plat!.idMenu == idMenuCourant;
      }).toList();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Vérifier si un utilisateur a déjà commandé pour un jour de la semaine spécifique (1-5)
  /// Vérifie parmi les commandes de la semaine courante (hors annulées)
  static Future<bool> aDejaCommandePourJourSemaine({
    required int idUser,
    required int jourSemaine, // 1=Lundi, 2=Mardi, 3=Mercredi, 4=Jeudi, 5=Vendredi
  }) async {
    try {
      // Récupérer toutes les commandes de la semaine courante
      final commandesSemaine = await obtenirCommandesSemaineCourante(idUser);

      // Vérifier si une commande active existe pour ce jour de la semaine
      for (final commande in commandesSemaine) {
        if (commande.statut != StatutCommande.annulee &&
            commande.plat?.jourSemaine == jourSemaine) {
          return true;
        }
      }

      return false;
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Modifier une commande en créant une nouvelle avec un autre plat
  static Future<Commande> modifierCommande({
    required int idCommandeAnnulee,
    required int idUser,
    required int nouveauIdPlat,
  }) async {
    try {
      // 1. Annuler l'ancienne commande
      await annulerCommande(
        idCommande: idCommandeAnnulee,
        idUser: idUser,
      );

      // 2. Créer une nouvelle commande avec le nouveau plat
      return await creerCommande(
        idUser: idUser,
        idPlat: nouveauIdPlat,
      );
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }
}
