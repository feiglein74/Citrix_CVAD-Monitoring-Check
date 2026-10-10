#try to install StoreFront Snapin
#wenn nicht möglich exit Script
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
    #Gibt das Letzte Storefront Sync-Datum aus
    Get-DSConfigurationReplicationState -ErrorAction Stop | Format-Table ServerName, ServerStates, LastUpdateStatus, LastEndTime, LastError -AutoSize | Out-String -Width 4096
    exit 0
}
catch{
    Write-Output "Fehler beim auslesen des StoreFront Sync Status: $($_.Exception.Message)"
    exit 3
}
