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
RUN apk add --no-cache curl unzip gettext

# 创建工作目录
WORKDIR /app

# 下载 EasyTier - 修复版本
RUN echo "下载 EasyTier v${EASYTIER_VERSION}" && \
    curl -L -o easytier.zip \
    "https://github.com/EasyTier/EasyTier/releases/download/v${EASYTIER_VERSION}/easytier-linux-x86_64-v${EASYTIER_VERSION}.zip" && \
    echo "解压文件..." && \
    unzip easytier.zip && \
    echo "解压后的文件:" && \
    ls -la && \
    echo "进入目录查看内容..." && \
    cd easytier-linux-x86_64 && \
    ls -la && \
    echo "安装二进制文件..." && \
    # 从目录中复制二进制文件
    cp easytier-linux-x86_64/easytier-core /usr/local/bin/ && \
    cp easytier-linux-x86_64/easytier-web-embed /usr/local/bin/ && \
    chmod +x /usr/local/bin/easytier-core /usr/local/bin/easytier-web-embed && \
    rm -rf easytier.zip easytier-linux-x86_64 && \
    echo "安装完成"

# 复制配置文件和启动脚本
COPY config.toml entrypoint.sh ./

# 设置权限
RUN chmod +x entrypoint.sh && \
    adduser -D -s /bin/sh easytier && \
    chown -R easytier:easytier /app

# 暴露端口
EXPOSE 19001/tcp 19001/udp 19002/tcp 11211/tcp 15889/tcp

# 切换用户
USER easytier

# 启动脚本
ENTRYPOINT ["./entrypoint.sh"]
