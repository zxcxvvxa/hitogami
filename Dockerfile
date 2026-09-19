FROM teddysun/xray:latest AS xray-bin
FROM ghcr.io/sagernet/sing-box:latest AS singbox-bin

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Install Nginx, Supervisord, Python, and utilities
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    python3 \
    python3-pip \
    curl \
    netcat \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries
COPY --from=xray-bin /usr/bin/xray /usr/local/bin/xray
COPY --from=singbox-bin /usr/local/bin/sing-box /usr/local/bin/sing-box

# Set up working directory
WORKDIR /app

# Copy scripts and configs
COPY nginx.conf /etc/nginx/nginx.conf
COPY sing-box.json /etc/sing-box/config.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY anti_ddos.py /app/anti_ddos.py
COPY sub_server.py /app/sub_server.py
COPY entrypoint.sh /app/entrypoint.sh
COPY wait-for-nginx.sh /app/wait-for-nginx.sh
COPY wait-for-xray.sh /app/wait-for-xray.sh

# Set permissions
RUN chmod +x /usr/local/bin/xray /usr/local/bin/sing-box /app/*.sh /app/*.py

EXPOSE 80 8080

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
