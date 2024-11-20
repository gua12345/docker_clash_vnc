# 使用 ARM64 的 Debian Slim 基础镜像
FROM debian:bullseye-slim

# 设置环境变量以避免交互
ENV DEBIAN_FRONTEND=noninteractive

# 设置默认环境变量（用户可覆盖）
ENV TZ=shanghai \
    VNC_HOST=127.0.0.1 \
    VNC_PORT=5901 \
    VNC_GEOMETRY=1280x800 \
    TITLE="Clash Verge" \
    NOVNC_HOST=0.0.0.0 \
    NOVNC_PORT=6081
    VNC_PASSWORD=password

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    wget \
    curl \
    gnupg2 \
    xz-utils \
    x11vnc \
    novnc \
    websockify \
    libgtk-3-0 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    && apt-get clean

# 阻止服务在构建时启动
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d
    
# 安装 Clash Verge 的依赖包
RUN apt-get update && apt-get install -y --no-install-recommends \
    libayatana-appindicator3-1 \
    libwebkit2gtk-4.0-37 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 下载并安装 Clash Verge Rev 的 .deb 包
RUN wget https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v1.7.7/clash-verge_1.7.7_arm64.deb -O /tmp/clash-verge_1.7.7_arm64.deb \
    && dpkg -i /tmp/clash-verge_1.7.7_arm64.deb \
    && apt-get install -f -y \
    && rm /tmp/clash-verge_1.7.7_arm64.deb

# 设置 VNC 密码，如果环境变量 VNC_PASSWORD 存在
RUN if [ -z "$VNC_PASSWORD" ]; then echo "No VNC password provided"; else x11vnc -storepasswd "$VNC_PASSWORD" /root/.vnc/passwd; fi

# 设置 VNC 服务器启动命令
RUN mkdir -p /etc/xdg/ \
    && echo "x11vnc -forever -usepw -create -geometry $VNC_GEOMETRY -display :0 -passwd /root/.vnc/passwd &" > /etc/xdg/start-vnc.sh \
    && chmod +x /etc/xdg/start-vnc.sh

# 启动 Clash Verge 和 noVNC 的命令
CMD clash-verge & \
    /etc/xdg/start-vnc.sh && \
    websockify --web /usr/share/novnc $NOVNC_HOST:$NOVNC_PORT $VNC_HOST:$VNC_PORT
