#!/bin/bash
set -e

echo "[Entrypoint] Initializing application stack..."

# Run health checks/wait scripts before full start
/app/wait-for-nginx.sh
/app/wait-for-xray.sh

echo "[Entrypoint] Health checks passed. Starting Supervisord..."
exec "$@"
