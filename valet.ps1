param([string]$operation)

function Is-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$services = @(
    "valet_phpcgi_xdebug",
    "valet_phpcgi",
    "valet_nginx"
)

$actions = [ordered]@{
    "start" = @{ action = {
            foreach ($s in $services) {
                try {
                    Start-Service -Name $s -ErrorAction Stop
                    Write-Host "Started $s." -ForegroundColor Green
                } catch {
                    Write-Host "Failed to start $s" -ForegroundColor Red
                }
            }
            return 0
        }; success = "Valet services started."; failure = "Failed to start some services."}

    "stop" = @{ action = {
            foreach ($s in $services) {
                try {
                    Stop-Service -Name $s -ErrorAction Stop
                    Write-Host "Stopped $s." -ForegroundColor Yellow
                } catch {
                    Write-Host "Failed to stop $s" -ForegroundColor Red
                }
            }
            return 0
        }; success = "Valet services stopped."; failure = "Failed to stop some services."}

    "restart" = @{ action = {
            foreach ($s in $services) {
                try {
                    Restart-Service -Name $s -ErrorAction Stop
                    Write-Host "Restarted $s." -ForegroundColor Cyan
                } catch {
                    Write-Host "Failed to restart $s" -ForegroundColor Red
                }
            }
            return 0
        }; success = "Valet services restarted."; failure = "Failed to restart some services."}

    "status" = @{ action = {
            foreach ($s in $services) {
                try {
                    $service = Get-Service -Name $s -ErrorAction Stop
                    $color = if ($service.Status -eq 'Running') { 'Green' } else { 'Yellow' }
                    Write-Host "$s is $($service.Status)." -ForegroundColor $color
                } catch {
                    Write-Host "$s not found or failed to get status." -ForegroundColor Red
                }
            }
            return 0
        }}
}

Write-Host "`n"

if (-not $actions.Contains($operation)) {
    Write-Host "Usage: valet.ps1 [start|stop|restart|status]"
    exit 1
}


# If already admin, run the action directly
if (($operation -eq "status") -or (Is-Admin)) {
    $exitCode = & $actions[$operation].action

    if ($exitCode -eq 0 -and $actions[$operation].success) {
        Write-Host $actions[$operation].success -ForegroundColor Green
    } elseif ($actions[$operation].failure) {
        Write-Host $actions[$operation].failure -ForegroundColor Red
    }

    exit $exitCode
}
    

try {
    $arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" `"$operation`""
    $process = Start-Process powershell -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -PassThru  
    $process.WaitForExit()
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0 -and $actions[$operation].success) {
        Write-Host $actions[$operation].success -ForegroundColor Green
    } elseif ($actions[$operation].failure) {
        Write-Host $actions[$operation].failure -ForegroundColor Red
    }

    exit $exitCode
} catch {
    Write-Host "Operation cancelled or failed to elevate." -ForegroundColor Red
    exit 1
}

