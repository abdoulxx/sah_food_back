-- ============================================================
-- CORRECTION DES POLITIQUES RLS POUR LE BUCKET AVATAR
-- ============================================================
-- Ce script supprime les anciennes politiques et en crée de nouvelles
-- adaptées au système avec id_user numérique
-- ============================================================

-- ÉTAPE 1 : Supprimer les anciennes politiques
DROP POLICY IF EXISTS "Les avatars sont publics en lecture" ON storage.objects;
DROP POLICY IF EXISTS "Les utilisateurs peuvent uploader leur avatar" ON storage.objects;
DROP POLICY IF EXISTS "Les utilisateurs peuvent mettre à jour leur avatar" ON storage.objects;
DROP POLICY IF EXISTS "Les utilisateurs peuvent supprimer leur avatar" ON storage.objects;

-- ============================================================
-- ÉTAPE 2 : Créer les nouvelles politiques simplifiées
-- ============================================================

-- Politique 1 : Tout le monde peut LIRE les avatars (public)
CREATE POLICY "Public peut lire les avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatar');

-- Politique 2 : Les utilisateurs authentifiés peuvent UPLOADER des avatars
CREATE POLICY "Authentifiés peuvent uploader des avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatar');

-- Politique 3 : Les utilisateurs authentifiés peuvent METTRE À JOUR des avatars
CREATE POLICY "Authentifiés peuvent mettre à jour des avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'avatar');

-- Politique 4 : Les utilisateurs authentifiés peuvent SUPPRIMER des avatars
CREATE POLICY "Authentifiés peuvent supprimer des avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'avatar');

-- ============================================================
-- VÉRIFICATIONS
-- ============================================================

-- Vérifier que le bucket existe
SELECT * FROM storage.buckets WHERE name = 'avatar';

-- Vérifier les nouvelles politiques
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'objects'
AND policyname LIKE '%avatar%';

-- ============================================================
-- FIN DU SCRIPT
-- ============================================================
