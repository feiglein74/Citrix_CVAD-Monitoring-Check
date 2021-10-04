#try to install Citrix Snapins 
#wenn nicht möglich exit Script
Try { 
    if((Get-PSSnapin -Name "Citrix.*" -ErrorAction SilentlyContinue)){ 
        Add-PsSnapin "Citrix.*" 
    } 
    Else{
        Write-Host Kein Snapin installiert
        exit 3
    }
}Catch{
}



try{
    #speichere einen laufenden worker in eine Variable 
    $DesktopGroupMember = Get-BrokerMachine  | where RegistrationState -eq Registered


    #Lese den RDS Lizenz Server des Workers aus
    $RDSLIC = Invoke-Command -ComputerName $DesktopGroupMember[0].DNSName {Get-ItemProperty -Path 'HKLm:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name LicenseServers } 
    write-host $RDSLIC.LicenseServers
    exit 0
}
catch{

    Write-Host Fehler beim auslesen des RDS Servers
    exit 3
    }
