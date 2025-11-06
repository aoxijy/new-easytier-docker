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

# 检查必要的环境变量
if [ -z "$NETWORK_SECRET" ]; then
    echo "ERROR: NETWORK_SECRET environment variable is required"
    exit 1
fi

# 复制原始配置文件
cp config.toml config.toml.template

# 使用 envsubst 替换环境变量（处理简单的 ${VAR} 替换）
envsubst < config.toml.template > config.toml.final

# 处理复杂的条件逻辑（移除模板语法）
sed -i '/{{ if fileExists "\/app\/peers.toml" }}/,/{{ end }}/d' config.toml.final

# 如果存在 peers.toml 文件，添加对应的配置
if [ -f "/app/peers.toml" ]; then
    echo "Using external peers configuration from peers.toml"
    # 这里可以添加逻辑来合并 peer 配置
    cat /app/peers.toml >> config.toml.final
else
    echo "Using default peers configuration"
    # 添加默认的 peer 配置
    cat >> config.toml.final << 'EOF'

# 默认 peer 配置
[[peer]]
uri = "tcp://gd.et.tianpao.top:11010"

[[peer]]
uri = "tcp://gz.server.piedaochuan.top:11010"
EOF
fi

# 使用最终的配置文件
mv config.toml.final config.toml

# 创建必要的目录
mkdir -p /app/data /app/logs

# 设置权限
chown -R easytier:easytier /app

# 启动 EasyTier Core (后台运行)
echo "Starting EasyTier Core..."
echo "Instance: ${INSTANCE_NAME}"
echo "Network: ${NETWORK_NAME}"
echo "IP: ${IPV4}"
echo "Machine ID: ${MACHINE_ID}"

easytier-core -c /app/config.toml &

# 等待 core 启动
sleep 5

# 启动 EasyTier Web Embed (前台运行)
echo "Starting EasyTier Web Embed..."
echo "Web Portal: http://0.0.0.0:${WEB_PORT}"
echo "API Host: ${API_HOST}"

exec easytier-web-embed --api-host "${API_HOST}" --web-port "${WEB_PORT}"
