


function Is-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Display-Service-Status {
    param($servicesNames)

    $maxLineLength = 60
    foreach ($serviceName in $servicesNames) {
        try {
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            $color = if ($service.Status -eq 'Running') { 'DarkGreen' } else { 'DarkYellow' }
            $dotsCount = $maxLineLength - $ServiceName.Length
            if ($dotsCount -lt 0) { $dotsCount = 0 }

            $dots = '.' * $dotsCount
            Write-Host "$ServiceName $dots " -NoNewline
            Write-Host $service.Status -ForegroundColor $color
        } catch {
            $dots = '.' * ($maxLineLength - $ServiceName.Length)
            Write-Host "$ServiceName $dots " -NoNewline
            Write-Host "NOT FOUND" -ForegroundColor Yellow
        }
    }
}
