# ==============================================================================
# DOCKERFILE DE TU APP FLASK
# Es la receta para "empaquetar" tu app y sus dependencias en una imagen.
# Este archivo vive en tu proyecto como: docker/Dockerfile
# Guía completa: docs/08-app-flask-en-docker.md
# ==============================================================================

# Imagen base: Python 3.12 liviano (oficial de Docker)
FROM python:3.12-slim

# Variables de entorno: nada de archivos .pyc y salida sin-buffer (se ve en logs)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Carpeta de trabajo dentro del contenedor
WORKDIR /app

# 1) Copiar solo requirements.txt primero (truco: si no cambian las librerías,
#    Docker reutiliza esta capa y el build es rapidísimo)
COPY requirements.txt .

# 2) Instalar dependencias + gunicorn (el servidor que usa producción;
#    el "runserver" de desarrollo NO se usa en producción)
RUN pip install --no-cache-dir -r requirements.txt gunicorn==23.0.0

# 3) Copiar el resto del código
COPY . .

# Carpetas que la app usa para guardar cosas (uploads, base de datos SQLite...)
RUN mkdir -p data uploads

# Puerto donde escucha gunicorn (debe coincidir con el Caddyfile y el compose)
EXPOSE 8000

# >>> AJUSTA A TU PROYECTO <<<
# "app:app" significa: archivo app.py, variable Flask "app".
# Si tu app principal se llama run.py con variable "application", sería:
#   gunicorn --bind 0.0.0.0:8000 run:application
# Si usas blueprints tipo factory:  "run:create_app()"
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "--timeout", "120", "app:app"]
