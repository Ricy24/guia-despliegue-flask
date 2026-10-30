# Plantilla — qué archivo va en cada parte de tu proyecto

Estos son los archivos que copias a **tu** proyecto Flask. No copies esta
carpeta tal cual: copia cada archivo en el destino indicado y ajusta lo que
está marcado con `AJUSTA` o `<...>`.

| Archivo de la plantilla | Cópialo en tu proyecto como | Qué ajustar |
|---|---|---|
| `.github/workflows/tests.yml` | `.github/workflows/tests.yml` | Nada. Funciona tal cual. |
| `.github/workflows/deploy.yml` | `.github/workflows/deploy.yml` | La carpeta en `cd "$HOME/mi-app"` |
| `scripts/setup_vps.sh` | `scripts/setup_vps.sh` | Nada (usa `APP_DIR` y `REPO_URL` por entorno) |
| `scripts/deploy.sh` | `scripts/deploy.sh` | Nada |
| `docker/Dockerfile` | `docker/Dockerfile` | La última línea `CMD` (el módulo de tu app) |
| `docker/docker-compose.yml` | `docker/docker-compose.yml` | `name:`, los `container_name:` y opcionalmente el servicio `db` |
| `server/Caddyfile` | `server/Caddyfile` | Tu dominio en la primera línea |
| `tests/test_smoke.py` | `tests/test_smoke.py` | El `from ... import app` y los endpoints que pruebas |
| `.env.ejemplo` | `.env.ejemplo` | Tus variables reales (sin claves fuertes) |

## Después de copiar, completa la lista

1. `.env.ejemplo` → cópialo como `.env` en local y en el VPS, con tus valores.
2. `.gitignore` → asegúrate de que tenga `.env` (si no, agrégalo YA).
3. `requirements.txt` → si no tienes `pytest`, agrégalo a `requirements-dev.txt`.
4. Revisa los comentarios `# AJUSTA` de cada archivo: son los 5 lugares donde
   el nombre debe coincidir con tu proyecto (`app.py`, `app:app`, `mi-app`...).

## El recorrido completo

Sigue la guía en orden: [`../docs/00-que-vamos-a-hacer.md`](../docs/00-que-vamos-a-hacer.md).
Los archivos de esta carpeta se usan sobre la marcha, en los capítulos 09 y 10.
