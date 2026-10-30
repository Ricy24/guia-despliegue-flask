# 02 — Crear la cuenta de Oracle sin sustos

Si aprobaste tu cuenta (capítulo 01), esta parte es corta: entrar a la consola,
entender los límites y no asustarte con la interfaz. La creación de la máquina
viene en el capítulo 03.

## Entrar a la consola

1. Ve a <https://cloud.oracle.com> y login con tu correo.
2. Acepta los términos.
3. Te sale el **Home Region** (tu región inicial). Anótala: los recursos
   Always Free solo funcionan ahí.

La consola de Oracle es... intensa. Tiene menús por servicio (Compute,
Networking, Storage). No uses el menú de navegación: en el buscador de
arriba escribe directamente lo que buscas, por ejemplo `Instances` o `VCN`.

## ¿Qué es gratis y cuánto te dan? (octubre 2026)

Todo lo de esta tabla está en el nivel **Always Free**: gratis mientras viva
tu cuenta, sin fecha de vencimiento.

| Recurso | Límite Always Free | Notas |
|---|---|---|
| Máquinas ARM (`VM.Standard.A1.Flex`) | **2 OCPU + 12 GB RAM en total** | Repartibles como quieras: 1 máquina de 2/12 o 2 de 1/6 |
| Máquinas AMD (`VM.Standard.E2.1.Micro`) | 2 máquinas de 1/8 OCPU y 1 GB RAM | Muy pequeñas; casi siempre mejor la ARM |
| Disco (boot volume) | 200 GB en total | Mínimo 50 GB por máquina |
| Salida de red | ~10 TB/mes | Más que suficiente |
| Cuentas con recursos "idle" | Pueden ser **reclamadas** | Ver la advertencia de abajo |

> ⚠️ **Advertencia importante (idle):** Oracle puede **borrar** máquinas
> gratuitas que estén "idle": menos del 20% de uso de CPU, red y memoria
> durante 7 días seguidos. Como tu app web casi siempre pasa por debajo de ese
> umbral, el truco que usan todos: deja un cron que haga un pequeño ruido cada
> pocos minutos. Ejemplo (lo ejecutas en el VPS en el capítulo 04):
> ```bash
> (crontab -l 2>/dev/null; echo "*/15 * * * * curl -s https://mi-app.duckdns.org/api/health > /dev/null") | crontab -
> ```
> Es solo un golpecito de salud cada 15 minutos, no consume nada real.

> ⚠️ **Advertencia de límites:** en junio de 2026 Oracle redujo las ARM de
> 4 OCPU/24 GB a **2 OCPU/12 GB** sin mucho aviso, y desactivó máquinas que se
> pasaran. Si algún día tu máquina es desactivada por "exceder el límite",
> es esto: rediméncionela a lo permitido antes de que borren el disco (tienes
> ~2 semanas de gracia para rescatar datos).

## Trampas comunes al registrarse

- **"Out of host capacity"**: significa "ahora no tengo máquinas ARM en esta
  región para clientes gratis". No es tu cuenta rota. Soluciones: intenta en
  otra **availability domain**, espera unas horas e inténtalo de nuevo, o
  prueba otra región. Es el error #1 de Oracle.
- **Región**: la eliges una sola vez y no se puede cambiar sin crear otra
  cuenta. Para Colombia, `sa-saopaulo-1` (Brasil) suele tener mejor latencia
  que EE. UU., pero Ashburn es más barata en recursos. **Ambas sirven.**
- **Reclamo de tarjeta**: si el monto temporal no se devuelve en unos días,
  revisa que tu banco no lo haya bloqueado por ser extranjero.

> ✅ **Así quedó en PlomApp:** región `sa-saopaulo-1` (Brasil), una sola
> instancia ARM con Ubuntu 24.04 y disco de 45 GB, corriendo desde septiembre
> de 2026 con la API de Django y el frontend detrás de Caddy.

> 🎯 **Tu turno:** entra a la consola, busca **Limits, Quotas and Usage**
> (en el menú de Governance o por el buscador) y revisa que veas tu límite de
> Compute. Anota en tu bloc de notas la región y qué límite te asignaron.

**Siguiente:** [03 — Red e instancia: crear tu VPS](03-red-e-instancia.md)
