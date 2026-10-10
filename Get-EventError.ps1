#Zählt, wie oft eine Event-ID im angegebenen Zeitraum aufgetreten ist
#Parameter: EventId, Log, Month, Days, Hours, Count, Warning
#EventId und Log sind verpflichtende Parameter, fehlt einer: exit 3 (Unknown)
#EventId: eine oder mehrere Event-Nummern
#Log: das Log, das überprüft wird (Application oder System)

#mit Month,Days,Hours kann man angeben wie weit zurück das Eventlog überprüft wird
#Count: ab dieser Anzahl wird Critical ausgegeben
#Warning (optional): ab dieser Anzahl wird Warning ausgegeben, 0 = aus

#Ausgabe: nur der Statuscode (0/1/2/3) auf stdout, derselbe Wert ist der Exit-Code
#der Monitoring-Agent wertet die Ausgabe aus, daher keine weiteren Texte ausgeben

#Parameter EventId hieß früher $event (automatische Variable), Alias hält Aufrufe mit -event kompatibel
#kein [Parameter(Mandatory)]: der Agent läuft nicht interaktiv, PowerShell würde auf eine Eingabe warten
param (
    [Alias('event')]
    [int[]]$EventId,
    [ValidateSet('Application','System')]
    [string]$Log,
    [int]$Month=0,
    [int]$Days=0,
    [int]$Hours=4,
    [int]$Count=10,
    [int]$Warning=0
    )

$returnOK = 0
$returnWarning = 1
$returnCritical = 2
$returnUnknown = 3

if(-not $EventId -or -not $Log){
    Write-Output $returnUnknown
    exit $returnUnknown
}

#Startzeitpunkt der Prüfung: jetzt minus Month/Days/Hours
$date = (Get-Date).AddMonths(-$Month).AddDays(-$Days).AddHours(-$Hours)

$hash = @{LogName=$Log;ID=$EventId;StartTime=$date}

try{
    $eventCount = @(Get-WinEvent -FilterHashtable $hash -ErrorAction Stop).Count
}
catch{
    #keine passenden Events ist kein Fehler, alles andere (z.B. Zugriff verweigert) schon
    if($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*'){
        $eventCount = 0
    }
    else{
        Write-Output $returnUnknown
        exit $returnUnknown
    }
}

if($eventCount -ge $Count){
    $returnCode = $returnCritical
}
elseif(($Warning -gt 0) -and ($eventCount -ge $Warning)){
    $returnCode = $returnWarning
}
else{
    $returnCode = $returnOK
}

Write-Output $returnCode
exit $returnCode
