# ==============================================================================
# APP FLASK DE EJEMPLO
# Es la app mínima de la guía: dos endpoints para practicar todo el despliegue.
# Guía: docs/08-app-flask-en-docker.md
# ==============================================================================
import os

from flask import Flask, jsonify, request

# "app" es el objeto Flask que gunicorn busca con "app:app" en el Dockerfile
app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-secret")


@app.get("/api/health")
def health():
    """Endpoint de salud: lo usan el VPS, Cloudflare y el frontend para saber
    que la app está viva."""
    return jsonify(status="ok", app=os.getenv("APP_NAME", "ejemplo"))


@app.post("/api/saludo")
def saludo():
    """Endpoint de ejemplo que recibe JSON y responde JSON."""
    datos = request.get_json(silent=True) or {}
    nombre = datos.get("nombre", "mundo")
    return jsonify(mensaje=f"¡Hola, {nombre}!")


if __name__ == "__main__":
    # Solo para desarrollo local (producción usa gunicorn, ver Dockerfile)
    debug = os.getenv("DEBUG", "0") == "1"
    app.run(host="0.0.0.0", port=8000, debug=debug)
