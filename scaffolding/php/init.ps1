# -----------------------------------------------------------
# PHP Project Scaffolding Tool (Windows)
# Usage: ./init.ps1
# -----------------------------------------------------------

Write-Host "🚀 WeberQ Infrastructure Scaffolding (PHP)" -ForegroundColor Cyan
Write-Host "This script will generate your Docker config and GitHub Action." -ForegroundColor Gray

# 1. Get Inputs
$AppName = Read-Host "Enter Application Name (e.g., my-php-app)"
if ([string]::IsNullOrWhiteSpace($AppName)) { Write-Error "App Name is required."; exit 1 }

$DomainName = Read-Host "Enter Domain Name (e.g., app.weberq.in)"
if ([string]::IsNullOrWhiteSpace($DomainName)) { Write-Error "Domain Name is required."; exit 1 }

$RepoOwner = Read-Host "Enter Repository Owner (GitHub Username/Org) [Default: weberq]"
if ([string]::IsNullOrWhiteSpace($RepoOwner)) { $RepoOwner = "weberq" }
$RepoOwner = $RepoOwner.ToLower()

# 2. Define Paths
$ScriptDir = $PSScriptRoot
$ProjectRoot = Get-Location

# 3. Copy Dockerfile
Write-Host "`n📄 Generating Dockerfile..." -ForegroundColor Yellow
Copy-Item "$ScriptDir\Dockerfile.template" "$ProjectRoot\Dockerfile"
Write-Host "   Done."

# 4. Process docker-compose.yml
Write-Host "📄 Generating docker-compose.yml..." -ForegroundColor Yellow
$ComposeContent = Get-Content "$ScriptDir\docker-compose.yml.template" -Raw
$ComposeContent = $ComposeContent -replace "{{APP_NAME}}", $AppName
$ComposeContent = $ComposeContent -replace "{{DOMAIN_NAME}}", $DomainName
$ComposeContent = $ComposeContent -replace "{{REPO_OWNER}}", $RepoOwner
Set-Content "$ProjectRoot\docker-compose.yml" $ComposeContent
Write-Host "   Done (Configured for $DomainName)."

# 5. Process GitHub Workflow
Write-Host "📄 Generating GitHub Workflow..." -ForegroundColor Yellow
$WorkflowDir = "$ProjectRoot\.github\workflows"
if (-not (Test-Path $WorkflowDir)) {
    New-Item -ItemType Directory -Path $WorkflowDir -Force | Out-Null
}

$DeployContent = Get-Content "$ScriptDir\deploy.yml.template" -Raw
$DeployContent = $DeployContent -replace "{{APP_NAME}}", $AppName
Set-Content "$WorkflowDir\deploy.yml" $DeployContent
Write-Host "   Done (Saved to .github/workflows/deploy.yml)."

Write-Host "`n✅ Scaffolding Complete!" -ForegroundColor Green
Write-Host "Next Steps:"
Write-Host "1. Git Add/Commit/Push these new files."
Write-Host "2. Add secrets (VPS_HOST, VPS_USER, VPS_SSH_KEY) to your GitHub Repo."
Write-Host "3. Add GHCR_PAT (Personal Access Token with 'read:packages' scope) to Secrets."
