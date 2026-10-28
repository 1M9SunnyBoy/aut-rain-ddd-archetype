# 关闭端口占用进程

在本目录运行脚本，按提示输入端口，例如 `5174 8080 8081`，回车后立即处理。空输入或任意无效端口会取消整次操作。

## Windows

```powershell
.\closeport.ps1
```

兼容 Windows PowerShell 5.1 和 Windows 上的 PowerShell 7，使用系统 NetTCPIP 模块。权限不足时使用管理员 PowerShell 运行。文件采用 UTF-8 BOM 编码。

## Linux / macOS

```bash
sudo bash ./closeport.sh
```

需要 Bash 3.2 及以上，以及 `lsof` 或 Linux 的 `ss`（iproute2）。使用 root 权限保证能识别其他用户的进程。先发送 TERM，最多等待 5 秒；如果进程仍占用指定端口，再发送 KILL。脚本使用 UTF-8 无 BOM、LF 换行。

## 行为

- 查询指定本地端口的 TCP 监听和 UDP 占用，覆盖 IPv4 / IPv6，不处理普通 TCP 客户端连接。
- 显示端口对应 PID，同一 PID 只处理一次，跳过关键系统进程与脚本自身。
- 停止的是整个进程，因此该进程占用的其他端口也会关闭。
- 结束后再次检查端口，仍占用时提示检查权限或服务自动重启；全部释放返回 0，失败返回非零。
- 不启动任何项目或服务，也不修改服务的自动重启配置。
