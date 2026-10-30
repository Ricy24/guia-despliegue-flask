# 11 — Frontend en Vercel

Si el proyecto tiene frontend (React, Vite, Next), Vercel lo aloja gratis con
HTTPS y deploy en cada push. El ejemplo usa un frontend Vite/React como el de
PlomApp.

## 1. Conectar el repo

En <https://vercel.com/new> se importa el repo del frontend. Vercel detecta
el framework (Vite → build `npm run build`, output `dist`). **Deploy** y en
~1 minuto queda en `https://<tu-proyecto>.vercel.app`.

## 2. Decirle al frontend dónde está la API

El frontend no puede usar `localhost:8000`: la API está en el VPS. La
variable `VITE_API_URL` (o `REACT_APP_API_URL`, según el proyecto) es el
puente.

En local, en el `.env` del frontend:

```dotenv
VITE_API_URL=https://mi-app.duckdns.org
```

En el dashboard de Vercel: **Settings → Environment Variables**, la misma
variable con el mismo valor, y **Redeploy** (las variables solo aplican en
deploys nuevos).

En Vite, las variables `VITE_*` se embeben en el build: por eso hay que
redeployar al cambiarlas, y por eso no van secretos reales en el frontend
(cualquiera los ve con F12).

## 3. CORS en el backend

El backend (capítulo 08, `.env`) tiene que permitir el origen de Vercel:

```dotenv
CORS_ORIGINS=https://<tu-proyecto>.vercel.app
```

En Flask con Flask-CORS:

```python
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*").split(",")
CORS(app, origins=CORS_ORIGINS)
```

En desarrollo `*` es cómodo; en producción solo los orígenes reales. PlomApp
usa `CORS_ALLOW_ALL_ORIGINS=False` con la lista explícita de sus orígenes.

> En PlomApp, `plomaap-react.vercel.app` es el respaldo del frontend apuntando
> directo a la API de Oracle, y el dominio principal pasa por el Worker de
> Cloudflare (capítulo 12). Su `vercel.json` además le dice a Vercel que sirva
> el SPA con fallback a `index.html` y que cachee `/assets/*` por un año.

## Errores comunes

- **`Failed to fetch` desde el navegador**: la variable no está en Vercel o no
  se redeployó. Revisar también el CORS del backend: la consola del navegador
  (F12) dice qué origen fue rechazado.
- **El build falla**: las variables de Vite tienen que empezar con `VITE_` para inyectarse.

**Siguiente:** [12 — Cloudflare](12-cloudflare.md)
