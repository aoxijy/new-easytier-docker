FROM alpine:latest

# 构建参数
ARG EASYTIER_VERSION=2.1.2
ARG TARGETARCH=amd64

# 环境变量
ENV EASYTIER_VERSION=${EASYTIER_VERSION}
ENV INSTANCE_NAME=node-docker
ENV MACHINE_ID=
ENV IPV4=172.18.28.100
ENV DHCP=false
ENV HOSTNAME=easytier-docker
ENV NETWORK_NAME=gqrunet
ENV NETWORK_SECRET=gqru123456
ENV RPC_PORTAL=127.0.0.1:15889
ENV TCP_PORT=19001
ENV WSS_PORT=19002
ENV CONFIG_SERVER=udp://127.0.0.1:22020
ENV DEFAULT_PROTOCOL=tcp
ENV MTU=1380
ENV ENABLE_EXIT_NODE=false
ENV DISABLE_P2P=false

# 安装依赖和创建用户
RUN apk add --no-cache curl iptables ip6tables unzip && \
    adduser -D -s /bin/sh easytier

# 创建工作目录
WORKDIR /app

# 下载并安装 EasyTier
RUN ARCH=$(case "$TARGETARCH" in \
        "amd64") echo "x86_64" ;; \
        "arm64") echo "aarch64" ;; \
        *) echo "x86_64" ;; \
    esac) && \
    curl -L -o easytier.zip \
    "https://github.com/EasyTier/EasyTier/releases/download/v${EASYTIER_VERSION}/easytier-linux-${ARCH}-v${EASYTIER_VERSION}.zip" && \
    unzip easytier.zip && \
    rm easytier.zip && \
    chmod +x easytier-core && \
    mv easytier-core /usr/local/bin/

# 复制配置文件和启动脚本
COPY config.toml.template ./
COPY entrypoint.sh ./

# 设置权限
RUN chown -R easytier:easytier /app && \
    chmod +x entrypoint.sh

# 暴露端口
# 19001: TCP/UDP 主要通信端口
# 19002: WebSocket Secure 端口
# 15889: RPC 管理端口
EXPOSE 19001/tcp 19001/udp 19002/tcp 15889/tcp

# 切换用户
USER easytier

# 启动脚本
ENTRYPOINT ["./entrypoint.sh"]
