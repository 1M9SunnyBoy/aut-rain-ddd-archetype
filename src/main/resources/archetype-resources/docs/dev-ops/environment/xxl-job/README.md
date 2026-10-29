#set( $dollar = '$' )
#set( $hash = '#' )
${hash} XXL-Job
镜像 xuxueli/xxl-job-admin:2.4.1，数据库 xxl_job，数据库用户 root，密码读取 MYSQL_ROOT_PASSWORD，内部监听 9090，开发地址 http://127.0.0.1:19090/xxl-job-admin。

初始管理员为 admin / 123456，由 ../mysql/sql/xxl-job.sql 写入密码的 MD5 值，开发和生产相同。首次登录后在控制台修改管理员密码；管理员密码不由 .env 设置。开发通信 token 为 default_token，生产通过 app/.env 的 XXL_JOB_ACCESS_TOKEN 配置。SQL 中没有示例任务。已有卷修改 SQL 不会重置账号。

XXL_JOB_ACCESS_TOKEN 用于调度中心与执行器通信，与管理员密码不同。业务接入时配置相同 token、可回调执行器地址及端口；仅启动管理中心不代表已集成任务执行。

生产不发布管理端口，使用受控网络或 SSH 隧道访问。健康检查只确认端口监听，上线应登录并执行测试任务验证。
