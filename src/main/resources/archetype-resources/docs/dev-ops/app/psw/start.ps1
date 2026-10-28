#set( $dollar = '$' )
#set( $hash = '#' )
[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}${dollar}')][string]${dollar}ImageTag = 'latest',
    [string]${dollar}EnvFile = ''
)
Set-StrictMode -Version Latest
${dollar}ErrorActionPreference = 'Stop'
function Invoke-Docker {
    param([string[]]${dollar}Arguments)
    & docker @Arguments
    if (${dollar}LASTEXITCODE -ne 0) { throw "Docker command failed (${dollar}LASTEXITCODE)" }
}
${dollar}OpsDir = [IO.Path]::GetFullPath((Join-Path ${dollar}PSScriptRoot '../..'))
if (-not ${dollar}EnvFile) { ${dollar}EnvFile = Join-Path ${dollar}OpsDir 'app/.env' }
if (-not (Test-Path -LiteralPath ${dollar}EnvFile -PathType Leaf)) { throw "Missing production env file: ${dollar}EnvFile (see app/.env.example)" }
${dollar}EnvFile = (Resolve-Path -LiteralPath ${dollar}EnvFile).Path
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Missing command: docker' }
${dollar}PreviousTag = ${dollar}env:IMAGE_TAG
try {
    ${dollar}env:IMAGE_TAG = ${dollar}ImageTag
    ${dollar}Compose = @('compose', '--project-name', '${artifactId}', '--project-directory', (Join-Path ${dollar}OpsDir 'environment'),
        '--env-file', ${dollar}EnvFile, '-f', (Join-Path ${dollar}OpsDir 'environment/docker-compose.yml'), '-f', (Join-Path ${dollar}OpsDir 'app/docker-compose.yml'))
    Invoke-Docker (${dollar}Compose + @('config', '--quiet'))
    foreach (${dollar}Component in @('app', 'web')) {
        Invoke-Docker @('image', 'inspect', "${artifactId}/${dollar}{Component}:${dollar}ImageTag") | Out-Null
    }
    Invoke-Docker (${dollar}Compose + @('up', '-d', '--no-deps', '--no-build', '--pull', 'never', '--force-recreate', '--wait', '--wait-timeout', '180', 'app'))
    Invoke-Docker (${dollar}Compose + @('up', '-d', '--no-deps', '--no-build', '--pull', 'never', '--force-recreate', '--wait', '--wait-timeout', '180', 'nginx'))
    Invoke-Docker (${dollar}Compose + @('ps', 'app', 'nginx'))
    Write-Host 'Application started.'
} finally {
    ${dollar}env:IMAGE_TAG = ${dollar}PreviousTag
}
