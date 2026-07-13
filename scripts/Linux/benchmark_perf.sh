#!/usr/bin/env bash

# Configurer la locale à C pour un formatage et un parsing standard (ex. séparateur décimal point pour le temps)
export LC_ALL=C

# Vérifier si python3 est installé
if ! command -v python3 >/dev/null 2>&1; then
    echo "Erreur : python3 est requis pour exécuter ce script de benchmark." >&2
    exit 1
fi

# Dossier d'enregistrement des résultats de performance
PERF_DIR="$HOME/perf_python"
mkdir -p "$PERF_DIR"

# Configurer les raccourcis clavier de bash readline pour le mode pavé numérique d'application (correspondant aux binds zsh de l'utilisateur dans zellij/kmscon)
if command -v bind >/dev/null 2>&1; then
    bind '"\eOp":"0"' 2>/dev/null
    bind '"\eOq":"1"' 2>/dev/null
    bind '"\eOr":"2"' 2>/dev/null
    bind '"\eOs":"3"' 2>/dev/null
    bind '"\eOt":"4"' 2>/dev/null
    bind '"\eOu":"5"' 2>/dev/null
    bind '"\eOv":"6"' 2>/dev/null
    bind '"\eOw":"7"' 2>/dev/null
    bind '"\eOx":"8"' 2>/dev/null
    bind '"\eOy":"9"' 2>/dev/null
    bind '"\eOn":"."' 2>/dev/null
    bind '"\eOo":"*"' 2>/dev/null
    bind '"\eOj":"/"' 2>/dev/null
    bind '"\eOm":"-"' 2>/dev/null
    bind '"\eOk":"+"' 2>/dev/null
    bind '"\eOM":"\n"' 2>/dev/null
fi

# Valeurs par défaut
NUM_RUNS=10
RANGE_EXPR="1 * 10**8"
NO_INTERACTIVE_FLAG=false
INTERACTIVE_FLAG=false
RUN_PASSED=false
RANGE_PASSED=false
SKIP_POWER_FLAG=false
QUIET_FLAG=false
CLEAN_FLAG=false
KEEP_TESTS=2
TEST_REQUESTED=false

# Fonctions d'affichage conditionnel pour le mode silencieux (-q/--quiet)
log_print() {
    if [ "$QUIET_FLAG" = false ]; then
        echo -e "$@"
    fi
}

log_print_n() {
    if [ "$QUIET_FLAG" = false ]; then
        echo -n "$@"
    fi
}

