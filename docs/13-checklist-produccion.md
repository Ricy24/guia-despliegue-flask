# 13 — Checklist de producción

Antes de exponer la app, revisar esta lista. Cada punto es un fallo real que
ha dejado apps fuera de servicio.

## Secretos

- [ ] `.env` no está en Git (`git status` limpio, `.gitignore` con `.env`).
- [ ] `SECRET_KEY` aleatorio y largo, no el de ejemplo.
- [ ] `DEBUG=0` en el VPS. Con `DEBUG=1`, Flask muestra trazas con variables
      secretas a cualquiera.
- [ ] Credenciales de correo y base de datos del `.env` son de producción y
      no están en commits viejos. Si lo estuvieron, rotarlas.

## App en producción

- [ ] Corre con gunicorn, nunca con el `runserver` de desarrollo.
- [ ] `ALLOWED_HOSTS` y `CORS_ORIGINS` con los dominios reales.
- [ ] Detrás de Caddy: `USE_X_FORWARDED_PROTO=True`,
      `SESSION_COOKIE_SECURE=True`, `CSRF_COOKIE_SECURE=True`.

## Servidor

- [ ] Firewall: solo 22, 80 y 443 (`sudo ss -tlnp` sin sorpresas).
- [ ] SSH solo con llaves: en `/etc/ssh/sshd_config`,
      `PasswordAuthentication no`.
- [ ] `docker compose ps` sin contenedores en `Restarting`.
- [ ] Logs revisados: `docker compose logs --tail=50 app`.

## Datos

- [ ] Los datos viven en volúmenes (`../data`, `db_data`), no dentro del
      contenedor. Si no, el próximo build los borra.
- [ ] Backup automatizado. Ejemplo con cron en el VPS:
      ```bash
      (crontab -l 2>/dev/null; echo "0 3 * * * docker compose -f $HOME/mi-app/docker/docker-compose.yml exec -T db pg_dump -U miapp miapp | gzip > $HOME/backups/db_$(date +\%F).sql.gz") | crontab -
      ```
- [ ] Restauración probada al menos una vez. Un backup que nunca se restauró
      es un salto de fe.

## Continuidad

- [ ] Latido cada 15 min contra `/api/health` (anti-idle de Oracle).
- [ ] Cron de DuckDNS actualizando la IP.
- [ ] El deploy pasa las pruebas antes de tocar el VPS (`needs: pruebas`).

> En PlomApp: secretos en `.env` ignorado por Git, gunicorn detrás de Caddy
> con cabeceras de seguridad (`nosniff`, `Referrer-Policy`, bloqueo de
> `/.env` y `/.git`), `transaction.atomic` contra doble agendamiento, errores
> JSON sin trazas. En el servidor hay un `Caddyfile.hardening-*.bak`: cada
> endurecimiento queda respaldado antes de tocar la config viva.

**Siguiente:** [14 — Sin Docker (apéndice)](14-sin-docker.md)
