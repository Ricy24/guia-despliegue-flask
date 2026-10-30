# Guía de despliegue Flask — Oracle Always Free + Docker + Caddy + CI/CD

Guía para desplegar una app Flask en un VPS gratis de Oracle Cloud, con
HTTPS automático, pruebas automáticas y despliegue automático con GitHub
Actions. Al terminar queda:

- `https://tu-app.duckdns.org` con HTTPS (Caddy + Let's Encrypt, sin pagar nada).
- La app Flask corriendo con Docker en Oracle Always Free.
- Pruebas en cada Pull Request y deploy solo al hacer push a `main`.
- Opcional: Worker de Cloudflare con rate limiting delante de la API, y
  frontend en Vercel.

Costo: $0/mes. Es la misma arquitectura que usa PlomApp en producción
(Django en Oracle detrás de Caddy, frontend en Vercel, Worker de Cloudflare).

## Cómo se usa

1. Fork a este repo, o dale a *Use this template* para copiarlo a tu cuenta.
2. Seguir los capítulos en orden, del 00 al 13. Cada uno continúa el anterior.
3. Cuando el capítulo lo pida, copiar archivos de [`plantilla/`](plantilla/LEEME.md)
   a tu proyecto. La tabla de qué archivo va en cada parte está en su LEEME.
4. Los comandos usan placeholder `mi-app` como nombre de proyecto y
   `mi-app.duckdns.org` como dominio. Reemplázalos por los tuyos.

## Índice

| Cap | Título | Contenido |
|---|---|---|
| 00 | [Qué vamos a hacer](docs/00-que-vamos-a-hacer.md) | Arquitectura final y qué hace cada pieza |
| 01 | [Las cuentas gratis](docs/01-cuentas-gratis.md) | GitHub, Oracle, DuckDNS, Cloudflare, Vercel |
| 02 | [Cuenta de Oracle](docs/02-cuenta-oracle.md) | Registro, límites Always Free, trampas comunes |
| 03 | [Red e instancia](docs/03-red-e-instancia.md) | VCN, security list, crear la máquina y la clave SSH |
| 04 | [SSH y firewall del servidor](docs/04-conexion-y-firewall.md) | Conexión, iptables, script de setup |
| 05 | [Docker en el servidor](docs/05-docker-en-el-vps.md) | Instalar Docker y comandos básicos |
| 06 | [DuckDNS](docs/06-dominio-gratis.md) | Subdominio gratis apuntando a la IP |
| 07 | [Caddy y HTTPS](docs/07-caddy-https.md) | Certificado automático y reverse proxy |
| 08 | [Tu Flask en Docker](docs/08-app-flask-en-docker.md) | Dockerfile + compose + .env, primer deploy |
| 09 | [Pruebas automáticas](docs/09-tests-github-actions.md) | CI con pytest en cada PR |
| 10 | [Despliegue automático](docs/10-despliegue-automatico.md) | CD: push a main → deploy por SSH |
| 11 | [Frontend en Vercel](docs/11-frontend-vercel.md) | VITE_API_URL y CORS |
| 12 | [Cloudflare (opcional)](docs/12-cloudflare.md) | Worker con rate limiting, IP oculta |
| 13 | [Checklist de producción](docs/13-checklist-produccion.md) | Secretos, backups, hardening |
| 14 | [Sin Docker (apéndice)](docs/14-sin-docker.md) | gunicorn + systemd directo |
| — | [Troubleshooting](docs/troubleshooting.md) | Errores comunes y su arreglo |

## Estructura

```text
docs/        la guía, capítulo por capítulo
plantilla/   archivos que copias a tu proyecto (workflows, scripts, docker, Caddyfile)
ejemplo/     app Flask mínima con la que se prueban todos los pasos
```

## Probar el ejemplo en local

```powershell
cd ejemplo
Copy-Item .env.ejemplo .env
docker compose up -d --build      # requiere Docker Desktop
# probar en https://mi-app.duckdns.org/api/health con tu dominio en server/Caddyfile
```

## Requisitos

- Computadora con terminal. Los comandos son para Windows; en macOS/Linux
  cambian las rutas y la conexión SSH.
- Proyecto Flask en un repo de GitHub.
- Paciencia con Oracle: la aprobación de la cuenta puede tardar días.

## Advertencias

- Las credenciales no van en Git. Las llaves e IP viven en los Secrets de
  GitHub y en el `.env` del servidor, que está en `.gitignore`.
- Oracle puede reclamar instancias gratuitas inactivas (menos del 20% de uso
  durante 7 días) y ha cambiado los límites sin avisar: en junio de 2026 bajó
  las ARM de 4 OCPU/24 GB a 2 OCPU/12 GB. Verificar los valores actuales en la
  consola antes de crear nada.
- No exponer apps con datos reales de personas sin aplicar el capítulo 13.
