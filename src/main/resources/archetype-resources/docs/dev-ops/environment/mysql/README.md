#set( $dollar = '$' )
#set( $hash = '#' )
${hash} MySQL
开发独立 Compose 使用 MySQL 8.0.32，默认映射 127.0.0.1:13306；生产 compose.yaml 同样使用 MySQL 8.0.32 且不发布端口。两者使用项目隔离的 mysql-data 命名卷，不能共用或原地降级。开发参数通过 command 配置，避免 Windows 挂载 my.cnf 的权限被 MySQL 忽略；生产 conf.d/my.cnf 保持只读、644 权限。

首次空卷启动由官方入口创建业务库 ${databaseName} 与同名用户，开发随后运行 initdb/10-development.sh，仅创建 xxl_job 及独立用户；生产运行 initdb/10-middleware.sh，创建 nacos_config、xxl_job 及独立用户。脚本均在 Linux 容器内部执行，兼容直接执行与 source 两种入口，保持 LF，无需在 Windows 上执行 chmod。业务表由 Flyway 管理，中间件表见 ../sql，不包含物理外键。

开发配置示例统一到 ../.env.example；服务器凭据在 app/.env 中手动配置。已有卷不重跑初始化，修改 .env 不会轮换数据库密码。业务与中间件需自行备份，说明见 ../sql/README.md。

开发默认 root / 123456，业务库同名备用用户密码也为 123456，允许 root 从开发 Docker 网络连接。后端 dev 配置默认使用 root；已有数据卷和本机数据库不会自动改密。生产凭据在 app/.env 中手动配置。
