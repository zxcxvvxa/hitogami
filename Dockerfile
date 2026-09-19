FROM teddysun/xray:latest AS xray-bin
FROM ghcr.io/sagernet/sing-box:latest AS singbox-bin

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Install system dependencies, C-build tools (required for uvloop compilation), Nginx, and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    supervisor \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    curl \
    netcat-openbsd \
    net-tools \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install uvloop with explicit system-override flag for Ubuntu 22.04
RUN pip3 install --no-cache-dir --break-system-packages uvloop

# Copy binaries
COPY --from=xray-bin /usr/bin/xray /usr/local/bin/xray
COPY --from=singbox-bin /usr/bin/sing-box /usr/local/bin/sing-box

WORKDIR /app

# Copy configuration files and scripts
COPY nginx.conf /etc/nginx/nginx.conf
COPY sing-box.json /etc/sing-box/config.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY anti_ddos.py /app/anti_ddos.py
COPY sub_server.py /app/sub_server.py
COPY entrypoint.sh /app/entrypoint.sh
COPY wait-for-nginx.sh /app/wait-for-nginx.sh
COPY wait-for-xray.sh /app/wait-for-xray.sh

# Ensure script formatting and execution permissions
RUN chmod +x /usr/local/bin/xray /usr/local/bin/sing-box /app/*.sh /app/*.py

# Cloud Run injects $PORT (defaulting to 8080)
EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
