# 12 — Cloudflare: proteger la API (opcional)

Un Worker de Cloudflare es un proxy en la red mundial (edge) que cuenta
peticiones por IP y corta el abuso antes de que lleguen al VPS. Es gratis
(100.000 peticiones/día) y no necesita dominio propio: funciona con
subdominios `*.workers.dev`.

Si el proyecto es solo para la clase y no se espera tráfico real, con los
capítulos 01-10 alcanza. Esto es el extra.

## Qué gana la app

- Rate limiting por IP: p. ej. 10 intentos/min en `/auth/login` (fuerza
  bruta), 40 en escrituras, 240 en lecturas.
- La IP del VPS queda oculta: los atacantes ven al Worker, no a Oracle.
- Cabeceras de seguridad (HSTS, nosniff) y bloqueo de sondeos (`/.env`,
  `/.git`, `*.php` → 404).
- Caché de edge para respuestas públicas (`GET /api/services`).

## 1. El Worker

Crear la carpeta `cloudflare/api-proxy/` con estos dos archivos.

**`wrangler.toml`**

```toml
name = "mi-app-api"
main = "src/index.js"
compatibility_date = "2026-10-01"

# la API real (el VPS con su dominio)
[vars]
ORIGIN = "https://mi-app.duckdns.org"

# rate limiting nativo de Cloudflare (gratis)
[[unsafe.bindings]]
name = "RL_AUTH"
type = "ratelimit"
namespace_id = "1001"
simple = { limit = 10, period = 60 }

[[unsafe.bindings]]
name = "RL_READ"
type = "ratelimit"
namespace_id = "1002"
simple = { limit = 240, period = 60 }
```

**`src/index.js`**

```javascript
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const esAuth = url.pathname.startsWith("/api/auth/");

    // los preflights CORS no consumen límite
    if (request.method !== "OPTIONS") {
      const binding = esAuth ? env.RL_AUTH : env.RL_READ;
      const { success } = await binding.limit({ key: request.headers.get("cf-connecting-ip") });
      if (!success) {
        return new Response(JSON.stringify({ error: "Demasiadas peticiones" }), {
          status: 429,
          headers: { "Content-Type": "application/json", "Retry-After": "60" },
        });
      }
    }

    // sondeos de bots: ni llegan a la app
    if (/\.(env|git|php)$/.test(url.pathname)) {
      return new Response("Not Found", { status: 404 });
    }

    // proxy hacia el dominio real
    const destino = new URL(request.url);
    destino.hostname = new URL(env.ORIGIN).hostname;
    const respuesta = await fetch(destino, request);
    const headers = new Headers(respuesta.headers);
    headers.set("X-Content-Type-Options", "nosniff");
    headers.set("Strict-Transport-Security", "max-age=31536000");
    headers.delete("server");
    return new Response(respuesta.body, { status: respuesta.status, headers });
  },
};
```

## 2. Desplegar

```powershell
npx wrangler login          # una vez, con la cuenta de Cloudflare
npx wrangler deploy -c cloudflare/api-proxy/wrangler.toml
```

Devuelve la URL: `https://mi-app-api.<tu-usuario>.workers.dev`. Probarla:

```powershell
curl https://mi-app-api.<tu-usuario>.workers.dev/api/health
```

El frontend en Vercel apunta con `VITE_API_URL` a ese Worker, y el Worker a
la IP del VPS.

## Nota: DuckDNS y Cloudflare

Como el dominio `duckdns.org` no es propio, no se puede poner el subdominio
dentro de una zona DNS de Cloudflare: no hay proxy naranja ni WAF de zona.
Por eso el patrón de PlomApp y el de esta guía es el Worker como proxy
independiente. Con un dominio propio (~10 USD/año) sí se puede migrar el DNS
completo a Cloudflare y usar sus reglas de zona.

> El Worker de PlomApp hace todo esto y más: tres bindings de rate limit
> (`RL_AUTH` 10/60s, `RL_WRITE` 40/60s, `RL_READ` 240/60s), caché de edge de
> 5 min para `GET /api/services` con `X-Cache: HIT/MISS` (reconstruyendo el
> CORS por petición, porque Django devuelve el origen en eco y una caché
> compartida serviría el de otro cliente), límite de cuerpo de 12 MB, y
> bloqueo de `/.env`, `/.git`, `*.php`, `/wp-*`. El frontend vive en Workers
> static assets (`plomaap-web...workers.dev`) y Vercel es el respaldo: dos
> caminos independientes.

## Errores comunes

- **Worker 502**: el `ORIGIN` no responde o el VPS rechaza la petición.
  Revisar `docker compose logs caddy`.
- **CORS roto**: si el Worker cachea respuestas, debe reconstruir
  `Access-Control-Allow-Origin` por petición (como el de PlomApp); si no, los
  navegadores rechazan la respuesta.

**Siguiente:** [13 — Checklist de producción](13-checklist-produccion.md)
