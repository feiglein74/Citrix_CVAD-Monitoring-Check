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
    #Liest den in der Site konfigurierten Lizenzserver aus
    $lizenzserver = (Get-ConfigSite -ErrorAction Stop).LicenseServerName
    if(-not $lizenzserver){
        throw "Kein Lizenzserver in der Site konfiguriert"
    }

    #Zertifikat des Lizenzservers holen (Admin-Port 8083), wird für die Inventar-Abfrage benötigt
    $LSAdminAddress = "https://" + $lizenzserver + ":8083"
    $LSCertificate = Get-LicCertificate -AdminAddress $LSAdminAddress -ErrorAction Stop 4>$Null

    #Lizenzinventar abfragen und als Tabelle formatieren
    #Einträge ohne LicenseEdition (z.B. Startup-License) werden ausgeblendet, die Anzahl wird mit ausgegeben
    $Inventory = @(Get-LicInventory -AdminAddress $LSAdminAddress -CertHash $LSCertificate.CertHash -ErrorAction Stop 4>$Null)
    $Licenses = @($Inventory | Where-Object -Property LicenseEdition -NE "")
    $HiddenCount = $Inventory.Count - $Licenses.Count
    $ProductLicenses = $Licenses |
        Format-Table 'LocalizedLicenseProductName', 'LicenseEdition', 'LicenseModel', 'LicenseExpirationDate', 'LicenseSubscriptionAdvantageDate', 'LicensesInUse', 'LicensesAvailable' -AutoSize |
        Out-String -Width 4096
}
catch{
    Write-Output "Fehler beim auslesen der Lizenzen von ${lizenzserver}: $($_.Exception.Message)"
    exit 3
}

Write-Output $ProductLicenses
if($HiddenCount -gt 0){
    Write-Output "[$HiddenCount Eintraege ohne LicenseEdition ausgeblendet]"
}
exit 0
