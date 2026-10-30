# 05 — Docker en el servidor

[Docker](https://docs.docker.com/) empaqueta tu app con Python, las librerías
y hasta la base de datos en **contenedores**: cajas aisladas que corren igual
en tu máquina y en el servidor. "En mi máquina sí funciona" deja de existir.

## Instalar (si no lo hiciste con el script)

Si ejecutaste `setup_vps.sh` en el capítulo 04, **Docker ya está instalado**.
Si prefieres hacerlo a mano, en el VPS:

> 🎯 **Tu turno:**
> ```bash
> curl -fsSL https://get.docker.com -o get-docker.sh
> sudo sh get-docker.sh
> rm get-docker.sh
> sudo systemctl enable --now docker
> sudo usermod -aG docker $USER
> ```

La última línea te da permiso para usar `docker` sin `sudo`. **Aplica al
próximo inicio de sesión**: sal (`exit`) y vuelve a entrar.

Verifica:

> 🎯 **Tu turno:**
> ```bash
> docker --version
> docker compose version
> ```
> Deben responder con versiones. Si el segundo falla ("compose" no existe),
> instala el plugin: `sudo apt install docker-compose-plugin`.

## Los 4 comandos que usarás siempre

| Comando | Qué hace |
|---|---|
| `docker compose up -d --build` | Construye las imágenes y levanta los contenedores (en segundo plano con `-d`) |
| `docker compose ps` | ¿Qué contenedores están corriendo y en qué estado? |
| `docker compose logs -f app` | Ver los logs de la app en vivo (Ctrl+C sale de los logs, no mata la app) |
| `docker compose down` | Detiene y borra los contenedores (los datos en volúmenes se quedan) |

> 💡 `docker compose` (con espacio) es el plugin moderno. Si ves tutoriales
> con `docker-compose` (guión), es la versión vieja: mismo uso.

> ✅ **Así quedó en PlomApp:** el servidor corre 6 contenedores con dos
> "stacks" (grupos): el de su proyecto principal (`lifeos_api`, `lifeos_postgres`,
> `lifeos_redis`, `lifeos_caddy`) y el de la API de PlomApp (`plomaap_api`,
> `plomaap_db`), compartiendo la red con Caddy. Verás esto con
> `docker ps` en su VPS.

> ⚠️ **Si te atascas:**
> - **`permission denied while trying to connect to the Docker daemon`**: no
>   cerraste sesión después del `usermod`. Escribe `exit` y vuelve a entrar
>   (`ssh vps`). Como alternativa rápida: `sudo docker compose ...`.
> - **`Cannot connect to the Docker daemon`**: Docker no arrancó;
>   `sudo systemctl start docker`.

**Siguiente:** [06 — Tu dominio gratis con DuckDNS](06-dominio-gratis.md)
