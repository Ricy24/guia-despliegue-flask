# 08 — Tu Flask en Docker

La app Flask dentro de un contenedor, detrás de Caddy, con los secretos en un
`.env`. Los pasos son iguales para la app de ejemplo
([`ejemplo/`](https://github.com/Ricy24/guia-despliegue-flask/blob/main/ejemplo/app.py)) y para un proyecto real.

## Probar en local (recomendado)

```powershell
cd ejemplo
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt pytest
python app.py        # en otra terminal: curl http://localhost:8000/api/health
pytest -q
```

## Los tres archivos

1. **`docker/Dockerfile`** → [`plantilla/docker/Dockerfile`](https://github.com/Ricy24/guia-despliegue-flask/blob/main/plantilla/docker/Dockerfile)
   Receta de la imagen: base Python 3.12, instala `requirements.txt` y
   gunicorn, copia el código, arranca gunicorn en el puerto 8000.
2. **`docker/docker-compose.yml`** → [`plantilla/docker/docker-compose.yml`](https://github.com/Ricy24/guia-despliegue-flask/blob/main/plantilla/docker/docker-compose.yml)
   Los servicios: `caddy` (del capítulo 07) y `app` (el Flask).
3. **`.env.ejemplo`** → [`plantilla/.env.ejemplo`](https://github.com/Ricy24/guia-despliegue-flask/blob/main/plantilla/.env.ejemplo)
   Variables que la app lee en producción.

### Los 5 lugares que hay que ajustar

1. `Dockerfile`, línea `CMD`: el módulo y variable de la app. `app:app`
   significa `app.py` con objeto Flask `app`. Si el entrypoint es `run.py` con
   `application`, queda `gunicorn ... run:application`.
2. `docker-compose.yml`: `name:`, y los `container_name:` de caddy y app.
3. `Caddyfile`: el dominio y el servicio (`app:8000`).
4. `requirements.txt`: que incluya todo lo que la app importa.
5. `.gitignore`: con `.env`, `venv/`, `__pycache__/` y `data/`. Subir un
   `.env` a Git es el error más caro posible.

## Subir el código y arrancar

Forma rápida desde la máquina local:

```powershell
scp -r .\docker .\server .\requirements.txt .\app.py vps:mi-app/
```

Para un proyecto real lo mejor es subir todo el repo por git, que es
justamente lo que automatiza el capítulo 10.

En el VPS:

```bash
cd ~/mi-app
cp .env.ejemplo .env
nano .env            # llenar valores. SECRET_KEY con:
# python3 -c "import secrets; print(secrets.token_hex(32))"
docker compose up -d --build
docker compose ps
docker compose logs -f app
```

## Probar

```bash
curl https://mi-app.duckdns.org/api/health
# {"app":"ejemplo-guia","status":"ok"}

curl -X POST https://mi-app.duckdns.org/api/saludo -H "Content-Type: application/json" -d '{"nombre":"SENA"}'
# {"mensaje":"¡Hola, SENA!"}
```

El navegador con el candado en `https://mi-app.duckdns.org`. La app ya está
publicada.

> En PlomApp, el servidor tiene `~/plomaap` con el Dockerfile
> (python:3.12-slim + gunicorn con 3 workers), el docker-compose (servicios
> `api` y `db` con pgvector, healthcheck y volúmenes) y un `.env` con los
> secretos reales que nunca se subió a Git. La red externa `lifeos_lifeos_net`
> conecta su app con el Caddy del otro stack: ese es el patrón cuando hay
> varias apps en el mismo servidor.

## Si la app usa MySQL o PostgreSQL

En el compose de la plantilla hay un bloque comentado con el servicio `db`.
Se descomenta, se ajustan las credenciales en `.env` y al servicio `app` se le
agrega `depends_on: [db]`. En PlomApp es `pgvector/pgvector:pg17` con
healthcheck y volumen nombrado `plomaap_pgdata`.

Con Flask-Migrate, las migraciones se ejecutan en cada deploy (lo siguiente en
automatizar):

```bash
docker compose exec app flask db upgrade
```

## Errores comunes

- **El build falla con "requirements.txt: no such file"**: el `context:` del
  compose apunta a la raíz del proyecto; verificar que `requirements.txt`
  esté ahí.
- **El contenedor de la app muere (`Exited (1)`)**: `docker compose logs app`
  muestra el error real de Python.
- **502 desde el navegador y `docker compose ps` en Up**: el Caddy y la app
  no están en la misma red, o el puerto del `reverse_proxy` no coincide con
  el de gunicorn. Los dos deben decir 8000.
- **"Address already in use" en 80/443**: algo más usa ese puerto:
  `sudo ss -tlnp | grep -E ':(80|443)'`.

**Siguiente:** [09 — Pruebas automáticas](09-tests-github-actions.md)
