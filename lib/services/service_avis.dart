import '../modeles/avis.dart';
import 'supabase_service.dart';

/// Service pour gérer les avis
class ServiceAvis {
  /// Récupérer tous les avis d'un utilisateur
  static Future<List<Avis>> obtenirAvisUtilisateur(int idUser) async {
    try {
      final reponse = await ServiceSupabase.avis
          .select()
          .eq('id_user', idUser)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (reponse as List)
          .map((json) => Avis.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer tous les avis d'un plat
  static Future<List<Avis>> obtenirAvisPlat(int idPlat) async {
    try {
      final reponse = await ServiceSupabase.avis
          .select()
          .eq('id_plat', idPlat)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (reponse as List)
          .map((json) => Avis.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer un avis par ID
  static Future<Avis?> obtenirAvisParId(int idAvis) async {
    try {
      final reponse = await ServiceSupabase.avis
          .select()
          .eq('id_avis', idAvis)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (reponse == null) return null;
      return Avis.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Vérifier si un avis existe pour un plat et un utilisateur
  static Future<Avis?> obtenirAvisUtilisateurPourPlat({
    required int idUser,
    required int idPlat,
  }) async {
    try {
      final reponse = await ServiceSupabase.avis
          .select()
          .eq('id_user', idUser)
          .eq('id_plat', idPlat)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (reponse == null) return null;
      return Avis.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Créer un nouvel avis
  static Future<Avis> creerAvis({
    required int idUser,
    required int idPlat,
    int? note,
    String? commentaire,
  }) async {
    try {
      final donnees = {
        'id_user': idUser,
        'id_plat': idPlat,
        'note': note,
        'commentaire': commentaire,
        'created_by': idUser,
      };

      final reponse = await ServiceSupabase.avis
          .insert(donnees)
          .select()
          .single();

      return Avis.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Mettre à jour un avis
  static Future<Avis> mettreAJourAvis({
    required int idAvis,
    int? note,
    String? commentaire,
    required int modifiePar,
  }) async {
    try {
      final donnees = {
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': modifiePar,
      };

      if (note != null) donnees['note'] = note;
      if (commentaire != null) donnees['commentaire'] = commentaire;

      final reponse = await ServiceSupabase.avis
          .update(donnees)
          .eq('id_avis', idAvis)
          .select()
          .single();

      return Avis.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Supprimer un avis (soft delete)
  static Future<void> supprimerAvis({
    required int idAvis,
    required int supprimePar,
  }) async {
    try {
      await ServiceSupabase.avis
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'deleted_by': supprimePar,
          })
          .eq('id_avis', idAvis);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Calculer la note moyenne d'un plat
  static Future<double> obtenirNoteMoyennePlat(int idPlat) async {
    try {
      final avisPlat = await obtenirAvisPlat(idPlat);

      if (avisPlat.isEmpty) return 0.0;

      final avisAvecNote = avisPlat.where((a) => a.note != null).toList();

      if (avisAvecNote.isEmpty) return 0.0;

      final sommeNotes = avisAvecNote.fold<int>(
        0,
        (sum, avis) => sum + (avis.note ?? 0),
      );

      return sommeNotes / avisAvecNote.length;
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Créer ou mettre à jour un avis
  static Future<Avis> creerOuMettreAJourAvis({
    required int idUser,
    required int idPlat,
    int? note,
    String? commentaire,
  }) async {
    try {
      // Vérifier si un avis existe déjà
      final avisExistant = await obtenirAvisUtilisateurPourPlat(
        idUser: idUser,
        idPlat: idPlat,
      );

      if (avisExistant != null) {
        // Mettre à jour l'avis existant
        return await mettreAJourAvis(
          idAvis: avisExistant.idAvis,
          note: note,
          commentaire: commentaire,
          modifiePar: idUser,
        );
      } else {
        // Créer un nouvel avis
        return await creerAvis(
          idUser: idUser,
          idPlat: idPlat,
          note: note,
          commentaire: commentaire,
        );
      }
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }
}
