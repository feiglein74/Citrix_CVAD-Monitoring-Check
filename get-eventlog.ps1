#Bericht: Event-Quellen im System- und Application-Log, gruppiert und nach Häufigkeit sortiert
#System: nur Einträge mit Level Error, Application: alle Einträge
#mit Month und Days kann man angeben wie weit zurück das Eventlog ausgewertet wird
param (
    [int]$Month=3,
    [int]$Days=15
    )

#Out-String -Width: ohne Angabe wird die Tabelle bei umgeleiteter Ausgabe (Monitoring-Agent) auf ca. 80 Zeichen gekürzt
#Get-EventLog gibt es in PowerShell 7 nicht mehr, daher Get-WinEvent (ProviderName entspricht Source)
function Get-EventSourceCount($filter){
    try{
        Get-WinEvent -FilterHashtable $filter -ErrorAction Stop |
            Group-Object -Property ProviderName -NoElement |
            Sort-Object -Property Count -Descending |
            Format-Table Count, Name -AutoSize |
            Out-String -Width 4096
    }
    catch{
        #keine passenden Events ist kein Fehler
        if($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*'){
            Write-Output 'Keine Eintraege gefunden'
        }
        else{
            Write-Output "Fehler beim auslesen: $($_.Exception.Message)"
        }
    }
}

Write-Output ''
Write-Output ''
Write-Output ---------------------------------------------------------------------------------------
Write-Output ' Windows event '
Write-Output ''
Write-Output ''


$date = (Get-Date).AddMonths(-$Month).AddDays(-$Days)
$a = 'Logs ab dem ' + $date
Write-Output $a
Write-Output -------------------------------------------
Write-Output 'SYSTEM (nur Errors)'

Write-Output ''

Get-EventSourceCount @{LogName='System'; Level=2; StartTime=$date}


Write-Output ''
Write-Output $a
Write-Output -------------------------------------------
Write-Output 'APPLICATION (alle Eintraege)'
Write-Output ''
Get-EventSourceCount @{LogName='Application'; StartTime=$date}
