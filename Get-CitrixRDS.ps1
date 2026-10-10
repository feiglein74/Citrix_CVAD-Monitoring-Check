# Get-CitrixRDS.ps1
# 07.10.2021
# Gerhard Unter
#
# Liest den per Policy gesetzten RDS-Lizenzserver (Registry: LicenseServers) auf allen registrierten
# Multisession-Workern der Site aus und vergleicht ihn.
#
# OK (0): alle Worker haben denselben Eintrag, Ausgabe: der Lizenzserver (wie bisher)
# Warning (1): Worker mit abweichendem oder fehlendem Eintrag bzw. nicht erreichbare Worker, Ausgabe: Liste pro Worker
# Unknown (3): Snapin fehlt, kein Worker registriert, kein Worker erreichbar oder Fehler beim Auslesen
#
# Edit - Sascha Feig - 07-10-2021 - Bedingung bei SessionSupport angepasst
# Edit - Gerhard Unter angepasster Try -Catch bei Add-Pssnapin
# Edit - Sascha Feig - 10.10.2026 - Fehlerdetails in der Ausgabe, Write-Output statt Write-Host (v1.0.0)
# Edit - Sascha Feig - 10.10.2026 - Worker-Filter im Cmdlet statt Where-Object, 250er-Limit umgangen (v1.0.1)
# Edit - Sascha Feig - 10.10.2026 - alle Worker prüfen und Abweichungen melden (v3.0.0)
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
    #alle registrierten Multisession-Worker der Site
    #Filter direkt im Cmdlet, MaxRecordCount aufgehoben (Default: nur die ersten 250 Maschinen)
    #Computername für Remoting: DNSName, ohne DNSName der Name aus MachineName (DOMAIN\Name)
    $Workers = @(Get-BrokerMachine -SessionSupport MultiSession -RegistrationState Registered -MaxRecordCount ([int]::MaxValue) -ErrorAction Stop |
        ForEach-Object { if($_.DNSName){ $_.DNSName } else { ($_.MachineName -split '\\')[-1] } } |
        Sort-Object)
    if($Workers.Count -eq 0){
        throw "Kein registrierter Multisession-Worker gefunden"
    }
}
catch{
    Write-Output "Fehler beim auslesen der Worker: $($_.Exception.Message)"
    exit 3
}

#RDS-Lizenzserver auf allen Workern parallel auslesen
#OpenTimeout begrenzt die Wartezeit bei nicht erreichbaren Workern (Laufzeit des Checks im Agent)
#der Scriptblock liefert immer ein Objekt, damit "kein Eintrag" von "nicht erreichbar" unterscheidbar ist
$sessionOption = New-PSSessionOption -OpenTimeout 15000
$results = @(Invoke-Command -ComputerName $Workers -SessionOption $sessionOption -ErrorAction SilentlyContinue -ErrorVariable remoteErrors -ScriptBlock {
    $value = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name LicenseServers -ErrorAction SilentlyContinue).LicenseServers
    [pscustomobject]@{ LicenseServers = $value }
})

#Eintrag pro Worker: Rohwert für die Ausgabe, normalisierter Wert für den Vergleich
#(Reihenfolge und Groß-/Kleinschreibung egal, REG_SZ mit Komma oder REG_MULTI_SZ)
$entries = foreach($result in $results){
    $servers = @($result.LicenseServers | ForEach-Object { $_ -split '[,;]' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    [pscustomobject]@{
        Worker     = $result.PSComputerName
        Display    = "$($result.LicenseServers)"
        Normalized = (($servers | ForEach-Object { $_.ToLower() } | Sort-Object -Unique) -join ',')
    }
}
$entries = @($entries)

$reachable = @($entries.Worker)
$unreachable = @($Workers | Where-Object { $reachable -notcontains $_ })

if($entries.Count -eq 0){
    Write-Output "Kein Worker erreichbar ($($Workers.Count) abgefragt): $(($remoteErrors | ForEach-Object { $_.Exception.Message } | Select-Object -Unique) -join ' | ')"
    exit 3
}

#OK nur, wenn alle Worker erreichbar sind und denselben, nicht leeren Eintrag haben
$variants = @($entries | Where-Object { $_.Normalized } | Select-Object -ExpandProperty Normalized -Unique)
$missing = @($entries | Where-Object { -not $_.Normalized })

if(($variants.Count -eq 1) -and ($missing.Count -eq 0) -and ($unreachable.Count -eq 0)){
    #Ausgabe wie bisher: nur der Lizenzserver
    Write-Output $entries[0].Display
    exit 0
}

Write-Output "WARNING - RDS-Lizenzserver uneinheitlich: $($variants.Count) Varianten, $($missing.Count) ohne Eintrag, $($unreachable.Count) nicht erreichbar ($($Workers.Count) Worker)"
foreach($entry in $entries){
    if($entry.Normalized){
        Write-Output "$($entry.Worker): $($entry.Display)"
    }
    else{
        Write-Output "$($entry.Worker): (kein Eintrag)"
    }
}
foreach($worker in $unreachable){
    Write-Output "${worker}: (nicht erreichbar)"
}
exit 1
