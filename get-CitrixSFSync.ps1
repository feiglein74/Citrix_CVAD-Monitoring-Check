Add-PSSnapin Citrix.DeliveryServices.ConfigurationReplication.Commands

#Gibt das Letzte Storefront Sync-Datum aus
Get-DSConfigurationReplicationState | ft ServerName, ServerStates, LastUpdateStatus,LastEndTime,LastError
