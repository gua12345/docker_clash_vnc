# 使用 ARM64 的 Debian Slim 基础镜像
FROM debian:bullseye-slim

# 设置默认环境变量（用户可覆盖）
ENV TZ=shanghai \
    VNC_HOST=127.0.0.1 \
    VNC_PORT=5901 \
    VNC_GEOMETRY=1280x800 \
    TITLE="Clash Verge" \
    NOVNC_HOST=0.0.0.0 \
    NOVNC_PORT=6081

# 更新系统并安装依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    x11vnc \
    fluxbox \
    xvfb \
    libgtk-3-0 \
    python3 \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装 noVNC
RUN pip3 install websockify && \
    mkdir -p /opt/novnc && \
    wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | tar xz --strip-components=1 -C /opt/novnc && \
    ln -s /opt/novnc/utils/novnc_proxy /usr/local/bin/novnc_proxy

# 下载并安装 Clash Verge Rev
RUN wget -q https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v1.7.7/clash-verge_1.7.7_arm64.deb -O /tmp/clash-verge.deb && \
    dpkg -i /tmp/clash-verge.deb || apt-get -f install -y && \
    rm -f /tmp/clash-verge.deb

# 设置工作目录
WORKDIR /root

# 下载 startup.sh 并保存到镜像中
RUN wget -O /root/startup.sh https://raw.githubusercontent.com/gua12345/docker_clash_vnc/refs/heads/main/startup.sh && \
    chmod +x /root/startup.sh

# 暴露端口
EXPOSE 5901 6081 7897 9097

# 启动容器时运行脚本
CMD ["/root/startup.sh"]
