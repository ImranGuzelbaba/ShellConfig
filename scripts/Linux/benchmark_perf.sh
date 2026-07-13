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

# Fonction d'affichage de l'aide
show_help() {
    # Définition des codes couleur ANSI
    local bold="\e[1m"
    local green="\e[32m"
    local yellow="\e[33m"
    local cyan="\e[36m"
    local reset="\e[0m"

    echo -e "${bold}NOM${reset}"
    echo -e "    benchmark_perf.sh - Script de test comparatif de performance pour Python3"
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
            shift
            ;;
        -i|--interactive)
            INTERACTIVE_FLAG=true
            shift
            ;;
        -r|--run)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                NUM_RUNS="$2"
                RUN_PASSED=true
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
    echo "=================================================="
    echo "       Configuration du Benchmark de Performance  "
    echo "=================================================="

    # 1. Demande du nombre de runs
    if [ "$ASK_RUNS" = true ]; then
        read -e -p "Entrez le nombre d'exécutions (runs) par configuration [par défaut : $NUM_RUNS] : " input_runs
        NUM_RUNS=${input_runs:-$NUM_RUNS}
    fi

    # Validation du nombre de runs
    if ! [[ "$NUM_RUNS" =~ ^[0-9]+$ ]] || [ "$NUM_RUNS" -le 0 ]; then
        echo "[!] Nombre d'exécutions invalide. Retour à la valeur par défaut : 10"
        NUM_RUNS=10
    fi

    # 2. Demande de la plage Python
    if [ "$ASK_RANGE" = true ]; then
        echo -e "\n[!] Note : Le temps d'exécution varie de façon linéaire O(N) avec la taille de la plage :"
        echo "    - 1 * 10**8 prend ~5s par run (~50s au total pour 10 runs)"
        echo "    - 5 * 10**8 prend ~25s par run (~250s au total pour 10 runs)"
        read -e -p "Entrez la taille de la plage Python (ex. 1 * 10**8) [par défaut : $RANGE_EXPR] : " input_range
        RANGE_EXPR=${input_range:-$RANGE_EXPR}
    fi

    # Validation de l'expression de plage Python
    if ! python3 -c "int($RANGE_EXPR)" >/dev/null 2>&1; then
        echo "[!] Expression Python invalide. Retour à la valeur par défaut : 1 * 10**8"
        RANGE_EXPR="1 * 10**8"
    fi

    echo -e "\n[+] Benchmark configuré : $NUM_RUNS runs par config avec la plage ($RANGE_EXPR)."
    echo "=================================================="
else
    # Validation pour le mode automatique / non-interactif
    if ! [[ "$NUM_RUNS" =~ ^[0-9]+$ ]] || [ "$NUM_RUNS" -le 0 ]; then
        echo "[!] Nombre d'exécutions invalide. Retour à la valeur par défaut : 10"
        NUM_RUNS=10
    fi
    if ! python3 -c "int($RANGE_EXPR)" >/dev/null 2>&1; then
        echo "[!] Expression Python invalide. Retour à la valeur par défaut : 1 * 10**8"
        RANGE_EXPR="1 * 10**8"
    fi

    if [ "$NO_INTERACTIVE_FLAG" = true ]; then
        echo "[+] Mode non-interactif : Exécution avec $NUM_RUNS runs et la plage ($RANGE_EXPR)."
    else
        echo "[+] Exécution automatique (arguments fournis) : $NUM_RUNS runs et la plage ($RANGE_EXPR)."
    fi
fi

# Détection de l'utilitaire de profil énergétique
USE_ASUSCTL=false
USE_POWERPROFILESCTL=false
ORIG_PROFILE=""

if command -v asusctl >/dev/null 2>&1; then
    USE_ASUSCTL=true
    # Recherche flexible du profil d'alimentation pour s'adapter aux différentes versions d'asusctl
    ORIG_PROFILE=$(asusctl profile get | grep -i 'active profile' | awk -F' ' '{print $NF}')
    echo "[+] asusctl trouvé. Profil d'origine : $ORIG_PROFILE"
elif command -v powerprofilesctl >/dev/null 2>&1; then
    USE_POWERPROFILESCTL=true
    ORIG_PROFILE=$(powerprofilesctl get)
    echo "[+] powerprofilesctl trouvé. Profil d'origine : $ORIG_PROFILE"
else
    echo "[!] Aucun utilitaire de profil énergétique supporté (asusctl ou powerprofilesctl) n'a été trouvé. La gestion du profil d'énergie sera ignorée."
fi

# Fonction pour s'assurer que le mode performance est actif
ensure_performance_mode() {
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
    if [ "$USE_ASUSCTL" = true ] && [ -n "$ORIG_PROFILE" ]; then
        echo -e "\n[+] Restauration du profil asusctl à : $ORIG_PROFILE..."
        asusctl profile set "$ORIG_PROFILE" >/dev/null 2>&1 || true
    elif [ "$USE_POWERPROFILESCTL" = true ] && [ -n "$ORIG_PROFILE" ]; then
        echo -e "\n[+] Restauration du profil powerprofilesctl à : $ORIG_PROFILE..."
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
echo "[+] Attente de 3 secondes pour la stabilisation des états d'alimentation..."
sleep 3

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

    echo -e "\n=================================================="
    echo "Lancement du Benchmark : $label"
    if [ -n "$wrapper" ]; then
        echo "Commande : $wrapper bash -c \"time $payload\""
    else
        echo "Commande : time $payload"
    fi
    echo "Sauvegarde des résultats dans : $outfile"
    echo "=================================================="

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
        echo -n "  Exécution $i/$NUM_RUNS... "

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
            echo "INTERROMPU"
            echo "Run $i : INTERROMPU" >> "$outfile"
            echo "--------------------------------------" >> "$outfile"
            interrupted=true
            exit $status
        fi

        if [ $status -ne 0 ]; then
            echo "ÉCHEC (code de sortie $status)"
            echo "Run $i : ÉCHEC (code de sortie $status)" >> "$outfile"
            echo "$time_output" >> "$outfile"
            echo "--------------------------------------" >> "$outfile"
            continue
        fi

        # Extraire le temps réel en secondes depuis la sortie de la commande time
        # Ex. "real 0m5.266s" -> 5.266
        local real_time
        real_time=$(echo "$time_output" | awk '/real/ { split($2, a, "m"); gsub(/s/, "", a[2]); print a[1] * 60 + a[2] }')

        echo "Terminé (${real_time}s)"

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
        echo "Erreur : Toutes les exécutions ont échoué pour $label."
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
    echo -e "\n[-] game-performance n'est pas installé. Saut de ce benchmark."
fi

if command -v gamemoderun >/dev/null 2>&1; then
    run_benchmark "GameMode Run" "gamemoderun" "$payload_cmd" "$PERF_DIR/gamemoderun_python_perf-${TIMESTAMP}.txt" "gamemoderun_python_perf"
else
    echo -e "\n[-] gamemoderun n'est pas installé. Saut de ce benchmark."
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

# Affichage des résultats finaux dans le terminal
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
echo "Rapports détaillés écrits dans le dossier $PERF_DIR :"
echo "  - $PERF_DIR/normal_python_perf-${TIMESTAMP}.txt"
[ "$game_performance_python_perf_total" != "N/A" ] && echo "  - $PERF_DIR/game-performance_python_perf-${TIMESTAMP}.txt"
[ "$gamemoderun_python_perf_total" != "N/A" ] && echo "  - $PERF_DIR/gamemoderun_python_perf-${TIMESTAMP}.txt"
echo ""
