# Guía de despliegue Flask — Oracle Always Free + Docker + Caddy + CI/CD

Guía **paso a paso, en español y para principiantes**, para desplegar tu app
Flask gratis en la nube y automatizar pruebas y despliegues con GitHub
Actions. Terminas con:

- 🔒 `https://tu-app.duckdns.org` con **HTTPS automático y gratis** (Caddy/Let's Encrypt).
- 🐳 Tu app Flask empaquetada con **Docker** en un VPS de **Oracle Cloud Always Free**.
- 🤖 **Pruebas automáticas** en cada Pull Request y **despliegue automático** con cada push a `main`.
- 🛡️ Opcional: proxy de **Cloudflare** con rate limiting (oculta tu IP) y frontend en **Vercel**.

Costo total: **$0/mes**. Inspirado en la arquitectura real de PlomApp (Django
en Oracle + Caddy + Cloudflare Workers + Vercel).

## Cómo usar este repo

1. Hazle **fork** o usa este repo como **plantilla** (botón *Use this template*).
2. Sigue los capítulos **en orden** — cada uno construye sobre el anterior:
3. Cuando el capítulo lo pida, copia archivos de [`plantilla/`](plantilla/LEEME.md)
   a tu proyecto (la tabla de "qué va en cada parte" está en su LEEME).

## Índice

| Cap | Título | Qué logras |
|---|---|---|
| 00 | [Qué vamos a hacer](docs/00-que-vamos-a-hacer.md) | El mapa mental: cada pieza y por qué existe |
| 01 | [Las cuentas gratis](docs/01-cuentas-gratis.md) | GitHub, Oracle, DuckDNS, Cloudflare, Vercel |
| 02 | [Cuenta de Oracle sin sustos](docs/02-cuenta-oracle.md) | Límites Always Free, trampas del registro, anti-idle |
| 03 | [Red e instancia](docs/03-red-e-instancia.md) | VCN, firewall en la nube, crear la máquina y la clave SSH |
| 04 | [SSH y firewall del servidor](docs/04-conexion-y-firewall.md) | Alias de conexión, iptables, el script de setup |
| 05 | [Docker en el servidor](docs/05-docker-en-el-vps.md) | Instalar Docker y los 4 comandos clave |
| 06 | [DuckDNS](docs/06-dominio-gratis.md) | Subdominio gratis → tu IP, con cron que la mantiene viva |
| 07 | [Caddy + HTTPS](docs/07-caddy-https.md) | Candado 🔒 automático, sin tocar certbot |
| 08 | [Tu Flask en Docker](docs/08-app-flask-en-docker.md) | Dockerfile + compose + .env → app en internet |
| 09 | [Pruebas automáticas](docs/09-tests-github-actions.md) | CI con pytest en cada PR |
| 10 | [Despliegue automático](docs/10-despliegue-automatico.md) | CD: push a `main` → deploy por SSH |
| 11 | [Frontend en Vercel](docs/11-frontend-vercel.md) | `VITE_API_URL` + CORS bien |
| 12 | [Cloudflare (opcional)](docs/12-cloudflare.md) | Worker con rate limiting e IP oculta |
| 13 | [Checklist de producción](docs/13-checklist-produccion.md) | Secretos, backups, hardening |
| 14 | [Sin Docker (apéndice)](docs/14-sin-docker.md) | gunicorn + systemd a pelo |
| — | [Troubleshooting](docs/troubleshooting.md) | Errores comunes → arreglo |

## Estructura

```text
docs/        la guía, capítulo por capítulo
plantilla/   los archivos que copias a TU proyecto (workflows, scripts, docker, Caddyfile)
ejemplo/     app Flask mínima con la que se prueban todos los pasos
```

## Probar el ejemplo en 3 comandos (opcional)

```powershell
cd ejemplo
Copy-Item .env.ejemplo .env
docker compose up -d --build      # requiere Docker Desktop
# https://mi-app.duckdns.org/api/health  (con tu dominio en server/Caddyfile)
```

## Requisitos previos

- Computadora con terminal (instrucciones para Windows; macOS/Linux solo
  cambian rutas y comandos de conexión).
- Un proyecto Flask en GitHub.
- Paciencia con Oracle (el registro puede tardar días en aprobarse).

## Advertencias que importan

- 🔑 **Las credenciales nunca van en Git.** Todo lo que sea IP, llave o
  contraseña vive en *Secrets* de GitHub o en el `.env` del servidor.
- ⚡ Oracle puede **reclamar** máquinas gratuitas inactivas (7 días <20% de
  uso) y ha **cambiado sus límites sin aviso** (en junio de 2026 bajó las ARM
  de 4/24 a 2 OCPU/12 GB). Verifica siempre los valores actuales.
- 🚫 Este material es para aprendizaje: no expongas apps con datos reales de
  personas sin las medidas del capítulo 13.
