param ($copyEverything = $null)

$source = "C:\xampp\mysql\backup"
$destination = "C:\xampp\mysql\data"

# Get all files and folders, optionally exclude "ibdata1"
Get-ChildItem -Path $source -Recurse | Where-Object {
    $copyEverything -or $_.Name -ne "ibdata1"
} | ForEach-Object {
    $targetPath = Join-Path $destination ($_.FullName.Substring($source.Length).TrimStart('\'))

    if ($_.PSIsContainer) {
        # Create directory if it doesn't exist
        if (-not (Test-Path $targetPath)) {
            New-Item -ItemType Directory -Path $targetPath | Out-Null
        }
    } else {
        # Copy file
        Copy-Item -Path $_.FullName -Destination $targetPath -Force
    }
}

Write-Host "Copy completed" -NoNewline
if ($copyEverything) {
    Write-Host " (including ibdata1)."
} else {
    Write-Host " (excluding ibdata1)."
}
Write-Host "$source to $destination"
