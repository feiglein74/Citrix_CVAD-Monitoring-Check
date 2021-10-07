$CVADSiteVersion = Get-ConfigSite
if($CVADSiteVersion.ProductVersion -gt "7.28" ){
    write "Aktueller als CVAD 2012 (" $CVADSiteVersion.ProductVersion ")"
}else{

    Switch ($CVADSiteVersion.ProductVersion){
        "7.28"	{$CVADSiteVersionReal = "CVAD 2012"; Break}
        "7.27"	{$CVADSiteVersionReal = "CVAD 2009"; Break}
        "7.26"	{$CVADSiteVersionReal = "CVAD 2006"; Break}
        "7.25"	{$CVADSiteVersionReal = "CVAD 2003"; Break}
        "7.24"	{$CVADSiteVersionReal = "CVAD 1912"; Break}
        "7.23"	{$CVADSiteVersionReal = "CVAD 1909"; Break}
        "7.22"	{$CVADSiteVersionReal = "CVAD 1906"; Break}
        "7.21"	{$CVADSiteVersionReal = "CVAD 1903"; Break}
        "7.20"	{$CVADSiteVersionReal = "CVAD 1811"; Break}
        "7.19"	{$CVADSiteVersionReal = "CVAD 1808"; Break}
        "7.18"	{$CVADSiteVersionReal = "XA/XD 7.18"; Break}
        "7.17"	{$CVADSiteVersionReal = "XA/XD 7.17"; Break}
        "7.16"	{$CVADSiteVersionReal = "XA/XD 7.16"; Break}
        "7.15"	{$CVADSiteVersionReal = "XA/XD 7.15"; Break}
        "7.14"	{$CVADSiteVersionReal = "XA/XD 7.14"; Break}
        "7.13"	{$CVADSiteVersionReal = "XA/XD 7.13"; Break}
        "7.12"	{$CVADSiteVersionReal = "XA/XD 7.12"; Break}
        "7.11"	{$CVADSiteVersionReal = "XA/XD 7.11"; Break}
        "7.9"	{$CVADSiteVersionReal = "XA/XD 7.9"; Break}
        "7.8"	{$CVADSiteVersionReal = "XA/XD 7.8"; Break}
        "7.7"	{$CVADSiteVersionReal = "XA/XD 7.7"; Break}
        "7.6"	{$CVADSiteVersionReal = "XA/XD 7.6"; Break}
        "7.5"	{$CVADSiteVersionReal = "XA/XD 7.5"; Break}
        "7.1"	{$CVADSiteVersionReal = "XD 7.1"; Break}
        "7.0"	{$CVADSiteVersionReal = "XD 7.0"; Break}
        Default	{$CVADSiteVersionReal = "Unknown"; Break}
    }

    write $CVADSiteVersionReal
   }
