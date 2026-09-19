#!/bin/bash
echo "[Wait-Script] Validating Sing-Box / Proxy configuration..."
if [ -f /etc/sing-box/config.json ]; then
    echo "[Wait-Script] Sing-Box configuration file found."
else
    echo "[Wait-Script] Missing configuration file!"
    exit 1
fi
