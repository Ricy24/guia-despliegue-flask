# 02 — Cuenta de Oracle

Si la cuenta ya fue aprobada, este capítulo es corto: entrar a la consola,
entender los límites y no asustarse con la interfaz. La máquina se crea en el
capítulo 03.

## Entrar a la consola

1. <https://cloud.oracle.com>, login con el correo.
2. Aceptar los términos.
3. Anotar el **Home Region** que aparece: los recursos Always Free solo
   funcionan en la región inicial.

La consola es confusa. No hay que navegar los menús: en el buscador de arriba
se escribe lo que se busca, por ejemplo `Instances` o `VCN`.

## Qué es gratis y cuánto dan (octubre 2026)

| Recurso | Límite Always Free | Notas |
|---|---|---|
| Máquinas ARM (`VM.Standard.A1.Flex`) | 2 OCPU + 12 GB de RAM en total | Se reparten como se quiera: una de 2/12 o dos de 1/6 |
| Máquinas AMD (`VM.Standard.E2.1.Micro`) | 2 máquinas de 1/8 OCPU y 1 GB RAM | Muy pequeñas; casi siempre conviene la ARM |
| Disco (boot volume) | 200 GB en total | Mínimo 50 GB por máquina |
| Salida de red | ~10 TB/mes | Sobra para un proyecto de clase |

> Oracle puede **borrar** las máquinas gratuitas que estén idle: menos del 20%
> de uso de CPU, red y memoria durante 7 días seguidos. Como una web casi
> siempre pasa por debajo de ese umbral, se deja un cron que haga un golpecito
> cada 15 minutos. Se configura en el capítulo 06 con el health check de la
> app:
> ```bash
> (crontab -l 2>/dev/null; echo "*/15 * * * * curl -s https://mi-app.duckdns.org/api/health > /dev/null") | crontab -
> ```

> En junio de 2026 Oracle redujo las ARM de 4 OCPU/24 GB a **2 OCPU/12 GB**
> sin anuncio, y desactivó máquinas que se pasaran del límite. Si una instancia
> es desactivada por exceder el límite, hay unos 2 semanas de gracia para
> redimensionarla y rescatar los datos antes de que borren el disco.

## Errores comunes al registrarse y al crear recursos

- **"Out of host capacity"**: Oracle no tiene máquinas ARM libres en esa
  región en este momento. No es que la cuenta esté rota. Se espera e
  reintenta, se prueba otra availability domain, u otra región. Es el error
  #1 de Oracle.
- **Región**: no se cambia sin crear otra cuenta nueva.
- **Rechazo de la tarjeta**: si el cargo temporal no se devuelve en unos días,
  revisar con el banco si bloqueó el pago por ser extranjero.

> En LifeOS se usó `sa-bogota-1` (Bogotá), una instancia `VM.Standard3.Flex`
> de 1 OCPU y 16 GB con Ubuntu 24.04 y disco de 45 GB, corriendo desde
> septiembre de 2026. El intento inicial con A1 Flex falló por falta de
> capacidad; el recorrido completo está en el
> [capítulo 15](15-caso-real-lifeos.md).

> En la consola, **Governance → Limits, Quotas and Usage** muestra el límite
> de Compute asignado a la cuenta. Vale la pena revisarlo antes de crear la
> instancia.

**Siguiente:** [03 — Red e instancia](03-red-e-instancia.md)
