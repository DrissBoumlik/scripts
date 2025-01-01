# To run this script:
# powershell -ExecutionPolicy Bypass -File "path\to\script\update-branches.ps1" -Branches master,staging -Remotes origin,github

# You might need to run this before: Set-ExecutionPolicy Bypass -Scope Process -Force if you are using powershell

param (
    [string]$Branches, # A single string of branches separated by commas (master,staging)
    [string]$Remotes  # A single string of remotes separated by commas (origin,github)
)

# Get the current branch
$CurrentBranch = (git branch --show-current).Trim()
if (-not $CurrentBranch) {
    Write-Host "Error: Unable to determine the current branch." -ForegroundColor Red
    exit 1
}

# Split the branches string into an array
$BranchArray = $Branches -split ","
# Split the remote string into an array
$RemoteArray = $Remotes -split ","

# Check if the branches parameter is provided
if (-not $BranchArray -or $BranchArray.Count -eq 0) {
    Write-Host "Error: Please provide at least one branch to merge into." -ForegroundColor Red
    exit 1
}

function Is-BranchUpToDate {
    param (
        [string]$branch
    )
    
    # Get the local and remote commit hashes
    $localHash = git rev-parse $branch
    $remoteHash = git rev-parse origin/$branch

    # Compare the hashes
    if ($localHash -eq $remoteHash) {
        return $true
    } else {
        return $false
    }
}

# Push the current branch
Write-Host "Pushing the current branch '$CurrentBranch' to remote..." -ForegroundColor Cyan
foreach ($remote in $RemoteArray) {
    git push $remote $CurrentBranch
}

# Iterate over the list of branches
foreach ($branch in $BranchArray) {
    if ($branch -eq $CurrentBranch) {
        Write-Host "Skipping the current branch '$CurrentBranch'." -ForegroundColor Yellow
        continue
    }
    
    if (Is-BranchUpToDate -branch $branch) {
        Write-Host "Branch $branch is up-to-date with the remote. Skipping merge."
    } else {
        Write-Host "Checking out branch '$branch'..." -ForegroundColor Cyan
        git checkout $branch

        Write-Host "Merging '$CurrentBranch' into '$branch'..." -ForegroundColor Cyan
        git merge $CurrentBranch

        Write-Host "Pushing branch '$branch' to remote..." -ForegroundColor Cyan
        foreach ($remote in $RemoteArray) {
            git push $remote $CurrentBranch
        }
    }
}

# Switch back to the original branch
Write-Host "Switching back to the original branch '$CurrentBranch'..." -ForegroundColor Cyan
git checkout $CurrentBranch

Write-Host "Operation completed successfully!" -ForegroundColor Green
