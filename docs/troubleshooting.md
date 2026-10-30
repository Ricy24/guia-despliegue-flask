# Troubleshooting — errores comunes y su arreglo

Errores típicos de esta guía, en orden de "más probable". Si uno no está,
busca el mensaje completo del error (las palabras clave importan).

## Conexión y servidor

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| `Connection timed out` al hacer SSH | Firewall de Oracle (Security List) sin el 22 abierto, o IP equivocada | Capítulo 03, paso A; verifica la IP con `nslookup` |
| `Permission denied (publickey)` | Conectando sin la llave, o la `.pub` no está en el VPS | `ssh -i ~\.ssh\mi-app-vps.pub ubuntu@<TU_IP>`; si no, vuelve al paso 3D |
| `sudo: ufw: command not found` | En Oracle el firewall es iptables, ufw no viene | Usa `iptables` o instala `sudo apt install ufw` |
| La instancia no arranca / "Out of host capacity" | Oracle sin máquinas gratis en esa región ahora | Espera e reintenta, otra availability domain (capítulo 02) |

## Docker y la app

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| `permission denied ... Docker daemon` | Falta el grupo docker + nueva sesión | `sudo usermod -aG docker $USER`, `exit`, `ssh vps` |
| `docker compose` no existe | Plugin viejo/no instalado | `sudo apt install docker-compose-plugin` |
| Contenedor `app` en `Exited (1)` | La app revienta al arrancar | `docker compose logs app` → el error real de Python está ahí |
| `Address already in use` (80/443) | Otro proceso usa el puerto | `sudo ss -tlnp \| grep -E ':(80\|443)'` |
| Se corta en mitad del `docker compose build` | VPS sin memoria/disco | `free -h`, `df -h`, baja workers de gunicorn |

## Dominio y HTTPS

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| El navegador no resuelve el dominio | DuckDNS mal configurado o IP vieja | `nslookup mi-app.duckdns.org` vs IP actual; revisa el cron del capítulo 06 |
| Resuelve pero "No secure" / error de certificado | Puerto 80 cerrado o dominio no apunta a este servidor | Ambas capas de firewall (03+04); Let's Encrypt valida por el 80 |
| `Error: 429 ... too many certificates` | Rate limit de Let's Encrypt (≈5 emisiones/semana por dominio) | Espera unos días; para probar usa `tls internal` en Caddy |
| `502 Bad Gateway` | Caddy no alcanza a la app (app caída o puerto distinto) | `docker compose ps` y `logs app`; el `reverse_proxy` debe ser `app:8000` |

## GitHub Actions y despliegue

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| El workflow ni aparece | Archivo fuera de `.github/workflows/` o en otra rama | Mueve el archivo y sube a `main` |
| `Host key verification failed` | Primera conexión sin known_hosts | El action lo maneja; si usa tu propio ssh, agrega `-o StrictHostKeyChecking=accept-new` |
| `Permission denied (publickey)` en el deploy | `VPS_SSH_KEY` mal pegado o falta la `.pub` en el VPS | Volver a pegar el contenido COMPLETO de la llave privada en el secret |
| El deploy pasa pero no cambia nada | `cd` a la carpeta equivocada o repo remoto malo en el VPS | `git remote -v` y `git log -1` dentro del VPS |
| `git pull` falla con "local changes" | Alguien editó archivos en el servidor | `git fetch && git reset --hard origin/main` (borra cambios locales) |

## Flask / CORS / frontend

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| `CORS policy: No 'Access-Control-Allow-Origin'` | Backend no permite el origen del frontend | `CORS_ORIGINS` con el dominio EXACTO de Vercel + redeploy |
| `Failed to fetch` desde Vercel | Variable de entorno no inyectada (o sin redeploy) | Settings → Environment Variables → Redeploy |
| 500 en el VPS pero 200 en local | `DEBUG`, `ALLOWED_HOSTS` o secretos distintos | `docker compose logs app`; revisa el `.env` del servidor |
| El correo de recuperación no llega | Puerto 25 de Oracle bloqueado por defecto | Usa puerto 587 (STARTTLS) con tu proveedor SMTP |

## Último recurso

1. `docker compose ps` — ¿está todo `Up`?
2. `docker compose logs --tail=100 app` — ¿qué dice la app?
3. `curl -v https://<TU_DOMINIO>/api/health` — ¿dónde se corta?
4. Reproduce el problema con la app de ejemplo ([`../ejemplo/`](../ejemplo/)):
   si el ejemplo funciona y tu app no, el problema está en tu código/config,
   no en el servidor.
