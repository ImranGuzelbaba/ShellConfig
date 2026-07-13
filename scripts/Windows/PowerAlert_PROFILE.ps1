# PowerAlert_PROFILE.ps1

function Start-BatteryMonitor {
    <#
    .SYNOPSIS
    Démarre un écouteur d'événements en arrière-plan qui déclenche une notification BurntToast
    et un bip sonore lorsque l'ordinateur passe sur batterie.
    #>
    [CmdletBinding()]
    param()

    # Nettoyer les enregistrements existants pour éviter les doublons et nettoyer les tâches
    Stop-BatteryMonitor

    $PowerDropAction = {
        $battery = Get-CimInstance -ClassName Win32_Battery
        if ($battery.BatteryStatus -eq 1) {
            New-BurntToastNotification -Text "⚡ ATTENTION : Alimentation secteur débranchée", "Le système est sur batterie. Branchez le chargeur immédiatement pour éviter l'arrêt !"
            1..3 | ForEach-Object {
                [System.Console]::Beep(1500, 200)
                Start-Sleep -Milliseconds 50
            }
        }
    }

    $Query = "SELECT * FROM __InstanceModificationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_Battery' AND TargetInstance.BatteryStatus = 1 AND PreviousInstance.BatteryStatus = 2"

    # Redirection vers la constante $null pour masquer le retour de la commande
    $null = Register-CimIndicationEvent -Query $Query -SourceIdentifier "PowerDropAlert" -Action $PowerDropAction
}

function Stop-BatteryMonitor {
    <#
    .SYNOPSIS
    Arrête la surveillance de la batterie en arrière-plan et nettoie les tâches.
    #>
    Unregister-Event -SourceIdentifier "PowerDropAlert" -ErrorAction SilentlyContinue
    Stop-Job -Name PowerDropAlert -ErrorAction Ignore
    Remove-Job -Name PowerDropAlert -ErrorAction Ignore
}
