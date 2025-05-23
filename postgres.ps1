param([string]$operation)

. $PSScriptRoot\common\functions.ps1

$actions = [ordered]@{
    "start" = @{ action = {
        Start-Service "postgresql-x64-17"; return $true
    }; success = "Postgres service started."; failure = "Failed to start Postgres service." }

    "stop" = @{ action = {
        Stop-Service "postgresql-x64-17"; return $true
    }; success = "Postgres service stopped."; failure = "Failed to stop Postgres service." }

    "restart" = @{ action = {
        Restart-Service "postgresql-x64-17"; return $true
    }; success = "Postgres service restarted."; failure = "Failed to restart Postgres service." }

    "status" = @{ action = {
        Display-Service-Status -servicesNames @("postgresql-x64-17")
        return $true
    }}
}

Write-Host "`n"

if (-not $actions.Contains($operation)) {
    Write-Host "Usage: postgres.ps1 [start|stop|restart|status]"
    exit $true
}

# If already admin, run the action directly
if (($operation -eq "status") -or (Is-Admin)) {
    $exitCode = $actions[$operation].action.Invoke()
    if ($exitCode -eq $true) {
        Write-Host $actions[$operation].success -ForegroundColor DarkGreen
    } else {
        Write-Host $actions[$operation].failure -ForegroundColor DarkYellow
    }
    exit $exitCode
}

# Not admin - relaunch as admin
try {
    $arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" `"$operation`""
    $process = Start-Process powershell -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -PassThru  
    $process.WaitForExit()
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0) {
        Write-Host $actions[$operation].success -ForegroundColor DarkGreen
    } else {
        Write-Host $actions[$operation].failure -ForegroundColor DarkYellow
    }

    exit $exitCode
}
catch {
    Write-Host "Operation canceled or failed to elevate privileges." -ForegroundColor DarkYellow
    exit 1
}
