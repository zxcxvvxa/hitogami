FROM teddysun/xray:latest AS xray-bin
FROM ghcr.io/sagernet/sing-box:latest AS singbox-bin

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Install system packages cleanly without extra recommended files
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    supervisor \
    python3 \
    python3-pip \
    curl \
    netcat-openbsd \
    net-tools \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install uvloop without unsupported flags
RUN pip3 install --no-cache-dir uvloop

# Copy binaries from multi-stage images
COPY --from=xray-bin /usr/bin/xray /usr/local/bin/xray
COPY --from=singbox-bin /usr/local/bin/sing-box /usr/local/bin/sing-box

WORKDIR /app

# Copy scripts & configs
COPY nginx.conf /etc/nginx/nginx.conf
COPY sing-box.json /etc/sing-box/config.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY anti_ddos.py /app/anti_ddos.py
COPY sub_server.py /app/sub_server.py
COPY entrypoint.sh /app/entrypoint.sh
COPY wait-for-nginx.sh /app/wait-for-nginx.sh
COPY wait-for-xray.sh /app/wait-for-xray.sh

RUN chmod +x /usr/local/bin/xray /usr/local/bin/sing-box /app/*.sh /app/*.py

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
