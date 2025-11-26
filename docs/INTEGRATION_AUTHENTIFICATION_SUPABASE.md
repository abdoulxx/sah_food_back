# 🔐 Intégration de l'Authentification Supabase - SAH Food

Ce document explique comment l'authentification Supabase a été intégrée dans l'application SAH Food.

---

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Configuration initiale](#configuration-initiale)
3. [Architecture](#architecture)
4. [Implémentation](#implémentation)
5. [Utilisation](#utilisation)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Vue d'ensemble

L'application utilise **Supabase** comme backend d'authentification avec les fonctionnalités suivantes :
- ✅ Connexion par email/mot de passe
- ✅ Inscription de nouveaux utilisateurs
- ✅ Déconnexion
- ✅ Gestion de session persistante
- ✅ Validation des emails `@sahanalytics.com`

---

## ⚙️ Configuration initiale

### 1. Dépendances ajoutées (`pubspec.yaml`)

```yaml
dependencies:
  supabase_flutter: ^2.8.0
  http: ^1.2.2
  shared_preferences: ^2.3.3
```

### 2. Configuration Supabase

**Fichier** : `lib/core/config/supabase_config.dart`

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://zqycudphoyconosopagi.supabase.co';
  static const String supabaseAnonKey = 'VOTRE_ANON_KEY';

  // Noms des tables
  static const String tableUsers = 'utilisateurs';
  static const String tableMenus = 'menus';
  static const String tablePlats = 'plats';
  static const String tableCommandes = 'commandes';
  static const String tableAvis = 'avis';
}
```

### 3. Initialisation dans `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const ApplicationSahFood());
}
```

---

## 🏗️ Architecture

### Structure des fichiers

```
lib/
├── core/
│   └── config/
│       └── supabase_config.dart          # Configuration Supabase
├── services/
│   ├── supabase_service.dart             # Service de base
│   └── service_authentification.dart     # Service d'authentification
├── modeles/
│   └── utilisateur.dart                  # Modèle Utilisateur avec fromJson/toJson
└── modeles_vues/
    └── authentification_model_vue.dart   # ViewModel pour l'UI
```

### Flux de données

```
[UI] ←→ [ViewModel] ←→ [Service] ←→ [Supabase Auth + DB]
```

---

## 💻 Implémentation

### 1. Service de base (`supabase_service.dart`)

```dart
class ServiceSupabase {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static SupabaseQueryBuilder get utilisateurs => client.from('utilisateurs');

  static String gererErreur(dynamic erreur) {
    if (erreur is AuthException) return erreur.message;
    if (erreur is PostgrestException) return erreur.message;
    return erreur.toString();
  }
}
```

### 2. Service d'authentification (`service_authentification.dart`)

#### ✅ Connexion

```dart
static Future<Utilisateur?> seConnecter({
  required String email,
  required String motDePasse,
}) async {
  try {
    // 1. Authentification Supabase
    final AuthResponse reponse = await ServiceSupabase.auth.signInWithPassword(
      email: email,
      password: motDePasse,
    );

    if (reponse.user == null) {
      throw Exception('Email ou mot de passe incorrect');
    }

    // 2. Récupération des données utilisateur depuis la table
    final utilisateurData = await ServiceSupabase.utilisateurs
        .select()
        .eq('email', email)
        .isFilter('deleted_at', null)
        .maybeSingle();

    if (utilisateurData == null) {
      throw Exception('Utilisateur non trouvé dans la base de données');
    }

    return Utilisateur.fromJson(utilisateurData);
  } catch (e) {
    throw Exception(ServiceSupabase.gererErreur(e));
  }
}
```

#### ✅ Inscription

```dart
static Future<Utilisateur?> inscrire({
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
    // 1. Créer l'utilisateur dans Supabase Auth
    final AuthResponse reponseAuth = await ServiceSupabase.auth.signUp(
      email: email,
      password: motDePasse,
    );

    if (reponseAuth.user == null) {
      throw Exception('Erreur lors de la création du compte');
    }

    // 2. Créer l'entrée dans la table utilisateurs
    final Map<String, dynamic> donneesUtilisateur = {
      'qid': qid,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'role': role,
      'site': site,
      'departement': departement,
    };

    final reponse = await ServiceSupabase.utilisateurs
        .insert(donneesUtilisateur)
        .select()
        .single();

    return Utilisateur.fromJson(reponse);
  } catch (e) {
    throw Exception(ServiceSupabase.gererErreur(e));
  }
}
```

#### ✅ Déconnexion

```dart
static Future<void> seDeconnecter() async {
  try {
    await ServiceSupabase.auth.signOut();
  } catch (e) {
    throw Exception(ServiceSupabase.gererErreur(e));
  }
}
```

### 3. Modèle Utilisateur (`utilisateur.dart`)

```dart
class Utilisateur {
  final int idUser;
  final String qid;
  final String prenom;
  final String nom;
  final String email;
  final String role;
  final String? departement;
  final String site;
  final DateTime createdAt;
  // ... autres champs d'audit

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      idUser: json['id_user'],
      qid: json['qid'],
      prenom: json['prenom'],
      nom: json['nom'],
      email: json['email'],
      role: json['role'],
      departement: json['departement'],
      site: json['site'],
      createdAt: DateTime.parse(json['created_at']),
      // ... autres champs
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'qid': qid,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'role': role,
      'departement': departement,
      'site': site,
      'created_at': createdAt.toIso8601String(),
      // ... autres champs
    };
  }
}
```

### 4. ViewModel (`authentification_model_vue.dart`)

```dart
class AuthentificationModelVue extends ChangeNotifier {
  Utilisateur? _utilisateurConnecte;
  bool _estEnChargement = false;
  String? _messageErreur;

