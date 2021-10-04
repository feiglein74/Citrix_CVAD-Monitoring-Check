#try to install Citrix Snapins 
#wenn nicht möglich exit Script
Try { 
    if((Get-PSSnapin -Name "Citrix.*" -ErrorAction SilentlyContinue)){ 
        Add-PsSnapin "Citrix.*" 
    } 
    Else{
        Write-Host Kein Snapin installiert
        exit
    }
}Catch{


#gibt den Citrix Lizenzserver aus
}
try{
    $lizenz = Get-BrokerController | select LastLicensingServerEventDetails
    $lizenzserver = $lizenz[0].LastLicensingServerEventDetails -split ": "
    Write-Host $lizenzserver[1]
}
catch{
    write-host Fehler beim auslesen
}
