# ShellConfig

Ce repo contient plein d'alias, fonctions et scripts que j'utilise et qui sont dans les fichiers config des shells (`ZSH` et `PowerShell`) ou fichiers exécutables à part.\
Ils ont été écrits par moi mais aussi aidés et générés par IA (pas de **AI Slop**, je regarde le code, je teste bien et je corrige !).

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
Sur Linux, pour installer les outils, on peut utiliser simplement le gestionnaire de paquets (`apt`, `pacman`, `dnf`, ...), mais aussi sur Windows via `WinGet`.
Rechercher d'abord dans les dépôts via le gestionnaire de paquet est très recommandé:
### Arch based (CachyOS, Manjaro, ...)
##### Recherche
   ```bash
   pacman -Ss [PAQUET]
   ```
##### Installation
   ```bash
   sudo pacman -S [PAQUET]
   ```

### Debian based (Linux Mint, Kali, Ubuntu, ...)
##### Recherche
   ```bash
   apt search [PAQUET]
   ```

##### Installation
   ```bash
   sudo apt install [PAQUET]
   ```

### RedHat based (Fedora, Bazzite, ...)
###### Recherche
   ```bash
   dnf search [PAQUET]
   ```
   
###### Installation
   ```bash
   sudo dnf install [PAQUET]
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
- [7-zip](https://www.7-zip.org/) - *Compression et Archivage des fichiers (Moderne)*
- [adb](https://developer.android.com/tools/adb?hl=fr) (via [SCRCPY](https://scrcpy.org/) pour Windows) - *Accès au Téléphone via Ordi*
- [bat](https://github.com/sharkdp/bat) - *Meilleure version de `cat`*
- [eza](https://github.com/eza-community/eza) - *Meilleure version de `ls`*
- [fd](https://github.com/sharkdp/fd) - *Meilleure version de `find`*
- [GIT](https://git-scm.com/) - *Clonage des dépôts (+ Outils Linux pour Windows)*
- [gsudo](https://github.com/gerardog/gsudo) - *Équivalent de `sudo` mais pour Windows*
- [msedit](https://github.com/microsoft/edit) - *Éditeur de texte simple d'utilisation (Comme Notepad + Couleurs)*
- [Oh-My-Posh](https://ohmyposh.dev/) - *Prompt pour les shells*
- [Oh-My-Zsh](https://ohmyz.sh/) - *Plugins et Prompt pour ZSH*
- [Python 3](https://www.python.org/) - *Language de programmation multiplateformes*
- [ripgrep](https://github.com/burntsushi/ripgrep) - *Meilleure version de `grep`*
- [SSHFS](https://github.com/libfuse/sshfs) (Pour Windows [SSHFS-Win](https://github.com/winfsp/sshfs-win)) - *Accès aux Fichiers de Téléphone via Ordi*
- [Sysinternals Suite](https://learn.microsoft.com/fr-fr/sysinternals/downloads/sysinternals-suite) - *Ensemble d'outils pour Windows*
- [tldr](https://tldr.sh) - *Équivalent de `man` mais court et compréhensible*
- [xz](https://github.com/tukaani-project/xz) - *Compression et Archivage des fichiers*
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - *Téléchargeur de vidéo YouTube et d'autres sites*
- [zoxide](https://github.com/ajeetdsouza/zoxide) - *Meilleure version de `cd`*

---
## Test
Mieux vaut tester les fichiers de configuration du repo avant de les ajouter dans les fichiers du PC.
On peut faire en sorte qu'on puisse exécuter le shell avec le fichier de config du repo à la place du fichier habituel.

Cloner le dépôt :
   ```bash
   git clone https://github.com/ImranGuzelbaba/ShellConfig.git ~/ShellConfig
   ```

#### Pour ZSH (Linux/Android)
On met la variable `ZDOTDIR` avec comme valeur le chemin du repo où il y a le fichier `.zshrc` puis on exécute `zsh`:
   ```bash
   ZDOTDIR=~/ShellConfig zsh
   ```

Lorsqu'on a fini de tester, on écrit `exit` ou on fait `[CTRL]+D`.

#### Pour PowerShell (Windows)
On exécute `pwsh` avec comme arguments :
- `-NoProfile` : Exécution sans chargement de configuration `$PROFILE`
- `-NoExit` : Exécution sans la fin de programme (intéractif)
- `-Command` : Exécution de commande (ici sourcer le fichier de config)

   ```powershell
   pwsh -NoProfile -NoExit -Command ". $HOME\ShellConfig\PROFILE.ps1"
   ```
Lorsqu'on a fini de tester, on écrit `exit`.

---
## Installation

Cloner le dépôt (préférablement dans le répertoire personnel `~`) :
   ```bash
   git clone https://github.com/ImranGuzelbaba/ShellConfig.git ~/ShellConfig
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
## Utilisation des scripts (Linux)

Pour pouvoir exécuter facilement les scripts du dossier `scripts/Linux` (comme `benchmark_perf.sh`) depuis n'importe où sans saisir le chemin complet :

1. Créer un dossier local pour les exécutables personnels s'il n'existe pas encore :
   ```bash
   mkdir -p ~/.local/bin
   ```

2. Créer un lien symbolique (symlink) du script vers ce dossier. Cela permet de garder le script à jour automatiquement après chaque `git pull` :
   ```bash
   ln -s ~/ShellConfig/scripts/Linux/benchmark_perf.sh ~/.local/bin/benchmark_perf
   # OU, créer un lien pour tous les scripts du dossier d'un seul coup
   ln -s ~/ShellConfig/scripts/Linux/* ~/.local/bin/
   ```
   *(Note : Il est possible de copier le fichier à la place du lien symbolique avec `cp ~/ShellConfig/scripts/Linux/benchmark_perf.sh ~/.local/bin/benchmark_perf`, mais il faudra le recopier à chaque `git pull`. Cela peut toutefois être utile si on souhaite modifier localement le script sans que `git` n'écrase nos modifications).*


3. S'assurer que le script d'origine est exécutable :
   ```bash
   chmod +x ~/ShellConfig/scripts/Linux/benchmark_perf.sh
   ```

4. Ajouter le dossier `~/.local/bin` à la variable d'environnement `PATH` dans le fichier `~/.zshrc` (ou `~/.bashrc`) :
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

5. Appliquer les changements du shell :
   ```bash
   source ~/.zshrc
   ```

On peut alors lancer le benchmark simplement avec la commande :
```bash
benchmark_perf
```

---
## Modification des configurations
C'est possible et même recommandé de modifier certaines choses, il peut y avoir des parties entre crochets (comme les valeurs des variables) qu'on peut changer (`var=[VALEUR]`).\
En ajoutant le contenu des fichiers, il faut bien regarder et modifier ce qu'il faut.
