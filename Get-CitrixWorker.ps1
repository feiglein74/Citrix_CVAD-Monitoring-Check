#Citrix-Snapins laden
#wenn nicht möglich: Meldung und exit 3 (Unknown)
Try {

    Add-PsSnapin "Citrix.*" -ErrorAction SilentlyContinue
    if((Get-PSSnapin -Name "Citrix.*" -ErrorAction SilentlyContinue)){

    }
    Else{
        Write-Output 'Kein Snapin installiert'
        exit 3
    }
}Catch{
    Write-Output "Kein Snapin installiert: $($_.Exception.Message)"
    exit 3
}

#gibt alle Maschinen mit dazugehörigen infos innerhalb der Citrix Site aus
#MaxRecordCount: ohne Angabe liefert Get-BrokerMachine nur die ersten 250 Maschinen
try{
    $DesktopGroupMember = Get-BrokerMachine -MaxRecordCount ([int]::MaxValue) -ErrorAction Stop | Sort-Object -Property MachineName
}
catch{
    Write-Output "Fehler beim auslesen der Maschinen: $($_.Exception.Message)"
    exit 3
}

Write-Output "DeliveryGroup;DNSName;IPAddress;SessionSupport;InMaintenanceMode;Tags;PowerState;RegistrationState"
foreach ($Member in $DesktopGroupMember)
{
    #Trennzeichen " ; " entspricht der bisherigen Ausgabe von Write-Host
    $fields = @(
        $Member.DesktopGroupName
        $Member.DNSName
        $Member.IPAddress
        $Member.SessionSupport
        $Member.InMaintenanceMode
        ($Member.Tags -join ',')
        $Member.PowerState
        $Member.RegistrationState
    )
    Write-Output ($fields -join ' ; ')
}
exit 0
