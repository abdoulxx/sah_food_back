import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service pour gérer l'upload de fichiers vers Supabase Storage
class ServiceUpload {
  static const String bucketAvatars = 'avatar';

  /// Uploader une photo de profil
  /// Retourne l'URL publique de la photo uploadée
  static Future<String> uploaderPhotoProfil({
    required File fichierImage,
    required int idUser,
  }) async {
    try {
      // Debug: Lister tous les buckets disponibles
      final buckets = await ServiceSupabase.stockage.listBuckets();
      print('📦 Buckets disponibles: ${buckets.map((b) => b.name).toList()}');

      final extension = fichierImage.path.split('.').last.toLowerCase();
      final nomFichier = 'avatar_$idUser.$extension';

      // Upload vers Supabase Storage
      await ServiceSupabase.stockage
          .from(bucketAvatars)
          .upload(
            nomFichier,
            fichierImage,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Écrase si le fichier existe déjà
            ),
          );

      // Obtenir l'URL publique
      final urlPublique = ServiceSupabase.stockage
          .from(bucketAvatars)
          .getPublicUrl(nomFichier);

      return urlPublique;
    } catch (e) {
      print('❌ Erreur upload: $e');
      throw Exception(ServiceSupabase.gererErreur(e));
    }
  }

  /// Supprimer une photo de profil
  static Future<void> supprimerPhotoProfil({
    required int idUser,
  }) async {
    try {
      // Chercher tous les fichiers qui commencent par avatar_idUser
      final searchQuery = 'avatar_$idUser';
      final List<FileObject> fichiers = await ServiceSupabase.stockage
          .from(bucketAvatars)
          .list(path: '', searchOptions: SearchOptions(
            search: searchQuery,
          ));

      // Supprimer tous les fichiers trouvés
      if (fichiers.isNotEmpty) {
        final List<String> nomsASupprimer = fichiers
            .map((f) => f.name)
            .where((name) => name.startsWith('avatar_$idUser'))
            .toList();

        if (nomsASupprimer.isNotEmpty) {
          await ServiceSupabase.stockage
              .from(bucketAvatars)
              .remove(nomsASupprimer);
        }
      }
    } catch (e) {
      // Ignorer les erreurs de suppression (le fichier n'existe peut-être pas)
      print('Erreur lors de la suppression de la photo: $e');
    }
  }

  /// Vérifier si le bucket avatars existe, sinon le créer
  static Future<void> initialiserBucketAvatars() async {
    try {
      // Tenter de lister les buckets
      final buckets = await ServiceSupabase.stockage.listBuckets();

      // Vérifier si le bucket avatars existe
      final bucketExiste = buckets.any((b) => b.name == bucketAvatars);

      if (!bucketExiste) {
        // Créer le bucket s'il n'existe pas
        await ServiceSupabase.stockage.createBucket(
          bucketAvatars,
          BucketOptions(
            public: true, // Rendre le bucket public pour les avatars
            fileSizeLimit: (5 * 1024 * 1024).toString(), // Limite de 5 MB
          ),
        );
        print('✅ Bucket "avatar" créé avec succès');
      } else {
        print('✅ Bucket "avatar" existe déjà');
      }
    } catch (e) {
      print('⚠️ Erreur lors de l\'initialisation du bucket: $e');
      // Ne pas throw, le bucket existe peut-être déjà
    }
  }
}
