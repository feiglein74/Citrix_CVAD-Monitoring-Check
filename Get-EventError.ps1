#es können beim Ausführen die Parameter event, log, Month,Day,Hours und Count mitgegeben werden
#Event und Log sind verpflichtende parameter
#Event: es muss eine Event nummer mit übergeben werden
#Log es muss das Log angegeben werden das überprüft wird

#mit Month,Days,Hours kann man angeben wie weit zurück das Eventlog überprüft wird
#Count sagt aus wan eine Warnung ausgegeben wird

param (
    $event,
    [ValidateSet('Application','System')]
    $log, 
    $Month=0, 
    $Days=0,
    $Hours=4,
    $count=10
    )

$returnOK = 0
$returnWarning = 1
$returnCritical = 2
$returnUnknown = 3
$returnCode = $returnOK



#Schreibt das Datum bis zu dem überprüft wird in eine Variable
$date = (get-date).AddMonths(-$Month).AddDays(-$Days).AddHours(-$Hours)

#Get-WinEvent -LogName app* | Select-Object -first 1  | Get-member



$hash = @{LogName=$log;ID=$event;StartTime=$date}

$event = Get-WinEvent -FilterHashtable $hash -ErrorAction Ignore | Group-Object -Property ID

if($event.count -lt $count){
    write $returnOK
    }
else{
    write $returnCritical
    }
