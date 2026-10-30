#!/usr/bin/env bash
# ==============================================================================
# Actualiza la app en el VPS. Es EXACTAMENTE lo que ejecuta el workflow de
# despliegue automático (deploy.yml). Útil para desplegar a mano o entender
# qué pasa "por dentro" cuando GitHub Actions se conecta por SSH.
# Guía: docs/10-despliegue-automatico.md
#
# Uso en el VPS:
#   bash deploy.sh              # usa ~/mi-app
#   bash deploy.sh ~/otra-app   # otra carpeta
# ==============================================================================
set -euo pipefail

APP_DIR="${1:-$HOME/mi-app}"

cd "$APP_DIR"
echo "==> Actualizando código desde GitHub..."
git pull --ff-only
echo "==> Reconstruyendo la imagen Docker..."
docker compose build
echo "==> Reiniciando los contenedores..."
docker compose up -d
echo "==> Estado:"
docker compose ps
