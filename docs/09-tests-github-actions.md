# 09 — Pruebas automáticas con GitHub Actions

**CI (Integración Continua)** = cada vez que alguien escribe código, un robot
en GitHub corre tus pruebas en una máquina gratis y le pone ✔ o ✘ al trabajo.
Si alguien rompe algo, se entera **antes** de mezclar, no en la demo.

## Paso 1 — Pruebas locales primero

Un workflow que corre pruebas rotas no sirve. Asegúrate de que pasen en local:

> 🎯 **Tu turno** — copia la prueba de humo a tu proyecto y ajusta el import:
> ```
> tests/test_smoke.py    → de plantilla/tests/test_smoke.py
> ```
> ```powershell
> pip install pytest
> pytest -q
> ```

Para tu proyecto real, escribe pruebas de tus endpoints críticos con el
cliente de pruebas de Flask (`app.test_client()`): no abren puertos ni tocan
la base de datos real. Buenas candidatas: login, registro, y que los errores
devuelvan el código correcto (401, 404...).

## Paso 2 — El workflow

> 🎯 **Tu turno** — copia el archivo a tu proyecto:
> ```
> .github/workflows/tests.yml    → de plantilla/.github/workflows/tests.yml
> ```
> Git solo vigila carpetas `.github/workflows/`: en cuanto subas ese archivo a
> `main`, el workflow **ya está activo**.

Anatomía (lo esencial, el archivo está comentado línea por línea):

```yaml
name: Pruebas
on:                    # ¿cuándo corro?
  push: {branches: [main]}
  pull_request: {branches: [main]}
jobs:
  pruebas:
    runs-on: ubuntu-latest   # una máquina Ubuntu GRATIS, ~10 min de uso
    steps:
      - uses: actions/checkout@v4      # baja tu código a la máquina
      - uses: actions/setup-python@v5  # instala Python 3.12
      - run: pip install -r requirements.txt pytest
      - run: pytest -q                 # tus pruebas
```

> 💡 `ubuntu-latest` es una máquina virtual descartable que GitHub presta
> gratis para repos públicos. Tus secretos locales (`.env`) **no existen**
> ahí: si tus pruebas necesitan variables, define `env:` en el workflow (así
> lo hace PlomApp con `SECRET_KEY` y `JWT_SECRET_KEY` de prueba).

## Paso 3 — Subir y ver el resultado

> 🎯 **Tu turno:**
> ```powershell
> git add .
> git commit -m "ci: agrega pruebas automaticas"
> git push
> ```
> Ve a tu repo → pestaña **Actions**. Verás el workflow corriendo. Al terminar,
> verde ✘/✔ con el tiempo que tomó.

El mismo resultado aparece en cada **Pull Request**: la palomita es
"requisito" para poder mezclar. Para exigirlo (que no se pueda hacer merge sin
pruebas verdes), en el repo: **Settings → Branches → Add branch protection
rule** → rama `main` → activa **Require status checks to pass** y selecciona
el job `pruebas`.

> ✅ **Así quedó en PlomApp:** su workflow `Pruebas` corre en cada PR y push:
> lint (ruff), seguridad (bandit), ~500 pruebas unitarias en **tres bases de
> datos** (SQLite, PostgreSQL y MySQL en contenedores), integración,
> **pruebas de mutación** y cobertura que **falla el pipeline si baja del
> 100%**. Todo eso en paralelo, en ~10 minutos de máquina gratis. Su
> `required` final verifica que todos los jobs pasaron. Tú empiezas con el
> tuyo de un solo job; el resto se agrega cuando lo necesites.

> ⚠️ **Si te atascas:**
> - **El workflow no aparece en Actions**: el archivo debe estar exactamente
>   en `.github/workflows/` (carpeta oculta; en Windows activa "ver ocultos")
>   y en la rama `main`.
> - **"No space left" o límite de minutos**: solo ocurre en repos PRIVADOS
>   (2000 min/mes gratis). Los públicos corren gratis e ilimitado.
> - **Pasa en local y falla en Actions**: instala las mismas dependencias
>   (`requirements.txt` completo) y evita rutas absolutas de Windows en las
>   pruebas.

**Siguiente:** [10 — Despliegue automático con cada push](10-despliegue-automatico.md)
