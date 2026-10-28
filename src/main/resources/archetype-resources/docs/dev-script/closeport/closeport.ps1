#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

try {
    Write-Host '关闭指定端口的 TCP 监听 / UDP 占用进程；同一进程的其他服务也会停止。'
    $inputText = Read-Host '请输入端口，多个端口用空格分隔'
    if ([string]::IsNullOrWhiteSpace($inputText)) {
        throw '没有输入端口。'
    }
    $ports = @(
        foreach ($value in ($inputText.Trim() -split '\s+')) {
            $port = 0
            if ($value -notmatch '^[0-9]{1,5}$' -or
                -not [int]::TryParse($value, [ref]$port) -or
                $port -lt 1 -or $port -gt 65535) {
                throw "无效端口：$value（必须是 1-65535）"
            }
            $port
        }
    ) | Sort-Object -Unique

    function Get-PortOwners {
        # 查询全部连接后过滤，避免把查询失败当作端口空闲。
        $tcp = @(Get-NetTCPConnection -ErrorAction Stop)
        $udp = @(Get-NetUDPEndpoint -ErrorAction Stop)
        @($tcp | Where-Object { $_.State -eq 'Listen' -and $_.LocalPort -in $ports })
        @($udp | Where-Object { $_.LocalPort -in $ports })
    }

    $owners = @(Get-PortOwners)
    $targets = @{}
    foreach ($port in $ports) {
        $matches = @($owners | Where-Object { $_.LocalPort -eq $port })
        if ($matches.Count -eq 0) {
            Write-Host "端口 $port 未被服务占用。"
        }
        foreach ($owner in $matches) {
            $processId = [int]$owner.OwningProcess
            Write-Host "端口 $port -> PID $processId"
            $targets[$processId] = $true
        }
    }

    $failed = $false
    foreach ($processId in $targets.Keys) {
        if ($processId -le 4 -or $processId -eq $PID) {
            Write-Warning "跳过系统或当前脚本进程 PID $processId。"
            $failed = $true
            continue
        }
        try {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if (-not $process) { continue }
            Write-Host "正在停止 $($process.ProcessName)（PID $processId）"
            $process | Stop-Process -Force -ErrorAction Stop
            $process.WaitForExit(3000) | Out-Null
        }
        catch {
            Write-Warning "停止 PID $processId 失败：$($_.Exception.Message)。权限不足时请以管理员身份运行。"
            $failed = $true
        }
    }

    $remaining = @(Get-PortOwners)
    foreach ($port in $ports) {
        $matches = @($remaining | Where-Object { $_.LocalPort -eq $port })
        if ($matches.Count -gt 0) {
            Write-Warning "端口 $port 仍被占用（PID：$(($matches.OwningProcess | Sort-Object -Unique) -join ', ')），请检查是否被自动重启。"
            $failed = $true
        } else {
            Write-Host "端口 $port 已空闲。"
        }
    }
    if ($failed) { exit 1 }
    exit 0
}
catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
