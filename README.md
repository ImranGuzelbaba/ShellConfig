# ShellConfig

Ce repo contient plein d'alias, fonctions et scripts que j'utilise et qui sont dans les fichiers config des shells (`ZSH` et `PowerShell`) ou fichiers exécutables à part.\
Ils ont été écrit par moi mais aussi aidé et généré par IA (pas de **AI Slop**, je regarde le code, je test bien et je corrige !).

---
## Exemples de Fonctionnalités

* **fonction youbest** : wrapper de `yt-dlp` pour télécharger les vidéos avec la meilleure qualité possible, avec des métadonnées en plus.
* **fonction 7zip** : fonction utilisant l'exécutable `7z` (du paquet `7-Zip`) avec le niveau de compression le plus élevé possible.
* **fonction man** : fonction permettant d'afficher de l'aide pour les commandes `PowerShell`, qui utilise la fonction `help` prédéfinie, le Cmdlet `Get-Help` et le programme `tldr`.

---
## Prérequis
- Avoir [`PowerShell`](https://github.com/PowerShell/PowerShell) version 7+
- Avoir [`ZSH`](https://www.zsh.org/) [(Aide d'installation)](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
- Avoir [`Termux`](https://termux.dev/en/) pour avoir un terminal sur Android

Certaines fonctions et alias nécessitent des outils tiers.\
Sur Linux, pour installer les outils, on peut utiliser simplement le gestionnaire de paquet (`apt`, `pacman`, `dnf`, ...), mais aussi sur Windows via `WinGet`.
Rechercher d'abord dans les dépôts via le gestionanire de paquet est très recommandé:
### Arch based (CachyOS, Manjaro, ...)
##### Recherche
   ```bash
   pacman -Ss [PAQUET]
   ```
##### Installation
   ```bash
   pacman -S [PAQUET]
   ```

### Debian based (Linux Mint, Kali, Ubuntu, ...)
##### Recherche
   ```bash
   apt search [PAQUET]
   ```

##### Installation
   ```bash
   apt install [PAQUET]
   ```

### RedHat based (Fedora, Bazzite, ...)
###### Recherche
   ```bash
   dnf search [PAQUET]
   ```
   
###### Installation
   ```bash
   dnf install [PAQUET]
   ```

### Android (Termux)
##### Recherche
   ```bash
   pkg search [PAQUET]
   # OU
   pkg se [PAQUET]
   ```
##### Installation
   ```bash
   pkg install [PAQUET]
   # OU
   pkg i [PAQUET]
   ```

### Windows (not based)
##### Recherche
   ```powershell
   winget search [ID_PAQUET]
   ```

##### Installation
   ```powershell
   winget install [ID_PAQUET]
   ```

### Outils
Outils tiers à installer si besoin pour pouvoir utiliser les shells et les fichiers de configurations:
- [7-zip](https://www.7-zip.org/) - *Compression et Archivage des fichiers*
- [adb](https://developer.android.com/tools/adb?hl=fr) (via [SCRCPY](https://scrcpy.org/) pour Windows) - *Accès au Téléphone via Ordi*
- [bat](https://github.com/sharkdp/bat) - *Meilleure version de `cat`*
- [eza](https://github.com/eza-community/eza) - *Meilleure version de `ls`*
- [fd](https://github.com/sharkdp/fd) - *Meilleure version de `find`*
- [GIT](https://git-scm.com/) - *Clonage des dépôts (+ Outils Linux pour Windows)*
- [gsudo](https://github.com/gerardog/gsudo) - *Équivalent de `sudo` mais pour Windows*
- [msedit](https://github.com/microsoft/edit) - *Éditeur de texte simple d'utilisation (Comme Notepad + Couleurs)*
- [Oh-My-Posh](https://ohmyposh.dev/) - *Prompt pour les shells*
- [Oh-My-Zsh](https://ohmyz.sh/) - *Plugins et Prompt pour ZSH*
- [SSHFS](https://github.com/libfuse/sshfs) (Pour Windows [SSHFS-Win](https://github.com/winfsp/sshfs-win)) - *Accès aux Fichiers de Téléphone via Ordi*
- [Sysinternals Suite](https://learn.microsoft.com/fr-fr/sysinternals/downloads/sysinternals-suite) - *Ensemble d'outils pour Windows*
- [tldr](https://tldr.sh) - *Équivalent de `man` mais court et compréhensible*
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - *Téléchargeur de vidéo YouTube et d'autres sites*
- [zoxide](https://github.com/ajeetdsouza/zoxide) - *Meilleure version de `cd`*

---
## Installation

Cloner le dépôt (préférablement dans le répertoire personnel `~`) :
   ```bash
   git clone https://github.com/ImranGuzelbaba/ShellConfig.git
   ```

### Pour ZSH (Linux/Android)

1. Intégrer le contenu de `~/ShellConfig/.zshrc` dans `~/.zshrc`:
   ```bash
   cat ~/ShellConfig/.zshrc >> ~/.zshrc
   ```

2. Appliquer le fichier de configuration:
   ```bash
   source ~/.zshrc
   ```

### Pour PowerShell (Windows)

1. Autoriser l'exécution des scripts (il faut faire en étant **admin**):
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. Créer le dossier pour `$PROFILE` s'il n'existe pas:
   ```powershell
   mkdir $HOME\Documents\PowerShell
   ```

3. Intégrer le contenu de `$HOME\ShellConfig\PROFILE.ps1` dans `$PROFILE`:
   ```powershell
   Get-Content $HOME\ShellConfig\PROFILE.ps1 | Add-Content $PROFILE
   ```

4. Appliquer le fichier de configuration:
   ```powershell
   .$PROFILE
   ```

---
## Modification des configurations
J'ai fait en sorte de mettre entre crochet les variables qu'on peut changer (`var=[VALEUR]`). En ajoutant le contenu des fichiers, il faut bien regarder et modifier ce qu'il faut.
