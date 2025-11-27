-- ============================================================
-- AJOUT DE NOUVEAUX CHAMPS
-- ============================================================
-- Ce script ajoute 3 nouveaux champs :
-- 1. site_livraison dans la table commandes (DANGA ou CAMPUS)
-- 2. notes_speciales dans la table commandes (notes du collaborateur)
-- 3. photo dans la table utilisateurs (URL de la photo de profil)
-- ============================================================


-- ============================================================
-- ÉTAPE 1 : Ajouter site_livraison à la table commandes
-- ============================================================
-- Permet au collaborateur de choisir où il veut être livré
-- Valeurs possibles : 'DANGA' ou 'CAMPUS'

ALTER TABLE "public"."commandes"
ADD COLUMN IF NOT EXISTS "site_livraison" VARCHAR(10);

-- Ajouter une contrainte pour n'accepter que DANGA ou CAMPUS
ALTER TABLE "public"."commandes"
DROP CONSTRAINT IF EXISTS "commandes_site_livraison_check";

ALTER TABLE "public"."commandes"
ADD CONSTRAINT "commandes_site_livraison_check"
CHECK (site_livraison IN ('DANGA', 'CAMPUS'));

-- Commentaire pour documentation
COMMENT ON COLUMN "public"."commandes"."site_livraison" IS 'Site de livraison choisi par le collaborateur (DANGA ou CAMPUS)';


-- ============================================================
-- ÉTAPE 2 : Ajouter notes_speciales à la table commandes
-- ============================================================
-- Permet au collaborateur de laisser des notes spéciales
-- Exemple : "Je veux du piment svp", "Sans oignons", etc.

ALTER TABLE "public"."commandes"
ADD COLUMN IF NOT EXISTS "notes_speciales" TEXT;

-- Commentaire pour documentation
COMMENT ON COLUMN "public"."commandes"."notes_speciales" IS 'Notes spéciales du collaborateur (ex: "Je veux du piment svp")';


-- ============================================================
-- ÉTAPE 3 : Ajouter photo à la table utilisateurs
-- ============================================================
-- Permet aux utilisateurs d'avoir une photo de profil
-- Stocke l'URL de la photo (peut être Supabase Storage ou autre)

ALTER TABLE "public"."utilisateurs"
ADD COLUMN IF NOT EXISTS "photo" TEXT;

-- Commentaire pour documentation
COMMENT ON COLUMN "public"."utilisateurs"."photo" IS 'URL de la photo de profil de l''utilisateur';


-- ============================================================
-- ÉTAPE 4 : Mettre à jour les commandes existantes (optionnel)
-- ============================================================
-- Définir le site_livraison des commandes existantes basé sur le site de l'utilisateur

UPDATE "public"."commandes" c
SET site_livraison = u.site
FROM "public"."utilisateurs" u
WHERE c.id_user = u.id_user
  AND c.site_livraison IS NULL
  AND c.deleted_at IS NULL;


-- ============================================================
-- VÉRIFICATIONS
-- ============================================================

-- Vérifier la structure de la table commandes
-- SELECT column_name, data_type, character_maximum_length, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'commandes'
--   AND column_name IN ('site_livraison', 'notes_speciales')
-- ORDER BY ordinal_position;

-- Vérifier la structure de la table utilisateurs
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'utilisateurs'
--   AND column_name = 'photo'
-- ORDER BY ordinal_position;

-- Vérifier les contraintes
-- SELECT constraint_name, constraint_type
-- FROM information_schema.table_constraints
-- WHERE table_name = 'commandes'
--   AND constraint_name LIKE '%site_livraison%';


-- ============================================================
-- FIN DU SCRIPT
-- ============================================================
--
-- Ce script a effectué les modifications suivantes :
-- 1. ✅ Ajouté site_livraison (VARCHAR(10)) à la table commandes
--       avec contrainte CHECK (DANGA ou CAMPUS)
-- 2. ✅ Ajouté notes_speciales (TEXT) à la table commandes
-- 3. ✅ Ajouté photo (TEXT) à la table utilisateurs
-- 4. ✅ Mis à jour les commandes existantes avec le site de l'utilisateur
--
-- Prochaines étapes :
-- - Mettre à jour les modèles Dart (Commande, Utilisateur)
-- - Adapter les services (ServiceCommande, ServiceUtilisateur)
-- - Modifier l'UI pour permettre la saisie de ces champs
-- ============================================================
