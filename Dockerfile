FROM alpine:latest

# 构建参数
ARG EASYTIER_VERSION=2.4.5

# 环境变量
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

# 安装依赖
RUN apk add --no-cache curl iptables ip6tables unzip gettext

# 创建工作目录
WORKDIR /app

# 下载 EasyTier - 修复版本和文件名问题
RUN set -eux && \
    # 设置架构
    if [ "$TARGETARCH" = "amd64" ]; then \
        ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        ARCH="aarch64"; \
    else \
        ARCH="x86_64"; \
    fi && \
    \
    # 测试下载链接
    echo "Downloading EasyTier v${EASYTIER_VERSION} for ${ARCH}..." && \
    \
    # 尝试不同的文件名格式
    URL="https://github.com/EasyTier/EasyTier/releases/download/v${EASYTIER_VERSION}/easytier-linux-${ARCH}-v${EASYTIER_VERSION}.zip" && \
    echo "Trying URL: $URL" && \
    \
    # 下载文件
    if curl -f -L -o easytier.zip "$URL"; then \
        echo "Download successful"; \
    else \
        echo "First download failed, trying alternative URL..." && \
        # 尝试其他可能的文件名格式
        ALT_URL="https://github.com/EasyTier/EasyTier/releases/download/v${EASYTIER_VERSION}/easytier-${ARCH}-v${EASYTIER_VERSION}.zip" && \
        echo "Trying alternative URL: $ALT_URL" && \
        curl -f -L -o easytier.zip "$ALT_URL" || \
        (echo "All download attempts failed" && exit 1); \
    fi && \
    \
    # 解压文件
    echo "Unzipping..." && \
    unzip -o easytier.zip && \
    \
    # 检查文件是否存在
    echo "Checking extracted files..." && \
    ls -la && \
    \
    # 设置执行权限并安装
    chmod +x easytier-core easytier-web-embed && \
    mv easytier-core easytier-web-embed /usr/local/bin/ && \
    \
    # 清理
    rm -f easytier.zip && \
    echo "Installation completed successfully"

# 复制配置文件和启动脚本
COPY config.toml ./
COPY entrypoint.sh ./

# 设置权限和用户
RUN chmod +x entrypoint.sh && \
    adduser -D -s /bin/sh easytier && \
    chown -R easytier:easytier /app

# 暴露端口
EXPOSE 19001/tcp 19001/udp 19002/tcp 11211/tcp 15889/tcp

# 切换用户
USER easytier

# 启动脚本
ENTRYPOINT ["./entrypoint.sh"]
