-- ============================================================
-- CRÉATION DU BUCKET STORAGE POUR LES AVATARS
-- ============================================================
-- Ce script crée le bucket Supabase Storage pour stocker
-- les photos de profil des utilisateurs
-- ============================================================

-- ÉTAPE 1 : Créer le bucket 'avatars' (à exécuter dans Supabase Dashboard)
-- Aller dans Storage > Créer un nouveau bucket
-- Nom : avatars
-- Public : Oui (coché)
-- File size limit : 5 MB

-- OU via SQL (si vous avez les permissions) :
-- insert into storage.buckets (id, name, public)
-- values ('avatars', 'avatars', true);

-- ============================================================
-- ÉTAPE 2 : Configurer les politiques RLS pour le bucket
-- ============================================================

-- Politique 1 : Tout le monde peut LIRE les avatars (public)
CREATE POLICY "Les avatars sont publics en lecture"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Politique 2 : Les utilisateurs authentifiés peuvent UPLOADER leur propre avatar
CREATE POLICY "Les utilisateurs peuvent uploader leur avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = 'avatar_' || auth.uid()::text
);

-- Politique 3 : Les utilisateurs peuvent METTRE À JOUR leur propre avatar
CREATE POLICY "Les utilisateurs peuvent mettre à jour leur avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = 'avatar_' || auth.uid()::text
);

-- Politique 4 : Les utilisateurs peuvent SUPPRIMER leur propre avatar
CREATE POLICY "Les utilisateurs peuvent supprimer leur avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = 'avatar_' || auth.uid()::text
);

-- ============================================================
-- INSTRUCTIONS MANUELLES POUR CRÉER LE BUCKET
-- ============================================================
-- Si le bucket n'existe pas encore, suivez ces étapes :
--
-- 1. Allez dans Supabase Dashboard
-- 2. Cliquez sur "Storage" dans le menu de gauche
-- 3. Cliquez sur "New bucket"
-- 4. Nom du bucket : avatars
-- 5. Cochez "Public bucket" (pour permettre la lecture publique)
-- 6. File size limit : 5242880 (5 MB)
-- 7. Allowed MIME types : image/jpeg, image/png, image/webp
-- 8. Cliquez sur "Create bucket"
--
-- Ensuite, exécutez les politiques RLS ci-dessus dans le SQL Editor
-- ============================================================

-- ============================================================
-- VÉRIFICATIONS
-- ============================================================

-- Vérifier que le bucket existe
-- SELECT * FROM storage.buckets WHERE name = 'avatars';

-- Vérifier les politiques RLS
-- SELECT * FROM pg_policies WHERE tablename = 'objects' AND policyname LIKE '%avatar%';

-- ============================================================
-- FIN DU SCRIPT
-- ============================================================
