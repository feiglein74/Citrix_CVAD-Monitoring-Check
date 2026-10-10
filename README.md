# Citrix_CVAD-Monitoring-Check

PowerShell-Skripte für den Health-Check einer Citrix Virtual Apps and Desktops (CVAD) Umgebung. Die Skripte werden von einem Monitoring-Agent aufgerufen und liefern Status bzw. Informationen über stdout und Exit-Code.

## Voraussetzungen

- Windows PowerShell 5.1 (PowerShell 7 für `Get-EventError.ps1` und `get-eventlog.ps1` ebenfalls möglich)
- Citrix-Skripte: Ausführung auf einem **Delivery Controller** (Citrix-Snapins `Citrix.*`)
- `get-CitrixSFSync.ps1`: Ausführung auf einem **StoreFront-Server**
- `get-CitrixLicence.ps1`: Zugriff auf den Lizenzserver über Port 8083
- `get-CitrixRDS.ps1`: PowerShell-Remoting (WinRM) zu den Workern

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
| `get-CitrixVersion.ps1` | DDC | Release-Name der Site, z.B. `CVAD 2203 LTSR` | 0 / 3 |
| `get-CitrixLicServer.ps1` | DDC | `True <server>` wenn der Lizenzserver der lokale Server ist, sonst `False <server>` | 0 / 3 (Info-Check) |
| `get-CitrixLicence.ps1` | DDC | Tabelle der Lizenzen (Produkt, Edition, Modell, Ablauf, Subscription Advantage, belegt/frei) | 0 / 3 |
| `get-CitrixRDS.ps1` | DDC | RDS-Lizenzserver aus der Registry des ersten registrierten Multisession-Workers | 0 / 3 |
| `get-CitrixWorker.ps1` | DDC | Alle Maschinen der Site als `;`-getrennte Liste | 0 / 3 |
| `get-CitrixSFSync.ps1` | StoreFront | Tabelle des Replikationsstatus der StoreFront-Servergruppe | 0 / 3 |
| `Get-EventError.ps1` | beliebig | Nur der Statuscode (`0`–`3`) | 0 / 1 / 2 / 3 |
| `get-eventlog.ps1` | beliebig | Bericht: Event-Quellen nach Häufigkeit | – |

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

### get-eventlog.ps1

```powershell
.\get-eventlog.ps1 -Month 3 -Days 15
```

System-Log: nur Einträge mit Level *Error*. Application-Log: alle Einträge. Beides gruppiert nach Quelle, absteigend nach Anzahl.

### get-CitrixWorker.ps1

Spalten: `DeliveryGroup;DNSName;IPAddress;SessionSupport;InMaintenanceMode;Tags;PowerState;RegistrationState`

Die Datenzeilen verwenden ` ; ` (mit Leerzeichen) als Trennzeichen – kompatibel zur bisherigen Ausgabe. Mehrere Tags werden mit `,` verbunden.

## Lizenz

MIT, siehe [LICENSE](LICENSE).
