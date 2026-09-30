# Gontran

Application Flutter multi-plateforme (Android, iOS, Web) connectée à Firebase Firestore.

## 🚀 Démarrage Rapide

Dès le clonage du dépôt, vous devez exécuter le script de configuration initial.

### 1. Ouvrir le terminal
Ouvrez votre terminal (ou le terminal intégré de votre IDE comme VS Code ou Android Studio) et naviguez jusqu'à la racine du projet :

```bash
cd gontran
```

### 2. Ce que fait le script d'installation

1. **Détection du système d'exploitation** (Linux, macOS, Windows).
2. **Vérification et installation de Task (Go-Task)** :
   * **Linux** : Installation via `snap install task --classic` ou binaire officiel.
   * **macOS** : Installation via `brew install go-task/tap/go-task` ou binaire officiel.
   * **Windows** : Installation via `winget install Task.Task`.
3. **Contrôle de présence des outils indispensables** :
   * **Git** (Gestion de version).
   * **Flutter SDK** (Moteur applicatif).
4. **Exécution du diagnostic `flutter doctor`** pour valider la présence de :
   * **Google Chrome** (Cible Web).
   * **Android Studio & SDK Android** (Cible Android).
   * **Xcode** (Cible iOS, macOS uniquement).

### 3. Lancer la configuration

Exécutez la commande correspondant à votre système d'exploitation :

* **Linux / macOS** :
  ```bash
  bash ./scripts/setup.sh
  ```

* **Windows (PowerShell en administrateur)** :
  ```powershell
  .\scripts\setup.ps1
  ```

### 4. Télécharger les dépendances

Une fois le script terminé avec succès, téléchargez les paquets Flutter du projet :

```bash
task get
```

---

## 🛠️ Commandes Usuelles (`Taskfile`)

Toutes les actions de développement s'exécutent via `task` depuis la racine du projet :

| Commande | Action |
| :--- | :--- |
| `task setup` | Relance la vérification et l'installation des prérequis système |
| `task get` | Télécharge les dépendances Dart/Flutter (`flutter pub get`) |
| `task run` | Lance l'application en mode développement |
| `task clean` | Nettoie les fichiers de build et réinstalle les dépendances |
| `task firebase-config` | Régénère `lib/firebase_options.dart` (Administrateur du projet) |

---

## 📋 Récapitulatif des Outils Requis

* **Git**
* **Flutter SDK** (Channel stable)
* **Task** (Go-Task)
* **Google Chrome**
* **Android Studio** (avec SDK Android & Émulateur)
* **Xcode** (macOS uniquement)

---

## 📁 Structure du Projet

```text
gontran/
├── lib/
│   ├── firebase_options.dart   # Configuration Firebase (générée)
│   └── main.dart               # Point d'entrée de l'application
├── scripts/
│   ├── setup.sh                # Script d'installation Linux/macOS
│   └── setup.ps1               # Script d'installation Windows
├── Taskfile.yml                # Définition des tâches automatisées
└── README.md
```