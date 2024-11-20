# 使用 ARM64 的 Debian Slim 基础镜像
FROM debian:bullseye-slim

# 设置环境变量以避免交互
ENV DEBIAN_FRONTEND=noninteractive

# 设置默认环境变量
ENV TZ=shanghai \
    VNC_HOST=127.0.0.1 \
    VNC_PORT=5900 \
    VNC_GEOMETRY=1280x800 \
    TITLE="Clash Verge" \
    NOVNC_HOST=0.0.0.0 \
    NOVNC_PORT=6081

# 安装系统依赖和 Xvfb
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
    libayatana-appindicator3-1 \
    libwebkit2gtk-4.0-37 \
    xvfb \
    dbus \
    && apt-get clean

# 阻止服务在构建时启动
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# 下载并安装 Clash Verge 的 .deb 包
RUN wget https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v1.7.7/clash-verge_1.7.7_arm64.deb -O /tmp/clash-verge_1.7.7_arm64.deb \
    && dpkg -i /tmp/clash-verge_1.7.7_arm64.deb \
    && apt-get install -f -y \
    && rm /tmp/clash-verge_1.7.7_arm64.deb

# 创建 .vnc 目录，并设置密码文件
RUN mkdir -p /root/.vnc && \
    echo "password" | x11vnc -storepasswd - /root/.vnc/passwd

# 创建启动脚本
RUN echo "#!/bin/sh\n\
# 启动 dbus 服务\n\
service dbus start\n\
# 启动虚拟显示\n\
Xvfb :0 -screen 0 ${VNC_GEOMETRY}x24 &\n\
sleep 5\n\
# 启动 x11vnc 并绑定到 127.0.0.1:5900\n\
x11vnc -display :0 -forever -usepw -passwdfile /root/.vnc/passwd -listen 127.0.0.1 -rfbport $VNC_PORT &\n\
sleep 2\n\
# 启动 Clash Verge\n\
clash-verge &\n\
sleep 2\n\
# 启动 noVNC 并代理到 127.0.0.1:5900\n\
websockify --web /usr/share/novnc $NOVNC_HOST:$NOVNC_PORT $VNC_HOST:$VNC_PORT &\n\
wait" \
> /usr/local/bin/start.sh && chmod +x /usr/local/bin/start.sh

# 使用启动脚本作为容器的入口点
CMD ["/usr/local/bin/start.sh"]
