# Arista - Application de Santé et Bien-être

Application iOS de suivi de santé et bien-être permettant de gérer ses exercices physiques, son sommeil et ses objectifs quotidiens.

## 🚀 Installation
```bash
git clone https://github.com/ton-username/arista.git
cd arista
open Arista.xcodeproj
```

**Prérequis :** Xcode 15.0+, iOS 17.0+

## 🧪 Compte de démonstration

**L'application crée automatiquement un compte de démo au premier lancement :**

Le compte est vide par défaut. Pour tester l'application :
- **Exercices :** Onglet "Exercices" → Bouton "Ajouter"
- **Sommeil :** Onglet "Sommeil" → Bouton "Commencer" puis "Terminer"
- **Objectifs :** Onglet "Profil" → Modifier les sliders (eau, pas)

## 📱 Fonctionnalités

- ✅ Suivi des exercices (24 types d'activités)
- ✅ Gestion du sommeil avec horloge visuelle
- ✅ Objectifs quotidiens (calories, pas, eau, sommeil)
- ✅ Historique et statistiques sur 7 jours
- ✅ Persistance locale (CoreData)
- ✅ Mots de passe hashés (SHA-256 + salt)

## 🏗️ Architecture

- **SwiftUI** + **MVVM**
- **CoreData** pour la persistance

## 🧪 Tests
```bash
Cmd + U
```

Les tests sont isolés (CoreData in-memory + UserDefaults de test).

## 📝 Structure
```
Arista/
├── App/              # AppCoordinator, ContentView
├── User/             # Profil et objectifs
├── Exercice/         # Gestion des exercices
├── Sleep/            # Gestion du sommeil
├── Goal/             # Objectifs quotidiens
└── CoreData/         # Modèle de données
```

## 👥 Auteurs

Julien Cotte - Développement iOS
