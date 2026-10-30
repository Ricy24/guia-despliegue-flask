# 05 — Docker en el servidor

Docker empaqueta la app con Python, las librerías y la base de datos en
contenedores: cajas aisladas que corren igual en la máquina local y en el
servidor.

## Instalar

Si se corrió `setup_vps.sh` en el capítulo 04, Docker ya está. Para instalarlo
a mano, en el VPS:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

La última línea permite usar `docker` sin `sudo`, pero aplica al próximo
inicio de sesión: `exit` y volver a entrar.

Verificar:

```bash
docker --version
docker compose version
```

Si el segundo falla (plugin no instalado):

```bash
sudo apt install docker-compose-plugin
```

## Comandos que se usan siempre

| Comando | Qué hace |
|---|---|
| `docker compose up -d --build` | Construye las imágenes y levanta todo en segundo plano |
| `docker compose ps` | Estado de los contenedores |
| `docker compose logs -f app` | Logs de la app en vivo. Ctrl+C sale de los logs, no mata la app |
| `docker compose down` | Detiene los contenedores. Los datos en volúmenes se quedan |

`docker compose` con espacio es el plugin actual. Los tutoriales con
`docker-compose` (guión) son la versión vieja, mismo uso.

> En el servidor de PlomApp corren 6 contenedores en dos stacks: `lifeos`
> (api, postgres con pgvector, redis, caddy) y `plomaap` (la API de Django y
> su postgres), compartiendo la red de Docker con el Caddy. Se ven con
> `docker ps`.

## Errores comunes

- **`permission denied while trying to connect to the Docker daemon`**: no se
  cerró sesión después del `usermod`. `exit`, `ssh vps`. Como alternativa
  rápida: `sudo docker compose ...`.
- **`Cannot connect to the Docker daemon`**: `sudo systemctl start docker`.

**Siguiente:** [06 — DuckDNS](06-dominio-gratis.md)
