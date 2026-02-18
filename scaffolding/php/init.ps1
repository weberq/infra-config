# -----------------------------------------------------------
# WeberQ PHP Infrastructure Scaffolding Tool (Stable)
# Usage: ./init.ps1
# -----------------------------------------------------------

Write-Host ""
Write-Host "WeberQ PHP Infrastructure Scaffolding (GHCR Ready)" -ForegroundColor Cyan
Write-Host "---------------------------------------------------" -ForegroundColor DarkGray

# 1. Inputs
$AppName = Read-Host "Enter Application Name (e.g., my-php-app)"
if ([string]::IsNullOrWhiteSpace($AppName)) {
    Write-Error "App Name is required."
    exit 1
}

$DomainName = Read-Host "Enter Domain Name (e.g., app.weberq.in)"
if ([string]::IsNullOrWhiteSpace($DomainName)) {
    Write-Error "Domain Name is required."
    exit 1
}

$RepoOwner = Read-Host "Enter Repository Owner (GitHub Username/Org) [Default: weberq]"
if ([string]::IsNullOrWhiteSpace($RepoOwner)) {
    $RepoOwner = "weberq"
}

$RepoOwner = $RepoOwner.ToLower()
$AppName = $AppName.ToLower()

Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Yellow
Write-Host "  App Name: $AppName"
Write-Host "  Domain  : $DomainName"
Write-Host "  Owner   : $RepoOwner"
Write-Host ""

# 2. Paths
$ScriptDir = $PSScriptRoot
$ProjectRoot = Get-Location
$WorkflowDir = "$ProjectRoot\.github\workflows"

# 3. Dockerfile
if (-not (Test-Path "$ProjectRoot\Dockerfile")) {
    Copy-Item "$ScriptDir\Dockerfile.template" "$ProjectRoot\Dockerfile"
    Write-Host "Dockerfile created." -ForegroundColor Green
} else {
    Write-Warning "Dockerfile already exists. Skipping."
}

# 4. .dockerignore
$DockerIgnorePath = "$ProjectRoot\.dockerignore"

if (-not (Test-Path $DockerIgnorePath)) {

$dockerIgnoreContent = @"
.git
.gitignore
node_modules
vendor
*.log
*.zip
*.tar
*.sql
.env
.github
docker-compose.yml
Dockerfile.template
init.ps1
"@

    Set-Content -Path $DockerIgnorePath -Value $dockerIgnoreContent
    Write-Host ".dockerignore created." -ForegroundColor Green
} else {
    Write-Warning ".dockerignore already exists. Skipping."
}

# 5. GitHub Workflow
if (-not (Test-Path $WorkflowDir)) {
    New-Item -ItemType Directory -Path $WorkflowDir -Force | Out-Null
}

$DeployTemplate = Get-Content "$ScriptDir\deploy.yml.template" -Raw
$DeployTemplate = $DeployTemplate -replace "{{APP_NAME}}", $AppName
$DeployTemplate = $DeployTemplate -replace "{{DOMAIN_NAME}}", $DomainName
$DeployTemplate = $DeployTemplate -replace "{{REPO_OWNER}}", $RepoOwner

Set-Content "$WorkflowDir\deploy.yml" $DeployTemplate

Write-Host "GitHub workflow generated." -ForegroundColor Green

# 6. Final Instructions
Write-Host ""
Write-Host "Scaffolding Complete!" -ForegroundColor Cyan
Write-Host "---------------------------------------------------"
Write-Host "Next Steps:"
Write-Host "1. git add ."
Write-Host "2. git commit -m 'Infra setup'"
Write-Host "3. git push"
Write-Host ""
Write-Host "Add these GitHub Secrets:"
Write-Host "  VPS_HOST"
Write-Host "  VPS_USER"
Write-Host "  VPS_SSH_KEY"
Write-Host "  GHCR_PAT (Classic token with read:packages)"
Write-Host ""
Write-Host "Deployment will auto-trigger on push to main."
Write-Host ""
