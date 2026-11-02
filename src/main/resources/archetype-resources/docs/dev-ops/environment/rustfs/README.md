#set( $dollar = '$' )
#set( $hash = '#' )
${hash} RustFS 对象存储

镜像固定为 rustfs/rustfs:1.0.4，提供兼容 S3 的对象存储与 Web 控制台。当前配置为单节点、单数据卷，加入 autrain-network。

| 环境 | S3 API | 控制台 | 凭据 |
| --- | --- | --- | --- |
| 开发宿主机 | http://127.0.0.1:19000 | http://127.0.0.1:19001 | rustfsadmin / rustfsadmin |
| Docker 网络内部 | http://rustfs:9000 | http://rustfs:9001 | 对应环境的 RUSTFS_ACCESS_KEY / RUSTFS_SECRET_KEY |

开发端口可通过 environment/.env 中 RUSTFS_API_PORT、RUSTFS_CONSOLE_PORT 覆盖。生产不发布宿主机端口，不经前端 Nginx 公开代理；在 app/.env 设置独立的 RUSTFS_ACCESS_KEY、RUSTFS_SECRET_KEY。控制台可通过受控网络或 SSH 隧道访问。

rustfs-data 挂载 /data（对象及内部元数据），rustfs-logs 挂载 /logs。使用镜像默认的非 root 用户 10001:10001；全新命名卷由 Docker 从镜像对应目录初始化并保留权限，无需在 Windows 执行 chmod。不要使用 nocopy 或直接换成未准备权限的宿主机目录。已有卷若来自其他镜像或用户，需先备份并检查目录属主。

健康检查同时访问 /health 与 /rustfs/console/health。启动后仍需登录控制台、创建 bucket 并验证上传下载。模板不自动创建 bucket、不修改业务代码、不引入 S3 SDK；应用接入时配置上述 endpoint、凭据并按客户端需要启用 path-style。浏览器直传或预签名 URL 需要配置浏览器可访问的 S3 地址，不能直接使用容器内的 rustfs 主机名。

在生成项目根目录按需执行以下命令（不会启动其他中间件）：

```powershell
docker compose -f docs/dev-ops/environment/docker-compose.dev.yml up -d --wait rustfs
docker compose -f docs/dev-ops/environment/docker-compose.dev.yml logs --tail 100 rustfs
docker compose -f docs/dev-ops/environment/docker-compose.dev.yml stop rustfs
```

stop / down 保留对象数据；down -v 会删除 Compose 管理的数据卷。对象数据需独立备份，不由数据库 Flyway 管理。此单节点配置不提供多节点容灾。

参考：https://github.com/rustfs/rustfs/tree/1.0.4
