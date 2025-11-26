import '../modeles/menu.dart';
import '../modeles/plat.dart';
import 'supabase_service.dart';

/// Service pour gérer les menus et plats
class ServiceMenu {
  /// Récupérer tous les menus actifs
  static Future<List<Menu>> obtenirMenus() async {
    try {
      final reponse = await ServiceSupabase.menus
          .select()
          .isFilter('deleted_at', null)
          .order('date_debut', ascending: false);

      return (reponse as List)
          .map((json) => Menu.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer le menu de la semaine courante
  static Future<Menu?> obtenirMenuSemaineCourante() async {
    try {
      final maintenant = DateTime.now();
      final reponse = await ServiceSupabase.menus
          .select()
          .lte('date_debut', maintenant.toIso8601String())
          .gte('date_fin', maintenant.toIso8601String())
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (reponse == null) return null;
      return Menu.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer les menus du mois courant
  /// Inclut les semaines qui chevauchent le mois (début OU fin dans le mois)
  static Future<List<Menu>> obtenirMenusDuMoisCourant() async {
    try {
      final maintenant = DateTime.now();

      // Charger les semaines dont la date_fin >= aujourd'hui (semaines en cours ou futures)
      // Limité à 4 semaines maximum
      final reponse = await ServiceSupabase.menus
          .select()
          .gte('date_fin', maintenant.toIso8601String())
          .isFilter('deleted_at', null)
          .order('date_debut', ascending: true)
          .limit(4);

      return (reponse as List)
          .map((json) => Menu.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer un menu par ID
  static Future<Menu?> obtenirMenuParId(int idMenu) async {
    try {
      final reponse = await ServiceSupabase.menus
          .select()
          .eq('id_menu', idMenu)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (reponse == null) return null;
      return Menu.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Créer un nouveau menu
  static Future<Menu> creerMenu({
    required int semaine,
    required DateTime dateDebut,
    required DateTime dateFin,
    required int creePar,
  }) async {
    try {
      final donnees = {
        'semaine': semaine,
        'date_debut': dateDebut.toIso8601String(),
        'date_fin': dateFin.toIso8601String(),
        'created_by': creePar,
      };

      final reponse = await ServiceSupabase.menus
          .insert(donnees)
          .select()
          .single();

      return Menu.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer tous les plats d'un menu
  static Future<List<Plat>> obtenirPlatsDuMenu(int idMenu) async {
    try {
      final reponse = await ServiceSupabase.plats
          .select()
          .eq('id_menu', idMenu)
          .isFilter('deleted_at', null)
          .order('nom_plat');

      return (reponse as List)
          .map((json) => Plat.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer un plat par ID
  static Future<Plat?> obtenirPlatParId(int idPlat) async {
    try {
      final reponse = await ServiceSupabase.plats
          .select()
          .eq('id_plat', idPlat)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (reponse == null) return null;
      return Plat.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Créer un nouveau plat
  static Future<Plat> creerPlat({
    required int idMenu,
    required String nomPlat,
    String? description,
    String? allergenes,
    String? photoUrl,
    required int creePar,
  }) async {
    try {
      final donnees = {
        'id_menu': idMenu,
        'nom_plat': nomPlat,
        'description': description,
        'allergenes': allergenes,
        'photo_url': photoUrl,
        'created_by': creePar,
      };

      final reponse = await ServiceSupabase.plats
          .insert(donnees)
          .select()
          .single();

      return Plat.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Mettre à jour un plat
  static Future<Plat> mettreAJourPlat({
    required int idPlat,
    String? nomPlat,
    String? description,
    String? allergenes,
    String? photoUrl,
    required int modifiePar,
  }) async {
    try {
      final donnees = {
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': modifiePar,
      };

      if (nomPlat != null) donnees['nom_plat'] = nomPlat;
      if (description != null) donnees['description'] = description;
      if (allergenes != null) donnees['allergenes'] = allergenes;
      if (photoUrl != null) donnees['photo_url'] = photoUrl;

      final reponse = await ServiceSupabase.plats
          .update(donnees)
          .eq('id_plat', idPlat)
          .select()
          .single();

      return Plat.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Supprimer un plat
  static Future<void> supprimerPlat({
    required int idPlat,
    required int supprimePar,
  }) async {
    try {
      await ServiceSupabase.plats
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'deleted_by': supprimePar,
          })
          .eq('id_plat', idPlat);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }
}
