import 'package:supabase_flutter/supabase_flutter.dart';
import '../modeles/utilisateur.dart';
import 'supabase_service.dart';
import 'service_stockage_local.dart';
import 'service_utilisateur.dart';
import 'service_notifications.dart';

/// Service d'authentification avec Supabase
class ServiceAuthentification {
  /// Inscription d'un nouvel utilisateur
  static Future<Map<String, dynamic>> inscrire({
    required String email,
    required String motDePasse,
    required String qid,
    required String prenom,
    required String nom,
    required String role,
    required String site,
    String? departement,
  }) async {
    try {
      // 1. Créer l'utilisateur dans Supabase Auth avec confirmation email
      final AuthResponse reponseAuth = await ServiceSupabase.auth.signUp(
        email: email,
        password: motDePasse,
      );

      if (reponseAuth.user == null) {
        throw Exception('Erreur lors de la création du compte');
      }

      // 2. Attendre un peu pour que la session soit stable
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Créer l'entrée dans la table utilisateurs
      final Map<String, dynamic> donneesUtilisateur = {
        'qid': qid,
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'role': role,
        'site': site,
        'departement': departement,
      };

      Map<String, dynamic>? reponse;
      Utilisateur? utilisateur;

      try {
        reponse = await ServiceSupabase.utilisateurs
            .insert(donneesUtilisateur)
            .select()
            .single();
        utilisateur = Utilisateur.fromJson(reponse);
      } catch (insertError) {
        // Si l'insertion échoue, nettoyer l'utilisateur Auth créé
        print('Erreur insertion utilisateur: $insertError');
        // On ne peut pas supprimer l'utilisateur, mais on signale l'erreur
      }

      // 4. Déconnecter pour forcer la vérification email
      try {
        await ServiceSupabase.auth.signOut();
      } catch (signOutError) {
        // Ignorer les erreurs de déconnexion
        print('Erreur déconnexion: $signOutError');
      }

      // 5. Retourner les informations
      return {
        'utilisateur': utilisateur,
        'emailConfirme': false,
        'message': 'Un email de confirmation a été envoyé à $email. Veuillez vérifier votre boîte mail.',
      };
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Connexion d'un utilisateur
  static Future<Utilisateur?> seConnecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      // 1. Connexion via Supabase Auth
      final AuthResponse reponse = await ServiceSupabase.auth.signInWithPassword(
        email: email,
        password: motDePasse,
      );

      if (reponse.user == null) {
        throw Exception('Email ou mot de passe incorrect');
      }

      // 2. Vérifier que l'email a été confirmé
      if (reponse.user!.emailConfirmedAt == null) {
        // Déconnecter l'utilisateur
        await ServiceSupabase.auth.signOut();
        throw Exception('Veuillez confirmer votre email avant de vous connecter. Vérifiez votre boîte mail.');
      }

      // 3. Récupérer les infos utilisateur depuis la table
      final utilisateurData = await ServiceSupabase.utilisateurs
          .select()
          .eq('email', email)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (utilisateurData == null) {
        throw Exception('Utilisateur non trouvé dans la base de données');
      }

      final utilisateur = Utilisateur.fromJson(utilisateurData);

      // 4. Sauvegarder l'utilisateur localement pour la persistance
      await ServiceStockageLocal.sauvegarderUtilisateur(utilisateur);

      // 5. Sauvegarder le token FCM pour les notifications
      final tokenFCM = await ServiceNotifications.obtenirTokenFCM();
      if (tokenFCM != null) {
        await ServiceUtilisateur.sauvegarderTokenFCM(
          idUser: utilisateur.idUser,
          tokenFCM: tokenFCM,
        );
      }

      return utilisateur;
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  //Déconnexion
  static Future<void> seDeconnecter() async {
    try {
      // 1. Déconnexion Supabase
      await ServiceSupabase.auth.signOut();

      // 2. Effacer les données locales
      await ServiceStockageLocal.effacerSession();
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Récupérer l'utilisateur actuellement connecté
  static Future<Utilisateur?> obtenirUtilisateurConnecte({bool forcerRechargement = false}) async {
    try {
      // 1. Si on ne force pas le rechargement, essayer le cache d'abord
      if (!forcerRechargement) {
        final utilisateurLocal = await ServiceStockageLocal.recupererUtilisateur();
        if (utilisateurLocal != null) {
          return utilisateurLocal;
        }
      }

      // 2. Récupérer depuis Supabase
      final User? utilisateur = ServiceSupabase.auth.currentUser;
      if (utilisateur == null) return null;

      final utilisateurData = await ServiceSupabase.utilisateurs
          .select()
          .eq('email', utilisateur.email!)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (utilisateurData == null) return null;

      final utilisateurFromDB = Utilisateur.fromJson(utilisateurData);

      // 3. Mettre à jour le cache local
      await ServiceStockageLocal.sauvegarderUtilisateur(utilisateurFromDB);

      return utilisateurFromDB;
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si un utilisateur est connecté
  static bool estConnecte() {
    return ServiceSupabase.auth.currentUser != null;
  }

  /// Réinitialiser le mot de passe
  static Future<void> reinitialiserMotDePasse(String email) async {
    try {
      await ServiceSupabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  // Mettre à jour le profil utilisateur
  static Future<Utilisateur?> mettreAJourProfil({
    required int idUser,
    String? prenom,
    String? nom,
    String? departement,
    String? site,
  }) async {
    try {
      final Map<String, dynamic> donnees = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (prenom != null) donnees['prenom'] = prenom;
      if (nom != null) donnees['nom'] = nom;
      if (departement != null) donnees['departement'] = departement;
      if (site != null) donnees['site'] = site;

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

  /// Changer le mot de passe
  static Future<void> changerMotDePasse({
    required String nouveauMotDePasse,
  }) async {
    try {
      await ServiceSupabase.auth.updateUser(
        UserAttributes(password: nouveauMotDePasse),
      );
    } catch (e) {
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }
}