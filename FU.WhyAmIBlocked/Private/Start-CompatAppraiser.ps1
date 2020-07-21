Function Start-CompatAppraiser {
    [cmdletbinding()]
    $TaskName = "Microsoft Compatibility Appraiser"
    $AppraiserTask = Get-ScheduledTask -TaskName $TaskName
    $AppraiserTask | Get-ScheduledTaskInfo
    $AppraiserTask | Start-ScheduledTask
    Do{start-sleep -Seconds 10}
    Until ((Get-ScheduledTask -TaskName $TaskName).State -eq "Ready")
}