# Fonction d'affichage de l'aide
show_help() {
    # Définition des codes couleur ANSI
    local bold="\e[1m"
    local green="\e[32m"
    local yellow="\e[33m"
    local cyan="\e[36m"
    local reset="\e[0m"
    local custom="\e[93m"

    echo -e "${bold}NOM${reset}"
    echo -e "    ${custom}benchmark_perf.sh V1.1${reset} - Script de test comparatif de performance pour Python3"
    echo -e ""
    echo -e "${bold}SYNOPSIS${reset}"
    echo -e "    ${green}./benchmark_perf.sh${reset} [${yellow}OPTIONS${reset}]"
    echo -e ""
    echo -e "${bold}DESCRIPTION${reset}"
    echo -e "    Ce script exécute un calcul intensif en Python (somme de carrés sur une plage donnée)"
    echo -e "    et compare les temps d'exécution sous trois environnements différents :"
    echo -e "      - Python standard (sans optimisation additionnelle)"
    echo -e "      - game-performance (si disponible sur le système)"
    echo -e "      - gamemoderun (si disponible sur le système)"
    echo -e "    Le script tente également d'activer le profil d'alimentation 'Performance'"
    echo -e "    durant le test et le restaure à la fin."
    echo -e "    Les rapports détaillés sont enregistrés dans : ${cyan}$PERF_DIR/${reset}"
    echo -e ""
    echo -e "${bold}OPTIONS${reset}"
    echo -e "    ${green}-h${reset}, ${green}--help${reset}"
    echo -e "        Affiche ce message d'aide et quitte."
    echo -e ""
    echo -e "    ${green}-n${reset}, ${green}--no-interaction${reset}"
    echo -e "        Désactive toute invite interactive. Le script s'exécute directement en"
    echo -e "        utilisant les valeurs par défaut ou celles fournies."
    echo -e ""
    echo -e "    ${green}-i${reset}, ${green}--interactive${reset}"
    echo -e "        Force la demande interactive des valeurs manquantes ou déjà fournies."
    echo -e "        Les valeurs fournies par -r et -p seront proposées comme valeurs par défaut."
    echo -e ""
    echo -e "    ${green}-s${reset}, ${green}--skip-power${reset}"
    echo -e "        Désactive la gestion automatique et le changement du profil énergétique."
    echo -e ""
    echo -e "    ${green}-q${reset}, ${green}--quiet${reset}"
    echo -e "        Mode silencieux. Masque les messages de progression et n'affiche"
    echo -e "        que le tableau de résultats final dans le terminal."
    echo -e ""
    echo -e "    ${green}-c${reset} ${cyan}[int]${reset}, ${green}--clean${reset} ${cyan}[int]${reset}"
    echo -e "        Nettoie le dossier des rapports pour ne conserver que les N derniers"
    echo -e "        tests (runs). Par défaut, conserve les ${yellow}2${reset} derniers tests."
    echo -e "        Affiche en détail les fichiers supprimés et conservés."
    echo -e ""
    echo -e "    ${green}-r${reset} ${cyan}[int]${reset}, ${green}--run${reset} ${cyan}[int]${reset}"
    echo -e "        Spécifie le nombre d'exécutions (runs) par configuration."
    echo -e "        (Valeur par défaut : ${yellow}$NUM_RUNS${reset})"
    echo -e ""
    echo -e "    ${green}-p${reset} ${cyan}[string]${reset}, ${green}--range${reset} ${cyan}[string]${reset}"
    echo -e "        Spécifie l'expression de la plage de calcul évaluée par Python."
    echo -e "        (Valeur par défaut : ${yellow}\"$RANGE_EXPR\"${reset})"
    echo -e ""
    echo -e "${bold}EXEMPLES DE COMMANDES${reset}"
    echo -e "    ${green}./benchmark_perf.sh${reset}"
    echo -e "        Exécution interactive complète (demande le nombre de runs et la plage)."
    echo -e ""
    echo -e "    ${green}./benchmark_perf.sh${reset} ${green}-r${reset} ${cyan}5${reset}"
    echo -e "        Exécution semi-interactive : ne demande que la plage (runs fixé à 5)."
    echo -e ""
    echo -e "    ${green}./benchmark_perf.sh${reset} ${green}-r${reset} ${cyan}5${reset} ${green}-p${reset} ${cyan}\"5 * 10**7\"${reset}"
    echo -e "        Exécution directe et automatique sans interaction (runs=5, plage=5*10**7)."
    echo -e ""
    echo -e "    ${green}./benchmark_perf.sh${reset} ${green}-r${reset} ${cyan}5${reset} ${green}-p${reset} ${cyan}\"5 * 10**7\"${reset} ${green}-i${reset}"
    echo -e "        Force l'invite interactive en proposant 5 et \"5 * 10**7\" comme valeurs par défaut."
    echo -e ""
    echo -e "    ${green}./benchmark_perf.sh${reset} ${green}-c${reset} ${cyan}3${reset}"
    echo -e "        Nettoie le dossier pour garder les 3 derniers tests, puis lance le benchmark."
    echo ""
    exit 0
}

