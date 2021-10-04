$DesktopGroupMember = Get-BrokerMachine  | where RegistrationState -eq Registered
write-host $DesktopGroupMember[0].MachineName


$RDSLIC = Invoke-Command -ComputerName ts-c-test{Get-ItemProperty -Path 'HKLm:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name LicenseServers } 
write-host $RDSLIC.LicenseServers
