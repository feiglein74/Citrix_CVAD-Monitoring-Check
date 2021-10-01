Add-PSSnapin "Citrix.*" -ErrorAction SilentlyContinue

#gibt alle Maschinen mit dazugehörigen infos innerhalb der Citrix Site aus

$DesktopGroupMember = Get-BrokerMachine  | Sort-Object -Property MachineName
Write-Host "DeliveryGroup;DNSName;IPAddress;SessionSupport;InMaintenaceMode;Tags;PowerState;RegistrationState"
foreach ($Member in $DesktopGroupMember)
{
    Write-Host $Member.DesktopGroupName";"$Member.DNSName";"$Member.IPAddress";"$Member.SessionSupport";"$Member.InMaintenanceMode";"$Member.Tags";"$Member.PowerState";"$member.RegistrationState
	 
}

