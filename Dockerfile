# 使用最小的 Linux 系统作为基础镜像
FROM alpine:latest

# 设置版本号环境变量
ARG VERSION=v2.3.2

# 安装必要工具
RUN apk add --no-cache curl unzip iptables iproute2 jq

# 创建工作目录
WORKDIR /app

# 下载 EasyTier 二进制文件
RUN curl -LO "https://github.com/EasyTier/EasyTier/releases/download/${VERSION}/easytier-linux-x86_64-${VERSION}.zip" \
    && unzip -j easytier-linux-x86_64-${VERSION}.zip \
    && rm easytier-linux-x86_64-${VERSION}.zip \
    && chmod +x easytier-*

# 创建 TUN 设备
RUN mkdir -p /dev/net \
    && mknod /dev/net/tun c 10 200 \
    && chmod 0666 /dev/net/tun

# 创建配置目录
RUN mkdir -p /etc/easytier

# 复制您的默认配置文件（从构建上下文复制）
COPY config.toml /etc/easytier/config.toml

# 创建 entrypoint 脚本
RUN echo '#!/bin/sh' > /app/entrypoint.sh && \
    echo 'if [ -n "$ET_CONFIG_SERVER" ]; then' >> /app/entrypoint.sh && \
    echo '    tmp_file=$(mktemp)' >> /app/entrypoint.sh && \
    echo '    jq --arg server "$ET_CONFIG_SERVER" '\''.config_server = $server'\'' /etc/easytier/config.toml > "$tmp_file"' >> /app/entrypoint.sh && \
    echo '    [ -s "$tmp_file" ] && mv "$tmp_file" /etc/easytier/config.toml' >> /app/entrypoint.sh && \
    echo 'fi' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo 'if [ -n "$ET_MACHINE_ID" ]; then' >> /app/entrypoint.sh && \
    echo '    tmp_file=$(mktemp)' >> /app/entrypoint.sh && \
    echo '    jq --arg id "$ET_MACHINE_ID" '\''.machine_id = $id'\'' /etc/easytier/config.toml > "$tmp_file"' >> /app/entrypoint.sh && \
    echo '    [ -s "$tmp_file" ] && mv "$tmp_file" /etc/easytier/config.toml' >> /app/entrypoint.sh && \
    echo 'fi' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo 'exec /app/easytier-core --config-file /etc/easytier/config.toml' >> /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# 暴露标准端口
EXPOSE 11010/tcp 11010/udp 11011/tcp 11020/tcp 15888/tcp

# 设置容器启动命令
ENTRYPOINT ["/app/entrypoint.sh"]
