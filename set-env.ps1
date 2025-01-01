
# To run this script:
# powershell -ExecutionPolicy Bypass -File "path\to\script\set-env.ps1" -variableName "[ENV VARIABLE]" -variableValue "[DIRECTORY OR ENV VARIABLE]"

# If you have chocolatey installed add the RefreshEnv command to reload the environment variables 
# powershell -ExecutionPolicy Bypass -File "path\to\script\set-env.ps1" -variableName "[ENV VARIABLE]" -variableValue "[DIRECTORY OR ENV VARIABLE]" && RefreshEnv.cmd

# You might need to run this before: Set-ExecutionPolicy Bypass -Scope Process -Force if you are using powershell

# Parameters:
param( [string]$variableName, [string]$variableValue )

try {
	# Check if running as administrator
	If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		# Relaunch as administrator with hidden window
		$arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -variableName `"$variableName`" -variableValue `"$variableValue`""
		Start-Process powershell -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden
		exit
	}

	if ($variableName -and $variableValue) {
		$variableValueContent = [System.Environment]::GetEnvironmentVariable($variableValue, [System.EnvironmentVariableTarget]::Machine)
		if ($variableValueContent) {
			[System.Environment]::SetEnvironmentVariable($variableName, $variableValueContent, [System.EnvironmentVariableTarget]::Machine)
		} else {
			[System.Environment]::SetEnvironmentVariable($variableName, $variableValue, [System.EnvironmentVariableTarget]::Machine)
		}
		Write-Host "Environment variable '$variableName' set to '$variableValue' at the system level."
	} else {
		Write-Host "Please provide both a variable name and value."
	}
} catch {
	Write-Host "Something went wrong, believe me !!"
}

