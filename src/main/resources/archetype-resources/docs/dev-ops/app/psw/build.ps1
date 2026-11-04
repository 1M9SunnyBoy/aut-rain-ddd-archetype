#set( $dollar = '$' )
#set( $hash = '#' )
${hash} description: 检查并构建前后端产物及 Docker 镜像，不启动服务。
${hash} author: zzy
${hash} created: 2026-10-28
${hash} Parameters: ImageTag is the shared app/web image tag; default latest.
${hash} Failure: any native command error aborts the remaining build steps.
[CmdletBinding()]
param([ValidatePattern('^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}${dollar}')][string]${dollar}ImageTag = 'latest')
Set-StrictMode -Version Latest
${dollar}ErrorActionPreference = 'Stop'
${hash} Propagate native exit codes: ErrorActionPreference alone does not catch every CLI failure.
function Invoke-Checked {
    param([string]${dollar}File, [string[]]${dollar}Arguments)
    & ${dollar}File @Arguments
    if (${dollar}LASTEXITCODE -ne 0) { throw "Command failed (${dollar}LASTEXITCODE): ${dollar}File" }
}
${dollar}ProjectRoot = [IO.Path]::GetFullPath((Join-Path ${dollar}PSScriptRoot '../../../..'))
foreach (${dollar}Name in @('java', 'mvn', 'node', 'corepack', 'docker')) {
    if (-not (Get-Command ${dollar}Name -ErrorAction SilentlyContinue)) { throw "Missing command: ${dollar}Name" }
}
${dollar}NodeVersion = & node --version
if (${dollar}LASTEXITCODE -ne 0 -or ${dollar}NodeVersion -ne 'v22.22.0') { throw 'Node.js 22.22.0 is required' }
Invoke-Checked 'docker' @('info')
Push-Location ${dollar}ProjectRoot
try {
    Invoke-Checked 'mvn' @('-B', '-ntp', '-f', 'app-backend/pom.xml', 'clean', 'package')
    Invoke-Checked 'corepack' @('pnpm', '--dir', 'web', 'install', '--frozen-lockfile')
    foreach (${dollar}Task in @('typecheck', 'lint', 'test', 'build')) {
        Invoke-Checked 'corepack' @('pnpm', '--dir', 'web', ${dollar}Task)
    }
    if (-not (Test-Path -LiteralPath 'app-backend/${artifactId}-app/target/${artifactId}-app.jar' -PathType Leaf) -or
        -not (Test-Path -LiteralPath 'web/dist/index.html' -PathType Leaf)) { throw 'Missing build artifacts' }
    Invoke-Checked 'docker' @('build', '--tag', "${artifactId}/app:${dollar}ImageTag", 'app-backend/${artifactId}-app')
    Invoke-Checked 'docker' @('build', '--tag', "${artifactId}/web:${dollar}ImageTag", '--file', 'docs/dev-ops/environment/nginx/Dockerfile', '.')
    Write-Host "Built ${artifactId}/app:${dollar}ImageTag and ${artifactId}/web:${dollar}ImageTag"
} finally {
    Pop-Location
}
