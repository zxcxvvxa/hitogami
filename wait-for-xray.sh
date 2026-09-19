#!/bin/bash
echo "[Wait-Script] Validating Sing-Box and Xray binaries..."
if [ -f /etc/sing-box/config.json ] && [ -x /usr/local/bin/sing-box ]; then
    echo "[Wait-Script] Proxy binary and config present."
else
    echo "[Wait-Script] Missing proxy files!"
    exit 1
fi
