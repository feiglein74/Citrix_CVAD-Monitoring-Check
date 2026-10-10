# get-CitrixRDS.ps1
# 07.10.2021
# Gerhard Unter
#
# Liest den per Policy gesetzten RDS-Lizenzserver (Registry: LicenseServers) aus und gibt ihn aus.
# Abgefragt wird per Remoting nur der erste registrierte Multisession-Worker der Site.
#
# Edit - Sascha Feig - 07-10-2021 - Bedingung bei SessionSupport angepasst
# Edit - Gerhard Unter angepasster Try -Catch bei Add-Pssnapin
# Edit - Sascha Feig - 10.10.2026 - Fehlerdetails in der Ausgabe, Write-Output statt Write-Host (v1.0.0)
# Edit - Sascha Feig - 10.10.2026 - Worker-Filter im Cmdlet statt Where-Object, 250er-Limit umgangen (v1.0.1)
#

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


try{
    #ersten registrierten Multisession-Worker der Site ermitteln
    #Filter direkt im Cmdlet: Where-Object würde nur die ersten 250 Maschinen (Default MaxRecordCount) durchsuchen
    $DesktopGroupMember = @(Get-BrokerMachine -SessionSupport MultiSession -RegistrationState Registered -MaxRecordCount 1 -ErrorAction Stop)
    if($DesktopGroupMember.Count -eq 0){
        throw "Kein registrierter Multisession-Worker gefunden"
    }


    #RDS-Lizenzserver vom ersten Worker auslesen
    $RDSLIC = Invoke-Command -ComputerName $DesktopGroupMember[0].DNSName -ErrorAction Stop {Get-ItemProperty -Path 'HKLm:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name LicenseServers -ErrorAction Stop }
    Write-Output "$($RDSLIC.LicenseServers)"
    exit 0
}
catch{

    Write-Output "Fehler beim auslesen des RDS Servers: $($_.Exception.Message)"
    exit 3
    }
