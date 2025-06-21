# To run this script:
# powershell -ExecutionPolicy Bypass -File "path\to\script\commit-date.ps1" -date 2025-01-01T12:00:00 -message "Your commit message"

# You might need to run this before: Set-ExecutionPolicy Bypass -Scope Process -Force if you are using powershell

param (
    [string]$date, # "2025-01-01T12:00:00"
    [string]$message
)


$env:GIT_AUTHOR_DATE=$date
$env:GIT_COMMITTER_DATE=$date


git commit -m $message


Remove-Item Env:\GIT_AUTHOR_DATE
Remove-Item Env:\GIT_COMMITTER_DATE
