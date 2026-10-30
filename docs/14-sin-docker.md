# 14 — Sin Docker (apéndice)

La misma app Flask corriendo directamente en el servidor: gunicorn como
servicio de systemd y Caddy instalado con apt. Más conceptos de Linux, pero
más control. No es obligatorio: el camino principal es Docker (capítulos
01-13). Este apéndice sirve para entender qué hace Docker por dentro, o para
un VPS que no pueda correr Docker.

## 1. Python y usuario de la app

En el VPS:

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip caddy
sudo useradd -m -s /bin/bash appuser
sudo -u appuser bash -c 'git clone https://github.com/<TU_USUARIO>/<TU_REPO>.git ~/mi-app'
sudo -u appuser bash -c 'cd ~/mi-app && python3 -m venv venv && ./venv/bin/pip install -r requirements.txt gunicorn'
```

## 2. Servicio systemd de gunicorn

Crear `/etc/systemd/system/mi-app.service`:

```bash
sudo nano /etc/systemd/system/mi-app.service
```

```ini
[Unit]
Description=App Flask (gunicorn)
After=network.target

[Service]
User=appuser
Group=www-data
WorkingDirectory=/home/appuser/mi-app
Environment="PATH=/home/appuser/mi-app/venv/bin"
ExecStart=/home/appuser/mi-app/venv/bin/gunicorn --bind 127.0.0.1:8000 --workers 3 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now mi-app
sudo systemctl status mi-app      # debe decir "active (running)"
```

Gunicorn escucha solo en `127.0.0.1:8000`: no necesita estar expuesto a
internet, Caddy (en el mismo servidor) le pasa las peticiones.

## 3. Caddy del sistema

Editar `/etc/caddy/Caddyfile` con el mismo contenido del capítulo 07, pero
con `reverse_proxy localhost:8000`:

```bash
sudo nano /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

HTTPS automático funciona igual.

## Diferencias con Docker

| Tema | Con Docker | Sin Docker |
|---|---|---|
| Actualizar | `git pull` + `docker compose up -d --build` | `git pull` + `pip install -r requirements.txt` + `systemctl restart mi-app` |
| Aislamiento | Cada app en su caja | Todo comparte el Python del sistema |
| Varias versiones de Python o librerías | Fácil | Complicado |
| Reconstruir en otra máquina | `docker compose up` | Reconstruir todo a mano |

> En PlomApp el servidor usa Docker, y su `DEPLOYMENT.md` documenta el
> topología equivalente: reverse proxy → app → base + caché.

**Volver al índice:** [README](../README.md). Si algo falla:
[Troubleshooting](troubleshooting.md).
