#if( $databaseName == "auto" )
#set( $databaseName = $artifactId.replace('-', '_') )
#end
#set( $dollar = '$' )
#set( $hash = '#' )
${hash} 运维配置

参考 XFG 的 app/environment 分层：app 放后端应用，environment 放 Nginx、中间件及配置。应用脚本位于 app/sh 和 app/psw；模板生成不会启动服务。

| 文件 | 用途 |
| --- | --- |
| app/docker-compose.yml | 生产 Java app 和 Nginx；与 environment/docker-compose.yml 合并 |
| ../../app-backend/${artifactId}-app/Dockerfile | 后端模块维护镜像定义，直接读取模块 target JAR |
| environment/nginx/Dockerfile、conf.d/default.conf | Nginx 镜像、API 同源代理及 SPA 路由 |
| environment/docker-compose.yml | 全部中间件的生产基础定义，不发布宿主机端口 |
| environment/docker-compose.dev.yml | 独立开发环境完整编排，绑定 127.0.0.1，项目名 ${artifactId}-dev；不与生产文件叠加 |
| environment/.env.example | 可选开发变量覆盖，内置默认账号；无需复制即可使用 |
| environment/mysql/conf.d/my.cnf | MySQL 字符集配置；生产服务直接定义于 environment/docker-compose.yml |
| environment/mysql/sql/00-project.sql | 创建项目业务数据库；表结构与业务初始数据由 Flyway 管理 |
| environment/mysql/sql/nacos.sql | 生产空卷初始化 Nacos 数据库与表结构 |
| environment/mysql/sql/xxl-job.sql | 开发和生产空卷初始化 XXL-Job 数据库、表结构及 admin / 123456 管理员 |
| environment/rustfs/README.md | RustFS 1.0.4 端口、凭据、命名卷及接入说明 |
| environment/redis/redis.conf | Redis AOF、监听及保护模式；开发无密码，生产通过环境变量启用密码 |
| environment/rocketmq/broker.conf | Broker 存储、Topic 策略；广播地址由 Compose 注入 |
| environment/nacos/README.md、xxl-job/README.md | 初始化与连接说明 |
| app/sh、app/psw | 应用 build/start/stop 脚本 |
| app/.env.example | 生产变量示例 |
| environment/nginx/Dockerfile.dockerignore | 前端镜像构建白名单 |

${hash}${hash} Windows 本地开发

安装 Docker Desktop 并切换为 Linux containers，使用 Docker Compose V2（docker compose）。所有宿主机命令都在 PowerShell 执行，无需打开 WSL 终端。Compose 中的 sh/bash 是 Linux 容器内部命令。

开发环境内置默认凭据，在生成的项目根目录按需执行，不需要先创建 .env：

```powershell
docker compose -f docs/dev-ops/environment/docker-compose.dev.yml config --quiet
docker compose -f docs/dev-ops/environment/docker-compose.dev.yml up -d --wait
docker compose -f docs/dev-ops/environment/docker-compose.dev.yml ps
docker compose -f docs/dev-ops/environment/docker-compose.dev.yml stop
```

| 组件 | 默认账号 | 默认密码 / 说明 |
| --- | --- | --- |
| MySQL / phpMyAdmin | root | 123456 |
| 业务库备用用户 | ${databaseName} | 123456 |
| Redis | 无 | 无密码 |
| RustFS | rustfsadmin | rustfsadmin（S3 与控制台共用） |
| Redis Commander | admin | admin（仅管理页面登录） |
| XXL-Job | admin | 123456；通信 token 为 default_token |
| Nacos | nacos | Nacos 3 首次需在控制台初始化，开发可设为 nacos；已有账号保持原密码 |
| RocketMQ Dashboard | 无 | 无登录 |

后端 dev 配置默认连接 root / 123456；可通过 APP_DB_URL、APP_DB_USERNAME、APP_DB_PASSWORD 覆盖。开发 Redis 关闭保护模式以供同一 Docker 网络的管理界面访问，宿主机端口仍绑定 127.0.0.1。

需要改端口或默认值时，可复制 environment/.env.example 为 environment/.env，修改后给上述命令增加 --env-file docs/dev-ops/environment/.env。已有 .env 中的值优先于默认值，旧 CHANGE_ME 值需要自行删除或调整。Compose 的 .env 不会自动传给 Windows 本机后端。

MySQL 的环境变量密码仅作用于空卷。XXL-Job 初始管理员 admin / 123456 固定写入 SQL，首次登录后在控制台修改密码。已有数据库不会因修改 .env 或 SQL 自动改密。

开发文件是独立完整编排，不能再叠加 environment/docker-compose.yml。需要某一组件时可在 up 命令末尾指定 mysql redis 等服务；依赖会自动启动。down 保留卷，down -v 会清空该开发项目的全部数据，只在明确重置时使用。

| 服务 | 开发镜像 | 本机端口 / 地址 |
| --- | --- | --- |
| MySQL | mysql:8.0.32 | 13306 |
| Redis | redis:6.2 | 16379 |
| RustFS | rustfs/rustfs:1.0.4 | S3 API 19000；控制台 http://127.0.0.1:19001 |
| Nacos | nacos/nacos-server:v3.0.3 | API 18848、gRPC 19848/19849；控制台 http://127.0.0.1:18080 |
| RocketMQ NameServer / Broker | apache/rocketmq:5.1.0 | 19876、20909/20911/20912 |
| RocketMQ Dashboard | apacherocketmq/rocketmq-dashboard:1.0.0 | http://127.0.0.1:18082 |
| XXL-Job | xuxueli/xxl-job-admin:2.4.1 | http://127.0.0.1:19090/xxl-job-admin |
| phpMyAdmin | phpmyadmin:5.2.1 | http://127.0.0.1:18899 |
| Redis Commander | spryker/redis-commander:0.8.0 | http://127.0.0.1:18081 |
| Java / 前端 | 本机开发运行 | 后端 8080 / Vite 5137 |

