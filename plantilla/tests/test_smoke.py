# ==============================================================================
# PRUEBA MÍNIMA DE HUMO (smoke test)
# "¿La app enciende y responde lo básico?"
# Este archivo vive en tu proyecto como: tests/test_smoke.py
# Guía: docs/09-tests-github-actions.md
#
# Ejecutar localmente:  pytest -q
# ==============================================================================
from app import app  # AJUSTA: el import de tu app. Ej: from mi_app import create_app


def test_health_responde_ok():
    """El endpoint /api/health debe responder 200 con estado ok."""
    client = app.test_client() # el cliente de pruebas de Flask: no abre puertos
    respuesta = client.get("/api/health")

    assert respuesta.status_code == 200
    assert respuesta.get_json()["status"] == "ok"


def test_saludo_devuelve_mensaje():
    """El endpoint /api/saludo debe devolver un JSON con el nombre recibido."""
    client = app.test_client()
    respuesta = client.post("/api/saludo", json={"nombre": "SENA"})

    assert respuesta.status_code == 200
    assert "SENA" in respuesta.get_json()["mensaje"]
