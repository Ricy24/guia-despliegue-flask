# 03 — Red e instancia: crear tu VPS

Aquí se hace la parte que da más miedo: crear la máquina en Oracle. Son 3
pasos: la **red** (por dónde entra el tráfico), la **instancia** (la máquina
propiamente dicha) y la **clave SSH** (tu llave de entrada, que reemplaza a la
contraseña).

## Paso A — La red (VCN)

Oracle no crea redes al vuelo: necesitas una VCN (Virtual Cloud Network).

1. En el buscador de la consola escribe `Networking` → **Virtual Cloud
   Networks**, o ve a **Networking → Virtual Cloud Networks**.
2. Da clic en **Start VCN Wizard** (botón arriba).
3. Elige **Create VCN with Internet Connectivity** y dale **Start**.
4. Nombre: `guia-vcn` (o el que quieras).
5. Deja todo lo demás por defecto y **Create** en dos pantallas (VCN y luego
   las dos subnets que crea).

Esto te crea: la VCN, una **subnet pública** (donde vivirá tu máquina, con
acceso a internet) y los **route tables** y **security lists** que regulan el
tráfico.

### Abrir los puertos (el paso que todos olvidan)

Cada subnet tiene una **Security List** (lista de seguridad): un firewall
**en la nube**, distinto del firewall del sistema operativo. Debe permitir lo
que tu app necesita.

1. Entra a tu VCN → pestaña **Security Lists** → **Default Security List**.
2. **Add Ingress Rules** y agrega estas tres reglas (una por clic):

| Stateless | Source CIDR | Dest. Port Range | Descripción |
|---|---|---|---|
| No | `0.0.0.0/0` | `22` | SSH desde cualquier lugar |
| No | `0.0.0.0/0` | `80` | HTTP (Caddy obtiene el certificado por aquí) |
| No | `0.0.0.0/0` | `443` | HTTPS |

> 💡 El puerto **80 debe estar abierto aunque uses solo HTTPS**: Let's Encrypt
> verifica tu dominio por el 80 para emitir el certificado.

> ⚠️ `0.0.0.0/0` significa "desde cualquier IP del mundo". Para SSH (22) es
> aceptable con clave fuerte; si quieres endurecer, pon ahí tu IP pública
> (`https://api.ipify.org` te la dice) — pero si tu IP de casa cambia, te
> quedas fuera del servidor. Lo dejamos abierto y lo protegemos con clave.

## Paso B — Generar tu par de claves SSH

La clave SSH es como una llave física: la **privada** no la comparte nunca; la
**pública** la pones en el servidor y él la reconoce.

> 🎯 **Tu turno** — en tu computadora (no en el servidor), abre PowerShell:
> ```powershell
> cd ~\.ssh
> ssh-keygen -t ed25519 -f mi-app-vps -C "vps-guia"
> ```
> (si te pregunta passphrase, puedes dejarla vacía o poner una; una passphrase
> la guarda Windows Credential Manager).
>
> Esto crea dos archivos:
> - `mi-app-vps` → tu **llave privada** (SECRETA, jamás la subas a ningún repo)
> - `mi-app-vps.pub` → la **llave pública** (esta va a Oracle y al VPS)

## Paso C — La instancia

1. Busca `Instances` → **Compute → Instances** → **Create Instance**.
2. **Name:** `guia-vps`.
3. **Image:** Change Image → **Canonical Ubuntu** → versión **24.04** (o 22.04).
4. **Shape:** Change Shape →
   - **VM.Standard.A1.Flex** (ARM: potente y gratis hasta 2 OCPU/12 GB), o
   - **VM.Standard.E2.1.Micro** (AMD: flojita, pero también gratis).
   - Para Flask + Caddy + Docker, con **1 OCPU / 6 GB** vas holgado.
5. **SSH keys:** elige **Paste SSH keys** y pega el contenido de
   `mi-app-vps.pub` (el archivo `.pub`, con `cat mi-app-vps.pub` en la
   terminal).
6. **Boot volume:** activa *Specify a custom boot volume size* y ponle
   **50 GB** (el mínimo; nos sobra para un proyecto de clase y ahorras de los
   200 GB gratis).
7. **Create** y espera ~3 minutos.

> ✅ **Así quedó en PlomApp:** instancia `VM.Standard` en `sa-saopaulo-1`,
> Ubuntu 24.04, hostname `lifeos`, con la llave SSH que hoy vive en
> `~\.ssh\lifeos.key` del equipo de Andrés.

## Paso D — La IP pública

1. En la página de tu instancia, copia la **Public IP address**. Verás algo
   como `158.247.126.81`.
2. Pégala en tu bloc de notas: `________________________` → esa es tu
   `<TU_IP>`, y la usas en TODA la guía.

> 🎯 **Tu turno** — prueba que responde antes de seguir:
> ```powershell
> ssh -i ~\.ssh\mi-app-vps.pub ubuntu@<TU_IP>
> ```
> (sí, con el `.pub`; solo cuando conectas la primera vez. Después, el
> cliente usa tu llave privada automáticamente.)
> Si pregula por fingerprint, escribe `yes`. Al entrar verás el mensaje de
> bienvenida de Ubuntu y el prompt `ubuntu@guia-vps:~$`.

> ⚠️ **Si te atascas:**
> - **"No suitable key exchange packet found"** o cuelga: casi siempre es el
>   firewall de la **Security List** (paso A) o que elegiste la imagen
>   equivocada. Verifica que el 22 esté abierto.
> - **"Connection refused"**: la instancia aún está arrancando; espera 1 min.
> - **"Permission denied (publickey)"**: estás conectando sin tu llave o con
>   otra. Revisa el `-i ~\.ssh\mi-app-vps.pub`.
> - **"Out of host capacity" al crear**: no es tu culpa; reintenta más tarde
>   o en otra availability domain (ver capítulo 02).

**Siguiente:** [04 — Conexión SSH y firewall del servidor](04-conexion-y-firewall.md)
