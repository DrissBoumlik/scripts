param([ValidateSet("start", "stop", "restart", "status")][string]$operation)

$messages = @{
    start   = "Valet services have been started."
    stop    = "Valet services have been stopped."
    restart = "Valet services have been restarted."
    status = "Valet services status displayed."
}

if (-not $messages.Contains($operation)) {
    Write-Host "`nUsage: valet.ps1 [start|stop|restart|status]"
    exit 1
}


if ($operation -eq "status") {
    $services = @("valet_phpcgi_xdebug", "valet_phpcgi", "valet_nginx")

    Write-Host "`n"
    foreach ($s in $services) {
        try {
            $service = Get-Service -Name $s -ErrorAction Stop
            $color = if ($service.Status -eq 'Running') { 'Green' } else { 'Yellow' }
            Write-Host "$s is $($service.Status)." -ForegroundColor $color
        } catch {
            Write-Host "$s not found or failed to get status." -ForegroundColor Yellow
        }
    }
    
    exit 0
}

function Is-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Display-Output-Message {
    param($exitCode, $operation)

    if ($exitCode -eq 0) {
        $message = $messages[$operation]
        Write-Host "`n$message" -ForegroundColor Green
    } else {
        Write-Host "`nvalet $operation failed with code $exitCode." -ForegroundColor Yellow
    }

    exit $exitCode
}


# Path to valet.bat
$valetBat = "$env:APPDATA\Composer\vendor\bin\valet.bat"

if (-not (Test-Path $valetBat)) {
    Write-Host "`nOups! Could not find valet.bat at:" -ForegroundColor Yellow
    Write-Host $valetBat
    exit 1
}

# Relaunch as Admin if not already
if (-not (Is-Admin)) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $operation"
    $psi.Verb = "runas"
    $psi.WindowStyle = "Hidden"
    $psi.UseShellExecute = $true

    try {
        $proc = [System.Diagnostics.Process]::Start($psi)
        $proc.WaitForExit()
        
        Display-Output-Message -exitCode $proc.ExitCode -operation $operation
        
    } catch {
        Write-Host "`nOups! Admin elevation was cancelled or failed." -ForegroundColor Yellow
        exit 1
    }
}

# Run valet command
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $valetBat
$startInfo.Arguments = $operation
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $startInfo
$proc.Start() | Out-Null

$output = $proc.StandardOutput.ReadToEnd()
$errorOutput = $proc.StandardError.ReadToEnd()
$proc.WaitForExit()


Display-Output-Message -exitCode $proc.ExitCode -operation $operation