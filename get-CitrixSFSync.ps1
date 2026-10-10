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

try{
    #Replikationsstatus pro StoreFront-Server: Status, Zeitpunkt und Fehler des letzten Syncs
    Get-DSConfigurationReplicationState -ErrorAction Stop | Format-Table ServerName, ServerStates, LastUpdateStatus, LastEndTime, LastError -AutoSize | Out-String -Width 4096
    exit 0
}
catch{
    Write-Output "Fehler beim auslesen des StoreFront Sync Status: $($_.Exception.Message)"
    exit 3
}
