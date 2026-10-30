# 10 — Despliegue automático con cada push

Ahora el "super automático": pruebas verdes en `main` → GitHub se conecta por
SSH a tu VPS → `git pull` → reconstruye el contenedor → queda publicado. Sin
tocar la terminal.

## Cómo funciona la seguridad (clave → secretos)

Nadie debe escribir IPs ni llaves en el código. El flujo:

1. Creas una **llave SSH dedicada solo para desplegar** (no es la tuya personal).
2. Su **llave pública** va al VPS (en `authorized_keys`).
3. Su **llave privada** va a los **Secrets de GitHub** (cifrados; el código
   nunca los ve).
4. El workflow usa esos secretos para conectarse.

## Paso 1 — La llave de despliegue

> 🎯 **Tu turno** — en tu computadora:
> ```powershell
> ssh-keygen -t ed25519 -f ~\.ssh\mi-app-deploy -N '""' -C "deploy-github"
> ```
> Luego súbela al VPS como autorizada (agrega, no reemplaza, tu llave personal):
> ```powershell
> type ~\.ssh\mi-app-deploy.pub | ssh vps "cat >> ~/.ssh/authorized_keys"
> ssh vps "tail -1 ~/.ssh/authorized_keys"   # confirma que apareció
> ```

## Paso 2 — Los secretos en GitHub

> 🎯 **Tu turno** — en tu repo: **Settings → Secrets and variables → Actions → New repository secret**. Crea:
>
> | Nombre | Valor |
> |---|---|
> | `VPS_HOST` | la IP pública de tu VPS (`<TU_IP>`) |
> | `VPS_USER` | `ubuntu` |
> | `VPS_SSH_KEY` | el contenido **completo** de `~\.ssh\mi-app-deploy` (con las líneas `BEGIN/END`), copiado con `type ~\.ssh\mi-app-deploy` |
> | `VPS_PORT` | `22` |

> 🔐 Nunca pegues la llave en el código, en issues, ni en el chat. Si se
> filtra: bórrala del VPS (`nano ~/.ssh/authorized_keys`) y genera otra.

## Paso 3 — El workflow de despliegue

> 🎯 **Tu turno** — copia y ajusta (la carpeta en el `cd`):
> ```
> .github/workflows/deploy.yml    → de plantilla/.github/workflows/deploy.yml
> ```

También ajusta el `tests.yml` de la plantilla: agrega `workflow_call:` al
bloque `on:` para que `deploy.yml` pueda reutilizarlo (así las pruebas corren
antes de desplegar, sin duplicar el archivo). El `deploy.yml` ya lo llama con:

```yaml
jobs:
  pruebas:
    uses: ./.github/workflows/tests.yml   # reutiliza el workflow completo
  despliegue:
    needs: pruebas                        # solo corro si las pruebas pasaron
    steps:
      - uses: appleboy/ssh-action@v1      # SSH desde el robot de GitHub
        with:
          host: ${{ secrets.VPS_HOST }}
          script: |
            cd "$HOME/mi-app"
            git pull --ff-only
            docker compose build
            docker compose up -d
```

## Paso 4 — El primer despliegue

> 🎯 **Tu turno:**
> ```powershell
> git add .
> git commit -m "ci: despliegue automatico al VPS"
> git push
> ```
> Pestaña **Actions**: verás `Despliegue` → job `pruebas` → job `despliegue`.
> Si todo sale bien, en el VPS:
> ```bash
> cd ~/mi-app && git log --oneline -1 && docker compose ps
> ```
> Y en el navegador: tu app actualizada. 🎉

## La regla de oro del servidor

> ⚠️ **Nunca edites archivos directamente en el servidor.** Todo cambio se hace
> en tu computadora, se commitea y se despliega. Si editas en el servidor, el
> próximo `git pull` fallará (y el deploy se romperá para todos). PlomApp
> aprendió esto a la fuerza: un fix de CORS hecho "a mano" por SSH en el
> servidor generó un commit de emergencia para dejar el `.env` oficial
> versionado.

Si ya pasó y `git pull` se queja:

```bash
git fetch origin && git reset --hard origin/main   # ¡cuidado! borra cambios locales
docker compose up -d --build
```

> 💡 **Rollback**: como el código vive en Git, volver atrás es
> `git revert <commit>` en local + push; el workflow se encarga del resto.

> ⚠️ **Si te atascas:**
> - **"Permission denied (publickey)" en el job**: el `VPS_SSH_KEY` está mal
>   copiado (falta el `-----BEGIN` o se cortó), o la llave pública no está en
>   `authorized_keys` del VPS.
> - **`docker: permission denied`**: el usuario `ubuntu` no está en el grupo
>   `docker` (capítulo 05) — `sudo usermod -aG docker ubuntu` y probar.
> - **El deploy "pass" pero no cambia nada**: revisa que el `cd` del script
>   apunte a la carpeta correcta y que el `git remote` del VPS apunte a tu
>   repo.
> - **Dos deploys pisándose**: el `concurrency` del workflow lo evita; no lo
>   quites.

> ✅ **Así quedó en PlomApp:** su pipeline de pruebas genera hasta un Excel de
> entrega que se commitea solo a `main` con un `GIT_PUSH_TOKEN` (con fallback
> a artefacto si no existe) — el mismo patrón de "Actions escribiendo de forma
> controlada". El despliegue al VPS de PlomApp hoy es manual por SSH (y así
> quedó documentado en sus commits); esta guía automatiza exactamente ese paso
> para tu proyecto.

**Siguiente:** [11 — Frontend en Vercel (opcional)](11-frontend-vercel.md)
