# 12 — Cloudflare: proteger la API (opcional)

Tu app ya vive en internet: cualquiera puede bombardear el login. Este
capítulo agrega un **Worker de Cloudflare** delante de tu API: un proxy en la
edge (red mundial) que cuenta peticiones por IP y corta el abuso **antes** de
llegar a tu VPS. Es gratis (100.000 peticiones/día) y no necesita dominio
propio: funciona con subdominios `*.workers.dev`.

> 💡 **Cuándo NO hace falta:** si tu proyecto es solo para la clase y no esperas
> tráfico real, con lo de los capítulos 01-10 estás listo. Este capítulo es el
> "extra pro".

## Qué gana tu app

- **Rate limiting por IP**: p. ej. 10 intentos/min en `/auth/login` (frena
  fuerza bruta), 40 en escrituras, 240 en lecturas.
- **Oculta la IP del VPS**: los atacantes ven al Worker, no a Oracle.
- **Cabeceras de seguridad** (HSTS, nosniff) y bloqueo de sondeos
  (`/.env`, `/.git`, `*.php` → 404).
- **Caché de edge** para respuestas públicas (p. ej. `GET /api/services`).

## Paso 1 — El Worker

Crea la carpeta `cloudflare/api-proxy/` con `wrangler.toml` y `src/index.js`.
Versión mínima funcional (rate limit con el binding nativo + proxy):

**`cloudflare/api-proxy/wrangler.toml`**
```toml
name = "mi-app-api"
main = "src/index.js"
compatibility_date = "2026-10-01"

# El destino real de tu API (tu VPS con su dominio)
[vars]
ORIGIN = "https://mi-app.duckdns.org"

# Rate limiting nativo de Cloudflare (gratis en el plan Free)
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

**`cloudflare/api-proxy/src/index.js`**
```javascript
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const esAuth = url.pathname.startsWith("/api/auth/");
    const esLectura = request.method === "GET" || request.method === "HEAD";

    // Preflights CORS no consumen límite
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

    // Sondeos de bots: ni llegan a la app
    if (/\.(env|git|php)$/.test(url.pathname)) {
      return new Response("Not Found", { status: 404 });
    }

    // Proxy: reescribo a mi dominio real y devuelvo la respuesta
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

## Paso 2 — Desplegarlo

> 🎯 **Tu turno** — en local (requiere Node.js):
> ```powershell
> npx wrangler login          # una vez, con tu cuenta de Cloudflare
> npx wrangler deploy -c cloudflare/api-proxy/wrangler.toml
> ```
> Te devuelve tu URL: `https://mi-app-api.<tu-usuario>.workers.dev`.
> Pruébala:
> ```powershell
> curl https://mi-app-api.<tu-usuario>.workers.dev/api/health
> ```
> Ahora tu frontend (Vercel) apunta a ese Worker en `VITE_API_URL`, y el
> Worker a tu VPS. **La IP del VPS queda escondida.**

> ⚠️ **Ojo con DuckDNS y Cloudflare:** como el dominio `duckdns.org` no te
> pertenece, **no** puedes poner tu subdominio dentro de la zona DNS de
> Cloudflare (no habrá proxy naranja ni WAF de zona). Por eso el patrón de
> PlomApp —y el de aquí— usa el Worker como proxy independiente. Si algún día
> compras tu propio dominio (~10 USD/año), sí puedes migrar el DNS completo a
> Cloudflare y usar sus reglas de zona.

> ✅ **Así quedó en PlomApp:** su Worker (`cloudflare/api-proxy/`) hace todo
> esto y más: tres bindings de rate limit (`RL_AUTH` 10/60s, `RL_WRITE` 40/60s,
> `RL_READ` 240/60s), caché de edge de 5 min para `GET /api/services` (con
> `X-Cache: HIT/MISS`, reconstruyendo CORS por petición porque Django devuelve
> el origen en eco), límite de cuerpo de 12 MB, y bloqueo de `/.env`, `/.git`,
> `*.php`, `/wp-*`. El frontend vive en Workers static assets
> (`plomaap-web...workers.dev`, estáticos gratis e ilimitados) y Vercel es el
> respaldo: dos caminos independientes.

> ⚠️ **Si te atascas:**
> - **Worker 502**: el `ORIGIN` no responde o el VPS bloquea peticiones sin
>   cabecera `Host` correcta; revisa `docker compose logs caddy`.
> - **El CORS "se rompió"**: si el Worker cachea respuestas, debe reconstruir
>   `Access-Control-Allow-Origin` por petición (como el de PlomApp) o los
>   navegadores rechazarán la respuesta.

**Siguiente:** [13 — Checklist de producción](13-checklist-produccion.md)
