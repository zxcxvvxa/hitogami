FROM teddysun/xray:latest AS xray-bin
FROM ghcr.io/sagernet/sing-box:latest AS singbox-bin

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    python3 \
    python3-pip \
    curl \
    netcat-openbsd \
    net-tools \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir uvloop

COPY --from=xray-bin /usr/bin/xray /usr/local/bin/xray
COPY --from=singbox-bin /usr/bin/sing-box /usr/local/bin/sing-box

WORKDIR /app

COPY nginx.conf /etc/nginx/nginx.conf
COPY sing-box.json /etc/sing-box/config.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY anti_ddos.py /app/anti_ddos.py
COPY sub_server.py /app/sub_server.py
COPY entrypoint.sh /app/entrypoint.sh
COPY wait-for-nginx.sh /app/wait-for-nginx.sh
COPY wait-for-xray.sh /app/wait-for-xray.sh

RUN chmod +x /usr/local/bin/xray /usr/local/bin/sing-box /app/*.sh /app/*.py

# Only expose 8080 to match your original configuration
EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
