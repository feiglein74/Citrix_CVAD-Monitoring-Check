#Prüft die Konfigurations-Replikation der StoreFront-Servergruppe
#OK (0): letzte Replikation auf allen Servern "completed" oder StoreFront läuft nicht im Cluster
#Critical (2): Replikation gesamt oder auf mindestens einem Server nicht "completed"
#Unknown (3): Snapin fehlt oder Fehler beim Auslesen
#Statuswerte und Aufbau von ServerStates wie im StoreFront Health Checker von ControlUp
#Quelle: https://www.controlup.com/script-library-posts/storefront-health-checker/ (Stand 10.10.2026)
#Get-DSConfigurationReplicationState ist von Citrix nicht öffentlich dokumentiert

#StoreFront-Snapin laden
#wenn nicht möglich: Meldung und exit 3 (Unknown)
Try {

    Add-PSSnapin Citrix.DeliveryServices.ConfigurationReplication.Commands -ErrorAction SilentlyContinue
    if((Get-PSSnapin -Name Citrix.DeliveryServices.ConfigurationReplication.Commands -ErrorAction SilentlyContinue)){

    }
    Else{
        Write-Output 'Kein Snapin installiert'
        exit 3
    }
}Catch{
    Write-Output "Kein Snapin installiert: $($_.Exception.Message)"
    exit 3
}

#Einzelner StoreFront-Server: keine Replikation, daher kein Fehler
#Get-STFServerGroup stammt aus dem Modul Citrix.StoreFront; ist es nicht verfügbar, entfällt diese Prüfung
Import-Module Citrix.StoreFront -ErrorAction SilentlyContinue
if(Get-Command Get-STFServerGroup -ErrorAction SilentlyContinue){
    try{
        $serverGroup = Get-STFServerGroup -ErrorAction Stop
        if(@($serverGroup.ClusterMembers).Count -le 1){
            Write-Output 'OK - StoreFront nicht im Cluster, keine Replikation'
            exit 0
        }
    }
    catch{
        Write-Output "Fehler beim auslesen der StoreFront Servergruppe: $($_.Exception.Message)"
        exit 3
    }
}

try{
    $replication = Get-DSConfigurationReplicationState -ErrorAction Stop
}
catch{
    Write-Output "Fehler beim auslesen des StoreFront Sync Status: $($_.Exception.Message)"
    exit 3
}

$serverStates = @($replication.ServerStates | Where-Object { $null -ne $_ })
$failedServers = @($serverStates | Where-Object { $_.LastUpdateStatus -ine 'completed' })

if(($replication.LastUpdateStatus -ine 'completed') -or ($failedServers.Count -gt 0)){
    $returnCode = 2
    Write-Output "CRITICAL - Replikation: $($replication.LastUpdateStatus), fehlerhaft auf $($failedServers.Count) von $($serverStates.Count) Servern"
}
else{
    $returnCode = 0
    Write-Output "OK - Replikation: $($replication.LastUpdateStatus) auf $($serverStates.Count) Servern"
}

#Details: Gesamtstatus und Status pro Server
($replication | Format-Table LastUpdateStatus, LastStartTime, LastEndTime, LastError -AutoSize | Out-String -Width 4096).Trim()
if($serverStates.Count -gt 0){
    Write-Output ""
    ($serverStates | Format-Table ServerName, LastUpdateStatus, LastStartTime, LastEndTime, LastError -AutoSize | Out-String -Width 4096).Trim()
}

exit $returnCode
