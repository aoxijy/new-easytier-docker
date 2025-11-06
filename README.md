# EasyTier Docker 部署

基于 Docker 的 EasyTier 虚拟专用网络解决方案，匹配生产环境配置。

## 快速开始

1. 克隆项目：
```bash
git clone <repository-url>
cd easytier-docker

2.配置环境变量：
cp .env.example .env
# 编辑 .env 文件，修改网络配置

3.启动服务：
docker-compose up -d

环境变量说明
变量名	描述	默认值
INSTANCE_NAME	实例名称	node-docker
MACHINE_ID	机器ID（为空自动生成）	空
IPV4	分配的IPv4地址	172.18.28.100
DHCP	是否启用DHCP	false
HOSTNAME	主机名	easytier-docker
NETWORK_NAME	网络名称	yksnet
NETWORK_SECRET	网络密钥	kulacc369Q
TCP_PORT	TCP/UDP外部端口	19001
WSS_PORT	WSS外部端口	19002
RPC_PORTAL	RPC管理接口	127.0.0.1:15889
端口映射
${TCP_PORT}:19001/tcp - TCP通信

${TCP_PORT}:19001/udp - UDP通信

${WSS_PORT}:19002/tcp - WebSocket Secure

15889:15889/tcp - RPC管理（内部）

自定义 Peer 节点
创建 peers.toml 文件来自定义对等节点：
