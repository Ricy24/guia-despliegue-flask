# ==============================================================================
# PRUEBAS de la app de ejemplo (mismas que la plantilla, ajustadas a esta app)
# Ejecutar:  pytest -q
# ==============================================================================
from app import app


def test_health_responde_ok():
    client = app.test_client()
    respuesta = client.get("/api/health")

    assert respuesta.status_code == 200
    assert respuesta.get_json()["status"] == "ok"


def test_saludo_devuelve_mensaje():
    client = app.test_client()
    respuesta = client.post("/api/saludo", json={"nombre": "SENA"})

    assert respuesta.status_code == 200
    assert "SENA" in respuesta.get_json()["mensaje"]
