# Scripts Windows (PowerShell)

Ce dossier contient divers scripts et fonctions écrits spécifiquement pour l'environnement Windows. Ils permettent d'automatiser des tâches, de surveiller le système ou d'ajouter des fonctionnalités pratiques à PowerShell.

---
## Présentation
Ces outils sont conçus pour être importés dans votre session PowerShell (via `$PROFILE`) ou exécutés de manière autonome. À mesure que le dépôt évolue, d'autres scripts y seront ajoutés pour couvrir différents aspects du système Windows.

Pour connaître le fonctionnement détaillé de chaque script individuel, veuillez consulter la documentation dédiée : **[SCRIPTS.md](file:///home/imran/ShellConfig/scripts/Windows/SCRIPTS.md)**.

---
## Prérequis

Certains scripts nécessitent l'installation de modules tiers disponibles sur la galerie PowerShell (PSGallery).

### Comment installer des modules PowerShell
Pour installer un module sur Windows, ouvrez une console PowerShell (en administrateur si vous souhaitez l'installer globalement, ou avec l'option `-Scope CurrentUser` pour votre utilisateur uniquement) et lancez :
```powershell
Install-Module -Name [NOM_DU_MODULE] -Scope CurrentUser
```

### Outils et Modules requis
Voici la liste des modules tiers à installer selon les scripts que vous utilisez :
- **[BurntToast](https://github.com/Windos/BurntToast)** - *Création de notifications Toast natives Windows (utilisé par le moniteur de batterie)*

---
## Test

Il est recommandé de tester les scripts dans une session isolée avant de les ajouter définitivement à votre configuration.

Pour tester les scripts sans charger ni modifier le `$PROFILE` de votre machine :

1. Ouvrez une console PowerShell sans profils :
   ```powershell
   pwsh -NoProfile -NoExit
   ```

2. Chargez (sourcez) le script spécifique que vous souhaitez tester (exemple avec le moniteur de batterie) :
   ```powershell
   . "$HOME\ShellConfig\scripts\Windows\PowerAlert_PROFILE.ps1"
   ```

3. Exécutez la commande ou fonction à tester (exemple) :
   ```powershell
   Start-BatteryMonitor
   ```
   *(Vous pouvez aussi exécuter directement `./PowerAlert.ps1` pour déclencher une alerte instantanée).*

4. Tapez `exit` pour quitter la session de test.

---
## Installation permanente

Si vous utilisez le profil de ce dépôt ([PROFILE.ps1](file:///home/imran/ShellConfig/PROFILE.ps1)), les scripts de ce dossier seront automatiquement détectés et importés lors du démarrage de PowerShell.

### Activation automatique d'un service/script au démarrage
Pour qu'une fonction spécifique (comme le moniteur de batterie) se lance automatiquement à l'ouverture de votre terminal :

1. Ouvrez le fichier **`PROFILE.ps1`** à la racine du dépôt (ou dans votre dossier `$PROFILE` utilisateur).
2. Décommentez la ligne d'activation correspondante à la fin du fichier :
   ```powershell
   # Avant :
   # Start-BatteryMonitor

   # Après :
   Start-BatteryMonitor
   ```
