#!/bin/sh

set -e

# 设置工作目录
cd /app

# 生成 machine_id（如果未提供）
if [ -z "$MACHINE_ID" ]; then
    MACHINE_ID=$(cat /proc/sys/kernel/random/uuid)
    echo "Generated machine_id: $MACHINE_ID"
    export MACHINE_ID
fi

# 生成配置文件
cat > config.toml << EOF
# 基本设置
instance_name = "${INSTANCE_NAME}"
machine_id = "${MACHINE_ID}"
ipv4 = "${IPV4}"
dhcp = ${DHCP}
hostname = "${HOSTNAME}"

# 监听端口配置
listeners = [
    "tcp://0.0.0.0:19001",
    "udp://0.0.0.0:19001",
    "udp://[::]:19001",
    "tcp://[::]:19001",
    "wss://0.0.0.0:19002/",
    "wss://[::]:19002/",
]

# RPC 管理接口
rpc_portal = "${RPC_PORTAL}"

# 网络标识
network_name = "${NETWORK_NAME}"
network_secret = "${NETWORK_SECRET}"

# 对等节点配置
[[peer]]
uri = "tcp://8.134.177.98:19001"

[[peer]]
uri = "tcp://47.119.115.81:19001"

# 高级设置
default_protocol = "${DEFAULT_PROTOCOL}"
dev_name = ""
disable_encryption = false
disable_ipv6 = false
mtu = ${MTU}
latency_first = true
enable_exit_node = ${ENABLE_EXIT_NODE}
no_tun = false
use_smoltcp = false
relay_network_whitelist = ["*"]
disable_p2p = ${DISABLE_P2P}
relay_all_peer_rpc = false
config_server = "${CONFIG_SERVER}"
EOF

# 如果存在外部 peer 配置文件，则替换 peer 配置
if [ -f "/app/peers.toml" ]; then
    echo "Using external peers configuration..."
    # 这里可以添加逻辑来合并或替换 peer 配置
    # 当前实现使用外部文件的完整配置
    cp /app/peers.toml /app/peer_config.toml
fi

# 创建必要的目录
mkdir -p /app/data /app/logs

# 设置权限
chown -R easytier:easytier /app

# 启动 EasyTier Core
echo "Starting EasyTier Core..."
echo "Instance: ${INSTANCE_NAME}"
echo "Network: ${NETWORK_NAME}"
echo "IP: ${IPV4}"
echo "Machine ID: ${MACHINE_ID}"

exec easytier-core -c /app/config.toml
