# -----------------------------------------------------------
# WeberQ PHP Infrastructure Scaffolding Tool (Production Safe)
# Usage: ./init.ps1
# -----------------------------------------------------------

Write-Host ""
Write-Host "WeberQ PHP Infrastructure Scaffolding (GHCR + SHA + Traefik)" -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------" -ForegroundColor DarkGray

# 1. Inputs
$AppName = Read-Host "Enter Application Name (e.g., my-php-app)"
if ([string]::IsNullOrWhiteSpace($AppName)) {
    Write-Error "App Name is required."
    exit 1
}

$DomainName = Read-Host "Enter Domain Name (e.g., stmorg.in or app.weberq.in)"
if ([string]::IsNullOrWhiteSpace($DomainName)) {
    Write-Error "Domain Name is required."
    exit 1
}

$EnableWWW = Read-Host "Does this domain require www support? (y/n)"

$AppName = $AppName.ToLower()

# 2. Build Traefik Rule (Proper Docker Escaping)
if ($EnableWWW -eq "y") {
    $TraefikRule = "Host(\`"$DomainName\`") || Host(\`"www.$DomainName\`")"
} else {
    $TraefikRule = "Host(\`"$DomainName\`")"
}

Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Yellow
Write-Host "  App Name : $AppName"
Write-Host "  Domain   : $DomainName"
Write-Host "  Rule     : $TraefikRule"
Write-Host ""

# 3. Paths
$ScriptDir = $PSScriptRoot
$ProjectRoot = Get-Location
$WorkflowDir = "$ProjectRoot\.github\workflows"

# 4. Dockerfile
if ($EnableWWW -eq "y") {
    $TraefikRule = "Host(``$DomainName``) || Host(``www.$DomainName``)"
} else {
    $TraefikRule = "Host(``$DomainName``)"
}

# 5. .dockerignore
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
Dockerfile.template
init.ps1
"@

    Set-Content -Path $DockerIgnorePath -Value $dockerIgnoreContent
    Write-Host ".dockerignore created." -ForegroundColor Green
}

# 6. GitHub Workflow
if (-not (Test-Path $WorkflowDir)) {
    New-Item -ItemType Directory -Path $WorkflowDir -Force | Out-Null
}

$DeployTemplate = Get-Content "$ScriptDir\deploy.yml.template" -Raw
$DeployTemplate = $DeployTemplate -replace "{{APP_NAME}}", $AppName
$DeployTemplate = $DeployTemplate -replace "{{TRAEFIK_RULE}}", $TraefikRule

Set-Content "$WorkflowDir\deploy.yml" $DeployTemplate

Write-Host ""
Write-Host "Scaffolding Complete!" -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------"
Write-Host "Next Steps:"
Write-Host "1. git add ."
Write-Host "2. git commit -m 'Infra setup'"
Write-Host "3. git push"
Write-Host ""
Write-Host "Add these GitHub Secrets:"
Write-Host "  VPS_HOST"
Write-Host "  VPS_USER"
Write-Host "  VPS_SSH_KEY"
Write-Host "  GHCR_PAT (read:packages)"
Write-Host ""
Write-Host "IMPORTANT:"
Write-Host "Cloudflare SSL Mode must be set to: Full"
Write-Host ""
