# 13 — Checklist de producción

Antes de mostrar tu app al mundo (o al profe), repasa esta lista. Cada punto
es un fallo real que ha dejado apps fuera de servicio.

## Secretos

- [ ] `.env` **no** está en Git (`git status` limpio y `.gitignore` con `.env`).
- [ ] `SECRET_KEY` es aleatorio y largo (no `dev-secret`, no el de ejemplo).
- [ ] `DEBUG=0` en el VPS (con `DEBUG=1` Flask muestra trazas con variables
      secretas a cualquiera).
- [ ] Las credenciales de correo/base de datos del `.env` son de producción y
      no están en ningún commit viejo (si lo estuvieron: **rotalas**).

## Django / Flask en producción

- [ ] La app corre con **gunicorn** (u otro WSGI), nunca con el `runserver` de
      desarrollo.
- [ ] `ALLOWED_HOSTS` y `CORS_ORIGINS` listan solo tus dominios reales.
- [ ] Si usas HTTPS (sí lo usas), activa `SESSION_COOKIE_SECURE`,
      `CSRF_COOKIE_SECURE` y, detrás de Caddy,
      `USE_X_FORWARDED_PROTO=True`.

## Servidor

- [ ] Firewall: solo 22/80/443 abiertos (`sudo ss -tlnp` no muestra sorpresas).
- [ ] SSH: solo con llaves (en `/etc/ssh/sshd_config`,
      `PasswordAuthentication no`) — opcional pero recomendado.
- [ ] `docker compose ps` sin contenedores en estado `Restarting`.
- [ ] Logs revisados: `docker compose logs --tail=50 app`.

## Datos

- [ ] Los datos viven en **volúmenes** (`../data`, `db_data`...), no dentro del
      contenedor (si no, el próximo `build` los borra).
- [ ] Backup automatizado de la base de datos. Ejemplo con cron en el VPS:
      ```bash
      (crontab -l 2>/dev/null; echo "0 3 * * * docker compose -f $HOME/mi-app/docker/docker-compose.yml exec -T db pg_dump -U miapp miapp | gzip > $HOME/backups/db_$(date +\%F).sql.gz") | crontab -
      ```
- [ ] Prueba de restauración hecha al menos una vez (un backup que nunca se
      restauró es un salto de fe).

## Vida

- [ ] "Latido" cada 15 min contra `/api/health` (anti-idle de Oracle,
      capítulo 02).
- [ ] Cron de DuckDNS actualizando la IP (capítulo 06).
- [ ] El deploy pasa las pruebas antes de tocar el VPS (`needs: pruebas`).

> ✅ **Así quedó en PlomApp:** sus secretos viven en `.env` (ignorado por Git),
> la app corre con gunicorn detrás de Caddy con cabeceras de seguridad
> (`nosniff`, `Referrer-Policy`, bloqueo de `/.env` y `/.git`), usan
> `transaction.atomic` contra doble agendamiento, y las respuestas de error
> son JSON sin trazas. En el VPS de PlomApp también hay un
> `Caddyfile.hardening-*.bak`: cada endurecimiento queda respaldado antes de
> tocar la config viva.

**Siguiente:** [14 — Alternativa sin Docker (apéndice)](14-sin-docker.md)
