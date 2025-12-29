# Hugo Blog Publish Script
# Usage: .\scripts\publish.ps1 [-Message "commit message"]

param(
    [Parameter(Mandatory=$false)]
    [string]$Message = ""
)

$BlogDir = "D:\OneDrive\repo\blog"
Set-Location $BlogDir

# Check for changes
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "No changes detected." -ForegroundColor Yellow
    exit 0
}

Write-Host "Detected changes:`n" -ForegroundColor Cyan
git status --short

Write-Host "`n" -NoNewline

# Prompt for commit message if not provided
if ([string]::IsNullOrWhiteSpace($Message)) {
    Write-Host "Please describe the changes (e.g., update article, fix typo, delete draft)" -ForegroundColor Yellow
    $Message = Read-Host "Commit message"

    if ([string]::IsNullOrWhiteSpace($Message)) {
        Write-Host "Error: Commit message cannot be empty" -ForegroundColor Red
        exit 1
    }
}

# Show changes to be committed
Write-Host "`nChanges to be committed:" -ForegroundColor Cyan
git diff --stat

Write-Host "`n" -NoNewline
$confirm = Read-Host "Confirm commit and publish? (y/n)"

if ($confirm -ne 'y') {
    Write-Host "Operation cancelled" -ForegroundColor Red
    exit 0
}

# Add all changes
Write-Host "`nAdding changes..." -ForegroundColor Cyan
git add -A

# Create commit message with co-author (avoiding angle brackets in script)
$tempFile = [System.IO.Path]::GetTempFileName()
$robotEmoji = [char]0x1F916
$email = "noreply" + "@" + "anthropic.com"
$coauthor = "Co-Authored-By: Claude Sonnet 4.5 " + [char]60 + $email + [char]62

$commitContent = $Message + "`n`n" + $robotEmoji + " Generated with [Claude Code](https://claude.com/claude-code)`n`n" + $coauthor

[System.IO.File]::WriteAllText($tempFile, $commitContent, [System.Text.Encoding]::UTF8)

# Commit
Write-Host "Committing..." -ForegroundColor Cyan
git commit -F $tempFile

# Clean up temp file
Remove-Item $tempFile -ErrorAction SilentlyContinue

# Push to GitHub
Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push

Write-Host "`n" -NoNewline
Write-Host "Published successfully!" -ForegroundColor Green
Write-Host "GitHub Actions is deploying the site..." -ForegroundColor Cyan
Write-Host "`nDeployment status: https://github.com/william-guo-2012/blog/actions" -ForegroundColor Yellow
Write-Host "Website: https://william-guo-2012.github.io/blog/" -ForegroundColor Yellow
Write-Host "`nNote: Deployment usually takes 1-2 minutes" -ForegroundColor Gray
