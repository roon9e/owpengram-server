#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo
echo "[1/2] docker compose -f docker-compose-env.yaml up -d"
docker compose -f docker-compose-env.yaml up -d

echo
echo "[2/2] docker compose up -d"
docker compose up -d

echo
echo "[OK] Server started"
