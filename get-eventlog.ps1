write-output ''
write-output ''
write-output ---------------------------------------------------------------------------------------
write-output ' Windows event '
write-output ''
write-output ''


$date = (get-date).AddMonths(-3).AddDays(-15)
$a = 'Logs ab dem ' + $date 
write-output $a
write-output -------------------------------------------
write-output SYSTEM

write-output ''

Get-EventLog -LogName System -After $date| where EntryType -eq error | Group-Object -Property Source -NoElement | Sort-Object -Property Count -Descending 


write-output ''
write-output $a
write-output -------------------------------------------
write-output APPLICATION
write-output ''
Get-EventLog -LogName APP* -After $date| Group-Object -Property Source -NoElement | Sort-Object -Property Count -Descending 


