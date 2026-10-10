# TODO – Citrix_CVAD-Monitoring-Check

Stand: 10.10.2026

## Erledigt (v1.0.0)

### Bugs

- [x] **get-CitrixVersion.ps1** – Versionsvergleich als String (`"7.9" -gt "7.28"` ist `$true`) → Vergleich über `[version]`
- [x] **get-CitrixVersion.ps1** – Snapin wurde nicht geladen → Snapin-Check ergänzt
- [x] **get-CitrixVersion.ps1** – Versionen ab 7.29 fehlten → Tabelle bis 7.41 (CVAD 2402 LTSR) erweitert, unbekannte Versionen werden mit Versionsnummer ausgegeben
- [x] **get-CitrixLicServer.ps1** – Vergleich `Array -eq Hostname` und nur gegen FQDN → Vergleich gegen Kurzname und FQDN (case-insensitive)
- [x] **Get-EventError.ps1** – Statuscode nur auf stdout, Exit-Code immer 0 → stdout bleibt unverändert (nur die Zahl), zusätzlich `exit <code>`
- [x] **Get-EventError.ps1** – `$returnWarning` ungenutzt → optionaler Parameter `-Warning`
- [x] **Get-EventError.ps1** – Parameter `$event` überschrieb die automatische Variable → `$EventId` mit Alias `event` (bestehende Aufrufe bleiben kompatibel)
- [x] **Get-EventError.ps1** – Fehler beim Lesen des Logs (z.B. Zugriff verweigert) wurden als OK gemeldet → Unknown (3)
- [x] **get-CitrixWorker.ps1** – `Get-BrokerMachine` lieferte ohne `-MaxRecordCount` nur 250 Maschinen
- [x] **Tabellen-Ausgaben** – bei umgeleiteter Ausgabe (Agent) wurden Spalten/Werte auf ca. 80 Zeichen gekürzt → `-AutoSize | Out-String -Width 4096`

### Robustheit

- [x] Lizenzserver aus `Get-ConfigSite` (`LicenseServerName`) statt `LastLicensingServerEventDetails -split ": "`
- [x] Snapin-Check, Try/Catch und Exit-Codes in allen Citrix-Skripten
- [x] Fehlermeldungen enthalten die Exception-Message
- [x] **get-eventlog.ps1** – `Get-WinEvent` statt `Get-EventLog` (PowerShell 7), Zeitraum als Parameter
- [x] **get-CitrixLicence.ps1** – Anzahl ausgeblendeter Einträge (ohne LicenseEdition) wird ausgegeben

### Code-Qualität & Doku

- [x] PSScriptAnalyzer: alle Findings behoben (Write-Host → Write-Output, Aliase, BOM, Whitespace)
- [x] Dateien als UTF-8 mit BOM (Umlaute in PowerShell 5.1)
- [x] Tippfehler `InMaintenaceMode` im CSV-Header
- [x] README, CHANGELOG, LICENSE, DESIGN-PRINCIPLES, .gitignore, .gitattributes

## Erledigt (v1.0.1)

- [x] **get-CitrixRDS.ps1** – 250er-Limit von `Get-BrokerMachine` → Filter im Cmdlet (`-SessionSupport`, `-RegistrationState`)
- [x] Kommentare an das tatsächliche Verhalten angepasst
- [x] README: englischer Kopf, Badges, Quickstart; GitHub-Description und Topics

## Offen

### Vor dem Rollout klären/testen

- [ ] **Alle Skripte auf Delivery Controller / StoreFront-Server testen** – Citrix-Teile sind lokal nicht testbar, nur Syntax + Linter geprüft
- [ ] **Get-EventError.ps1** – liefert jetzt zusätzlich Exit-Code 1/2/3. Prüfen, ob der Monitoring-Agent einen Exit-Code ≠ 0 als "Skript fehlgeschlagen" statt als Status interpretiert
- [ ] Welcher Monitoring-Agent wird eingesetzt und wertet er stdout oder Exit-Code aus? → in README dokumentieren

### Fachlich zu entscheiden

- [ ] **get-CitrixVersion.ps1** – Versionstabelle ab 7.42 (CVAD 2407 ff.) gegen Citrix-Doku prüfen und ergänzen
- [ ] **get-CitrixLicence.ps1** – Warning/Critical bei bald ablaufenden Lizenzen bzw. Subscription Advantage?
- [ ] **get-CitrixSFSync.ps1** – Critical, wenn `LastUpdateStatus` nicht `Complete` ist?
- [ ] **get-CitrixWorker.ps1** – Datenzeilen nutzen ` ; ` als Trennzeichen (Header `;`). Bewusst beibehalten wegen Kompatibilität, auf sauberes CSV umstellen, wenn der Agent-Parser angepasst wird?
- [ ] **get-CitrixRDS.ps1** – prüft nur den ersten Multisession-Worker. Alle Worker prüfen und Abweichungen melden?
- [ ] Dateinamen vereinheitlichen (`Get-` vs. `get-`) – Monitoring-Konfiguration referenziert die aktuellen Namen
