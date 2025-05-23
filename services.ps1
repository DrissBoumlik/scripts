param(
    [string]$operation
)

. $PSScriptRoot\common\functions.ps1

$serviceNames = $args

# Define services and their commands
$services = [ordered]@{
    "mariadb" = @{
        "actions" = @{
            "start" = @{ action = {
                Start-Service "MariaDB" -ErrorAction SilentlyContinue
                return 0
            }; success = "MariaDB service started."; failure = "Failed to start MariaDB service." }
            "stop" = @{ action = {
                Stop-Service "MariaDB" -ErrorAction SilentlyContinue
                return 0
            }; success = "MariaDB service stopped."; failure = "Failed to stop MariaDB service." }
            "restart" = @{ action = {
                Restart-Service "MariaDB" -ErrorAction SilentlyContinue
                return 0
            }; success = "MariaDB service restarted."; failure = "Failed to restart MariaDB service." }
            "status" = @{ action = {
                Display-Service-Status -servicesNames @("MariaDB")
                return 0
            }}
        }
    }
    "postgres" = @{
        "actions" = @{
            "start" = @{ action = {
                Start-Service "postgresql-x64-17" -ErrorAction SilentlyContinue
                return 0
            }; success = "Postgres service started."; failure = "Failed to start Postgres service." }
            "stop" = @{ action = {
                Stop-Service "postgresql-x64-17" -ErrorAction SilentlyContinue
                return 0
            }; success = "Postgres service stopped."; failure = "Failed to stop Postgres service." }
            "restart" = @{ action = {
                Restart-Service "postgresql-x64-17" -ErrorAction SilentlyContinue
                return 0
            }; success = "Postgres service restarted."; failure = "Failed to restart Postgres service." }
            "status" = @{ action = {
                Display-Service-Status -servicesNames @("postgresql-x64-17")
                return 0
            }}
        }
    }
    "valet" = @{
        "actions" = @{
            "start" = @{ action = {
                $exitCode = $services["valet"]["actions"]["default"].action.Invoke()
                return $exitCode
            }; success = "Valet services started."; failure = "Failed to start Valet services." }
            "stop" = @{ action = {
                $exitCode = $services["valet"]["actions"]["default"].action.Invoke()
                return $exitCode
            }; success = "Valet services stopped."; failure = "Failed to stop Valet services." }
            "restart" = @{ action = {
                $exitCode = $services["valet"]["actions"]["default"].action.Invoke()
                return $exitCode
            }; success = "Valet services restarted."; failure = "Failed to restart Valet services." }
            "default" = @{ action = {
                # Path to valet.bat
                $valetBat = "$env:APPDATA\Composer\vendor\bin\valet.bat"
                
                if (-not (Test-Path $valetBat)) {
                    Write-Host "`nOups! Could not find valet.bat at:" -ForegroundColor DarkYellow
                    Write-Host $valetBat
                    exit 1
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
                
                return $proc.ExitCode
            }}
            "status" = @{ action = {
                Display-Service-Status -servicesNames $services["valet"]["list"]
                return 0
            }}
        }
        "list" = @("valet_phpcgi_xdebug", "valet_phpcgi", "valet_nginx")
    }
    "vmware" = @{
        "actions" = @{
            "start" = @{ action = {
                $services["vmware"]["list"] | ForEach-Object { Start-Service $_ -ErrorAction SilentlyContinue }
                return 0
            }; success = "VMware services started."; failure = "Failed to start VMware services." }
            "stop" = @{ action = {
                $services["vmware"]["list"] | ForEach-Object { Stop-Service $_ -ErrorAction SilentlyContinue }
                return 0
            }; success = "VMware services stopped."; failure = "Failed to stop VMware services." }
            "restart" = @{ action = {
                $services["vmware"]["list"] | ForEach-Object { Restart-Service $_ -ErrorAction SilentlyContinue }
                return 0
            }; success = "VMware services restarted."; failure = "Failed to restart VMware services." }
            "status" = @{ action = {
                Display-Service-Status -servicesNames $services["vmware"]["list"]
                return 0
            }}
        }
        "list" = @("VMAuthdService", "VmwareAutostartService", "VMnetDHCP", "VMware NAT Service", "VMUSBArbService")
    }
}


function Show-Services {
    Write-Host "Supported services:"
    $services.Keys | ForEach-Object { Write-Host " - $_" }
}

Write-Host "`n"

# Handle list action
if ($operation -eq "list") {
    Show-Services
    exit 0
}

# Validate service
if ($serviceName -eq "") {
    Write-Host "Provide a valid service name."
    Show-Services
    exit 1
}

# Validate action for the service
$serviceNames | ForEach-Object {
    if (-not $services.Contains($_)) {
        Write-Host "Unknown service: $_"
        exit 1
    } elseif (-not $services[$_]['actions'].ContainsKey($operation)) {
        Write-Host "Action '$operation' not supported for service '$_'"
        exit 1
    }
}

# Execute the command
if (($operation -eq "status") -or (Is-Admin)) {
    foreach ($serviceName in $serviceNames) {
        $exitCode = & $services[$serviceName]['actions'][$operation].action
        if ($exitCode -eq 0) {
            Write-Host $services[$serviceName]['actions'][$operation].success -ForegroundColor DarkGreen
        } else {
            Write-Host $services[$serviceName]['actions'][$operation].failure -ForegroundColor DarkYellow
        }
    }

    exit $exitCode
}


# Not admin - relaunch as admin
try {
    $arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $operation $serviceNames"
    $process = Start-Process powershell -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -PassThru  
    $process.WaitForExit()
    $exitCode = $process.ExitCode
    
    foreach ($serviceName in $serviceNames) {
        if ($exitCode -eq 0) {
            Write-Host $services[$serviceName]['actions'][$operation].success -ForegroundColor DarkGreen
        } else {
            Write-Host $services[$serviceName]['actions'][$operation].failure -ForegroundColor DarkYellow
        }
    }

    exit $exitCode
}
catch {
    Write-Host "Operation canceled or failed to elevate privileges." -ForegroundColor DarkYellow
    exit 1
}