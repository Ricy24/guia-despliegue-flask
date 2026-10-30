# 04 — SSH y firewall del servidor

La máquina ya deja conectar. Ahora se deja el servidor listo: alias de
conexión, firewall abierto en los puertos correctos y actualizaciones.

## Conectar sin escribir todo

Crear (o editar) `~\.ssh\config` en la computadora local:

```powershell
notepad ~\.ssh\config
```

```
Host vps
    HostName <TU_IP>
    User ubuntu
    IdentityFile ~/.ssh/mi-app-vps.pub
```

De ahí en adelante la conexión es `ssh vps`.

## Actualizar el sistema

Dentro del VPS:

```bash
sudo apt update && sudo apt upgrade -y
```

## El firewall: dos capas

Hay dos firewalls y los dos tienen que dejar pasar el tráfico:

1. **Security List de Oracle** — la que se abrió en el capítulo 03, en la
   nube.
2. **Firewall del Ubuntu** — iptables del sistema operativo.

Oracle viene con iptables activo. El script de la plantilla hace las dos
cosas: abre 22, 80 y 443, guarda las reglas para que sobrevivan reinicios,
instala Docker y git, y crea la carpeta de la app.

Desde la computadora local, subir el script:

```powershell
scp .\plantilla\scripts\setup_vps.sh vps:~
```

Y en el VPS:

```bash
bash setup_vps.sh
```

> El usuario `ubuntu` tiene `sudo` sin contraseña en Oracle (por eso existe el
> archivo `.sudo_as_admin_successful`).

> Para ver qué puertos están abiertos y qué proceso los usa:
> `sudo ss -tlnp`.

**Siguiente:** [05 — Docker en el servidor](05-docker-en-el-vps.md)
