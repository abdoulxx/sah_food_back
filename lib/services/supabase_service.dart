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
      return erreur.message;
    } else if (erreur is PostgrestException) {
      return erreur.message;
    } else if (erreur is StorageException) {
      return erreur.message;
    }
    return erreur.toString();
  }
}