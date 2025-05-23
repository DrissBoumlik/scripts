


function Is-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Display-Service-Status {
    param($servicesNames)

    $maxLineLength = 60
    foreach ($serviceName in $servicesNames) {
            $serviceNameFormatted = $serviceName
        try {
            if ($serviceNameFormatted -match '[_-]') {
                $serviceNameFormatted = ($serviceName -replace '_', ' ' -split ' ' | ForEach-Object {
                    $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower()
                }) -join ' '
            }
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            $color = if ($service.Status -eq 'Running') { 'DarkGreen' } else { 'DarkYellow' }
            $dotsCount = $maxLineLength - $serviceNameFormatted.Length
            if ($dotsCount -lt 0) { $dotsCount = 0 }

            $dots = '.' * $dotsCount
            Write-Host "$serviceNameFormatted $dots " -NoNewline
            Write-Host $service.Status -ForegroundColor $color
        } catch {
            $dots = '.' * ($maxLineLength - $serviceNameFormatted.Length)
            Write-Host "$serviceNameFormatted $dots " -NoNewline
            Write-Host "NOT FOUND" -ForegroundColor Yellow
        }
    }
}

function Display-Output-Message {
    param($exitCode, $operation)

    if ($exitCode -eq 0) {
        $message = $messages[$operation]
        Write-Host "`n$message" -ForegroundColor DarkGreen
    } else {
        Write-Host "`nvalet $operation failed with code $exitCode." -ForegroundColor DarkYellow
    }
}