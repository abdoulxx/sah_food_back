import '../modeles/utilisateur.dart';
import 'supabase_service.dart';

/// Service pour gérer les utilisateurs
class ServiceUtilisateur {
  /// Mettre à jour le profil d'un utilisateur
  static Future<Utilisateur> mettreAJourProfil({
    required int idUser,
    String? prenom,
    String? nom,
    String? departement,
    String? site,
    String? photo,
  }) async {
    try {
      final donnees = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': idUser,
      };

      if (prenom != null) donnees['prenom'] = prenom;
      if (nom != null) donnees['nom'] = nom;
      if (departement != null) donnees['departement'] = departement;
      if (site != null) donnees['site'] = site;
      if (photo != null) donnees['photo'] = photo;

      final reponse = await ServiceSupabase.utilisateurs
          .update(donnees)
          .eq('id_user', idUser)
          .select()
          .single();

      return Utilisateur.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Mettre à jour uniquement la photo de profil
  static Future<Utilisateur> mettreAJourPhoto({
    required int idUser,
    required String photoUrl,
  }) async {
    try {
      final reponse = await ServiceSupabase.utilisateurs
          .update({
            'photo': photoUrl,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': idUser,
          })
          .eq('id_user', idUser)
          .select()
          .single();

      return Utilisateur.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Obtenir un utilisateur par ID
  static Future<Utilisateur?> obtenirUtilisateurParId(int idUser) async {
    try {
      final reponse = await ServiceSupabase.utilisateurs
          .select()
          .eq('id_user', idUser)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (reponse == null) return null;
      return Utilisateur.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Obtenir un utilisateur par email
  static Future<Utilisateur?> obtenirUtilisateurParEmail(String email) async {
    try {
      final reponse = await ServiceSupabase.utilisateurs
          .select()
          .eq('email', email)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (reponse == null) return null;
      return Utilisateur.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Sauvegarder le token FCM de l'utilisateur
  static Future<void> sauvegarderTokenFCM({
    required int idUser,
    required String tokenFCM,
  }) async {
    try {
      await ServiceSupabase.utilisateurs
          .update({
            'fcm_token': tokenFCM,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': idUser,
          })
          .eq('id_user', idUser);

      print('💾 Token FCM sauvegardé pour user $idUser');
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Supprimer le token FCM de l'utilisateur
  static Future<void> supprimerTokenFCM(int idUser) async {
    try {
      await ServiceSupabase.utilisateurs
          .update({
            'fcm_token': null,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': idUser,
          })
          .eq('id_user', idUser);

      print('🔕 Token FCM supprimé pour user $idUser');
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Supprimer le compte de l'utilisateur (soft delete)
  static Future<Utilisateur> supprimerCompte(int idUser) async {
    try {
      final reponse = await ServiceSupabase.utilisateurs
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'deleted_by': idUser,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': idUser,
          })
          .eq('id_user', idUser)
          .select()
          .single();

      print('🗑️ Compte supprimé (soft delete) pour user $idUser');
      return Utilisateur.fromJson(reponse);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }
}
