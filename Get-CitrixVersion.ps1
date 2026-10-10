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
    $CVADSiteVersion = Get-ConfigSite -ErrorAction Stop

    #nur Major.Minor betrachten (z.B. "7.24" oder "7.24.0.0" -> 7.24)
    #Vergleich über [version], als String wäre "7.9" größer als "7.28"
    $ProductVersion = [version](($CVADSiteVersion.ProductVersion -split '\.')[0..1] -join '.')
}
catch{
    Write-Output "Fehler beim auslesen der Site Version: $($_.Exception.Message)"
    exit 3
}

#Zuordnung ProductVersion -> Release laut https://www.carlwebster.com/citrix-xenapp-xendesktop-virtual-apps-and-desktop-product-numbers-and-versions/ (Stand 10.10.2026)
#LTSR-Kennzeichnung laut Citrix Docs, z.B. https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/2507-ltsr/
if($ProductVersion -gt [version]"7.48"){
    Write-Output "Aktueller als CVAD 2607 ($($CVADSiteVersion.ProductVersion))"
}else{

    Switch ("$ProductVersion"){
        "7.48"	{$CVADSiteVersionReal = "CVAD 2607"; Break}
        "7.47"	{$CVADSiteVersionReal = "CVAD 2603"; Break}
        "7.46"	{$CVADSiteVersionReal = "CVAD 2511"; Break}
        "7.45"	{$CVADSiteVersionReal = "CVAD 2507 LTSR"; Break}
        "7.44"	{$CVADSiteVersionReal = "CVAD 2503"; Break}
        "7.43"	{$CVADSiteVersionReal = "CVAD 2411"; Break}
        "7.42"	{$CVADSiteVersionReal = "CVAD 2407"; Break}
        "7.41"	{$CVADSiteVersionReal = "CVAD 2402 LTSR"; Break}
        "7.40"	{$CVADSiteVersionReal = "CVAD 2311"; Break}
        "7.39"	{$CVADSiteVersionReal = "CVAD 2308"; Break}
        "7.38"	{$CVADSiteVersionReal = "CVAD 2305"; Break}
        "7.37"	{$CVADSiteVersionReal = "CVAD 2303"; Break}
        "7.36"	{$CVADSiteVersionReal = "CVAD 2212"; Break}
        "7.35"	{$CVADSiteVersionReal = "CVAD 2209"; Break}
        "7.34"	{$CVADSiteVersionReal = "CVAD 2206"; Break}
        "7.33"	{$CVADSiteVersionReal = "CVAD 2203 LTSR"; Break}
        "7.32"	{$CVADSiteVersionReal = "CVAD 2112"; Break}
        "7.31"	{$CVADSiteVersionReal = "CVAD 2109"; Break}
        "7.30"	{$CVADSiteVersionReal = "CVAD 2106"; Break}
        "7.29"	{$CVADSiteVersionReal = "CVAD 2103"; Break}
        "7.28"	{$CVADSiteVersionReal = "CVAD 2012"; Break}
        "7.27"	{$CVADSiteVersionReal = "CVAD 2009"; Break}
        "7.26"	{$CVADSiteVersionReal = "CVAD 2006"; Break}
        "7.25"	{$CVADSiteVersionReal = "CVAD 2003"; Break}
        "7.24"	{$CVADSiteVersionReal = "CVAD 1912 LTSR"; Break}
        "7.23"	{$CVADSiteVersionReal = "CVAD 1909"; Break}
        "7.22"	{$CVADSiteVersionReal = "CVAD 1906"; Break}
        "7.21"	{$CVADSiteVersionReal = "CVAD 1903"; Break}
        "7.20"	{$CVADSiteVersionReal = "CVAD 1811"; Break}
        "7.19"	{$CVADSiteVersionReal = "CVAD 1808"; Break}
        "7.18"	{$CVADSiteVersionReal = "XA/XD 7.18"; Break}
        "7.17"	{$CVADSiteVersionReal = "XA/XD 7.17"; Break}
        "7.16"	{$CVADSiteVersionReal = "XA/XD 7.16"; Break}
        "7.15"	{$CVADSiteVersionReal = "XA/XD 7.15 LTSR"; Break}
        "7.14"	{$CVADSiteVersionReal = "XA/XD 7.14"; Break}
        "7.13"	{$CVADSiteVersionReal = "XA/XD 7.13"; Break}
        "7.12"	{$CVADSiteVersionReal = "XA/XD 7.12"; Break}
        "7.11"	{$CVADSiteVersionReal = "XA/XD 7.11"; Break}
        "7.9"	{$CVADSiteVersionReal = "XA/XD 7.9"; Break}
        "7.8"	{$CVADSiteVersionReal = "XA/XD 7.8"; Break}
        "7.7"	{$CVADSiteVersionReal = "XA/XD 7.7"; Break}
        "7.6"	{$CVADSiteVersionReal = "XA/XD 7.6 LTSR"; Break}
        "7.5"	{$CVADSiteVersionReal = "XA/XD 7.5"; Break}
        "7.1"	{$CVADSiteVersionReal = "XD 7.1"; Break}
        "7.0"	{$CVADSiteVersionReal = "XD 7.0"; Break}
        Default	{$CVADSiteVersionReal = "Unknown ($($CVADSiteVersion.ProductVersion))"; Break}
    }

    Write-Output $CVADSiteVersionReal
   }
exit 0
