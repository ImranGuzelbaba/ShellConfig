# ==============================================================================
# Configuration ZSH - ShellConfig (.zshrc)
# ==============================================================================
# Fichier de configuration Zsh pour Linux / Android (Termux).
# Contient les variables d'environnement, options, fonctions et alias des outils.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Variables d'environnement & Système
# ------------------------------------------------------------------------------

# Éditeur de texte par défaut (utilisé par Git, systemd, etc.)
# Peut être remplacé par nano, micro, vim ou code selon vos préférences
export EDITOR="msedit"
export SYSTEMD_EDITOR="$EDITOR"

# Afficheur page par page (Pager) : utilise bat si disponible
if (( $+commands[bat] )); then
    export PAGER="bat -p --color=always"
else
    export PAGER="less -R"
fi

# Navigateur web par défaut
export BROWSER="${BROWSER:-google-chrome-stable}"

# Dossiers temporaires
export TEMP="/tmp"
export TMP="$TEMP"
export temp="$TEMP"
export tmp="$TEMP"

# Optimisation du PATH : suppression automatique des doublons
typeset -U path fpath
path=(
    "$HOME/.local/bin"
    $path
)
export PATH

# ------------------------------------------------------------------------------
# 2. Variables de chemins utiles (Dossiers personnels)
# ------------------------------------------------------------------------------
down="$HOME/Downloads"
music="$HOME/Music"
vid="$HOME/Videos"
pic="$HOME/Pictures"
doc="$HOME/Documents"
config="$HOME/.config"

# Sous-dossiers spécifiques pour les médias téléchargés
ytdlp="$vid/yt-dlp"
ytb="$ytdlp"

# ------------------------------------------------------------------------------
# 3. Autoloads & Gestionnaire de complétion / Thèmes
# ------------------------------------------------------------------------------
# Intégration Oh My Zsh (si installé sur le système)
if [ -d "$HOME/.oh-my-zsh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    plugins=(git z fzf extract zsh-completions zsh-syntax-highlighting zsh-autosuggestions)
    [ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
else
    # Initialisation standard de la complétion et des couleurs Zsh
    autoload -Uz compinit colors
    compinit
    colors
fi

# Initialisation d'Oh-My-Posh (si installé)
if (( $+commands[oh-my-posh] )); then
    if [ -f "$HOME/.config/omp/themes/kali.omp.json" ]; then
        eval "$(oh-my-posh init zsh --config $HOME/.config/omp/themes/kali.omp.json)"
    else
        eval "$(oh-my-posh init zsh)"
    fi
fi

# Initialisation de zoxide (remplacement intelligent de cd)
if (( $+commands[zoxide] )); then
    eval "$(zoxide init --cmd cd zsh)"
fi

# ------------------------------------------------------------------------------
# 4. Options et comportement du Shell (Zsh Options)
# ------------------------------------------------------------------------------
# Empêche l'écrasement accidentel de fichiers avec '>' (utiliser '>!' pour forcer)
setopt NO_CLOBBER

# Correspondance de motifs étendue (Extended Globbing)
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB       # Insensible à la casse lors de l'autocomplétion
setopt NUMERIC_GLOB_SORT  # Tri numérique des fichiers (file1, file2, file10)

# Retourne le code d'erreur de la commande ayant échoué dans un pipeline
setopt PIPEFAIL

# Proposition automatique de correction en cas de faute de frappe
setopt correct_all

# Configuration de l'historique
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ------------------------------------------------------------------------------
# 5. Raccourcis clavier (Keybindings)
# ------------------------------------------------------------------------------
bindkey -e  # Mode Emacs standard

# Déplacement début / fin de ligne
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Suppression mot par mot (Alt + Retour arrière) et ligne entière
bindkey "^[^?" backward-kill-word
bindkey "^[\e" kill-whole-line

# ------------------------------------------------------------------------------
# 6. Fonctions utilitaires
# ------------------------------------------------------------------------------

# 7zip : compression d'archives au format 7z avec le taux maximal (LZMA2 Ultra)
7zip() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: 7zip <archive.7z> <fichiers...>"
        return 1
    fi
    local archive="$1"; shift
    7z a -t7z -m0=lzma2 -mx=9 -mmt=on -md=1024m -ms=on -mfb=273 -mmemuse=p90 "$archive" "$@"
}

# txz : création rapide d'une archive tar.xz compressée au maximum
txz() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: txz <archive.tar.xz> <fichiers...>"
        return 1
    fi
    local archive="$1"; shift
    tar -cf - "$@" | xz -9e -T0 >| "$archive"
}

