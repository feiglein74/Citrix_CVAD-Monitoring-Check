#try to install Citrix Snapins 
#wenn nicht möglich exit Script
Try { 

    Add-PsSnapin "Citrix.*" -ErrorAction SilentlyContinue
    if((Get-PSSnapin -Name "Citrix.*" -ErrorAction SilentlyContinue)){ 

    } 
    Else{
        Write-Host Kein Snapin installiert
        exit 3
    }
}Catch{
    Write-Host Kein Snapin installiert
    exit 3
}
try{

    #Lese den Lizenzserver aus
    $lizenz = Get-BrokerController | select LastLicensingServerEventDetails
    $lizenzserver = $lizenz[0].LastLicensingServerEventDetails -split ": "


    #überprüfe ob es sich um den Lokalen Server handelt
    $hostname = [System.Net.Dns]::GetHostByName('').hostname
    if($lizenzserver -eq $hostname ){
        Write-Host $true $lizenzserver[1]
        exit 0
    }
    else{
        Write-Host $false $lizenzserver[1]
        exit 0
    }       
}
catch{
    write-host Fehler beim auslesen
    exit 3
}
