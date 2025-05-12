param([string]$operation)

. $PSScriptRoot\common\functions.ps1

$messages = [ordered]@{
    "start"   = "Valet services have been started."
    "stop"    = "Valet services have been stopped."
    "restart" = "Valet services have been restarted."
    "status"  = "Valet services status displayed."
}

if (-not $messages.Contains($operation)) {
    Write-Host "`nUsage: valet.ps1 [start|stop|restart|status]"
    exit 1
}


if ($operation -eq "status") {
    $services = @("valet_phpcgi_xdebug", "valet_phpcgi", "valet_nginx")

    Write-Host "`n"
    Display-Service-Status -servicesNames $services
    
    exit 0
}


function Display-Output-Message {
    param($exitCode, $operation)

    if ($exitCode -eq 0) {
        $message = $messages[$operation]
        Write-Host "`n$message" -ForegroundColor DarkGreen
    } else {
        Write-Host "`nvalet $operation failed with code $exitCode." -ForegroundColor DarkYellow
    }

    exit $exitCode
}


# Path to valet.bat
$valetBat = "$env:APPDATA\Composer\vendor\bin\valet.bat"

if (-not (Test-Path $valetBat)) {
    Write-Host "`nOups! Could not find valet.bat at:" -ForegroundColor DarkYellow
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
        Write-Host "`nOups! Admin elevation was cancelled or failed." -ForegroundColor DarkYellow
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