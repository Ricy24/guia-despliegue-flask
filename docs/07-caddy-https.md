# 07 — HTTPS gratis y automático con Caddy

**HTTPS** es la "S" del candado: cifra la conexión. Sin ella, los navegadores
marcan tu sitio como "No seguro". Normalmente conseguir un certificado gratis
(Certbot/Let's Encrypt) implica crons y renovaciones. **Caddy lo hace solo.**

[Caddy](https://caddyserver.com) es un servidor web moderno que:
- Detecta tu dominio en su configuración y pide **solo** el certificado.
- Lo **renueva automáticamente** antes de caducar.
- Es reverse proxy: recibe en 80/443 y le pasa todo a tu app internamente.

## El Caddyfile

> 🎯 **Tu turno** — crea la carpeta `server` en tu proyecto y guarda ahí el
> archivo `Caddyfile` (copia el de la plantilla y ajusta TU dominio en la
> primera línea y el nombre del servicio `app`):
> [`plantilla/server/Caddyfile`](../plantilla/server/Caddyfile)

Su esencia (comentada en el archivo):

```
mi-app.duckdns.org {              # mi dominio
    encode gzip                   # comprimir respuestas
    request_body { max_size 10MB } # cortar subidas gigantes
    @probe path /.env* /.git*     # bloquear sondeos de bots
    respond @probe 404
    reverse_proxy app:8000        # el resto, a mi app interna
}
```

## Levantar Caddy (probemos Caddy solo, antes que la app)

> 🎯 **Tu turno** — en el VPS, en `~/mi-app` (crea los archivos ahí con
> `nano` o súbelos con `scp`):
> ```bash
> mkdir -p ~/mi-app/server
> nano ~/mi-app/server/Caddyfile    # pega y ajusta tu dominio
> ```
> Levanta solo Caddy con un compose mínimo. Crea `~/mi-app/docker/docker-compose.yml`
> con SOLO el servicio `caddy` por ahora (el archivo completo de la plantilla
> lo usamos en el capítulo 08; puedes pegarlo completo, el servicio `app`
> fallará hasta que exista el código — lo normal es seguir el capítulo 08 y
> volver aquí):
> ```bash
> docker compose -f ~/mi-app/docker/docker-compose.yml up -d caddy
> docker compose logs -f caddy
> ```

En los logs verás algo mágico:

```
{"level":"info","msg":"certificate obtained successfully","identifier":"mi-app.duckdns.org"}
{"level":"info","msg":"serving initial configuration"}
```

> 🎯 **Tu turno** — abre <https://mi-app.duckdns.org> en el navegador (con
> https). Debe aparecer el **candado** 🔒 (aún sin app detrás, Caddy responde
> con su página 502 "Bad Gateway", eso confirma que HTTPS funciona y que solo
> falta la app).

> 💡 Let's Encrypt solo entrega certificados para **puertos 80 y 443
> abiertos** y **dominios que resuelven a tu IP**. Si el certificado falla,
> son esas dos condiciones (capítulos 03/04 y 06).

## Cómo renueva (no haces nada)

Caddy guarda el certificado en el volumen `caddy_data` y lo renueva a los ~60
días solo. Lo único que debes: **no borrar ese volumen** y mantener el
dominio apuntando a tu IP.

> ✅ **Así quedó en PlomApp:** el contenedor `lifeos_caddy` (imagen
> `caddy:2-alpine`) escucha en 80/443 de todo el servidor y enruta:
> `lifeosandres.duckdns.org/plomaap-api/* → plomaap_api:8000` y el resto →
> su API principal, además de bloquear `/.env`, `/.git` y limitar cuerpos a
> 12 MB. Este guía usa una versión simplificada de ese mismo archivo.

> ⚠️ **Si te atascas:**
> - **Falla "certificate obtained"**: casi siempre es que la IP de tu DNS no
>   coincide con la del servidor o el puerto 80 está cerrado. Verifica con
>   `nslookup mi-app.duckdns.org` y revisando las dos capas de firewall.
> - **Error de rate limit (429)**: Let's Encrypt limita emisiones por
>   dominio (~5 por semana). Si lo has reinstalado mucho, espera unos días o
>   prueba primero con el dominio de prueba `mi-app.duckdns.org` en staging:
>   Caddy tiene opción `tls internal` para pruebas.
> - **502 Bad Gateway**: es NORMAL si aún no levantaste la app (capítulo 08).

**Siguiente:** [08 — Empaquetar tu app Flask en Docker](08-app-flask-en-docker.md)
