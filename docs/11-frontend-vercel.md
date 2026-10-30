# 11 — Frontend en Vercel (opcional)

Si tu proyecto tiene frontend (React, Vite, Next...), [Vercel](https://vercel.com)
lo aloja gratis con HTTPS automático y deploy en cada push. Este capítulo usa
de ejemplo un frontend Vite/React como el de PlomApp.

## Paso 1 — Conectar el repo

1. En <https://vercel.com/new> importa tu repo de GitHub del frontend.
2. Vercel detecta el framework solo (Vite → framework `Vite`,
   build `npm run build`, output `dist`).
3. **Deploy**. En ~1 minuto tienes tu app en `https://<tu-proyecto>-<algo>.vercel.app`.

## Paso 2 — Decirle al frontend dónde está la API

Tu frontend no puede usar `localhost:8000`: la API vive en tu VPS. La
variable `VITE_API_URL` (o la que use tu proyecto: `REACT_APP_API_URL`, etc.)
es el puente.

> 🎯 **Tu turno** — en local, en el `.env` de tu frontend:
> ```dotenv
> VITE_API_URL=https://mi-app.duckdns.org
> ```
> Y en el dashboard de Vercel: **Settings → Environment Variables** → misma
> variable con el mismo valor → **Redeploy** (las variables solo aplican en
> deploys nuevos).

> 💡 En Vite, las variables `VITE_*` se "embeben" en el build: por eso hay
> que redeployar al cambiarlas, y por eso **jamás** pongas secretos reales en
> el frontend (cualquiera los ve con F12).

## Paso 3 — CORS: que la API acepte al frontend

Tu backend (capítulo 08, `.env`) debe permitir el origen de Vercel:

```dotenv
CORS_ORIGINS=https://<tu-proyecto>-<algo>.vercel.app
```

En Flask con Flask-CORS:

```python
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*").split(",")
CORS(app, origins=CORS_ORIGINS)
```

> ⚠️ En desarrollo `*` es cómodo, en producción pon **solo** tus orígenes
> reales (es lo que hizo PlomApp: `CORS_ALLOW_ALL_ORIGINS=False` con su
> lista explícita).

> ✅ **Así quedó en PlomApp:** `plomaap-react.vercel.app` es el respaldo del
> frontend, apuntando directo a la API de Oracle; el dominio principal pasa
> por un Worker de Cloudflare (capítulo 12). Su `vercel.json` además le dice
> a Vercel que sirva el SPA con fallback a `index.html` y que cachee
> `/assets/*` por un año.

> ⚠️ **Si te atascas:**
> - **"Failed to fetch" en el navegador**: la variable de entorno no está en
>   Vercel o no redeployaste; revisa también el CORS del backend (F12 →
>   Console te dice el origen bloqueado).
> - **Build falla**: los `env` de Vite deben empezar con `VITE_` para
>   inyectarse.

**Siguiente:** [12 — Cloudflare: proteger la API (opcional)](12-cloudflare.md)
