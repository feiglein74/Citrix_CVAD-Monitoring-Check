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
}

try{
$DesktopGroupMember = Get-BrokerMachine  | where RegistrationState -eq Registered

$RDSLIC = Invoke-Command -ComputerName $DesktopGroupMember[0].DNSName {Get-ItemProperty -Path 'HKLm:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name LicenseServers } 
write-host $RDSLIC.LicenseServers
}
catch{

    Write-Host Fehler beim auslesen des RDS Servers

    }
