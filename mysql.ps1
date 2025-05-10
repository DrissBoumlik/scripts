param([string]$operation)

$actions = [ordered]@{
    "start" = @{action = {
        Start-Service "MariaDB"
        Write-Host "MariaDB service started." -ForegroundColor Green
    }}
    "stop" = @{action = {
        Stop-Service "MariaDB"
        Write-Host "MariaDB service stopped." -ForegroundColor Yellow
    }}
    "restart" = @{action = {
        Restart-Service "MariaDB"
        Write-Output "MariaDB service restarted."
    }}
    "status" = @{action = {
        $service = Get-Service "MariaDB"
        if ($service.Status -eq 'Running') {
            Write-Host "MariaDB service is running." -ForegroundColor Green
        } else {
            Write-Host "MariaDB service is stopped." -ForegroundColor Yellow
        }
    }}
}

Write-Host "`n"

if (-not $actions.Contains($operation)) {
    Write-Output "Usage: mysql [start|stop|restart|status]"
    exit 0
}

$actions[$operation].action.Invoke()
