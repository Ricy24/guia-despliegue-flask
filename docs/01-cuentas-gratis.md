# 01 — Las cuentas gratis

Todo lo que usa esta guía tiene plan gratuito. Aquí se crean las cuentas y se
entender para qué sirve cada una.

| Servicio | Para qué | Cuándo se usa |
|---|---|---|
| [GitHub](https://github.com) | Código, pruebas y despliegue automático | Capítulos 09 y 10 |
| [Oracle Cloud](https://www.oracle.com/cloud/free/) | El VPS | Capítulos 02 y 03 |
| [DuckDNS](https://www.duckdns.org) | Subdominio gratis | Capítulo 06 |
| [Cloudflare](https://dash.cloudflare.com) | Worker con rate limiting | Capítulo 12 |
| [Vercel](https://vercel.com) | Frontend | Capítulo 11 |

## GitHub

Si no tienes cuenta: <https://github.com/signup>, crearla y verificar el
correo. Sin verificar, los workflows de Actions no corren en repos nuevos.

Luego se sube el proyecto Flask con los comandos del capítulo 00.

## Oracle Cloud

Ingresamos a <https://www.oracle.com/cloud/free/> y en **Start for free**
ponemos correo, nombre y contraseña. Después pide país, región y **tarjeta de
crédito**: no la cobra, es solo verificación de identidad. Un cargo temporal
aparece y se devuelve solo.

La región se elige una sola vez y no se cambia después sin crear otra cuenta.
Para Colombia sirve Bogotá (`sa-bogota-1`), São Paulo (`sa-saopaulo-1`) o
Ashburn (`us-ashburn-1`).

La aprobación puede ser inmediata o tardar de 1 a 3 días. Si Oracle pide más
verificación (selfie o documento), se responde desde el correo que llega y se
espera. Por eso este trámite empieza primero.

> No pagar nada en este paso. Todo lo que sigue usa recursos etiquetados
> *Always Free*. Si en algún paso aparece un precio, se está creando algo que
> no es gratis.

## DuckDNS

Entramos a <https://www.duckdns.org> y nos logueamos con Google, GitHub o
Twitter. En **Domains** escribimos el subdominio que queremos (ej. `mi-app`)
y **Add Domain**. Ya queda `mi-app.duckdns.org`. Anotamos el **token** que
aparece arriba a la derecha: se usa en el capítulo 06.

## Cloudflare

Cuenta en <https://dash.cloudflare.com/sign-up>. No hay que agregar nada
todavía: el Worker funciona con subdominios `*.workers.dev` sin dominio
propio, que es lo que hace PlomApp.

## Vercel

Cuenta en <https://vercel.com/signup> con login de GitHub, para que después
importa los repos sin configurar remotos.

## Anotar los valores

```text
Región de Oracle:                 ________________________
Subdominio DuckDNS:               ____________________.duckdns.org
Token DuckDNS:                    ________________________
Repo del backend en GitHub:       github.com/________________________
Repo del frontend en GitHub:      github.com/________________________
```

**Siguiente:** [02 — Cuenta de Oracle](02-cuenta-oracle.md)
