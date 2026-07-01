# HirfaHome

> **Application mobile de mise en relation entre artisans et particuliers au Maroc.**
>
> Projet de Fin d'Études — Anass Marji (2DAI-2)
> Encadrant : Dr. Amina Aboulmira
> Établissement : Centre Préparation BTS Al Kendy
> Année académique : 2024-2025

## 📱 À propos

HirfaHome est une application mobile Flutter qui facilite la mise en relation entre artisans qualifiés (plombiers, électriciens, peintres, menuisiers, etc.) et particuliers au Maroc. Le projet répond à une problématique concrète : trouver un artisan fiable rapidement est difficile, et les artisans manquent souvent de visibilité numérique.

## ✨ Fonctionnalités

### Pour les clients
- 🔍 Recherche d'artisans par métier, localisation, budget et disponibilité
- 📨 Envoi de demandes d'intervention avec photos
- 💬 Chat en temps réel avec l'artisan
- ⭐ Notation et avis après intervention
- 📜 Historique complet des demandes

### Pour les artisans
- 👤 Profil professionnel vérifié (CIN obligatoire)
- 📸 Portfolio avant/après des réalisations
- 📅 Gestion des demandes et du planning
- 📊 Tableau de bord statistique
- 🔔 Notifications en temps réel

### Pour l'administrateur
- ✅ Validation des inscriptions artisans
- 🛡️ Modération de la plateforme
- 📈 Statistiques globales
- 🗂️ Gestion des catégories métiers

## 🛠️ Stack Technique

| Domaine | Technologie |
|---|---|
| Application mobile | Flutter (Dart) |
| Authentification | Firebase Authentication |
| Base de données | Cloud Firestore |
| Stockage images | Firebase Storage |
| Notifications | Firebase Cloud Messaging |
| Back-office | Flutter Web (prévu) |
| Design | Figma + Google Fonts (Inter) |
| Versioning | Git + GitHub |

## 🚀 Démarrage

### Prérequis
- Flutter SDK ≥ 3.10
- Dart SDK ≥ 3.10
- Un projet Firebase configuré

### Installation
```bash
# Cloner le dépôt
git clone https://github.com/AnassMarji/HirfaHome3.git
cd HirfaHome3

# Installer les dépendances
flutter pub get

# Configurer Firebase
# 1. Créer un projet sur https://console.firebase.google.com
# 2. Activer Authentication, Firestore, Storage et Messaging
# 3. Placer google-services.json dans android/app/
# 4. Placer GoogleService-Info.plist dans ios/Runner/
# 5. Configurer lib/firebase_options.dart avec vos identifiants

# Lancer l'application
flutter run
```

## 📂 Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée
├── firebase_options.dart        # Configuration Firebase
├── config/
│   ├── app_theme.dart           # Thème & design system
│   └── category_config.dart     # Catégories métiers
├── models/                      # Modèles de données
│   ├── app_user.dart
│   ├── demande.dart
│   ├── chat_message.dart
│   └── portfolio_item.dart
├── repositories/                # Couche d'accès aux données
│   ├── demande_repository.dart
│   ├── firestore_demande_repository.dart
│   ├── artisan_repository.dart
│   ├── firestore_artisan_repository.dart
│   ├── chat_repository.dart
│   └── firestore_chat_repository.dart
├── services/                    # Services métier
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── rating_service.dart
│   ├── notification_service.dart
│   ├── category_service.dart
│   └── seed_service.dart
├── viewmodels/                  # ViewModels (Provider)
│   ├── auth_viewmodel.dart
│   └── language_viewmodel.dart
├── views/                       # Écrans UI
│   ├── auth/
│   ├── client/
│   ├── artisan/
│   ├── admin/
│   ├── profile/
│   └── shared/
├── widgets/                     # Widgets réutilisables
│   ├── status_badge.dart
│   ├── empty_state.dart
│   ├── error_state.dart
│   └── skeleton_loader.dart
├── strings/
│   └── app_strings.dart         # Localisation FR/AR
└── utils/
    ├── validators.dart
    └── status_style.dart
```

## 🌐 Localisation

L'application supporte le **français** et l'**arabe** (avec support RTL). Les chaînes de caractères sont centralisées dans `lib/strings/app_strings.dart`.

## 🔒 Sécurité

- **Firestore Rules** : contrôle d'accès basé sur les rôles (client, artisan, admin)
- **Storage Rules** : protection des documents sensibles (CIN) — admin uniquement
- **Authentification** : email/mot de passe + Google Sign-In
- **Validation** : champs obligatoires et formats validés côté client et serveur

## 📋 Cahier des Charges

Le cahier des charges complet est disponible dans le rapport PFE.

## 📄 Licence

Projet académique — Centre Préparation BTS Al Kendy.
