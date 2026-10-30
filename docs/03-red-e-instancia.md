# 03 — Red e instancia

Crear la máquina en Oracle son 3 pasos: la red (por dónde entra el tráfico),
la instancia (la máquina) y la clave SSH (que reemplaza a la contraseña).

## A. La red (VCN)

Oracle no crea redes al vuelo: hace falta una VCN.

1. En el buscador de la consola: `Networking` → **Virtual Cloud Networks**.
2. **Start VCN Wizard**.
3. Elegir **Create VCN with Internet Connectivity** → **Start**.
4. Nombre: `guia-vcn`. Todo lo demás por defecto.
5. **Create** en las dos pantallas (la VCN y las subnets que crea).

Esto crea la VCN, una **subnet pública** (donde vive la máquina, con acceso a
internet), las route tables y las security lists.

### Abrir los puertos

Cada subnet tiene una **Security List**: un firewall en la nube, distinto del
firewall del sistema operativo. Hay que permitir los puertos que la app
necesita.

1. Entrar a la VCN → **Security Lists** → **Default Security List**.
2. **Add Ingress Rules**, una regla por cada fila:

| Source CIDR | Dest. Port Range | Para qué |
|---|---|---|
| `0.0.0.0/0` | `22` | SSH |
| `0.0.0.0/0` | `80` | HTTP (Let's Encrypt valida el dominio por aquí) |
| `0.0.0.0/0` | `443` | HTTPS |

El puerto 80 hace falta aunque todo vaya por HTTPS: es por donde Let's
Encrypt verifica el dominio para emitir el certificado.

`0.0.0.0/0` significa desde cualquier IP. Para SSH se deja abierto porque el
servidor solo acepta llaves, no contraseñas. Si se quiere endurecer, se pone
la IP propia (la dice <https://api.ipify.org>), pero si la IP de casa cambia
uno queda fuera del servidor.

## B. El par de claves SSH

La llave privada no se comparte nunca; la pública se pone en el servidor.

En la computadora local, en PowerShell:

```powershell
cd ~\.ssh
ssh-keygen -t ed25519 -f mi-app-vps -C "vps-guia"
```

Crea dos archivos:

- `mi-app-vps` — la llave privada. No sube a ningún repo.
- `mi-app-vps.pub` — la llave pública. Va a Oracle y al VPS.

## C. La instancia

1. `Instances` → **Compute → Instances** → **Create Instance**.
2. **Name**: `guia-vps`.
3. **Image**: **Change Image** → **Canonical Ubuntu** → 24.04 (o 22.04).
4. **Shape**: **Change Shape** → `VM.Standard.A1.Flex` (ARM, gratis hasta
   2 OCPU/12 GB) o `VM.Standard.E2.1.Micro` (AMD, más floja). Con 1 OCPU y
   6 GB para Flask + Caddy + Docker sobra.
5. **SSH keys**: **Paste SSH keys** y pegar el contenido de `mi-app-vps.pub`
   (se ve con `type mi-app-vps.pub`).
6. **Boot volume**: activar *Specify a custom boot volume size* y poner
   **50 GB**. Cuenta de los 200 GB gratis.
7. **Create** y esperar unos 3 minutos.

## D. La IP pública

En la página de la instancia está la **Public IP address**, algo como
`158.247.126.81`. Esa es la `<TU_IP>` de la guía.

Para probar que deja conectar:

```powershell
ssh -i ~\.ssh\mi-app-vps.pub ubuntu@<TU_IP>
```

Pregunta por fingerprint: `yes`. Entra el prompt `ubuntu@guia-vps:~$`.

> En PlomApp quedó una instancia en `sa-saopaulo-1` con Ubuntu 24.04,
> hostname `lifeos`, y la llave que hoy está en `~\.ssh\lifeos.key`.

## Errores comunes

- **"Connection refused"**: la instancia todavía está arrancando. Esperar un
  minuto.
- **"Permission denied (publickey)"**: se está conectando sin la llave o con
  otra. Revisar el `-i`.
- **"No suitable key exchange packet found"** o la conexión cuelga: la
  Security List no tiene el 22 abierto, o se eligió la imagen equivocada.
- **"Out of host capacity" al crear**: reintentar más tarde u otra
  availability domain (capítulo 02).

**Siguiente:** [04 — SSH y firewall del servidor](04-conexion-y-firewall.md)
