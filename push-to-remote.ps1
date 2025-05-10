param (
    [string]$GitHubToken,
    [string]$RepoName,
    [string]$GitHubUsername = "drissboumlik",
    [int]$withAllBranches = 0
)

# GitHub API endpoint
$GitHubApiUrl = "https://api.github.com/user/repos"

# Create a new repository on GitHub via the API
$Headers = @{
    "Authorization" = "token $GitHubToken"
    "User-Agent" = "$GitHubUsername"
}

$Body = @{
    name = $RepoName
    private = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri $GitHubApiUrl -Method Post -Headers $Headers -Body $Body

# Add GitHub repository as remote
git remote add origin "https://github.com/$GitHubUsername/$RepoName.git"

# Push to GitHub
if ($withAllBranches) {
    git push --all origin
} else {
    git push -u origin master
}