# ------------------------------------------------------------------------------
# 7. Alias des Outils Modernes (Listés dans le README)
# ------------------------------------------------------------------------------

# eza (remplaçant moderne et coloré de ls)
if (( $+commands[eza] )); then
    alias l="eza -ahl --icons --color=always"
    alias ll="eza -al --icons --color=always"
    alias ls="eza -a --icons --color=always"
    alias la="eza -aF --icons --color=always"
    alias ladir="la --only-dirs --group-directories-first"
    alias lsdir="ls -F --only-dirs --group-directories-first"
    alias tree="eza --tree --icons"
else
    alias l="ls -lah"
    alias ll="ls -lh"
    alias la="ls -A"
fi

# bat (remplaçant moderne de cat avec coloration syntaxique)
if (( $+commands[bat] )); then
    alias cat="bat -p"
fi

# fd (remplaçant rapide de find)
if (( $+commands[fd] )); then
    alias fd="fd -u -g"
fi

# ripgrep (remplaçant rapide de grep)
alias grep="grep -i -E --color=auto"
if (( $+commands[rg] )); then
    alias ripgrep="rg -i"
fi
alias grepsearch="grep -Hn"

# msedit (éditeur de texte simple et moderne)
alias edit="msedit"

# tldr (aide résumée et pratique pour la ligne de commande)
if (( $+commands[tldr] )); then
    alias help="tldr"
fi

# yt-dlp (téléchargement haute fidélité avec miniatures et métadonnées)
alias youbest='yt-dlp -o "$ytb/%(title)s - %(uploader)s.%(ext)s" -f "bv*+ba/best" --merge-output-format mp4 --embed-thumbnail --convert-thumbnails jpg --add-metadata'
alias ylbest="youbest --break-on-existing --download-archive $ytb/history.txt"
alias yybest='yt-dlp -o "$ytb/%(title)s - %(id)s - %(uploader)s.%(ext)s" -f "bv*+ba/best" --merge-output-format mp4 --embed-thumbnail --convert-thumbnails jpg --add-metadata'
alias yflac='yt-dlp -o "$music/%(title)s - %(uploader)s.%(ext)s" -f "bestaudio" --extract-audio --audio-format flac --audio-quality 0 --no-embed-thumbnail --add-metadata'

# Outils d'archivage (7-Zip & xz & tar)
alias 7list="7z l"
alias 7verify="7z t"
alias un7="7z x"
alias xzverify="xz -tv"
alias tarcomb="tar -cvf"    #Archive sans compression
alias untar="tar -xvf"
alias tarlist="tar -tvf"

# ------------------------------------------------------------------------------
# 8. Alias Système, Navigation et Sécurité
# ------------------------------------------------------------------------------

# Navigation rapide dans l'arborescence des dossiers
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cd..="cd .."
alias home="cd ~"

# Raccourcis de commandes fréquentes
alias c="clear"
alias cls="clear"
alias ex="exit"
alias please="sudo"

# Sécurité des opérations sur fichiers (demande de confirmation pour éviter les accidents)
alias cp="nocorrect cp -i"
alias mv="nocorrect mv -i"
alias rm="nocorrect rm -I"

# Git (raccourcis quotidiens)
alias gl="git pull"
alias gs="git status"
alias ga="git add"
alias gd="git diff"
alias gc="git commit"
alias gp="git push"
alias gr="git restore"

# Gestion et édition rapide de la configuration Zsh
alias confzsh="$EDITOR ~/.zshrc"
alias editzsh="$EDITOR ~/.zshrc"
alias applyzsh="source ~/.zshrc"
alias apply="applyzsh"
