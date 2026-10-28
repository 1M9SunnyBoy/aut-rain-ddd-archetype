#set( $dollar = '$' )
#set( $hash = '#' )
${hash} RocketMQ
开发与生产 NameServer/Broker 均使用官方 apache/rocketmq:5.1.0，单 Master。消息卷 rocketmq-store，日志使用独立命名卷。生产广播 rocketmq-broker，开发广播 127.0.0.1，适用于本机 remoting 客户端；没有 Proxy，不提供 RocketMQ 5 gRPC 接入。

关闭自动 Topic/消费组创建，在 environment 目录显式初始化：

```bash
docker compose -f docker-compose.dev.yml exec rocketmq-broker sh mqadmin updateTopic -n rocketmq-namesrv:9876 -c DefaultCluster -t example-topic
docker compose -f docker-compose.dev.yml exec rocketmq-broker sh mqadmin updateSubGroup -n rocketmq-namesrv:9876 -c DefaultCluster -g example-consumer
```

生产使用对应发布目录的 Compose。基础配置未启用 Broker ACL，仅供隔离内部网络；跨主机接入需一并设计广播地址、端口、ACL。只改 NameServer 地址不足以支持外部客户端。

开发附带 apacherocketmq/rocketmq-dashboard:1.0.0，入口 http://127.0.0.1:18082。Dashboard 与 Broker 共享网络命名空间，因此可以访问 Broker 广播的 127.0.0.1；18082 端口由 Broker 服务映射到控制台的 8080。原地更新 Broker 时一起重建 Dashboard。Windows 宿主机客户端使用 127.0.0.1:19876；这些命令在 PowerShell 执行，sh mqadmin 在容器内部执行。

开发 Broker 在容器内监听并向客户端广播 20911，VIP 为 20909，HA 为 20912，宿主机以同端口映射；这是为保持广播地址与发布端口一致。NameServer 容器仍使用 9876，所以以上 docker compose exec 命令继续使用 rocketmq-namesrv:9876。五位 Broker 端口按原值加 10000，避免直接前加 1 超过端口上限。
