#!/bin/bash
set -e

echo "[Entrypoint] Initializing services..."

# Run non-blocking checks
/app/wait-for-nginx.sh
/app/wait-for-xray.sh

echo "[Entrypoint] Starting process manager..."
exec "$@"
