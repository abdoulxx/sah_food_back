-- ============================================================
-- MISE À JOUR POUR SUPPORTER 7 JOURS (LUNDI AU DIMANCHE)
-- ============================================================
-- Ce script met à jour la base de données pour étendre
-- les semaines de 5 jours (Lundi-Vendredi) à 7 jours (Lundi-Dimanche)
-- ============================================================

-- ============================================================
-- ÉTAPE 0 : Supprimer la contrainte jour_semaine (1-5)
-- ============================================================
-- La table plats a une contrainte CHECK qui limite jour_semaine à 1-5
-- Il faut la supprimer ou la modifier pour accepter 1-7

-- Supprimer l'ancienne contrainte
ALTER TABLE "public"."plats"
DROP CONSTRAINT IF EXISTS "plats_jour_semaine_check";

-- Ajouter une nouvelle contrainte pour accepter 1-7 (Lundi-Dimanche)
ALTER TABLE "public"."plats"
ADD CONSTRAINT "plats_jour_semaine_check"
CHECK (jour_semaine >= 1 AND jour_semaine <= 7);


-- ============================================================
-- ÉTAPE 1 : Mettre à jour les dates de fin des menus
-- ============================================================
-- Étendre date_fin pour qu'elle soit 6 jours après date_debut
-- (au lieu de 4 jours) pour couvrir jusqu'au dimanche

UPDATE "public"."menus"
SET
    date_fin = date_debut + INTERVAL '6 days',
    updated_at = NOW()
WHERE deleted_at IS NULL;

-- Vérification des nouvelles dates
-- SELECT id_menu, semaine, date_debut, date_fin FROM menus WHERE deleted_at IS NULL ORDER BY semaine;


-- ============================================================
-- ÉTAPE 2 : Ajouter des plats pour SAMEDI (jour_semaine = 6)
-- ============================================================

-- Plats pour le samedi du menu 12 (semaine 44)
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (12, 'Poulet DG', 'Poulet Directeur Général avec plantains frits et légumes sautés', null, 'assets/images/repas/foutou.png', 6, NOW()),
    (12, 'Ndolé', 'Plat camerounais aux feuilles de ndolé avec viande et crevettes', 'Crevettes', 'assets/images/repas/soupe.jpg', 6, NOW()),
    (12, 'Riz cantonais', 'Riz sauté aux légumes, œufs et morceaux de jambon', 'Œufs', 'assets/images/repas/riz.jpg', 6, NOW());


-- ============================================================
-- ÉTAPE 3 : Ajouter des plats pour DIMANCHE (jour_semaine = 7)
-- ============================================================

-- Plats pour le dimanche du menu 12 (semaine 44)
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (12, 'Thiou', 'Sauce traditionnelle sénégalaise aux légumes servie avec du riz', null, 'assets/images/repas/soupe.jpg', 7, NOW()),
    (12, 'Domoda', 'Ragoût gambien à la pâte d''arachide avec légumes et viande', 'Arachides', 'assets/images/repas/riz.jpg', 7, NOW()),
    (12, 'Alloco poisson', 'Bananes plantains frites accompagnées de poisson frit et sauce tomate pimentée', 'Poisson', 'assets/images/repas/poissons.jpg', 7, NOW());


-- ============================================================
-- ÉTAPE 4 : Ajouter des plats pour les autres semaines (8, 9, 10, 11)
-- ============================================================

-- SEMAINE 8 - SAMEDI
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (8, 'Poulet rôti', 'Poulet rôti au four avec pommes de terre et légumes', null, 'assets/images/repas/foutou.png', 6, NOW()),
    (8, 'Attiéké poisson', 'Attiéké avec poisson frit et légumes', 'Poisson', 'assets/images/repas/poissons.jpg', 6, NOW()),
    (8, 'Riz jollof', 'Riz jollof épicé avec légumes et viande', null, 'assets/images/repas/riz.jpg', 6, NOW());

-- SEMAINE 8 - DIMANCHE
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (8, 'Sauce arachide', 'Sauce onctueuse à la pâte d''arachide avec viande et légumes', 'Arachides', 'assets/images/repas/riz.jpg', 7, NOW()),
    (8, 'Capitaine braisé', 'Poisson capitaine grillé avec attiéké', 'Poisson', 'assets/images/repas/poissons.jpg', 7, NOW()),
    (8, 'Riz aux légumes', 'Riz sauté avec mélange de légumes frais', null, 'assets/images/repas/riz.jpg', 7, NOW());


-- SEMAINE 9 - SAMEDI
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (9, 'Grillades mixtes', 'Assortiment de viandes grillées avec frites', null, 'assets/images/repas/foutou.png', 6, NOW()),
    (9, 'Soupe de poisson', 'Soupe traditionnelle au poisson frais avec légumes', 'Poisson', 'assets/images/repas/soupe.jpg', 6, NOW()),
    (9, 'Thiéboudienne rouge', 'Riz au poisson à la sauce tomate', 'Poisson', 'assets/images/repas/tchep.jpeg', 6, NOW());

