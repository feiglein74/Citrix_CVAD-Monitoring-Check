#es können beim Ausführen die Parameter event, log, Month,Day,Hours und Count mitgegeben werden
#Event und Log sind verpflichtende parameter
#Event: es muss eine Event nummer mit übergeben werden
#Log es muss das Log angegeben werden das überprüft wird

#mit Month,Days,Hours kann man angeben wie weit zurück das Eventlog überprüft wird
#Count sagt aus wan eine Warnung ausgegeben wird
#Warning (optional) gibt ab dieser Anzahl Warning aus, Count bleibt die Schwelle für Critical

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

#Schreibt das Datum bis zu dem überprüft wird in eine Variable
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
