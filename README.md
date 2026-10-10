# Citrix_CVAD-Monitoring-Check

PowerShell health-check scripts for **Citrix Virtual Apps and Desktops (CVAD / XenApp / XenDesktop)**, built to be called by a monitoring agent (Nagios, Icinga, PRTG, Checkmk …) with Nagios-style exit codes.

![License](https://img.shields.io/badge/license-MIT-blue) ![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white) ![Platform](https://img.shields.io/badge/platform-Windows%20%C2%B7%20Citrix%20DDC%20%2F%20StoreFront-0078D6)

Checks: site version, Citrix license server and license inventory, RDS license server on the workers, VDA/worker inventory, StoreFront replication state, Windows event log thresholds.

```text
PS> .\Get-EventError.ps1 -EventId 7036 -Log System -Days 7 -Count 1
2
PS> $LASTEXITCODE
2
```

**Exit codes:** `0` OK · `1` Warning · `2` Critical · `3` Unknown (snap-in missing, read error, missing parameters)

## Quickstart

```powershell
git clone https://github.com/feiglein74/Citrix_CVAD-Monitoring-Check.git
cd Citrix_CVAD-Monitoring-Check

# on a Delivery Controller (Citrix PowerShell snap-ins required)
.\Get-CitrixVersion.ps1          # e.g. "CVAD 2203 LTSR"
.\Get-CitrixWorker.ps1           # all machines of the site as CSV (semicolon)
.\Get-CitrixRDS.ps1              # warning if workers use different RDS license servers

# on a StoreFront server: critical if configuration replication failed
.\Get-CitrixSFSync.ps1

# anywhere: critical if event 1000 occurs 10+ times within the last 4 hours
.\Get-EventError.ps1 -EventId 1000 -Log Application -Hours 4 -Count 10
```

Point your monitoring agent at the script and evaluate the exit code (and stdout where noted).

> Detailed documentation is in German.

---

## Überblick

PowerShell-Skripte für den Health-Check einer Citrix Virtual Apps and Desktops (CVAD) Umgebung. Die Skripte werden von einem Monitoring-Agent aufgerufen und liefern Status bzw. Informationen über stdout und Exit-Code.

## Voraussetzungen

- Windows PowerShell 5.1 (PowerShell 7 für `Get-EventError.ps1` und `Get-EventSourceReport.ps1` ebenfalls möglich)
- Citrix-Skripte: Ausführung auf einem **Delivery Controller** (Citrix-Snapins `Citrix.*`)
- `Get-CitrixSFSync.ps1`: Ausführung auf einem **StoreFront-Server**
- `Get-CitrixLicense.ps1`: Zugriff auf den Lizenzserver über Port 8083
- `Get-CitrixRDS.ps1`: PowerShell-Remoting (WinRM) zu allen Multisession-Workern
- `Get-CitrixSFSync.ps1`: optional Modul `Citrix.StoreFront` für die Cluster-Erkennung (siehe unten)

## Exit-Codes

Alle Skripte folgen dem Nagios/Icinga/PRTG-Schema:

| Code | Bedeutung |
|------|-----------|
| 0 | OK |
| 1 | Warning |
| 2 | Critical |
| 3 | Unknown (Snapin fehlt, Fehler beim Auslesen, fehlende Parameter) |

Im Fehlerfall wird die Exception-Message mit ausgegeben (Ausnahme: `Get-EventError.ps1`, siehe unten).

## Skripte

| Skript | Läuft auf | Ausgabe | Exit-Code |
|--------|-----------|---------|-----------|
| `Get-CitrixVersion.ps1` | DDC | Release-Name der Site, z.B. `CVAD 2203 LTSR` | 0 / 3 |
| `Get-CitrixLicServer.ps1` | DDC | `True <server>` wenn der Lizenzserver der lokale Server ist, sonst `False <server>` | 0 / 3 (Info-Check) |
| `Get-CitrixLicense.ps1` | DDC | Tabelle der Lizenzen (Produkt, Edition, Modell, Ablauf, Subscription Advantage, belegt/frei) | 0 / 3 |
| `Get-CitrixRDS.ps1` | DDC | RDS-Lizenzserver aller Multisession-Worker; bei Abweichungen Liste pro Worker | 0 / 1 / 3 |
| `Get-CitrixWorker.ps1` | DDC | Alle Maschinen der Site als CSV (`;`) | 0 / 3 |
| `Get-CitrixSFSync.ps1` | StoreFront | Statuszeile + Tabellen der StoreFront-Replikation | 0 / 2 / 3 |
| `Get-EventError.ps1` | beliebig | Nur der Statuscode (`0`–`3`) | 0 / 1 / 2 / 3 |
| `Get-EventSourceReport.ps1` | beliebig | Bericht: Event-Quellen nach Häufigkeit | – |

### Get-EventError.ps1

Zählt das Vorkommen einer Event-ID in einem Zeitraum.

```powershell
.\Get-EventError.ps1 -EventId 1000 -Log Application -Hours 4 -Count 10 -Warning 5
```

| Parameter | Pflicht | Default | Beschreibung |
|-----------|---------|---------|--------------|
| `-EventId` (Alias `-event`) | ja | – | Event-ID(s) |
| `-Log` | ja | – | `Application` oder `System` |
| `-Month`, `-Days`, `-Hours` | nein | 0, 0, 4 | Zeitraum rückwärts ab jetzt |
| `-Count` | nein | 10 | ab dieser Anzahl **Critical** |
| `-Warning` | nein | 0 (aus) | ab dieser Anzahl **Warning** |

Ausgabe ist **nur** der Statuscode, weil der Agent stdout auswertet. Fehlende Pflichtparameter oder ein nicht lesbares Log ergeben `3`.

### Get-EventSourceReport.ps1

```powershell
.\Get-EventSourceReport.ps1 -Month 3 -Days 15
```

System-Log: nur Einträge mit Level *Error*. Application-Log: alle Einträge. Beides gruppiert nach Quelle, absteigend nach Anzahl.

### Get-CitrixWorker.ps1

CSV mit `;` als Trennzeichen, alle Felder in Anführungszeichen (`ConvertTo-Csv`). Mehrere Tags werden mit `,` verbunden.

```text
"DeliveryGroup";"DNSName";"IPAddress";"SessionSupport";"InMaintenanceMode";"Tags";"PowerState";"RegistrationState"
"DG Office";"ctx-w01.example.local";"10.0.0.11";"MultiSession";"False";"Office,Pool1";"On";"Registered"
```

### Get-CitrixRDS.ps1

Liest auf **allen** registrierten Multisession-Workern den per Policy gesetzten RDS-Lizenzserver (`HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services`, Wert `LicenseServers`) und vergleicht ihn. Reihenfolge und Groß-/Kleinschreibung spielen keine Rolle.

| Ergebnis | Exit | Ausgabe |
|----------|------|---------|
| alle Worker gleich | 0 | nur der Lizenzserver (wie bisher) |
| abweichender oder fehlender Eintrag, Worker nicht erreichbar | 1 | `WARNING - …` + eine Zeile pro Worker |
| kein Worker registriert / erreichbar | 3 | Fehlermeldung |

Pro Worker wird höchstens 15 Sekunden auf den Verbindungsaufbau gewartet, die Abfrage läuft parallel.

### Get-CitrixSFSync.ps1

Wertet die Konfigurations-Replikation der StoreFront-Servergruppe aus. Erste Zeile ist der Status, danach folgen Gesamtstatus und Status pro Server als Tabelle.

| Ergebnis | Exit |
|----------|------|
| letzte Replikation gesamt und auf allen Servern `completed` | 0 |
| StoreFront läuft nicht im Cluster (ein Server) | 0 |
| Replikation gesamt oder auf mindestens einem Server nicht `completed` | 2 |

Die Cluster-Erkennung nutzt `Get-STFServerGroup` aus dem Modul `Citrix.StoreFront`. Ist das Modul nicht verfügbar, entfällt sie – ein einzelner StoreFront-Server ohne Replikation würde dann Critical melden.

### Get-CitrixVersion.ps1

Übersetzt die `ProductVersion` der Site in den Release-Namen, bekannt bis 7.48 (CVAD 2607). Neuere Versionen werden als `Aktueller als CVAD 2607 (<version>)` ausgegeben.

## Quellen

Grundlagen für Werte und Verhalten, die sich nicht aus dem Code selbst ergeben (Stand 10.10.2026):

| Thema | Verwendet in | Quelle |
|-------|--------------|--------|
| Zuordnung `ProductVersion` (7.xx) → Release-Name | `Get-CitrixVersion.ps1` | [Carl Webster – Citrix product numbers and versions](https://www.carlwebster.com/citrix-xenapp-xendesktop-virtual-apps-and-desktop-product-numbers-and-versions/) (Community-Tabelle, keine offizielle Citrix-Quelle) |
| Versionsschema `7 YYMM` ab CVAD 1808 | `Get-CitrixVersion.ps1` | [Citrix Docs – New product names and version numbers](https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/1912-ltsr/new-names-numbers.html) |
| 2507 ist ein LTSR-Release | `Get-CitrixVersion.ps1` | [Citrix Docs – CVAD 2507 LTSR](https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/2507-ltsr/document-history.html) |
| `Get-ConfigSite` (u.a. `ProductVersion`, `LicenseServerName`) | `Get-CitrixVersion.ps1`, `Get-CitrixLicServer.ps1`, `Get-CitrixLicense.ps1` | [Citrix SDK – Get-ConfigSite](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2411/centralconfig/get-configsite) |
| Status `completed`, Aufbau von `ServerStates`, Cluster-Erkennung über `Get-STFServerGroup` | `Get-CitrixSFSync.ps1` | [ControlUp – StoreFront Health Checker](https://www.controlup.com/script-library-posts/storefront-health-checker/) (`Get-DSConfigurationReplicationState` ist von Citrix nicht öffentlich dokumentiert) |
| `Get-STFServerGroup` (Mitglieder der Servergruppe) | `Get-CitrixSFSync.ps1` | [Citrix StoreFront SDK – Get-STFServerGroup](https://developer-docs.citrix.com/en-us/storefront-powershell-sdk/current-release/Get-STFServerGroup/) |
| Offiziell dokumentiertes Gegenstück zur Replikationsabfrage | `Get-CitrixSFSync.ps1` | [Citrix StoreFront SDK – Get-STFServerGroupConfiguration](https://developer-docs.citrix.com/en-us/storefront-powershell-sdk/current-release/Get-STFServerGroupConfiguration/) |

## Lizenz

MIT, siehe [LICENSE](LICENSE).
