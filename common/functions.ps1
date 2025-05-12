


function Is-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Display-Service-Status {
    param($servicesNames)

    # Define fixed column widths
    $nameWidth = 22
    $statusWidth = 12

    Write-Host ("-" * ($nameWidth + $statusWidth + 7))
    Write-Host ("| {0,-$nameWidth} | {1,-$statusWidth} |" -f "Service", "Status")
    Write-Host ("-" * ($nameWidth + $statusWidth + 7))

    foreach ($serviceName in $servicesNames) {
        try {
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            $color = if ($service.Status -eq 'Running') { 'DarkGreen' } else { 'DarkYellow' }
            $serviceLine = "| {0,-$nameWidth} | " -f $service.ServiceName
            Write-Host -NoNewline $serviceLine
            Write-Host -NoNewline ($service.Status.ToString().PadRight($statusWidth)) -ForegroundColor $color
            Write-Host " |"
        } catch {
            $errorLine = "| {0,-$nameWidth} | {1,-$statusWidth} |" -f $serviceName, "NOT FOUND"
            Write-Host $errorLine -ForegroundColor DarkYellow
        }
    }

    Write-Host ("-" * ($nameWidth + $statusWidth + 7))
}
