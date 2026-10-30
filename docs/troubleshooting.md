# Troubleshooting

Errores comunes de la guía, en orden de probabilidad. Buscar el mensaje
completo del error: las palabras clave importan.

## Conexión y servidor

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| `Connection timed out` al hacer SSH | Security List de Oracle sin el 22, o IP equivocada | Capítulo 03 sección A; verificar la IP con `nslookup` |
| `Permission denied (publickey)` | Conexión sin la llave, o la `.pub` no está en el VPS | `ssh -i ~\.ssh\mi-app-vps.pub ubuntu@<TU_IP>`; si no, capítulo 03D |
| `sudo: ufw: command not found` | En Oracle el firewall es iptables, ufw no viene instalado | Usar `iptables` o `sudo apt install ufw` |
| La instancia no arranca / "Out of host capacity" | Oracle sin máquinas gratis disponibles en esa región | Esperar y reintentar, u otra availability domain (capítulo 02) |

## Docker y la app

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| `permission denied ... Docker daemon` | Falta el grupo docker o la sesión no se reinició | `sudo usermod -aG docker $USER`, `exit`, `ssh vps` |
| `docker compose` no existe | Plugin no instalado | `sudo apt install docker-compose-plugin` |
| Contenedor `app` en `Exited (1)` | La app revienta al arrancar | `docker compose logs app` muestra el error real de Python |
| `Address already in use` (80/443) | Otro proceso usa el puerto | `sudo ss -tlnp \| grep -E ':(80\|443)'` |
| El build se corta a la mitad | VPS sin memoria o disco lleno | `free -h`, `df -h`; bajar los workers de gunicorn |

## Dominio y HTTPS

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| El navegador no resuelve el dominio | DuckDNS mal configurado o IP vieja | `nslookup mi-app.duckdns.org` contra la IP actual; capítulo 06 |
| Resuelve pero sin candado | Puerto 80 cerrado o el dominio no apunta a este servidor | Ambas capas de firewall (03 y 04); Let's Encrypt valida por el 80 |
| `429 too many certificates` | Rate limit de Let's Encrypt (~5/semana por dominio) | Esperar unos días; para pruebas usar `tls internal` en Caddy |
| `502 Bad Gateway` | Caddy no alcanza a la app | `docker compose ps` y `logs app`; el `reverse_proxy` debe ser `app:8000` |

## GitHub Actions y despliegue

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| El workflow no aparece | Archivo fuera de `.github/workflows/` o en otra rama | Mover el archivo y subir a `main` |
| `Host key verification failed` | Primera conexión sin known_hosts | El action lo maneja; con ssh propio: `-o StrictHostKeyChecking=accept-new` |
| `Permission denied (publickey)` en el deploy | `VPS_SSH_KEY` mal pegado o falta la `.pub` en el VPS | Pegar el contenido completo de la llave privada en el secret |
| El deploy pasa pero no cambia nada | `cd` a la carpeta equivocada o remote malo en el VPS | `git remote -v` y `git log -1` dentro del VPS |
| `git pull` falla con "local changes" | Alguien editó archivos en el servidor | `git fetch && git reset --hard origin/main` (borra cambios locales) |

## Flask, CORS y frontend

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| `CORS policy: No 'Access-Control-Allow-Origin'` | El backend no permite el origen del frontend | `CORS_ORIGINS` con el dominio exacto de Vercel y redeploy |
| `Failed to fetch` desde Vercel | Variable de entorno no inyectada o sin redeploy | Settings → Environment Variables → Redeploy |
| 500 en el VPS y 200 en local | `DEBUG`, `ALLOWED_HOSTS` o secretos distintos | `docker compose logs app`; revisar el `.env` del servidor |
| El correo no llega | Puerto 25 de Oracle bloqueado por defecto | Usar 587 (STARTTLS) con el proveedor SMTP |

## Último recurso

1. `docker compose ps` — ¿está todo `Up`?
2. `docker compose logs --tail=100 app` — ¿qué dice la app?
3. `curl -v https://<TU_DOMINIO>/api/health` — ¿dónde se corta?
4. Reproducir el problema con la app de ejemplo ([`ejemplo/`](https://github.com/Ricy24/guia-despliegue-flask/tree/main/ejemplo)):
   si el ejemplo funciona y la app propia no, el problema está en el código o
   la configuración, no en el servidor.
