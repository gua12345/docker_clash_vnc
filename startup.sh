#!/bin/bash

# 设置时区
echo "Setting timezone to ${TZ}..."
ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# 启动虚拟帧缓冲区
echo "Starting Xvfb on display :0 with geometry ${VNC_GEOMETRY}..."
Xvfb :0 -screen 0 ${VNC_GEOMETRY}x24 &

# 启动 Fluxbox 窗口管理器
echo "Starting Fluxbox window manager..."
fluxbox &

# 启动 x11vnc
echo "Starting x11vnc server on ${VNC_HOST}:${VNC_PORT}..."
x11vnc -display :0 -forever -rfbport ${VNC_PORT} -rfbportv6 ${VNC_PORT} -shared -bg

# 启动 noVNC
echo "Starting noVNC on http://${NOVNC_HOST}:${NOVNC_PORT}..."
novnc_proxy --vnc ${VNC_HOST}:${VNC_PORT} --listen ${NOVNC_PORT} --web /opt/novnc &

# 启动 Clash Verge Rev
echo "Starting Clash Verge Rev..."
/usr/share/clash-verge/clash-verge --no-sandbox &
wait