# Analyse des arguments de la ligne de commande
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -n|--no-interaction)
            NO_INTERACTIVE_FLAG=true
            TEST_REQUESTED=true
            shift
            ;;
        -i|--interactive)
            INTERACTIVE_FLAG=true
            TEST_REQUESTED=true
            shift
            ;;
        -s|--skip-power)
            SKIP_POWER_FLAG=true
            shift
            ;;
        -q|--quiet)
            QUIET_FLAG=true
            shift
            ;;
        -c|--clean)
            CLEAN_FLAG=true
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                KEEP_TESTS="$2"
                shift 2
            else
                KEEP_TESTS=2
                shift 1
            fi
            ;;
        -r|--run)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                NUM_RUNS="$2"
                RUN_PASSED=true
                TEST_REQUESTED=true
                shift 2
            else
                echo -e "\e[31mErreur : L'option $1 nécessite un entier positif en paramètre.\e[0m" >&2
                exit 1
            fi
            ;;
        -p|--range)
            if [[ -n "$2" ]]; then
                RANGE_EXPR="$2"
                RANGE_PASSED=true
                TEST_REQUESTED=true
                shift 2
            else
                echo -e "\e[31mErreur : L'option $1 nécessite une expression de plage en paramètre.\e[0m" >&2
                exit 1
            fi
            ;;
        *)
            echo -e "\e[31mErreur : Option inconnue : $1\e[0m" >&2
            echo "Utilisez -h ou --help pour afficher l'aide." >&2
            exit 1
            ;;
    esac
done

