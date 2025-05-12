param([string]$operation)

. $PSScriptRoot\common\functions.ps1

$actions = [ordered]@{
    "start" = @{ action = {
        Start-Service "MariaDB"; return $true
    }; success = "MariaDB service started."; failure = "Failed to start MariaDB service." }

    "stop" = @{ action = {
        Stop-Service "MariaDB"; return $true
    }; success = "MariaDB service stopped."; failure = "Failed to stop MariaDB service." }

    "restart" = @{ action = {
        Restart-Service "MariaDB"; return $true
    }; success = "MariaDB service restarted."; failure = "Failed to restart MariaDB service." }

    "status" = @{ action = {
        Display-Service-Status -servicesNames @("MariaDB")
        return $true
    }}
}

Write-Host "`n"

if (-not $actions.Contains($operation)) {
    Write-Host "Usage: mysql.ps1 [start|stop|restart|status]"
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
