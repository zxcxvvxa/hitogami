#!/bin/bash
echo "[Wait-Script] Checking Nginx configuration syntax..."
nginx -t
if [ $? -eq 0 ]; then
    echo "[Wait-Script] Nginx configuration syntax OK."
else
    echo "[Wait-Script] Nginx configuration error!"
    exit 1
fi
