#try to install Citrix Snapins
#wenn nicht möglich exit Script
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
try{

    #Lese den in der Site konfigurierten Lizenzserver aus
    $lizenzserver = (Get-ConfigSite -ErrorAction Stop).LicenseServerName
    if(-not $lizenzserver){
        throw "Kein Lizenzserver in der Site konfiguriert"
    }

    #überprüfe ob es sich um den Lokalen Server handelt (Kurzname oder FQDN, Groß-/Kleinschreibung egal)
    #Info-Check: beide Fälle enden mit exit 0
    $fqdn = [System.Net.Dns]::GetHostByName('').hostname
    $shortname = $env:COMPUTERNAME
    if(($lizenzserver -eq $fqdn) -or ($lizenzserver -eq $shortname) -or ($lizenzserver -eq 'localhost')){
        Write-Output "True $lizenzserver"
        exit 0
    }
    else{
        Write-Output "False $lizenzserver"
        exit 0
    }
}
catch{
    Write-Output "Fehler beim auslesen: $($_.Exception.Message)"
    exit 3
}