配置按参考项目的服务注释、端口、环境变量、挂载、依赖、网络顺序展开；开发和生产均使用固定名称 autrain-network 的 bridge 网络，通过网络定义中的 name 禁用项目名前缀。同一 Docker 主机上的该网络不按项目隔离；这些配置面向开发、生产分别部署到不同主机的场景。没有复制旧版 version、links、volumes_from 数据容器或 Mac ARM 镜像替代说明。数据库及消息持久化使用命名卷，避免 Windows NTFS 文件权限影响；配置采用相对路径只读挂载。MySQL 开发参数在 Compose command 中传入，不依赖 Windows 挂载文件的 Unix 权限。MySQL 直接执行挂载到 /docker-entrypoint-initdb.d 的 SQL 文件，文件使用 UTF-8。

Nacos 3 使用 Derby 和 nacos-data 命名卷，不导入生产 MySQL 的初始化 SQL；首次进入控制台初始化管理员。XXL-Job 默认 admin / 123456，phpMyAdmin 默认 root / 123456，Redis Commander 默认 admin / admin。Nacos 与 XXL-Job 健康检查确认端口监听，启动后仍需登录验证功能。模板只提供基础设施，不自动接入业务 SDK；BOM 管理的 xxl-job-core 3.3.0 不能据此认定与此处 2.4.1 管理中心兼容，启用执行器前须统一版本并迁移表结构。

RocketMQ 使用官方 NameServer/Broker 拆分镜像，Dashboard 与 Broker 共享网络，因此 Windows 本机客户端和 Dashboard 均能访问广播地址 127.0.0.1。18082 到 Dashboard 8080 的端口映射放在 Broker 服务上。其他独立容器不能直接使用此广播地址；本配置针对宿主机开发客户端。Windows 上的 XXL-Job 执行器需要向调度中心登记 host.docker.internal 与实际执行器端口，确保 Docker Desktop 能回调主机。

开发宿主机端口统一使用原四位端口前加 1（即加 10000），例如 MySQL 13306、Redis 16379。原本五位的 RocketMQ Broker 端口不能直接前加 1（会超过 65535），改为加 10000 后的 20909/20911/20912；Broker 容器监听端口也同步修改，保证广播给客户端的端口可达。其他组件保持容器内部端口，Nacos API 18848 与 gRPC 19848/19849 保持 +1000/+1001 偏移。Nacos 控制台使用 18080，Dashboard 使用 18082 以避开冲突。

后端 dev 数据库地址已同步为 127.0.0.1:13306，连接本机原有 3306 数据库时可通过 APP_DB_URL 覆盖。需要其他宿主机端口时，在 environment/.env 调整 MYSQL_PORT 等变量并通过 --env-file 指定，同时同步应用连接地址。Java 后端 8080、Vite 5137 属于本机开发进程，本次只调整 Compose 端口。

开发与生产的中间件镜像统一为 MySQL 8.0.32、Redis 6.2、Nacos 3.0.3、RocketMQ 5.1.0、XXL-Job 2.4.1、RustFS 1.0.4。开发 Nacos 使用 Derby，生产使用 MySQL，项目名和命名卷按环境区分，网络固定命名为 autrain-network。

已有部署若使用 MySQL 8.4、Redis 7.x 或 RocketMQ 5.3.x，不要直接让较低版本打开旧数据卷。先备份并验证逻辑迁移/消息迁移到新卷；Nacos 2.x 升级 3.0.3 需按官方升级说明处理已有表和灰度配置。本仓库的初始化 SQL 仅用于空库，不会自动迁移已有生产数据。

${hash}${hash} 生产部署

生产 Nacos 和 XXL-Job 参照 XFG 使用 MySQL root 连接，密码来自 app/.env 的 MYSQL_ROOT_PASSWORD；业务应用继续使用业务库专用用户。XXL-Job 初始管理员仍为 admin / 123456，首次登录后修改。

使用[应用脚本](app/README.md)。先独立准备生产中间件，再构建和启动 app/nginx；stop 只停止应用。后端、Nginx 和中间件统一连接 autrain-network bridge 网络。前端资源内置于镜像，远程部署使用镜像仓库或 docker save/load。

生产只有 Nginx 发布宿主机端口；管理页面可通过 SSH 隧道转发到服务在服务器上的 bridge IP（docker inspect 查询），Nacos 3 控制台示例：ssh -L 18080:容器IP:8080 user@server，随后打开 http://127.0.0.1:18080。容器重建后重新查询 IP。Nacos 管理员先在受控隧道中初始化再交给团队访问。

单机配置建议至少 4 CPU / 8 GiB 内存，预留消息和数据库磁盘空间。当前仅提供基础设施，业务 SDK、Nacos 配置加载、XXL-Job 执行器仍需按项目选用。XXL-Job 健康检查只确认监听端口，验收时应实际登录并验证执行器回调。

业务库 ${databaseName} 继续由应用 Flyway 管理；中间件库独立初始化，不接入业务 Flyway。已有数据卷不会重新执行初始化 SQL，不能通过删卷做迭代。备份和已有环境升级见 [SQL 说明](environment/mysql/sql/README.md)。

RustFS 使用独立的 rustfs-data 与 rustfs-logs 命名卷；开发 S3 API / 控制台为 19000 / 19001，生产仅在容器网络监听 9000 / 9001。生产需在 app/.env 补充 RUSTFS_ACCESS_KEY 与 RUSTFS_SECRET_KEY。详见 [RustFS 说明](environment/rustfs/README.md)。
