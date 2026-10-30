# 14 — Alternativa sin Docker (apéndice)

¿Quieres entender qué hace Docker "por dentro"? Aquí la misma app Flask
corriendo **directamente en el servidor**, con gunicorn como servicio de
systemd y Caddy instalado con apt. Es más conceptos de Linux, pero te deja el
control fino.

> 💡 No es obligatorio: el camino principal (01-13) es Docker y es el que
> recomiendo para la clase. Este apéndice es para curiosos o para cuando el
> VPS no puede correr Docker.

## Paso 1 — Python y usuario de la app

> 🎯 **Tu turno** — en el VPS:
> ```bash
> sudo apt update
> sudo apt install -y python3 python3-venv python3-pip caddy
> sudo useradd -m -s /bin/bash appuser
> sudo -u appuser bash -c 'git clone https://github.com/<TU_USUARIO>/<TU_REPO>.git ~/mi-app'
> sudo -u appuser bash -c 'cd ~/mi-app && python3 -m venv venv && ./venv/bin/pip install -r requirements.txt gunicorn'
> ```

## Paso 2 — Servicio systemd de gunicorn

> 🎯 **Tu turno** — crea `/etc/systemd/system/mi-app.service`:
> ```bash
> sudo nano /etc/systemd/system/mi-app.service
> ```
> ```ini
> [Unit]
> Description=App Flask (gunicorn)
> After=network.target
>
> [Service]
> User=appuser
> Group=www-data
> WorkingDirectory=/home/appuser/mi-app
> Environment="PATH=/home/appuser/mi-app/venv/bin"
> ExecStart=/home/appuser/mi-app/venv/bin/gunicorn --bind 127.0.0.1:8000 --workers 3 app:app
> Restart=always
>
> [Install]
> WantedBy=multi-user.target
> ```
> ```bash
> sudo systemctl daemon-reload
> sudo systemctl enable --now mi-app
> sudo systemctl status mi-app      # debe decir "active (running)"
> ```
> Nota: gunicorn escucha solo en `127.0.0.1:8000`: **no necesita** estar
> expuesto a internet; Caddy (en el mismo servidor) le pasa las peticiones.

## Paso 3 — Caddy del sistema

> 🎯 **Tu turno** — edita `/etc/caddy/Caddyfile` con el MISMO contenido que
> el capítulo 07, pero con `reverse_proxy localhost:8000`:
> ```bash
> sudo nano /etc/caddy/Caddyfile
> sudo systemctl reload caddy
> ```

HTTPS automático funciona igual: Caddy pide el certificado solo.

## Diferencias frente a Docker

| Tema | Con Docker | Sin Docker (esto) |
|---|---|---|
| Actualizar | `git pull` + `docker compose up -d --build` | `git pull` + `pip install -r requirements.txt` + `systemctl restart mi-app` |
| Aislamiento | Cada app en su caja | Todo comparte el mismo Python del sistema |
| Varias versiones de Python/librerías | Fácil | Complicado |
| Desastre y reconstrucción | `docker compose up` en otra máquina | Reconstruir todo a mano |

> ✅ **Así quedó en PlomApp:** su servidor usa el camino Docker, pero su
> `lifeos` tiene documentado (en `DEPLOYMENT.md`) el topología equivalente:
> reverse proxy → app → base + caché. Los servicios de systemd solo los usan
> los agentes del sistema de Oracle.

**Volver al índice:** [README](../README.md) · ¿Algo falló?
→ [Troubleshooting](troubleshooting.md)
