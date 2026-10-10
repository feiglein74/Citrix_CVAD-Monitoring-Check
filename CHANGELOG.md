# Changelog

Alle relevanten Änderungen an diesem Projekt. Format nach [Keep a Changelog](https://keepachangelog.com/de/1.1.0/), Versionierung nach [SemVer](https://semver.org/lang/de/).

## [1.0.0] – 2026-10-10

Erste versionierte Fassung. Der Stand vor dieser Version (Oktober 2021) ist unversioniert.

### Hinzugefügt

- `Get-EventError.ps1`: Parameter `-Warning` (Schwelle für Warning), Parameter `-EventId` (Alias `-event` für bestehende Aufrufe)
- `get-eventlog.ps1`: Parameter `-Month` und `-Days` (Defaults wie bisher: 3 Monate, 15 Tage)
- `get-CitrixVersion.ps1`: Versionen 7.29 bis 7.41 (CVAD 2103 bis 2402 LTSR), LTSR-Kennzeichnung
- `get-CitrixLicence.ps1`: Hinweis auf die Anzahl ausgeblendeter Einträge ohne LicenseEdition
- Snapin-Check, Fehlerbehandlung und Exit-Codes in allen Citrix-Skripten
- Dokumentation: README, TODO, CHANGELOG, LICENSE (MIT), DESIGN-PRINCIPLES, .gitignore, .gitattributes

### Geändert

- `Get-EventError.ps1`: beendet sich zusätzlich mit dem Statuscode als Exit-Code (bisher immer 0). stdout ist unverändert
- `get-CitrixLicServer.ps1`, `get-CitrixLicence.ps1`: Lizenzserver wird aus `Get-ConfigSite` gelesen statt aus `LastLicensingServerEventDetails`
- `get-eventlog.ps1`: `Get-WinEvent` statt `Get-EventLog`; Überschriften nennen den Filter (`nur Errors` / `alle Eintraege`)
- Tabellen-Ausgaben in voller Breite (`-AutoSize`, `Out-String -Width 4096`)
- Fehlermeldungen enthalten die Exception-Message
- `Write-Host` → `Write-Output`, Aliase ausgeschrieben, Dateien als UTF-8 mit BOM

### Behoben

- `get-CitrixVersion.ps1`: String-Vergleich der Version meldete 7.5–7.9 als "Aktueller als CVAD 2012"
- `get-CitrixVersion.ps1`: Citrix-Snapin wurde nicht geladen
- `get-CitrixLicServer.ps1`: Vergleich mit dem lokalen Server schlug bei Kurznamen fehl
- `Get-EventError.ps1`: nicht lesbares Eventlog wurde als OK gemeldet, jetzt Unknown (3)
- `get-CitrixWorker.ps1`: nur die ersten 250 Maschinen wurden ausgegeben; Tippfehler `InMaintenaceMode` im Header
- Tabellen wurden bei umgeleiteter Ausgabe auf ca. 80 Zeichen gekürzt