  Utilisateur? get utilisateurConnecte => _utilisateurConnecte;
  bool get estEnChargement => _estEnChargement;
  String? get messageErreur => _messageErreur;

  Future<bool> seConnecter() async {
    _estEnChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      _utilisateurConnecte = await ServiceAuthentification.seConnecter(
        email: controleurEmail.text.trim(),
        motDePasse: controleurMotDePasse.text,
      );

      _estEnChargement = false;
      notifyListeners();
      return _utilisateurConnecte != null;
    } catch (erreur) {
      _messageErreur = erreur.toString().replaceAll('Exception: ', '');
      _estEnChargement = false;
      notifyListeners();
      return false;
    }
  }
}
```

---

## 🚀 Utilisation

### Dans l'UI (exemple : `ecran_connexion.dart`)

```dart
final modelVue = context.read<AuthentificationModelVue>();

// Lors du clic sur "Se connecter"
onPressed: () async {
  if (_formKey.currentState!.validate()) {
    final succes = await modelVue.seConnecter();

    if (succes && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const NavigationPrincipale(),
        ),
      );
    } else if (modelVue.messageErreur != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(modelVue.messageErreur!)),
      );
    }
  }
}
```

---

## 🗄️ Configuration de la base de données

### Schéma PostgreSQL

```sql
-- Table utilisateurs (sans mot_de_passe car géré par Supabase Auth)
CREATE TABLE utilisateurs (
  id_user BIGSERIAL PRIMARY KEY,
  qid VARCHAR(50) NOT NULL UNIQUE,
  prenom VARCHAR(100) NOT NULL,
  nom VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  role VARCHAR(20) CHECK (role IN ('ADMIN','COLLAB','PRESTATAIRE','SECRETAIRE')) NOT NULL,
  departement VARCHAR(100),
  site VARCHAR(10) CHECK (site IN ('DANGA','CAMPUS')) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT,
  updated_at TIMESTAMPTZ,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ,
  deleted_by BIGINT
);

-- Index pour améliorer les performances
CREATE INDEX idx_utilisateurs_email ON utilisateurs(email);
CREATE INDEX idx_utilisateurs_qid ON utilisateurs(qid);
```

### Configuration Supabase Dashboard

1. **Désactiver la confirmation d'email (pour le développement)** :
   - `Authentication` → `Settings` → `Email Auth`
   - Décochez "Enable email confirmations"

2. **Créer un utilisateur test** :
   - `Authentication` → `Users` → `Add user`
   - Email : `test@sahanalytics.com`
   - Password : `Test1234!`

3. **Insérer dans la table `utilisateurs`** :
   ```sql
   INSERT INTO utilisateurs (qid, prenom, nom, email, role, site, departement)
   VALUES ('QID001', 'Test', 'User', 'test@sahanalytics.com', 'COLLAB', 'CAMPUS', 'DEV');
   ```

---

## 🔧 Troubleshooting

### ❌ Erreur : "Email not confirmed"
**Solution** : Désactiver la confirmation d'email dans Supabase Settings

### ❌ Erreur : "Cannot coerce the result to a single json object"
**Solution** : Utiliser `.maybeSingle()` au lieu de `.single()`

### ❌ Erreur : "null value in column mot_de_passe violates not null constraint"
**Solution** : Supprimer la colonne `mot_de_passe` de la table (non nécessaire avec Supabase Auth)
```sql
ALTER TABLE utilisateurs DROP COLUMN mot_de_passe;
```

### ❌ Erreur : "Invalid login credentials"
**Solution** : Vérifier que :
1. L'utilisateur existe dans `Authentication` → `Users`
2. L'email est confirmé (ou confirmation désactivée)
3. Le mot de passe est correct

---

## 📝 Bonnes pratiques

### ✅ À faire
- Toujours utiliser `.trim()` sur les inputs email
- Valider l'email côté client avant l'envoi
- Gérer les erreurs de façon user-friendly
- Utiliser `maybeSingle()` pour les requêtes qui peuvent retourner 0 ou 1 résultat
- Nettoyer l'état après déconnexion

### ❌ À éviter
- Stocker le mot de passe dans la table utilisateurs
- Utiliser `.single()` sans vérifier l'existence des données
- Exposer les messages d'erreur techniques à l'utilisateur
- Oublier de gérer les cas où `utilisateurConnecte` est null

---

## 🔐 Sécurité

### Points importants
1. **Anon Key** : La clé anonyme est sûre côté client (RLS protège les données)
2. **Service Role Key** : ⚠️ Ne JAMAIS exposer dans l'app Flutter
3. **Row Level Security (RLS)** : À configurer pour sécuriser l'accès aux données
4. **Validation** : Toujours valider les données côté client ET serveur

### Prochaines étapes de sécurité
- Configurer les politiques RLS sur toutes les tables
- Implémenter la réinitialisation de mot de passe
- Ajouter l'authentification à deux facteurs (2FA)
- Mettre en place des logs d'audit

---

## 📚 Ressources

- [Documentation Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Guide d'authentification Supabase](https://supabase.com/docs/guides/auth)
- [PostgreSQL dans Supabase](https://supabase.com/docs/guides/database)

---

## 👨‍💻 Auteur

Documentation créée pour l'équipe de développement SAH Food

**Date** : 30 septembre 2025
**Version** : 1.0.0
