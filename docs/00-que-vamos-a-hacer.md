# 00 — Qué vamos a hacer (y por qué)

Al terminar esta guía, tu app Flask tendrá una dirección pública como
`https://mi-app.duckdns.org`, con **certificado HTTPS gratis**, **despliegue
automático** cada vez que hagas push a `main`, y **pruebas automáticas** en
cada Pull Request. Todo con **$0 al mes**, usando las cuentas gratuitas de
Oracle Cloud, DuckDNS, GitHub y Cloudflare.

> **¿Ya terminaste?** Este es el mapa. Si vienes siguiendo la guía, este
> capítulo solo te muestra cómo encajan las piezas.

## Las piezas y qué hace cada una

| Pieza | Qué es | Por qué la usamos |
|---|---|---|
| **VPS** (Oracle Cloud Always Free) | Un computador Linux tuyo, encendido 24/7, en internet | Es donde correrá tu app cuando tú no estés |
| **Docker** | Empaca tu app con todo lo que necesita | "En mi máquina sí funciona" deja de ser un problema |
| **Caddy** | Servidor que escucha en el 80/443 y le pasa las peticiones a tu app | Nos da **HTTPS gratis y automático** (Let's Encrypt) |
| **DuckDNS** | Subdominio gratis (`mi-app.duckdns.org`) que apunta a la IP de tu VPS | Sin esto solo tendrías una IP fea tipo `158.247.126.81` |
| **GitHub Actions** | Robots que corren pruebas y despliegan solos | Cada push prueba el código y lo publica sin que muevas un dedo |
| **Vercel** (opcional) | Aloja tu frontend React/Vite gratis | Conectarlo con la API por una variable `VITE_API_URL` |
| **Cloudflare** (opcional) | Workers con rate limiting y caché | Protege la API de abuso y oculta la IP del VPS |

## La arquitectura final

```
      El usuario
          │
          │  https://mi-app.duckdns.org
          ▼
   ┌──────────────┐      DNS: "mi-app.duckdns.org"
   │   DuckDNS    │      = la IP de tu VPS
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐  puertos 80/443 (abiertos en Oracle)
   │ VPS Oracle  │
   │  ┌────────┐ │
   │  │ Caddy  │ │  ← genera el certificado HTTPS solo
   │  └───┬────┘ │
   │      │ red interna de Docker (nadie más ve esto)
   │  ┌───▼────┐ │
   │  │  app   │ │  ← tu Flask + gunicorn (puerto 8000)
   │  │ Flask  │ │
   │  └────────┘ │
   └──────────────┘
```

**Lo importante:** solo Caddy está expuesto a internet. Tu app vive en una red
interna de Docker y nadie puede tocarla directamente. Es exactamente la
arquitectura que usa PlomApp en producción (su backend Django detrás de Caddy
en Oracle, con el frontend en Vercel y Workers delante).

## Así se usa esta guía

1. Los capítulos están en orden: **01 → 13**. No saltes: cada uno construye
   sobre el anterior.
2. Verás tres tipos de cajas:

   > 🎯 **Tu turno** — comandos o decisiones que TÚ ejecutas con tus datos.
   > Salta el copiar/pegar automático: cambia `<TU_IP>`, `<TU_DOMINIO>`, etc.

   > ✅ **Así quedó en PlomApp** — valores reales del proyecto que sirvió de
   > inspiración, para que sepas qué esperar.

   > ⚠️ **Si te atascas** — los errores más comunes de cada paso.
   > Si algo falla, mira aquí antes de desesperar (y luego
   > [`troubleshooting.md`](troubleshooting.md)).

3. Los archivos que copias a tu proyecto viven en [`../plantilla/`](../plantilla/LEEME.md),
   y la app mínima con la que se prueban todos los pasos está en [`../ejemplo/`](../ejemplo/).

## Antes de empezar: lo que necesitas

- Una computadora con terminal (las instrucciones son para **Windows**, con
  macOS/Linux solo cambian los comandos de conexión).
- Tu proyecto **Flask** en un repo de **GitHub**. Si aún no lo tienes en
  GitHub, crea uno en <https://github.com/new> y sube tu código:
  ```bash
  git init
  git add .
  git commit -m "versión inicial"
  git remote add origin https://github.com/<TU_USUARIO>/<TU_REPO>.git
  git branch -M main
  git push -u origin main
  ```
- ~2 horas con calma. Oracle es lo más lento (crear la cuenta y la instancia).

**Siguiente:** [01 — Cuentas gratis que vamos a crear](01-cuentas-gratis.md)
