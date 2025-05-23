param([string]$operation)

. $PSScriptRoot\common\functions.ps1

$services = @(
    "VMAuthdService",          # VMware Authorization Service
    "VmwareAutostartService",  # VMware Autostart Service
    "VMnetDHCP",               # DHCP
    "VMware NAT Service",      # NAT
    "VMUSBArbService"          # USB Arbitration
)

$actions = [ordered]@{
    "start" = @{ action = {
        foreach ($s in $services) { Start-Service -Name $s -ErrorAction SilentlyContinue }
        return $true
    }; success = "VMware services started."; failure = "Failed to start VMware services." }

    "stop" = @{ action = {
            foreach ($s in $services) { Stop-Service -Name $s -ErrorAction SilentlyContinue }
            return $true
    }; success = "VMware services stopped."; failure = "Failed to stop VMware services." }

    "restart" = @{ action = {
        foreach ($s in $services) { Restart-Service -Name $s -ErrorAction SilentlyContinue }
        return $true
    }; success = "VMware services restarted."; failure = "Failed to restart VMware services." }

    "status" = @{ action = {
        Display-Service-Status -servicesNames $services
        return $true
    }}
}

Write-Host "`n"

if (-not $actions.Contains($operation)) {
    Write-Host "Usage: vmware.ps1 [start|stop|restart|status]"
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
