# Description des Scripts Windows

Ce fichier documente le rôle, les commandes et l'utilisation de chacun des scripts présents dans le dossier `scripts/Windows`.

---

## 1. PowerAlert.ps1

### Description
Script autonome de test de notification. Il émet immédiatement trois bips sonores sur le haut-parleur système et déclenche une notification Toast Windows en français indiquant que l'alimentation secteur est débranchée.

### Utilisation
Peut être lancé directement à partir du terminal :
```powershell
& "$HOME\ShellConfig\scripts\Windows\PowerAlert.ps1"
```

---

## 2. PowerAlert_PROFILE.ps1

### Description
Ce script définit des fonctions pour surveiller en temps réel la perte d'alimentation secteur (AC) sur un ordinateur portable via les événements CIM/WMI de Windows.

### Fonctions incluses

#### `Start-BatteryMonitor`
* **Description** : Démarre un écouteur d'événements en arrière-plan qui surveille l'état de la batterie (`Win32_Battery`). Dès que l'ordinateur passe sur batterie (débranchement du secteur), le script joue 3 bips et affiche une alerte Toast invitant à rebrancher l'appareil.
* **Lancement** :
  ```powershell
  Start-BatteryMonitor
  ```

#### `Stop-BatteryMonitor`
* **Description** : Arrête proprement l'écouteur d'événements en arrière-plan et nettoie les tâches PowerShell associées.
* **Lancement** :
  ```powershell
  Stop-BatteryMonitor
  ```
