#!/usr/bin/env bash
# ==============================================================================
# Deja el VPS listo para tu app: firewall + Docker + carpeta de la app.
# Guía: docs/04-conexion-y-firewall.md y docs/05-docker-en-el-vps.md
#
# Uso (después de conectarte por SSH al VPS):
#   bash setup_vps.sh
#
# Variables opcionales:
#   APP_DIR   carpeta donde vivirá la app   (default: ~/mi-app)
#   REPO_URL  tu repo de GitHub para clonar (default: no clona nada)
# ==============================================================================
set -euo pipefail # cualquier error detiene el script

APP_DIR="${APP_DIR:-$HOME/mi-app}"
REPO_URL="${REPO_URL:-}"

echo "==> 1/4 Puertos 22 (SSH), 80 (HTTP) y 443 (HTTPS) abiertos"
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT || true
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT || true
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT || true

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y iptables-persistent netfilter-persistent curl git
  # Guarda las reglas para que sigan vigentes tras reiniciar el servidor
  sudo netfilter-persistent save || true
fi

echo "==> 2/4 Docker"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
fi
sudo systemctl enable --now docker
# Para usar "docker" sin sudo (se aplica al volver a entrar)
sudo usermod -aG docker "$USER" || true

echo "==> 3/4 Carpeta de la app: $APP_DIR"
mkdir -p "$APP_DIR"

if [ -n "$REPO_URL" ] && [ ! -d "$APP_DIR/.git" ]; then
  git clone "$REPO_URL" "$APP_DIR"
fi

echo "==> 4/4 Archivo .env con claves aleatorias"
if [ ! -f "$APP_DIR/.env" ] && [ -f "$APP_DIR/.env.ejemplo" ]; then
  cp "$APP_DIR/.env.ejemplo" "$APP_DIR/.env"
  sed -i "s|SECRET_KEY=.*|SECRET_KEY=$(openssl rand -hex 32)|" "$APP_DIR/.env"
  echo "==> .env creado. Ahora EDITA el resto de valores con:"
  echo "    nano $APP_DIR/.env"
else
  echo "==> (omitido: ya existe .env o no hay .env.ejemplo)"
fi

echo ""
echo "==> LISTO. Importante:"
echo "    1. Sal y vuelve a entrar por SSH (para usar docker sin sudo):  exit"
echo "    2. Edita el .env si aún no lo hiciste:  nano $APP_DIR/.env"
