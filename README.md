# Ecclesia

Monorepo du projet **Ecclesia** : application de gestion d'église avec un backend et une application mobile.

## Structure

| Dossier      | Description                              | Stack                       |
|--------------|------------------------------------------|-----------------------------|
| `Ecclesia/`  | API / backend + dashboard d'administration | Laravel (PHP), Blade + Tailwind |
| `ecclesia_/` | Application cliente                      | Flutter (Dart)              |

## Dashboard d'administration

Le backend inclut un dashboard web (Blade + Tailwind v4) partageant la même base
et les mêmes modèles que l'API — toute annonce/paroisse gérée depuis le dashboard
est immédiatement disponible dans l'application mobile.

- **Super administrateur** (toutes les paroisses) : `/super/login`
- **Administrateur de paroisse** (limité à sa paroisse) : `/admin/login`

## Déploiement

Voir [`DEPLOYMENT.md`](DEPLOYMENT.md) — déploiement automatique sur Hostinger via
GitHub Actions (`.github/workflows/deploy.yml`) à chaque `push` sur `main`.

## Mise en route

### Backend (`Ecclesia/`)
```bash
cd Ecclesia
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Application Flutter (`ecclesia_/`)
```bash
cd ecclesia_
flutter pub get
flutter run
```

## Notes

- Les dépendances (`vendor/`, `node_modules/`) et les artefacts de build
  (`build/`, `.dart_tool/`, `flutter/ephemeral/`) ne sont pas versionnés :
  ils sont régénérables via `composer.lock` et `pubspec.lock`.
- Les fichiers `.env` contiennent des secrets et ne sont **pas** poussés.
  Utilisez `Ecclesia/.env.example` comme modèle.
