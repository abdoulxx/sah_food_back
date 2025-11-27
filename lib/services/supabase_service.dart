import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

/// Service de base pour accéder à Supabase
class ServiceSupabase {
  // Instance Supabase
  static SupabaseClient get client => Supabase.instance.client;

  // Auth
  static GoTrueClient get auth => client.auth;

  // Storage
  static SupabaseStorageClient get stockage => client.storage;

  // Tables
  static SupabaseQueryBuilder get utilisateurs => client.from(SupabaseConfig.tableUsers);
  static SupabaseQueryBuilder get menus => client.from(SupabaseConfig.tableMenus);
  static SupabaseQueryBuilder get plats => client.from(SupabaseConfig.tablePlats);
  static SupabaseQueryBuilder get commandes => client.from(SupabaseConfig.tableCommandes);
  static SupabaseQueryBuilder get avis => client.from(SupabaseConfig.tableAvis);

  // Helper pour gérer les erreurs
  static String gererErreur(dynamic erreur) {
    if (erreur is AuthException) {
      // Traduire les messages d'erreur courants en français
      final message = erreur.message.toLowerCase();

      if (message.contains('email not confirmed')) {
        return 'Veuillez confirmer votre email avant de vous connecter. Vérifiez votre boîte mail.';
      }
      if (message.contains('invalid login credentials')) {
        return 'Email ou mot de passe incorrect';
      }
      if (message.contains('user already registered')) {
        return 'Un compte existe déjà avec cet email';
      }
      if (message.contains('email rate limit exceeded')) {
        return 'Trop de tentatives. Veuillez réessayer dans quelques minutes.';
      }

      return erreur.message;
    } else if (erreur is PostgrestException) {
      return erreur.message;
    } else if (erreur is StorageException) {
      return erreur.message;
    }
    return erreur.toString();
  }
}