<### Variables d'environnement ###>
# Certaines programme du monde de Linux peuvent avoir besoin de ces variables
$env:TERM = "xterm-256color"
$env:SHELL = "/c/bin/pwsh/pwsh.exe" # Faite des dossiers "C:\bin\pwsh", puis faire 'New-Item -ItemType SymbolicLink -Path C:\bin\pwsh -Target "C:\Program Files\PowerShell\7\"' ou Enlever cette ligne

# Programme pour voir page par page
$env:PAGER = "bat.exe -p"

<### Comportement de PowerShell avec le clavier ###>
# Sortie de PowerShell (EXIT) avec [CTRL]+D
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

# Historique de commande sur un commande partiellement écrite avec [CTRL]+[FLECHE]
# Exemple: winget in[[CTRL]+[FLECHE HAUT]] -> winget install Microsoft.Edit
Set-PSReadLineKeyHandler -Key Ctrl+DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+UpArrow -Function HistorySearchBackward

# Suppression mot par mot avec [ALT]+[RETOUR|SUPPRIMER]
# Exemple: winget install Microsoft.Edit[[CTRL]+[RETOUR]] -> winget install Microsoft.
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+Delete -Function KillWord

# Proposition de complétion complète avec [CTRL]+[ESPACE]
# Exemple: cat C:\Windows\[[CTRL]+[ESPACE]] -> cat {CHOIX: Boot Media System32 ...}
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete

# Ajout du dernier argument des commandes précédentes avec [ALT|CTRL]+!|:
# Exemple: winget show Microsoft.Edit -> Résultat de la commande
# winget install [[ALT]+!] -> winget install Microsoft.Edit
Set-PSReadLineKeyHandler -Key Alt+! -Function YankLastArg
Set-PSReadLineKeyHandler -Key Ctrl+! -Function YankLastArg
Set-PSReadLineKeyHandler -Key Alt+: -Function YankLastArg
Set-PSReadLineKeyHandler -Key Ctrl+: -Function YankLastArg

<### Variables Pour PowerShell Directement ###>
# Nombre de commandes max dans l'historiques
$MaximumHistoryCount = 32767

# Chemin de l'historique
$hist = [Microsoft.PowerShell.PSConsoleReadLine]::GetOptions().HistorySavePath #"$HOME\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

<### Variables de Chemins ###>
# Dossier présent dans $HOME
# $HOME = ~ = "C:\Users\[NOM]"
$appdata = "$HOME\AppData"
$app = "$appdata"
$appdatalocal = "$env:LOCALAPPDATA"
$appdataroaming = "$env:APPDATA"
$download = "$HOME\Downloads"
$down = "$download"
$documents = "$HOME\Documents"
$doc = "$documents"
$favorites = "$HOME\Favorites"
$fav = "$favorites"
$pictures = "$HOME\Pictures"
$pic = "$pictures"
$videos = "$HOME\Videos"
$vid = "$videos"

# Autres dossiers
$programfiles = "$env:ProgramFiles"             # "C:\Program Files\"
$prog = "$programfiles"
$programfiles86 = "${env:ProgramFiles(x86)}"    # "C:\Program Files (x86)"
$prog86 = "$programfiles86"
$tmp = "$env:TEMP"                              # "$HOME\AppData\Local\Temp"

<### Chargement des scripts additionnels ###>
# Chargement automatique des fonctions de batterie si le script existe
$PowerAlertPath = "$HOME\ShellConfig\scripts\Windows\PowerAlert_PROFILE.ps1"
if (Test-Path $PowerAlertPath) {
    . $PowerAlertPath
    # Start-BatteryMonitor # Décommenter pour lancer la surveillance automatiquement à l'ouverture de PowerShell
}