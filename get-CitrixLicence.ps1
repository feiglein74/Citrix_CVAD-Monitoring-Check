Add-PSSnapin Citrix*

#Liest den Aktuellen Lizenzserver aus und speichert ihn in einer Variablen
$lizenz = Get-BrokerController | select LastLicensingServerEventDetails
$lizenzserver = $lizenz[0].LastLicensingServerEventDetails -split ": "


#Verbindung mit dem Lizenzserver herstellen und die Lizenzinformationen in eine Variable übergeben
$LSAdminAddress =  "https://"+$lizenzserver[1]+":8083"
$LSCertificate = Get-LicCertificate -AdminAddress $LSAdminAddress -EA 0 4>$Null

#Die gewünschten informationen ausgeben und Formatieren
$ProductLicenses = Get-LicInventory -AdminAddress $LSAdminAddress -CertHash $LSCertificate.CertHash -EA 0 4>$Null | where -Property LicenseEdition -NE "" |ft 'LocalizedLicenseProductName','LicenseEdition','LicenseModel','LicenseExpirationDate','LicenseSubscriptionAdvantageDate', 'LicensesInUse' , 'LicensesAvailable'
 

Write-output $ProductLicenses 
