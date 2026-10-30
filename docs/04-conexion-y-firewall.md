# 04 — Conexión SSH y firewall del servidor

Ya entraste a tu VPS una vez (capítulo 03). Ahora lo dejamos listo: alias de
conexión cómodo, firewall del servidor abierto en los puertos correctos, y
actualizaciones básicas.

## Conectarte sin escribir todo cada vez

> 🎯 **Tu turno** — crea (o edita) el archivo `~\.ssh\config` en Windows:
> ```powershell
> notepad ~\.ssh\config
> ```
> Pega y ajusta:
> ```
> Host vps
>     HostName <TU_IP>
>     User ubuntu
>     IdentityFile ~/.ssh/mi-app-vps.pub
> ```
> Ahora conectarte será solo:
> ```powershell
> ssh vps
> ```

## Actualizar el sistema

Lo primero en cualquier servidor nuevo (puede tardar unos minutos):

> 🎯 **Tu turno** — dentro del VPS:
> ```bash
> sudo apt update && sudo apt upgrade -y
> ```

## El firewall: DOS capas (¡la confusión #1!)

Hay dos firewalls distintos y los dos deben dejar pasar el tráfico:

1. **Security List de Oracle** — ya lo abrimos en el capítulo 03 (en la nube).
2. **Firewall del propio Ubuntu** — reglas del sistema operativo.

Oracle viene con `iptables` activo y, además, su **Oracle Cloud Agent**
gestiona cosas del sistema. El script de la plantilla hace ambas cosas por ti:

> 🎯 **Tu turno** — sube el script de la plantilla y ejecútalo. En local
> (PowerShell, desde la carpeta de esta guía):
> ```powershell
> scp .\plantilla\scripts\setup_vps.sh vps:~
> ```
> Y en el VPS:
> ```bash
> bash setup_vps.sh
> ```
> El script:
> 1. Abre los puertos 22, 80 y 443 en iptables.
> 2. Guarda las reglas para que sobrevivan reinicios (`netfilter-persistent`).
> 3. Instala Docker (capítulo siguiente) y git.
> 4. Crea la carpeta `~/mi-app` de tu app.

> ✅ **Así quedó en PlomApp:** el servidor `lifeos` corre `iptables` y los
> puertos 22/80/443 están abiertos en ambas capas; el 80 y 443 los consume
> el contenedor Caddy (que veremos en el capítulo 07) y el 22 el SSH.

> ⚠️ **Si te atascas:**
> - **`sudo` pide contraseña y no hay**: no pasa nada, el usuario `ubuntu`
>   tiene `sudo` sin contraseña en Oracle (por eso aparece el archivo
>   `.sudo_as_admin_successful`).
> - **Se desconecta al instalar**: raro; revisa `df -h` (disco lleno) y
>   `free -h` (RAM), y reintenta solo `apt upgrade`.
> - **Quieres verificar qué está escuchando**: `sudo ss -tlnp` muestra todos
>   los puertos abiertos y qué proceso los usa.

**Siguiente:** [05 — Docker en el servidor](05-docker-en-el-vps.md)
