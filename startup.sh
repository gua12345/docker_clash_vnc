#!/bin/bash

echo "Setting timezone to ${TZ}..."
ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

echo "Starting Xvfb on display :0 with geometry ${VNC_GEOMETRY}..."
Xvfb :0 -screen 0 ${VNC_GEOMETRY}x24 &

echo "Starting Fluxbox window manager..."
fluxbox &

echo "Starting x11vnc server on ${VNC_HOST}:${VNC_PORT}..."
x11vnc -display :0 -forever -rfbport ${VNC_PORT} -rfbportv6 ${VNC_PORT} -shared -bg

echo "Starting noVNC on http://${NOVNC_HOST}:${NOVNC_PORT}..."
novnc_proxy --vnc ${VNC_HOST}:${VNC_PORT} --listen ${NOVNC_PORT} --web /opt/novnc &

echo "Starting Clash Verge Rev..."
/usr/share/clash-verge/clash-verge --no-sandbox &
wait
