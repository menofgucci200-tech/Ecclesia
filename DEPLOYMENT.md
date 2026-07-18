# Déploiement — Ecclesia (backend + dashboard) sur Hostinger

Ce guide décrit le déploiement de l'**API Laravel + dashboard d'administration**
(dossier [`Ecclesia/`](Ecclesia/)) sur un **hébergement mutualisé Hostinger (hPanel)**,
avec **déploiement automatique via GitHub Actions** à chaque `push` sur `main`.

> L'application mobile Flutter (`ecclesia_/`) n'est pas hébergée sur le serveur :
> elle se compile séparément et consomme l'API déployée ici.

---

## 1. Architecture du déploiement

```
GitHub (push main)
   └─> GitHub Actions (.github/workflows/deploy.yml)
         1. composer install --no-dev        (dépendances PHP)
         2. npm ci && npm run build          (assets Tailwind/Vite)
         3. rsync via SSH  ───────────────>  Hostinger : ~/domains/…/ecclesia
         4. php artisan migrate + caches     (sur le serveur)
```

Le **document root** du site pointe vers `…/ecclesia/public` (jamais la racine du projet).

---

## 2. Prérequis

- Un plan Hostinger **avec accès SSH** (Premium/Business/Cloud). L'accès SSH s'active
  dans **hPanel → Avancé → Accès SSH**.
- Un domaine ou sous-domaine (recommandé : `admin.votre-domaine.com`).
- Le port SSH Hostinger est **65002** (et non 22).

---

## 3. Configuration du serveur (une seule fois)

### 3.1 Base de données MySQL
hPanel → **Bases de données → MySQL** : créez une base et un utilisateur, notez :
`DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` (souvent préfixés `uXXXXXXXX_`).

### 3.2 Sous-domaine + document root
hPanel → **Domaines → Sous-domaines** : créez `admin.votre-domaine.com`.
Puis définissez son **dossier racine (document root)** sur :

```
domains/votre-domaine.com/ecclesia/public
```

> C'est l'étape clé sur mutualisé : la racine web doit être le dossier `public/`
> de Laravel, pas la racine du projet.

### 3.3 Dossier de l'application
Via SSH, créez le dossier cible (le `DEPLOY_PATH`) :

```bash
ssh -p 65002 uXXXXXXXX@votre-serveur.hostinger.com
mkdir -p ~/domains/votre-domaine.com/ecclesia
```

### 3.4 Clé SSH de déploiement
Générez une paire de clés **dédiée au déploiement** (sur votre machine) :

```bash
ssh-keygen -t ed25519 -C "github-actions-ecclesia" -f ~/.ssh/ecclesia_deploy -N ""
```

- Ajoutez la **clé publique** (`ecclesia_deploy.pub`) sur le serveur :
  hPanel → **Avancé → Accès SSH → Gérer les clés SSH**, ou bien
  `cat ~/.ssh/ecclesia_deploy.pub >> ~/.ssh/authorized_keys` sur le serveur.
- La **clé privée** (`ecclesia_deploy`) ira dans les secrets GitHub (étape 4).

### 3.5 Fichier `.env`
Copiez le modèle et renseignez les valeurs, puis générez la clé :

```bash
cd ~/domains/votre-domaine.com/ecclesia
cp .env.production.example .env     # (présent après le 1er déploiement)
nano .env                           # renseigner DB_*, APP_URL, MAIL_*
php artisan key:generate
```

> Le `.env` **reste sur le serveur** et n'est jamais écrasé par les déploiements
> (il est exclu du `rsync`).

---

## 4. Secrets GitHub

Dépôt GitHub → **Settings → Secrets and variables → Actions → New repository secret** :

| Secret             | Exemple / valeur                                             |
|--------------------|-------------------------------------------------------------|
| `SSH_HOST`         | `votre-serveur.hostinger.com` (ou l'IP)                     |
| `SSH_USER`         | `uXXXXXXXX`                                                  |
| `SSH_PORT`         | `65002`                                                     |
| `SSH_PRIVATE_KEY`  | contenu **intégral** de `~/.ssh/ecclesia_deploy`            |
| `DEPLOY_PATH`      | `/home/uXXXXXXXX/domains/votre-domaine.com/ecclesia`       |

---

## 5. Premier déploiement

1. Poussez sur `main` (ou lancez **Actions → Déploiement Hostinger → Run workflow**).
2. Le workflow compile et envoie les fichiers, puis exécute `migrate` + les caches.
3. Si c'est la toute première fois et que le `.env` n'existait pas encore lors du
   `migrate`, créez le `.env` (étape 3.5) puis **relancez le workflow**.

### Créer le super administrateur (mot de passe fort)
Ne lancez **pas** les seeders de démo en production. Créez le compte à la main :

```bash
cd ~/domains/votre-domaine.com/ecclesia
php artisan tinker
>>> \App\Models\User::create([
...   'first_name' => 'Prénom', 'last_name' => 'Nom',
...   'gender' => 'male', 'phone' => '+2250700000000',
...   'email' => 'admin@votre-domaine.com',
...   'password' => \Illuminate\Support\Facades\Hash::make('UN_MOT_DE_PASSE_FORT'),
...   'status' => 'active', 'role' => 'super_admin',
...   'email_verified_at' => now(),
... ]);
```

Connexion super-admin : `https://admin.votre-domaine.com/super/login`
Connexion admin paroisse : `https://admin.votre-domaine.com/admin/login`

---

## 6. Application mobile Flutter

Pointez la base d'URL de l'API vers le domaine déployé dans
[`ecclesia_/lib/core/constants/api_constants.dart`](ecclesia_/lib/core/constants/api_constants.dart)
(ex. `https://admin.votre-domaine.com/api`), puis recompilez l'app.

---

## 7. Dépannage

- **Erreur 500 / page blanche** : vérifiez `storage/logs/laravel.log`, les permissions
  (`chmod -R 775 storage bootstrap/cache`) et que `APP_KEY` est bien défini.
- **CSS/JS absents** : les assets sont compilés par la CI dans `public/build`. Vérifiez
  que le job GitHub Actions s'est bien terminé et que `public/build/manifest.json` existe.
- **`route:cache` échoue** : ne pas ajouter de closures aux routes (la route `/` est déjà
  un contrôleur invokable pour cette raison).
- **Liens en `http://` sous HTTPS** : vérifiez `APP_URL=https://…` et
  `SESSION_SECURE_COOKIE=true` dans `.env`.

### Alternative sans SSH (FTP)
Si votre plan n'a pas SSH, remplacez l'étape `rsync` du workflow par l'action
[`SamKirkland/FTP-Deploy-Action`](https://github.com/SamKirkland/FTP-Deploy-Action)
avec les secrets `FTP_SERVER`, `FTP_USERNAME`, `FTP_PASSWORD`, et exécutez les
commandes `artisan` (migrate/cache) manuellement depuis le **Terminal hPanel**.
