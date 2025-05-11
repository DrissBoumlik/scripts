param([string]$operation)

function Is-Admin {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

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
        $service = Get-Service "MariaDB"
        if ($service.Status -eq 'Running') {
            Write-Host "MariaDB service is running." -ForegroundColor Green
        } else {
            Write-Host "MariaDB service is stopped." -ForegroundColor Yellow
        }
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
        Write-Host $actions[$operation].success -ForegroundColor Green
    } else {
        Write-Host $actions[$operation].failure -ForegroundColor Yellow
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
        Write-Host $actions[$operation].success -ForegroundColor Green
    } else {
        Write-Host $actions[$operation].failure -ForegroundColor Yellow
    }

    exit $exitCode
}
catch {
    Write-Host "Operation canceled or failed to elevate privileges." -ForegroundColor Yellow
    exit 1
}
