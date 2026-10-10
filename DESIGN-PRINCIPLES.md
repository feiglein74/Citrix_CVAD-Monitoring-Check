# Design-Prinzipien für Citrix_CVAD-Monitoring-Check

## Leitprinzipien

### 1. Vollständigkeit vor Kürze

Ein Health-Check, der Daten verschluckt, meldet "alles OK", obwohl er nur einen Teil gesehen hat.

**Konkret im Projekt:**
- Cmdlets mit eingebautem Limit bekommen das Limit explizit aufgehoben (`Get-BrokerMachine` liefert ohne `-MaxRecordCount` nur 250 Maschinen)
- Tabellen werden in voller Breite ausgegeben – der Agent leitet die Ausgabe um, dann kürzt PowerShell auf die Fensterbreite (ca. 80 Zeichen) oder lässt ganze Spalten weg

```powershell
# ❌ FALSCH - beim Agent werden Spalten abgeschnitten oder fehlen
Get-LicInventory ... | Format-Table Produkt, Edition, Ablauf, InUse, Available

# ✅ RICHTIG - volle Breite unabhängig vom Aufrufer
Get-LicInventory ... | Format-Table Produkt, Edition, Ablauf, InUse, Available -AutoSize | Out-String -Width 4096
```

### 2. Opt-in statt Opt-out für Einschränkungen

Schwellwerte und zusätzliche Bewertungen sind optional und standardmäßig aus.

```powershell
# ✅ -Warning ist 0 (aus), wer eine Warnstufe will, setzt sie
.\Get-EventError.ps1 -EventId 1000 -Log Application -Count 10 -Warning 5
```

### 3. Transparenz bei Modifikationen

Wenn ein Skript filtert, steht das in der Ausgabe.

```powershell
# ❌ FALSCH - Leser weiß nicht, dass etwas fehlt
APPLICATION

# ✅ RICHTIG
SYSTEM (nur Errors)
APPLICATION (alle Eintraege)
[2 Eintraege ohne LicenseEdition ausgeblendet]
```

## Projekt-spezifische Entscheidungen

### Die Ausgabe ist eine Schnittstelle

Die Skripte werden von einem Monitoring-Agent aufgerufen, der stdout und/oder den Exit-Code auswertet. Eine Änderung am Ausgabeformat kann eine Prüfung unbemerkt kaputt machen.

**Regel:** Bestehende Ausgabeformate bleiben bytegleich, solange der Agent-Parser nicht mit angepasst wird. Formatänderungen werden im CHANGELOG als Breaking markiert (Major-Version).

Wird ein Check um eine Bewertung erweitert, bleibt die bisherige Ausgabe im Gutfall möglichst erhalten und nur der Problemfall bekommt ein neues Format (Beispiel `Get-CitrixRDS.ps1`: einheitlich → nur der Lizenzserver wie bisher, Abweichung → `WARNING - …` mit Liste).

```powershell
# ❌ FALSCH - "verbesserte" Ausgabe, Agent erwartet nur die Zahl
Write-Output "CRITICAL - 12 Events (ID 1000) seit 08:00"

# ✅ RICHTIG - stdout wie bisher, Exit-Code zusätzlich
Write-Output $returnCode
exit $returnCode
```

Beispiele für bewusst beibehaltene Eigenheiten:
- `Get-EventError.ps1` gibt nur den Statuscode aus (daher auch keine Fehlerdetails – Ausnahme zu Prinzip "Fehler-Details vollständig")
- `Get-CitrixLicServer.ps1` gibt `True <server>` / `False <server>` aus und endet immer mit 0 (Info-Check)

### Exit-Codes nach Nagios-Schema

`0` OK, `1` Warning, `2` Critical, `3` Unknown. **Unknown heißt: Das Skript konnte nicht prüfen** – Snapin fehlt, Zugriff verweigert, Parameter fehlen. Ein Fehler darf nie als OK durchgehen.

```powershell
# ❌ FALSCH - "Zugriff verweigert" sieht aus wie "keine Events" → OK
Get-WinEvent -FilterHashtable $hash -ErrorAction Ignore

# ✅ RICHTIG - nur "keine Treffer" ist 0, alles andere Unknown
catch {
    if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') { $eventCount = 0 }
    else { exit 3 }
}
```

### Nicht interaktiv

Der Agent läuft ohne Konsole. Nichts darf auf eine Eingabe warten.

```powershell
# ❌ FALSCH - fehlt der Parameter, wartet PowerShell auf Eingabe und der Check hängt
param([Parameter(Mandatory)]$EventId)

# ✅ RICHTIG - selbst prüfen und Unknown melden
if (-not $EventId) { Write-Output 3; exit 3 }
```

### Eigenständige Skripte

Jedes Skript ist allein lauffähig. Der Snapin-Check ist in jedem Skript dupliziert, statt in ein gemeinsames Modul ausgelagert zu werden – sonst müsste das Modul auf jeden Agent mitverteilt werden, und ein fehlendes Modul ließe alle Checks gleichzeitig ausfallen.

### Kompatibilität mit Windows PowerShell 5.1

Delivery Controller haben nicht zwingend PowerShell 7, die Citrix-Snapins laufen nur in 5.1.

- Dateien als **UTF-8 mit BOM** – ohne BOM liest 5.1 die Datei als ANSI und Umlaute werden falsch dargestellt
- Ausgabetexte trotzdem ohne Umlaute (`Eintraege`), damit sie auch bei falsch eingestellter Codepage des Agents lesbar bleiben
- Keine Cmdlets, die es nur in einer Version gibt (`Get-EventLog` fehlt in 7 → `Get-WinEvent`)

### Robuste Datenquellen

Werte aus strukturierten Properties lesen, nicht aus Freitext parsen.

```powershell
# ❌ FALSCH - bricht, sobald Citrix den Meldungstext ändert
(Get-BrokerController)[0].LastLicensingServerEventDetails -split ": "

# ✅ RICHTIG
(Get-ConfigSite).LicenseServerName
```

## Test-Kriterium

> **"Wird der Monitoring-Agent – oder der Admin, der um 3 Uhr nachts den Alarm liest – überrascht sein?"**

Wenn JA → Design ändern.

## Merksätze

> **"Der Default ist die Wahrheit, Einschränkungen sind explizit."**

> **"Die Ausgabe ist eine Schnittstelle."**

> **"Wer nicht prüfen konnte, meldet Unknown – nie OK."**
