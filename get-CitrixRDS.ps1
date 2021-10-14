# get-CitrixRDS.ps1
# 07.10.2021
# Gerhard Unter
#
# Ruft den Registry Key auf dem ersten 'Worker' ab, in dem der Terminlserver-Lizenzserver gespeichert ist und gibt ihn aus.
# Das Script ruft diesen Key vom ersten registrierten Server ab.
#
# Edit - Sascha Feig - 07-10-2021 - Bedingung bei SessionSupport angepasst
# Edit - Gerhard Unter angepasster Try -Catch bei Add-Pssnapin
#

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
    #speichere einen laufenden worker in eine Variable 
    $DesktopGroupMember = Get-BrokerMachine  | where SessionSupport -eq "Multisession" | where RegistrationState -eq Registered 


    #Lese den RDS Lizenz Server des Workers aus
    $RDSLIC = Invoke-Command -ComputerName $DesktopGroupMember[0].DNSName {Get-ItemProperty -Path 'HKLm:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name LicenseServers } 
    write-host $RDSLIC.LicenseServers
    exit 0
}
catch{

    Write-Host Fehler beim auslesen des RDS Servers
    exit 3
    }
