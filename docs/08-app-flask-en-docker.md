# 08 — Empaquetar tu app Flask en Docker

Llegó el momento: tu Flask + gunicorn dentro de un contenedor, detrás de
Caddy, con tus secretos en un `.env`. Usaremos la app de ejemplo
([`ejemplo/`](../ejemplo/app.py)) para probar, pero los mismos pasos aplican
a tu proyecto real.

## Probar la app en local (opcional pero recomendado)

> 🎯 **Tu turno** — en tu computadora:
> ```powershell
> cd ejemplo
> python -m venv venv
> .\venv\Scripts\Activate.ps1
> pip install -r requirements.txt pytest
> python app.py        # en otra terminal:  curl http://localhost:8000/api/health
> pytest -q            # las pruebas deben pasar
> ```

## Los 3 archivos que hacen la magia

En tu proyecto crea estas carpetas (ajusta los `# AJUSTA`):

1. **`docker/Dockerfile`** → [`plantilla/docker/Dockerfile`](../plantilla/docker/Dockerfile)
   La receta de la imagen: base Python, instala `requirements.txt` + gunicorn,
   copia el código y arranca gunicorn en el puerto 8000.
2. **`docker/docker-compose.yml`** → [`plantilla/docker/docker-compose.yml`](../plantilla/docker/docker-compose.yml)
   Define los servicios: `caddy` (el del capítulo 07) y `app` (tu Flask).
3. **`.env.ejemplo`** → [`plantilla/.env.ejemplo`](../plantilla/.env.ejemplo)
   Las variables que tu app leerá en producción.

> 🎯 **Tu turno — la lista de ajustes (los 5 lugares):**
> 1. `Dockerfile`: la línea `CMD` → el archivo y variable de tu app
>    (`app:app`, `run:application`, `wsgi:app`...).
> 2. `docker-compose.yml`: `name:`, `container_name:` de caddy y app.
> 3. `Caddyfile`: tu dominio y el servicio (`app:8000`).
> 4. `requirements.txt`: que incluya todo lo que tu app importa.
> 5. `.gitignore`: que contenga `.env`, `venv/`, `__pycache__/` y `data/`.
>    **Subir un `.env` a Git es el error más caro de todos.**

## Subir el código al servidor y arrancar

> 🎯 **Tu turno** — forma rápida con `scp` (en local):
> ```powershell
> scp -r .\docker .\server .\requirements.txt .\app.py vps:mi-app/
> ```
> (para tu proyecto real, mejor sube TODO el repo por git, que es como lo
> haremos de forma automática en el capítulo 10).

En el VPS:

> 🎯 **Tu turno** — crea el `.env` real y levanta todo:
> ```bash
> cd ~/mi-app
> cp .env.ejemplo .env
> nano .env            # ajusta valores; genera SECRET_KEY:
> # python3 -c "import secrets; print(secrets.token_hex(32))"
> docker compose up -d --build
> docker compose ps    # app: Up (health si lo configuraste)
> docker compose logs -f app
> ```

> 🎯 **Tu turno** — la prueba final del capítulo:
> ```bash
> curl https://mi-app.duckdns.org/api/health
> # {"app":"ejemplo-guia","status":"ok"}
>
> curl -X POST https://mi-app.duckdns.org/api/saludo -H "Content-Type: application/json" -d '{"nombre":"SENA"}'
> # {"mensaje":"¡Hola, SENA!"}
> ```
> Y el candado 🔒 en el navegador. **¡Tu app está en internet!**

> ✅ **Así quedó en PlomApp:** el servidor contiene `~/plomaap` con
> `Dockerfile` (python:3.12-slim + gunicorn con 3 workers), `docker-compose.yml`
> (servicios `api` y `db` con pgvector, healthcheck y volúmenes de datos) y un
> `.env` con los secretos reales (que jamás se subió a Git). La red externa
> `lifeos_lifeos_net` conecta su app con el Caddy del otro stack — cuando
> tengas varias apps, ese es el patrón a seguir.

## Si tu app usa MySQL o PostgreSQL

En el `docker-compose` de la plantilla hay un bloque comentado con el servicio
`db`. Descomentarlo, ajustar credenciales en `.env`, y en el servicio `app`
agregar `depends_on: [db]`. Ejemplo real de PlomApp: `pgvector/pgvector:pg17`
con healthcheck y volumen nombrado `plomaap_pgdata`.

Para Flask + Flask-Migrate, las migraciones se ejecutan así en cada deploy
(lo automatizaremos en el capítulo 10):

```bash
docker compose exec app flask db upgrade
```

> ⚠️ **Si te atascas:**
> - **`build` falla con "requirements.txt: no such file"**: el `context:` del
>   compose apunta a la raíz del proyecto; revisa que `requirements.txt`
>   esté ahí.
> - **La app muere al arrancar (`exited (1)`)**: `docker compose logs app`
>   muestra el error real de Python (import faltante, variable mal escrita...).
> - **502 desde el navegador pero `docker compose ps` dice Up**: el Caddy y
>   la app no están en la misma red o el puerto del `reverse_proxy` no
>   coincide con el de gunicorn. Deben decir ambos `8000`.
> - **"Address already in use" en 443/80**: otro proceso (u otro Caddy) ya
>   usa ese puerto: `sudo ss -tlnp | grep -E ':(80|443)'`.

**Siguiente:** [09 — Pruebas automáticas con GitHub Actions](09-tests-github-actions.md)
