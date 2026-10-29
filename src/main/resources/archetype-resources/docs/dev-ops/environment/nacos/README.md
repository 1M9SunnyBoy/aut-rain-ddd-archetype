#set( $dollar = '$' )
#set( $hash = '#' )
${hash} Nacos
生产 3.0.3 standalone + MySQL nacos_config，数据库用户 root，密码读取 MYSQL_ROOT_PASSWORD。配置位于 ../docker-compose.yml，表结构位于 ../mysql/sql/nacos.sql。

开发独立 docker-compose.dev.yml 使用 3.0.3 standalone + 内嵌 Derby，数据在 nacos-data 命名卷，日志在 nacos-logs。开发不使用 nacos.sql 或 MySQL 数据源。控制台入口 http://127.0.0.1:18080，首次设置 nacos 管理员密码；宿主机 18848 为 API，19848/19849 为 gRPC，映射容器 8848/9848/9849。不能沿用 2.x 的 /nacos 控制台地址。健康检查仅检查监听端口，需实际登录并注册客户端验证。

已开启 NACOS_AUTH_ENABLE。NACOS_AUTH_TOKEN 是至少 32 字节随机数据的标准 Base64；生产 NACOS_AUTH_IDENTITY_VALUE 是独立随机值，在 app/.env 中手动配置。开发 Compose 自带固定 token 和身份值，无需手动生成；它们不等于登录密码，首次控制台初始化可将 nacos 账号密码设为 nacos。

生产 Nacos 3.0.3 控制台位于容器 8080，首次需经受控 SSH 隧道转发该端口后打开根路径 /，按照初始化提示设置 nacos 管理员密码；模板不预置管理员密码。它与数据库密码、token 是不同凭据。完成初始化后再交给团队访问。

开发客户端使用 127.0.0.1:18848，同时需要 19848；容器客户端使用 nacos:8848。生产不向宿主机发布端口，也不经前端 Nginx 公开代理。模板没有替应用引入 Spring Cloud Alibaba 或配置加载依赖。

生产健康检查使用 /nacos/v3/admin/core/state/readiness（8848），检查服务可读状态；控制台独立监听 8080。生产 MySQL 初始化 SQL 与 3.0.3 官方版本一致，包含 config_info_gray 及历史记录灰度字段。已有 2.x 数据库需要按官方升级流程迁移，不重放空库建表 SQL。
