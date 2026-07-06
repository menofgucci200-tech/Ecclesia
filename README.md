# Ecclesia

Monorepo du projet **Ecclesia** : application de gestion d'église avec un backend et une application mobile.

## Structure

| Dossier      | Description                     | Stack              |
|--------------|---------------------------------|--------------------|
| `Ecclesia/`  | API / backend                   | Laravel (PHP)      |
| `ecclesia_/` | Application cliente             | Flutter (Dart)     |

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