# Fonction de nettoyage des rapports de performance anciens
clean_old_runs() {
    local keep_count="$1"

    # Sécurité 1 : S'assurer que PERF_DIR n'est pas vide, racine (/), ou le répertoire HOME lui-même
    if [ -z "$PERF_DIR" ] || [ "$PERF_DIR" = "/" ] || [ "$PERF_DIR" = "$HOME" ]; then
        echo "Erreur : Chemin de dossier de performance invalide ou dangereux ($PERF_DIR)." >&2
        exit 1
    fi

    # Sécurité 2 : S'assurer que le dossier existe et est bien un répertoire
    if [ ! -d "$PERF_DIR" ]; then
        log_print "[+] Le dossier $PERF_DIR n'existe pas. Rien à nettoyer."
        return
    fi

    # Récupérer la liste des fichiers triés par nom (donc par date chronologique)
    local all_files
    all_files=$(find "$PERF_DIR" -maxdepth 1 -type f \( -name "normal_python_perf-*.txt" -o -name "game-performance_python_perf-*.txt" -o -name "gamemoderun_python_perf-*.txt" \) | sort)

    if [ -z "$all_files" ]; then
        log_print "[+] Aucun rapport de performance trouvé dans $PERF_DIR pour le nettoyage."
        return
    fi

    # Extraire les horodatages uniques (format YYYY-MM-DD_HH-MM-SS)
    local timestamps
    timestamps=$(echo "$all_files" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}' | sort -u)

    if [ -z "$timestamps" ]; then
        log_print "[+] Aucun rapport avec un horodatage valide trouvé pour le nettoyage."
        return
    fi

    local total_timestamps
    total_timestamps=$(echo "$timestamps" | wc -l)

    # Si le nombre de tests existants est inférieur ou égal à la limite de conservation, on s'arrête
    if [ "$keep_count" -ge "$total_timestamps" ]; then
        log_print "[+] Nombre de tests existants ($total_timestamps) inférieur ou égal à la limite de conservation ($keep_count). Aucun fichier supprimé."
        log_print "Fichiers conservés :"
        echo "$all_files" | while read -r f; do
            if [ -n "$f" ]; then
                log_print "  - ${f/#$HOME/\~}"
            fi
        done
        return
    fi

    # Déterminer les horodatages à conserver (les N derniers)
    local keep_timestamps
    keep_timestamps=$(echo "$timestamps" | tail -n "$keep_count")

    # Classer les fichiers à supprimer et à garder
    local files_to_delete=()
    local files_to_keep=()

    while read -r f; do
        if [ -z "$f" ]; then continue; fi
        local matched=false
        while read -r ts; do
            if [ -z "$ts" ]; then continue; fi
            if [[ "$f" == *"$ts"* ]]; then
                matched=true
                break
            fi
        done <<< "$keep_timestamps"

        if [ "$matched" = true ]; then
            files_to_keep+=("$f")
        else
            files_to_delete+=("$f")
        fi
    done <<< "$all_files"

    # Suppression verbeuse avec Sécurité 3 (double-validation du chemin et du nom de fichier)
    local deleted_count=0
    if [ ${#files_to_delete[@]} -gt 0 ]; then
        for f in "${files_to_delete[@]}"; do
            if [[ "$f" == "$PERF_DIR"/normal_python_perf-*.txt ]] || \
               [[ "$f" == "$PERF_DIR"/game-performance_python_perf-*.txt ]] || \
               [[ "$f" == "$PERF_DIR"/gamemoderun_python_perf-*.txt ]]; then
                log_print "Suppression de ${f/#$HOME/\~}"
                rm -f "$f"
                deleted_count=$((deleted_count + 1))
            else
                log_print "[Avertissement] Fichier suspect ignoré par sécurité : ${f/#$HOME/\~}"
            fi
        done
    fi

    log_print "[+] Nombre de fichiers supprimés : $deleted_count"

    log_print "Fichiers conservés :"
    for f in "${files_to_keep[@]}"; do
        log_print "  - ${f/#$HOME/\~}"
    done
}

# Exécuter le nettoyage si demandé
if [ "$CLEAN_FLAG" = true ]; then
    clean_old_runs "$KEEP_TESTS"
fi

# Si le nettoyage a été fait et qu'aucun test n'a été explicitement demandé, on quitte ici
if [ "$CLEAN_FLAG" = true ] && [ "$TEST_REQUESTED" = false ]; then
    exit 0
fi

# Déterminer si on doit poser des questions interactives
ASK_RUNS=false
ASK_RANGE=false

if [ "$NO_INTERACTIVE_FLAG" = false ]; then
    if [ "$INTERACTIVE_FLAG" = true ] || [ "$RUN_PASSED" = false ]; then
        ASK_RUNS=true
    fi
    if [ "$INTERACTIVE_FLAG" = true ] || [ "$RANGE_PASSED" = false ]; then
        ASK_RANGE=true
    fi
fi

# Prompts utilisateur interactifs
if [ "$ASK_RUNS" = true ] || [ "$ASK_RANGE" = true ]; then
    # On n'affiche les invites de configuration que si on n'est pas en mode silencieux
    if [ "$QUIET_FLAG" = false ]; then
        echo "=================================================="
        echo "       Configuration du Benchmark de Performance  "
        echo "=================================================="
    fi

    # 1. Demande du nombre de runs
    if [ "$ASK_RUNS" = true ]; then
        if [ "$QUIET_FLAG" = false ]; then
            read -e -p "Entrez le nombre d'exécutions (runs) par configuration [par défaut : $NUM_RUNS] : " input_runs
            NUM_RUNS=${input_runs:-$NUM_RUNS}
        fi
    fi

    # Validation du nombre de runs
    if ! [[ "$NUM_RUNS" =~ ^[0-9]+$ ]] || [ "$NUM_RUNS" -le 0 ]; then
        log_print "[!] Nombre d'exécutions invalide. Retour à la valeur par défaut : 10"
        NUM_RUNS=10
    fi

    # 2. Demande de la plage Python
    if [ "$ASK_RANGE" = true ]; then
        if [ "$QUIET_FLAG" = false ]; then
            echo -e "\n[!] Note : Le temps d'exécution varie de façon linéaire O(N) avec la taille de la plage :"
            echo "    - 1 * 10**8 prend ~5s par run (~50s au total pour 10 runs)"
            echo "    - 5 * 10**8 prend ~25s par run (~250s au total pour 10 runs)"
            read -e -p "Entrez la taille de la plage Python (ex. 1 * 10**8) [par défaut : $RANGE_EXPR] : " input_range
            RANGE_EXPR=${input_range:-$RANGE_EXPR}
        fi
    fi

    # Validation de l'expression de plage Python
    if ! python3 -c "int($RANGE_EXPR)" >/dev/null 2>&1; then
        log_print "[!] Expression Python invalide. Retour à la valeur par défaut : 1 * 10**8"
        RANGE_EXPR="1 * 10**8"
    fi

    if [ "$QUIET_FLAG" = false ]; then
        echo -e "\n[+] Benchmark configuré : $NUM_RUNS runs par config avec la plage ($RANGE_EXPR)."
        echo "=================================================="
    fi
else
    # Validation pour le mode automatique / non-interactif
    if ! [[ "$NUM_RUNS" =~ ^[0-9]+$ ]] || [ "$NUM_RUNS" -le 0 ]; then
        log_print "[!] Nombre d'exécutions invalide. Retour à la valeur par défaut : 10"
        NUM_RUNS=10
    fi
    if ! python3 -c "int($RANGE_EXPR)" >/dev/null 2>&1; then
        log_print "[!] Expression Python invalide. Retour à la valeur par défaut : 1 * 10**8"
        RANGE_EXPR="1 * 10**8"
    fi

    if [ "$NO_INTERACTIVE_FLAG" = true ]; then
        log_print "[+] Mode non-interactif : Exécution avec $NUM_RUNS runs et la plage ($RANGE_EXPR)."
    else
        log_print "[+] Exécution automatique (arguments fournis) : $NUM_RUNS runs et la plage ($RANGE_EXPR)."
    fi
fi

# Détection de l'utilitaire de profil énergétique
USE_ASUSCTL=false
USE_POWERPROFILESCTL=false
ORIG_PROFILE=""

if [ "$SKIP_POWER_FLAG" = false ]; then
    if command -v asusctl >/dev/null 2>&1; then
        USE_ASUSCTL=true
        # Recherche flexible du profil d'alimentation pour s'adapter aux différentes versions d'asusctl
        ORIG_PROFILE=$(asusctl profile get | grep -i 'active profile' | awk -F' ' '{print $NF}')
        log_print "[+] asusctl trouvé. Profil d'origine : $ORIG_PROFILE"
    elif command -v powerprofilesctl >/dev/null 2>&1; then
        USE_POWERPROFILESCTL=true
        ORIG_PROFILE=$(powerprofilesctl get)
        log_print "[+] powerprofilesctl trouvé. Profil d'origine : $ORIG_PROFILE"
    else
        log_print "[!] Aucun utilitaire de profil énergétique supporté (asusctl ou powerprofilesctl) n'a été trouvé. La gestion du profil d'énergie sera ignorée."
    fi
else
    log_print "[+] Optimisation du profil énergétique désactivée (option --skip-power active)."
fi

# Fonction pour s'assurer que le mode performance est actif
ensure_performance_mode() {
    if [ "$SKIP_POWER_FLAG" = true ]; then return; fi
    if [ "$USE_ASUSCTL" = true ] && [ -n "$ORIG_PROFILE" ]; then
        local current
        current=$(asusctl profile get | grep -i 'active profile' | awk -F' ' '{print $NF}')
        if [ "$current" != "Performance" ]; then
            asusctl profile set Performance >/dev/null 2>&1 || true
        fi
    elif [ "$USE_POWERPROFILESCTL" = true ] && [ -n "$ORIG_PROFILE" ]; then
        local current
        current=$(powerprofilesctl get)
        if [ "$current" != "performance" ]; then
            powerprofilesctl set performance >/dev/null 2>&1 || true
        fi
    fi
}

# Fonction pour restaurer le profil énergétique d'origine
restore_original_profile() {
    if [ "$SKIP_POWER_FLAG" = true ]; then return; fi
    if [ "$USE_ASUSCTL" = true ] && [ -n "$ORIG_PROFILE" ]; then
        log_print -e "\n[+] Restauration du profil asusctl à : $ORIG_PROFILE..."
        asusctl profile set "$ORIG_PROFILE" >/dev/null 2>&1 || true
    elif [ "$USE_POWERPROFILESCTL" = true ] && [ -n "$ORIG_PROFILE" ]; then
        log_print -e "\n[+] Restauration du profil powerprofilesctl à : $ORIG_PROFILE..."
        powerprofilesctl set "$ORIG_PROFILE" >/dev/null 2>&1 || true
    fi
}

# Permet de savoir si l'on quitte à cause d'un signal d'interruption
interrupted=false

# Fonction de nettoyage pour restaurer le profil d'origine à la sortie/interruption
cleanup() {
    # Désactiver les traps pour éviter une récursion
    trap - EXIT INT TERM
    restore_original_profile
    if [ "$interrupted" = true ]; then
        exit 130
    fi
}
# Configuration des captures de signaux (traps)
trap 'interrupted=true; exit 130' INT TERM
trap 'cleanup' EXIT

# Bascule initiale vers le mode performance
ensure_performance_mode
if [ "$SKIP_POWER_FLAG" = false ]; then
    log_print "[+] Attente de 3 secondes pour la stabilisation des états d'alimentation..."
    sleep 3
fi

# Fonction utilitaire pour exécuter un benchmark
# Arguments :
#   1 : Label (ex. "Normal Python")
#   2 : Commande wrapper (ex. "game-performance", "gamemoderun", ou "" si aucune)
#   3 : Commande payload (ex. "python3 -c '...'")
#   4 : Nom du fichier de sortie (ex. "normal_python_perf.txt")
#   5 : Préfixe de la variable globale (ex. "normal_python_perf")
run_benchmark() {
    local label="$1"
    local wrapper="$2"
    local payload="$3"
    local outfile="$4"
    local var_prefix="$5"

    if [ "$QUIET_FLAG" = false ]; then
        echo -e "\n=================================================="
        echo "Lancement du Benchmark : $label"
        if [ -n "$wrapper" ]; then
            echo "Commande : $wrapper bash -c \"time $payload\""
        else
            echo "Commande : time $payload"
        fi
        echo "Sauvegarde des résultats dans : $outfile"
        echo "=================================================="
    fi

    # Initialisation du fichier de sortie
    echo "=== Benchmark : $label ===" > "$outfile"
    if [ -n "$wrapper" ]; then
        echo "Commande : $wrapper bash -c \"time $payload\"" >> "$outfile"
    else
        echo "Commande : time $payload" >> "$outfile"
    fi
    echo "Date : $(date)" >> "$outfile"
    echo "--------------------------------------" >> "$outfile"

    local times=()
    for ((i=1; i<=NUM_RUNS; i++)); do
        log_print_n "  Exécution $i/$NUM_RUNS... "

        # Exécution de la commande et capture du stderr de time
        local time_output
        local status
        if [ -n "$wrapper" ]; then
            time_output=$( $wrapper bash -c "time $payload >/dev/null" 2>&1 )
            status=$?
        else
            time_output=$( bash -c "time $payload >/dev/null" 2>&1 )
            status=$?
        fi

        # Vérifier si la commande a été interrompue par Ctrl+C (code de sortie 130 ou 143)
        if [ $status -eq 130 ] || [ $status -eq 143 ]; then
            log_print "INTERROMPU"
            echo "Run $i : INTERROMPU" >> "$outfile"
            echo "--------------------------------------" >> "$outfile"
            interrupted=true
            exit $status
        fi

        if [ $status -ne 0 ]; then
            log_print "ÉCHEC (code de sortie $status)"
            echo "Run $i : ÉCHEC (code de sortie $status)" >> "$outfile"
            echo "$time_output" >> "$outfile"
            echo "--------------------------------------" >> "$outfile"
            continue
        fi

        # Extraire le temps réel en secondes depuis la sortie de la commande time
        # Ex. "real 0m5.266s" -> 5.266
        local real_time
        real_time=$(echo "$time_output" | awk '/real/ { split($2, a, "m"); gsub(/s/, "", a[2]); print a[1] * 60 + a[2] }')

        log_print "Terminé (${real_time}s)"

        # Écriture dans le fichier de sortie
        echo "Run $i : ${real_time}s" >> "$outfile"
        echo "$time_output" >> "$outfile"
        echo "--------------------------------------" >> "$outfile"

        times+=("$real_time")

        # S'assurer à nouveau que le mode performance est actif (car game-performance le restaure à "balanced" à la sortie)
        ensure_performance_mode

        # Attente de stabilisation (1s) pour permettre aux fréquences CPU et états d'énergie de se calmer
        sleep 1
    done

    if [ ${#times[@]} -eq 0 ]; then
        log_print "Erreur : Toutes les exécutions ont échoué pour $label."
        echo "Toutes les exécutions ont échoué." >> "$outfile"
        return 1
    fi

    # Calcul des temps totaux et moyens avec Python pour une précision optimale des nombres flottants
    local times_str="${times[*]}"
    local stats
    stats=$(python3 -c "times = [${times_str// /, }]; total = sum(times); print(f'{total:.3f} {total/len(times):.3f}')")

    local total_time
    local avg_time
    total_time=$(echo "$stats" | cut -d' ' -f1)
    avg_time=$(echo "$stats" | cut -d' ' -f2)

    # Ajout des statistiques globales au fichier de sortie
    echo "Summary:" >> "$outfile"
    echo "  Total Time:   ${total_time}s" >> "$outfile"
    echo "  Average Time: ${avg_time}s" >> "$outfile"
    echo "=======================================" >> "$outfile"

    # Stockage des résultats dans les variables globales pour l'affichage final
    eval "${var_prefix}_total=\$total_time"
    eval "${var_prefix}_avg=\$avg_time"
}

# Initialisation des variables à N/A
normal_python_perf_total="N/A"
normal_python_perf_avg="N/A"
game_performance_python_perf_total="N/A"
game_performance_python_perf_avg="N/A"
gamemoderun_python_perf_total="N/A"
gamemoderun_python_perf_avg="N/A"

# Capture d'un horodatage unique partagé par tous les fichiers de sortie
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Construction dynamique de la commande de calcul
payload_cmd="python3 -c 'sum(i*i for i in range($RANGE_EXPR))'"

# Exécution des 3 benchmarks si les commandes respectives sont disponibles
run_benchmark "Normal Python" "" "$payload_cmd" "$PERF_DIR/normal_python_perf-${TIMESTAMP}.txt" "normal_python_perf"

if command -v game-performance >/dev/null 2>&1; then
    run_benchmark "Game Performance" "game-performance" "$payload_cmd" "$PERF_DIR/game-performance_python_perf-${TIMESTAMP}.txt" "game_performance_python_perf"
else
    log_print -e "\n[-] game-performance n'est pas installé. Saut de ce benchmark."
fi

if command -v gamemoderun >/dev/null 2>&1; then
    run_benchmark "GameMode Run" "gamemoderun" "$payload_cmd" "$PERF_DIR/gamemoderun_python_perf-${TIMESTAMP}.txt" "gamemoderun_python_perf"
else
    log_print -e "\n[-] gamemoderun n'est pas installé. Saut de ce benchmark."
fi

# Fonction utilitaire pour formater une ligne du tableau de résultats finaux
print_row() {
    local label="$1"
    local total="$2"
    local avg="$3"
    if [ "$total" = "N/A" ]; then
        printf "%-25s | %-12s | %-12s\n" "$label" "$total" "$avg"
    else
        printf "%-25s | %-11ss | %-11ss\n" "$label" "$total" "$avg"
    fi
}

# Affichage des résultats finaux dans le terminal (toujours affichés)
echo -e "\n"
echo "=================================================="
echo "                RÉSULTATS FINAUX                  "
echo "=================================================="
printf "%-25s | %-12s | %-12s\n" "Configuration Benchmark" "Temps Total" "Temps Moyen"
echo "--------------------------------------------------"
print_row "Normal Python" "$normal_python_perf_total" "$normal_python_perf_avg"
print_row "game-performance" "$game_performance_python_perf_total" "$game_performance_python_perf_avg"
print_row "gamemoderun" "$gamemoderun_python_perf_total" "$gamemoderun_python_perf_avg"
echo "=================================================="
echo "Rapports détaillés écrits dans le dossier ${PERF_DIR/#$HOME/\~} :"
echo "  - ${PERF_DIR/#$HOME/\~}/normal_python_perf-${TIMESTAMP}.txt"
[ "$game_performance_python_perf_total" != "N/A" ] && echo "  - ${PERF_DIR/#$HOME/\~}/game-performance_python_perf-${TIMESTAMP}.txt"
[ "$gamemoderun_python_perf_total" != "N/A" ] && echo "  - ${PERF_DIR/#$HOME/\~}/gamemoderun_python_perf-${TIMESTAMP}.txt"
echo ""
