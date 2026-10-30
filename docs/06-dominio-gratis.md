# 06 — Dominio gratis con DuckDNS

DuckDNS da subdominios gratis bajo `duckdns.org` y los apunta a la IP que le
digas.

## Crear el subdominio

1. Entrar a <https://www.duckdns.org> y loguearse (con GitHub o Google).
2. En **Domains**, escribir el nombre (ej. `mi-app`) y **Add Domain**.
3. Aparece `mi-app.duckdns.org` apuntando a la IP actual. Si no la detecta,
   se pega la IP en el cuadro **A** y **Update IP**.
4. Anotar el **token** de arriba.

Verificar desde la máquina local:

```powershell
nslookup mi-app.duckdns.org
```

Debe devolver la IP del VPS.

## Mantener la IP actualizada

Las IP elásticas de Oracle pueden cambiar si la instancia se para y arranca.
Se resuelve con un cron que avise a DuckDNS la IP cada 5 minutos. En el VPS:

```bash
(crontab -l 2>/dev/null; echo "*/5 * * * * curl -s 'https://www.duckdns.org/update?domains=TU_SUBDOMINIO&token=TU_TOKEN&ip='") | crontab -
crontab -l
```

La misma línea, apuntando a `/api/health`, sirve también como el latido que
evita que Oracle reclame la máquina por inactiva (capítulo 02). Puede ser una
segunda línea en el cron.

## Nota sobre Cloudflare

DuckDNS no permite cambiar los nameservers ni manejar DNS avanzado: no se le
puede poner Cloudflare encima. Por eso el HTTPS lo hace Caddy (capítulo 07) y
si más adelante se quiere Cloudflare completo, se hace con el Worker del
capítulo 12, que funciona con subdominio propio `*.workers.dev` sin tocar
DuckDNS.

## Errores comunes

- **No resuelve**: revisar el subdominio en el panel de DuckDNS y que la IP
  coincida con la del VPS. DuckDNS es casi instantáneo.
- **Resuelve pero no conecta**: el problema no es el DNS; es el firewall
  (capítulo 04) o la app que no está corrienda (capítulo 08).

**Siguiente:** [07 — Caddy y HTTPS](07-caddy-https.md)
