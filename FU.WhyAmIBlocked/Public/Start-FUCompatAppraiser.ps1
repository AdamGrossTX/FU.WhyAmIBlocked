function Start-FUCompatAppraiser {
    [cmdletbinding()]
    param()
    try {
        $TaskName = "Microsoft Compatibility Appraiser"
        Write-Host " + $($TaskName) .. " -ForegroundColor Cyan -NoNewline
        $AppraiserTask = Get-ScheduledTask -TaskName $TaskName
        $AppraiserTask | Get-ScheduledTaskInfo
        $AppraiserTask | Start-ScheduledTask
        Do { start-sleep -Seconds 10 }
        Until ((Get-ScheduledTask -TaskName $TaskName).State -eq "Ready")
        Write-Host $script:tick -ForegroundColor Green
    }
    catch {
        Write-Warning $_
    }

}