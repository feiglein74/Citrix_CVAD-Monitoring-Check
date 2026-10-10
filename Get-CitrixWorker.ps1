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

#Ausgabe als CSV mit ";" als Trennzeichen, alle Felder in Anführungszeichen (ConvertTo-Csv)
#mehrere Tags werden mit "," verbunden
$header = '"DeliveryGroup";"DNSName";"IPAddress";"SessionSupport";"InMaintenanceMode";"Tags";"PowerState";"RegistrationState"'
if(@($DesktopGroupMember).Count -eq 0){
    #ConvertTo-Csv gibt ohne Objekte auch keinen Header aus
    Write-Output $header
    exit 0
}

$DesktopGroupMember | ForEach-Object {
    [pscustomobject][ordered]@{
        DeliveryGroup     = $_.DesktopGroupName
        DNSName           = $_.DNSName
        IPAddress         = $_.IPAddress
        SessionSupport    = $_.SessionSupport
        InMaintenanceMode = $_.InMaintenanceMode
        Tags              = ($_.Tags -join ',')
        PowerState        = $_.PowerState
        RegistrationState = $_.RegistrationState
    }
} | ConvertTo-Csv -Delimiter ';' -NoTypeInformation
exit 0
