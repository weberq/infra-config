# -----------------------------------------------------------
# WeberQ PHP Infrastructure Scaffolding Tool (v2)
# Usage: ./init.ps1
# -----------------------------------------------------------

Write-Host ""
Write-Host "🚀 WeberQ PHP Infrastructure Scaffolding (GHCR Ready)" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------" -ForegroundColor DarkGray

# -------------------------------
# 1️⃣ Collect Inputs
# -------------------------------

$AppName = Read-Host "Enter Application Name (e.g., my-php-app)"
if ([string]::IsNullOrWhiteSpace($AppName)) {
    Write-Error "❌ App Name is required."
    exit 1
}

$DomainName = Read-Host "Enter Domain Name (e.g., app.weberq.in)"
if ([string]::IsNullOrWhiteSpace($DomainName)) {
    Write-Error "❌ Domain Name is required."
    exit 1
}

$RepoOwner = Read-Host "Enter Repository Owner (GitHub Username/Org) [Default: weberq]"
if ([string]::IsNullOrWhiteSpace($RepoOwner)) {
    $RepoOwner = "weberq"
}

$RepoOwner = $RepoOwner.ToLower()
$AppName = $AppName.ToLower()

Write-Host ""
Write-Host "📦 Configuration Summary:" -ForegroundColor Yellow
Write-Host "   App Name: $AppName"
Write-Host "   Domain  : $DomainName"
Write-Host "   Owner   : $RepoOwner"
Write-Host ""

# -------------------------------
# 2️⃣ Paths
# -------------------------------

$ScriptDir = $PSScriptRoot
$ProjectRoot = Get-Location
$WorkflowDir = "$ProjectRoot\.github\workflows"

# -------------------------------
# 3️⃣ Safety Check
# -------------------------------

if (Test-Path "$ProjectRoot\Dockerfile") {
    Write-Warning "⚠ Dockerfile already exists. Skipping overwrite."
} else {
    Copy-Item "$ScriptDir\Dockerfile.template" "$ProjectRoot\Dockerfile"
    Write-Host "✔ Dockerfile created." -ForegroundColor Green
}

# -------------------------------
# 4️⃣ Generate .dockerignore
# -------------------------------

$DockerIgnorePath = "$ProjectRoot\.dockerignore"

if (-not (Test-Path $DockerIgnorePath)) {
@"
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
docker-compose.yml.template
init.ps1
"@ | Set-Content $DockerIgnorePath

    Write-Host "✔ .dockerignore created." -ForegroundColor Green
}
else {
    Write-Warning "⚠ .dockerignore already exists. Skipping."
}

# -------------------------------
# 5️⃣ Generate GitHub Workflow
# -------------------------------

if (-not (Test-Path $WorkflowDir)) {
    New-Item -ItemType Directory -Path $WorkflowDir -Force | Out-Null
}

$DeployTemplate = Get-Content "$ScriptDir\deploy.yml.template" -Raw
$DeployTemplate = $DeployTemplate -replace "{{APP_NAME}}", $AppName
$DeployTemplate = $DeployTemplate -replace "{{DOMAIN_NAME}}", $DomainName
$DeployTemplate = $DeployTemplate -replace "{{REPO_OWNER}}", $RepoOwner

Set-Content "$WorkflowDir\deploy.yml" $DeployTemplate

Write-Host "✔ GitHub Workflow created (.github/workflows/deploy.yml)" -ForegroundColor Green

# -------------------------------
# 6️⃣ Final Output
# -------------------------------

Write-Host ""
Write-Host "🎉 Scaffolding Complete!" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------"
Write-Host "Next Steps:"
Write-Host "1️⃣  git add ."
Write-Host "2️⃣  git commit -m `"Infra setup`""
Write-Host "3️⃣  git push"
Write-Host ""
Write-Host "Then configure these GitHub Secrets:"
Write-Host "   - VPS_HOST"
Write-Host "   - VPS_USER"
Write-Host "   - VPS_SSH_KEY"
Write-Host "   - GHCR_PAT (Classic PAT with read:packages)"
Write-Host ""
Write-Host "🔥 Deployment will auto-trigger on push to main."
Write-Host ""
