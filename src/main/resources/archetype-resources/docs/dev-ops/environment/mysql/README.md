#if( $databaseName == "auto" )
#set( $databaseName = $artifactId.replace('-', '_') )
#end
#set( $dollar = '$' )
#set( $hash = '#' )
${hash} MySQL

开发独立 Compose 使用 MySQL 8.0.32，默认映射 127.0.0.1:13306；生产 ../docker-compose.yml 直接定义 MySQL 服务，同样使用 MySQL 8.0.32 且不发布端口。两者使用项目隔离的 mysql-data 命名卷，不能共用或原地降级。开发参数通过 command 配置，避免 Windows 挂载 my.cnf 的权限被 MySQL 忽略；生产 conf.d/my.cnf 保持只读、644 权限。

库名默认由 artifactId 的连字符转下划线生成，也可在生成时通过 databaseName 指定；当前项目库名为 ${databaseName}。sql/00-project.sql 提供显式建库语句，可用于预先建库，业务建表和初始数据由 Flyway 执行。

首次空卷启动由官方入口创建业务库 ${databaseName} 与同名用户，再直接执行挂载到 /docker-entrypoint-initdb.d 的 SQL：

- 开发：挂载 sql/00-project.sql 和 sql/xxl-job.sql，创建 XXL-Job 数据库、表和默认管理员；Nacos 使用 Derby。
- 生产：挂载整个 sql 目录，创建 nacos_config、xxl_job 数据库及表，并初始化 XXL-Job 管理员。

SQL 自带 CREATE DATABASE 与 USE，不再使用 initdb Shell 脚本。Nacos 和 XXL-Job 参照 XFG 使用 MySQL root 连接，Compose 从 MYSQL_ROOT_PASSWORD 读取密码，并通过 MYSQL_ROOT_HOST=% 允许容器网络连接。业务应用的生产连接仍使用业务库专用用户。SQL 不含物理外键；业务表由 Flyway 管理。

开发默认 root / 123456，业务库同名备用用户密码也为 123456，后端 dev 默认使用 root。开发配置示例位于 ../.env.example，生产配置位于 ../../app/.env.example。

XXL-Job 初始管理员为 admin / 123456，由 sql/xxl-job.sql 固定初始化，首次登录后通过控制台修改。已有数据卷不重跑 SQL，修改 .env 不会轮换数据库密码。业务与中间件需自行备份，说明见 sql/README.md。
