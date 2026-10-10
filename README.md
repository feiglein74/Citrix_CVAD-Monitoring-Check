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
.\Get-CitrixWorker.ps1           # all machines of the site, semicolon separated

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
- `Get-CitrixRDS.ps1`: PowerShell-Remoting (WinRM) zu den Workern

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
| `Get-CitrixRDS.ps1` | DDC | RDS-Lizenzserver aus der Registry des ersten registrierten Multisession-Workers | 0 / 3 |
| `Get-CitrixWorker.ps1` | DDC | Alle Maschinen der Site als `;`-getrennte Liste | 0 / 3 |
| `Get-CitrixSFSync.ps1` | StoreFront | Tabelle des Replikationsstatus der StoreFront-Servergruppe | 0 / 3 |
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

Spalten: `DeliveryGroup;DNSName;IPAddress;SessionSupport;InMaintenanceMode;Tags;PowerState;RegistrationState`

Die Datenzeilen verwenden ` ; ` (mit Leerzeichen) als Trennzeichen – kompatibel zur bisherigen Ausgabe. Mehrere Tags werden mit `,` verbunden.

## Lizenz

MIT, siehe [LICENSE](LICENSE).