-- SEMAINE 9 - DIMANCHE
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (9, 'Yassa poisson', 'Poisson mariné aux oignons et citron', 'Poisson', 'assets/images/repas/poissons.jpg', 7, NOW()),
    (9, 'Couscous royal', 'Couscous avec viandes variées et légumes', 'Gluten', 'assets/images/repas/spaghetti.jpeg', 7, NOW()),
    (9, 'Riz gras poulet', 'Riz wolof au poulet', null, 'assets/images/repas/riz.jpg', 7, NOW());


-- SEMAINE 10 - SAMEDI
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (10, 'Mafé poulet', 'Poulet à la sauce arachide avec légumes', 'Arachides', 'assets/images/repas/riz.jpg', 6, NOW()),
    (10, 'Attiéké thon', 'Attiéké avec thon grillé', 'Poisson', 'assets/images/repas/riz.jpg', 6, NOW()),
    (10, 'Riz sauce tomate', 'Riz avec sauce tomate et viande', null, 'assets/images/repas/riz.jpg', 6, NOW());

-- SEMAINE 10 - DIMANCHE
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (10, 'Poisson braisé attiéké', 'Poisson grillé accompagné d''attiéké', 'Poisson', 'assets/images/repas/poissons.jpg', 7, NOW()),
    (10, 'Riz wolof viande', 'Riz sénégalais avec viande et légumes', null, 'assets/images/repas/riz.jpg', 7, NOW()),
    (10, 'Foutou sauce graine', 'Foutou avec sauce aux graines de palme', null, 'assets/images/repas/foutou.png', 7, NOW());


-- SEMAINE 11 - SAMEDI
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (11, 'Poulet braisé', 'Poulet grillé mariné aux épices avec frites', null, 'assets/images/repas/foutou.png', 6, NOW()),
    (11, 'Thiéboudienne blanche', 'Riz au poisson sans sauce tomate', 'Poisson', 'assets/images/repas/tchep.jpeg', 6, NOW()),
    (11, 'Garba attiéké', 'Attiéké avec thon frit et sauce', 'Poisson', 'assets/images/repas/riz.jpg', 6, NOW());

-- SEMAINE 11 - DIMANCHE
INSERT INTO "public"."plats"
("id_menu", "nom_plat", "description", "allergenes", "photo_url", "jour_semaine", "created_at")
VALUES
    (11, 'Soupe kandia gombo', 'Soupe traditionnelle au gombo avec riz', null, 'assets/images/repas/soupe.jpg', 7, NOW()),
    (11, 'Alloco banane', 'Bananes plantains frites avec poisson', 'Poisson', 'assets/images/repas/poissons.jpg', 7, NOW()),
    (11, 'Riz sauce graine', 'Riz avec sauce aux graines de palme', null, 'assets/images/repas/riz.jpg', 7, NOW());


-- ============================================================
-- ÉTAPE 5 : Vérifications finales
-- ============================================================

-- Compter le nombre de plats par jour de semaine
-- SELECT jour_semaine, COUNT(*) as nombre_plats
-- FROM plats
-- WHERE deleted_at IS NULL
-- GROUP BY jour_semaine
-- ORDER BY jour_semaine;

-- Afficher tous les plats du samedi et dimanche
-- SELECT p.id_plat, p.id_menu, m.semaine, p.nom_plat, p.jour_semaine
-- FROM plats p
-- JOIN menus m ON p.id_menu = m.id_menu
-- WHERE p.jour_semaine IN (6, 7) AND p.deleted_at IS NULL
-- ORDER BY m.semaine, p.jour_semaine;

-- Vérifier que toutes les semaines ont des plats pour les 7 jours
-- SELECT m.id_menu, m.semaine, m.date_debut, m.date_fin,
--        COUNT(DISTINCT p.jour_semaine) as jours_avec_plats
-- FROM menus m
-- LEFT JOIN plats p ON m.id_menu = p.id_menu AND p.deleted_at IS NULL
-- WHERE m.deleted_at IS NULL
-- GROUP BY m.id_menu, m.semaine, m.date_debut, m.date_fin
-- ORDER BY m.semaine;

-- ============================================================
-- FIN DU SCRIPT
-- ============================================================
--
-- Ce script a effectué les modifications suivantes :
-- 1. ✅ Étendu les dates de fin des menus pour couvrir 7 jours
-- 2. ✅ Ajouté 3 plats pour chaque samedi (jour_semaine = 6)
-- 3. ✅ Ajouté 3 plats pour chaque dimanche (jour_semaine = 7)
--
-- Votre application supporte maintenant une semaine complète
-- du lundi au dimanche (7 jours) au lieu de lundi au vendredi (5 jours)
-- ============================================================
