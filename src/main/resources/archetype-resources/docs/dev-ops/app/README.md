#set( $dollar = '$' )
#set( $hash = '#' )
${hash} 应用构建与启停

提供 Shell 和原生 PowerShell 两套等价入口。脚本自动定位项目目录，可从任意工作目录调用；路径允许空格。Windows 使用 Docker Desktop Linux containers，无需 WSL 终端。Shell 脚本使用 Bash，保持 LF。

| 文件 | 用途 |
| --- | --- |
| sh/build.sh、psw/build.ps1 | Maven 打包测试后端，安装前端依赖并执行类型检查、lint、测试和构建，构建 app/web 镜像 |
| sh/start.sh、psw/start.ps1 | 校验配置和两个本地镜像，先更新后端并等待健康，再更新 Nginx 并等待健康 |
| sh/stop.sh、psw/stop.ps1 | 仅停止 nginx 和 app，保留容器、中间件和数据卷 |
| docker-compose.yml | 与 environment/docker-compose.yml 合并使用的生产应用编排 |
| .env.example | 生产配置示例，复制为同目录 .env 并填写独立凭据 |

构建需要 Java 21、Maven 3.9+、Node.js 22.22.0、Corepack 和可用的 Docker Engine/Compose V2（支持 --wait），需要访问软件和镜像源。start/stop 只需要 Docker Compose 和生产 .env。任一步失败立即返回非零，不自动回滚。

${hash}${hash} 首次准备

在项目根目录执行；已有 .env 应保留，不覆盖凭据：

```powershell
Copy-Item docs/dev-ops/app/.env.example docs/dev-ops/app/.env
notepad docs/dev-ops/app/.env
```

Linux 用 cp 完成同样的复制。替换全部 CHANGE_ME，密码用 24～128 位字母、数字、下划线或连字符，每项使用独立随机值。Nacos token 为至少 32 字节随机数据的标准 Base64。PowerShell 可生成密码与 token：

```powershell
${dollar}bytes = New-Object byte[] 48
${dollar}rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
${dollar}rng.GetBytes(${dollar}bytes)
[BitConverter]::ToString(${dollar}bytes).Replace('-', '').ToLowerInvariant()
${dollar}rng.GetBytes(${dollar}bytes)
[Convert]::ToBase64String(${dollar}bytes)
${dollar}rng.Dispose()
```

每个密码重新生成。按需要独立启动中间件，使用同一个生产 .env 和项目名：

```powershell
docker compose -p ${artifactId} --env-file docs/dev-ops/app/.env -f docs/dev-ops/environment/docker-compose.yml config --quiet
docker compose -p ${artifactId} --env-file docs/dev-ops/app/.env -f docs/dev-ops/environment/docker-compose.yml up -d --wait
```

开发 Compose 使用不同项目、端口和凭据，不用于生产应用。生产只有 Nginx 发布端口，由 app/.env 中 HTTP_PORT 控制。MySQL 初始化只对空卷执行，更改 .env 不会更新已有账号密码。

${hash}${hash} Windows PowerShell

```powershell
./docs/dev-ops/app/psw/build.ps1 -ImageTag 1.0.0
./docs/dev-ops/app/psw/start.ps1 -ImageTag 1.0.0
./docs/dev-ops/app/psw/stop.ps1 -ImageTag 1.0.0
```

${hash}${hash} Linux Bash

```bash
bash docs/dev-ops/app/sh/build.sh 1.0.0
bash docs/dev-ops/app/sh/start.sh 1.0.0
bash docs/dev-ops/app/sh/stop.sh 1.0.0
```

标签默认 latest，建议迭代使用新标签。PowerShell 用 -EnvFile 指定其他配置文件，Shell 的第二个参数为配置路径；相对配置路径按调用时工作目录解析。start 检查两个本地镜像后依次重建 app、nginx，避免后端地址变化后 Nginx 缓存旧地址。中间件需提前启动；脚本不构建、不拉取应用镜像，不启动依赖服务。健康等待超时返回失败，旧应用可能已被替换，需查看日志修复后重试。

${hash}${hash} 镜像和远程部署

后端镜像 ${artifactId}/app:<tag> 从 app-backend/${artifactId}-app/target/${artifactId}-app.jar 构建，Dockerfile 仍由后端 app 模块维护。前端镜像 ${artifactId}/web:<tag> 内置 web/dist 和 Nginx 配置。构建上下文使用白名单，.env 不进入镜像；无需 WEB_ROOT 或旧发布清单。

build 只在当前机器构建。远程部署需要传输 docs/dev-ops 配置目录（保留 app/environment 结构）及两个镜像，在服务器单独配置 app/.env。使用镜像仓库或 docker save/load 传输，例如：

```powershell
docker save -o application-images.tar ${artifactId}/app:1.0.0 ${artifactId}/web:1.0.0
```

服务器 docker load -i application-images.tar 后执行 sh/start.sh 1.0.0。已加载镜像启动时不要求源码、JDK 或 Node.js。Windows 构建的 Linux 镜像必须匹配服务器 CPU 架构。上传、备份和恢复由维护者执行。

${hash}${hash} 查看状态与日志

```powershell
docker compose -p ${artifactId} --env-file docs/dev-ops/app/.env -f docs/dev-ops/environment/docker-compose.yml -f docs/dev-ops/app/docker-compose.yml ps
docker compose -p ${artifactId} --env-file docs/dev-ops/app/.env -f docs/dev-ops/environment/docker-compose.yml -f docs/dev-ops/app/docker-compose.yml logs --tail 100 app nginx
```

更新前备份业务及中间件数据，Flyway 只执行新增迁移。恢复旧镜像需要确认数据库兼容。stop 不等于卸载，数据清理和旧镜像清理由维护者明确执行。没有自动备份、自动回滚或常驻监控。
