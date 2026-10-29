#if( $databaseName == "auto" )
#set( $databaseName = $artifactId.replace('-', '_') )
#end
#set( $dollar = '$' )
#set( $hash = '#' )
${hash} 中间件初始化 SQL
- 00-project.sql：创建当前项目业务库 ${databaseName}，使用 IF NOT EXISTS，可重复执行；不创建业务表。默认库名取 artifactId 并将连字符转为下划线，生成时可通过 databaseName 覆盖。
- nacos.sql 来源：https://github.com/alibaba/nacos/blob/3.0.3/distribution/conf/mysql-schema.sql ，保留 Apache 许可证头。
- xxl-job.sql 来源：https://github.com/xuxueli/xxl-job/blob/2.4.1/doc/db/tables_xxl_job.sql ，保留上游版权说明，补齐建库与 USE，保留 admin / 123456 默认管理员，不包含示例执行器和任务。
- 不复制参考项目的业务分库、历史数据或账号；两套 SQL 均不含物理外键。

生产将 mysql/sql 目录直接挂载到 /docker-entrypoint-initdb.d；开发将 00-project.sql 和 xxl-job.sql 挂载到该初始化目录，Nacos 3 使用独立 Derby 数据卷。SQL 自带 CREATE DATABASE 和 USE，避免表落入业务库。MySQL 官方入口仅在空数据卷首次启动时执行，Windows 无需运行 Shell 脚本。XXL-Job 管理员初始密码为 123456，首次登录后在控制台修改。升级镜像须审核并手动应用对应上游升级 SQL，替换初始化文件不会升级已有数据库。业务 Flyway 仅管理 ${databaseName}。

已有环境不会自动重新导入 SQL。若之前使用 nacos / xxl_job 独立数据库用户，可保留这些用户并在 Compose 中设置实际用户名和密码；切换到本版 root 连接方式前，确认 root 允许容器网络连接。已有库应按上游升级流程迁移，不要重复执行空库 CREATE TABLE，也不要删卷升级。

应用脚本不自动备份，业务库与中间件库需自行备份。中间件可用 mysqldump --single-transaction --databases nacos_config xxl_job，密码从容器环境读取，输出保存为权限 600 的备份。Redis AOF 与 RocketMQ store 位于独立命名卷，维护窗口需做一致性快照。应用 stop 保留数据卷，恢复与清理由维护者明确执行。

版本统一后的已有环境处理：MySQL 8.4 → 8.0.32 需要兼容性审查和逻辑导出/导入到新卷，不能复用原数据目录；Redis 7.x → 6.2、RocketMQ 5.3.x → 5.1.0 的持久化格式也须先验证迁移。Nacos 2.x → 3.0.3 应按官方升级指南处理已有表、历史字段和灰度配置，nacos.sql 是 3.0.3 空库基线，不能直接在已有库运行。部署脚本不会代为执行这些跨版本迁移。
