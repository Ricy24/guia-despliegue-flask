# 06 — Tu dominio gratis con DuckDNS

Un **DNS** es la guía telefónica de internet: traduce nombres
(`mi-app.duckdns.org`) a direcciones (`158.247.126.81`). [DuckDNS](https://www.duckdns.org)
da subdominios gratis bajo `duckdns.org`.

## Crear el subdominio

1. Entra a <https://www.duckdns.org> e inicia sesión (con GitHub o Google).
2. En la sección **Domains**, escribe el nombre que quieres (ej. `mi-app`) y
   pulsa **Add Domain**.
3. Aparecerá `mi-app.duckdns.org` con tu IP actual ya apuntando (DuckDNS la
   detecta solo). Si no, pégala manualmente en el cuadro **A** y **Update IP**.
4. Anota arriba tu **token** (lo usaremos pronto).

> 🎯 **Tu turno** — verifica desde tu computadora que el nombre ya resuelve:
> ```powershell
> nslookup mi-app.duckdns.org
> ```
> Debe responder con la IP de tu VPS. Si responde otra cosa o falla, espera
> unos segundos y reintenta (DuckDNS es casi instantáneo).

## El problema: la IP de Oracle cambia (a veces)

Las IPs elásticas de Oracle pueden cambiar si para y arranca la instancia
gratis. La solución clásica: un pequeño programador (**cron**) que avisa a
DuckDNS tu IP actual cada 5 minutos.

> 🎯 **Tu turno** — en el VPS:
> ```bash
> (crontab -l 2>/dev/null; echo "*/5 * * * * curl -s 'https://www.duckdns.org/update?domains=TU_SUBDOMINIO&token=TU_TOKEN&ip='") | crontab -
> crontab -l   # confirma que quedó la línea
> ```
> Reemplaza `TU_SUBDOMINIO` y `TU_TOKEN` por los tuyos.

> 💡 **Bonus:** esa misma línea, apuntando a `/api/health` de tu app, es
> también el "latido" que evita que Oracle reclame tu máquina por inactiva
> (capítulo 02). Puedes agregar una segunda línea al cron con esa URL.

> ⚠️ **Si te atascas:**
> - **`nslookup` no resuelve pero en el navegador tampoco**: revisa que el
>   subdominio esté bien escrito en el panel de DuckDNS y que la IP sea la de
>   tu VPS.
> - **Resuelve, pero no conecta**: el problema NO es el DNS; es el firewall
>   (capítulo 04) o que la app no está corrienda (capítulo 08).
> - **DuckDNS no es un DNS "gestionado"**: no puedes ponerle nameservers de
>   Cloudflare ni certificados wildcard a mano. Por eso en la guía el HTTPS lo
>   hace Caddy automáticamente, sin tocar DuckDNS. (PlomApp resuelve esto con
>   un Worker de Cloudflare en el capítulo 12.)

**Siguiente:** [07 — HTTPS gratis y automático con Caddy](07-caddy-https.md)
