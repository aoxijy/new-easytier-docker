FROM alpine:latest

# 构建参数
ARG EASYTIER_VERSION=2.1.2
ARG TARGETARCH=amd64

# 环境变量（移除敏感信息）
ENV EASYTIER_VERSION=${EASYTIER_VERSION}
ENV INSTANCE_NAME=node-docker
ENV MACHINE_ID=
ENV IPV4=172.18.28.100
ENV DHCP=false
ENV HOSTNAME=easytier-docker
ENV NETWORK_NAME=yksnet
ENV RPC_PORTAL=0.0.0.0:15889
ENV WEB_PORT=11211
ENV API_HOST=https://zw.gqru.com
ENV TCP_PORT=19001
ENV WSS_PORT=19002
ENV CONFIG_SERVER=udp://127.0.0.1:22020
ENV DEFAULT_PROTOCOL=tcp
ENV MTU=1380
ENV ENABLE_EXIT_NODE=false
ENV DISABLE_P2P=false

# 安装依赖和创建用户（添加 gettext 包用于 envsubst）
RUN apk add --no-cache curl iptables ip6tables unzip gettext && \
    adduser -D -s /bin/sh easytier

# 创建工作目录
WORKDIR /app

# 下载并安装 EasyTier (包含 core 和 web-embed)
RUN ARCH=$(case "$TARGETARCH" in \
        "amd64") echo "x86_64" ;; \
        "arm64") echo "aarch64" ;; \
        *) echo "x86_64" ;; \
    esac) && \
    curl -L -o easytier.zip \
    "https://github.com/EasyTier/EasyTier/releases/download/v${EASYTIER_VERSION}/easytier-linux-${ARCH}-v${EASYTIER_VERSION}.zip" && \
    unzip easytier.zip && \
    rm easytier.zip && \
    chmod +x easytier-core easytier-web-embed && \
    mv easytier-core easytier-web-embed /usr/local/bin/

# 复制配置文件和启动脚本
COPY config.toml ./
COPY entrypoint.sh ./

# 设置权限
RUN chown -R easytier:easytier /app && \
    chmod +x entrypoint.sh

# 暴露端口
EXPOSE 19001/tcp 19001/udp 19002/tcp 11211/tcp 15889/tcp

# 切换用户
USER easytier

# 启动脚本
ENTRYPOINT ["./entrypoint.sh"]
