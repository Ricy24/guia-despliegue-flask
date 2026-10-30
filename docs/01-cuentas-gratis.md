# 01 — Las cuentas gratis que vamos a crear

Todo lo que usaremos tiene plan gratuito real (no prueba de 30 días). Aquí
creas las cuentas y entiendes para qué sirve cada una. Donde hay que elegir
contraseña o guardar algo, hazlo con calma: **esta lista es tu inventario de
servicios**.

| Servicio | Para qué | Cuánto | Capítulo donde lo usamos |
|---|---|---|---|
| [GitHub](https://github.com) | Código + pruebas + despliegue automático | Gratis | 09, 10 |
| [Oracle Cloud](https://www.oracle.com/cloud/free/) | El servidor (VPS) | Always Free | 02, 03 |
| [DuckDNS](https://www.duckdns.org) | Subdominio gratis → tu IP | Gratis | 06 |
| [Cloudflare](https://dash.cloudflare.com) | Proxy, rate limiting, ocultar IP | Gratis | 12 |
| [Vercel](https://vercel.com) | Frontend (React/Vite) | Gratis | 11 |

## 1. GitHub (si no lo tienes)

1. Entra a <https://github.com/signup> y crea tu cuenta con tu correo.
2. Verifica el correo.
3. Sube tu proyecto Flask (comandos en el capítulo 00).

> 💡 Verifica el correo **antes** del capítulo 09: sin verificar, los
> workflows de Actions no corren en repos nuevos.

## 2. Oracle Cloud (el más enredado)

La cuenta de Oracle tiene fama de ser tediosa: piden tarjeta de crédito en el
registro (no la cobran; es para verificar identidad) y a veces demora horas o
días en aprobar. **Empieza este trámite primero.**

1. Entra a <https://www.oracle.com/cloud/free/> y en **Start for free**:
   - País, correo, nombre y contraseña.
2. Región: elige la más cercana a tu público (en Colombia suele ser
   **São Paulo (sa-saopaulo-1)** o **Ashburn (us-ashburn-1)**). Verás por qué
   en el capítulo 03: la región es difícil de cambiar después.
3. Datos de la tarjeta (crédito o débito). Oracle hace un cargo temporal que
   se devuelve solo; si prefiere, puedes usar una tarjeta virtual.
4. Espera el correo de aprobación. Puede ser **inmediato o de 1 a 3 días**.

> ⚠️ **No pagues nada.** Todo lo que sigue usa recursos etiquetados
> *Always Free*, que son gratis de por vida mientras exista la cuenta. Si en
> algún paso ves un precio, estás a punto de crear algo que **no** es gratis:
> revisa antes de darle a Create.

> ⚠️ Oracle reduce y cambia sus límites gratis sin avisar. En junio de 2026,
> por ejemplo, bajó las máquinas ARM de 4/24 a **2 OCPU / 12 GB**. Los valores
> de este capítulo están verificados en octubre de 2026, pero en el paso 03
> confirma siempre los números que te muestra la consola.

## 3. DuckDNS

1. Entra a <https://www.duckdns.org> y haz login (con Google, GitHub, Twitter...).
2. En **Domains** escribe el subdominio que quieres (ej. `mi-app`) y dale a
   **Add Domain**. Ya tienes `mi-app.duckdns.org`.
3. Anota el **token** que aparece arriba a la derecha: lo usaremos en el
   capítulo 06.

## 4. Cloudflare (opcional, capítulo 12)

Crea la cuenta en <https://dash.cloudflare.com/sign-up>. No hace falta agregar
nada todavía: Workers funciona con subdominios `*.workers.dev` sin dominio
propio (es lo que hace PlomApp).

## 5. Vercel (opcional, capítulo 11)

1. Entra a <https://vercel.com/signup> y usa tu cuenta de **GitHub** para
   registrarte (así después importa repos sin configurar remotos).

## Inventario personal (llénalo mientras avanzas)

> 🎯 **Tu turno** — copia esto a un bloc de notas y ve llenando:

```text
Región de Oracle elegida:        ________________________
Nombre del usuario en el VPS:    ubuntu (por defecto)
Subdominio DuckDNS:              ____________________.duckdns.org
Token DuckDNS:                   ________________________
Repositorio GitHub del backend:  github.com/________________________
Repositorio GitHub del frontend: github.com/________________________
```

> ⚠️ **Si te atascas:** el paso más común de fallar es Oracle pidiendo "más
> verificación" (selfie, documento o espera larga). Es normal; responde desde
> el correo que te mandan y sigue esperando. El resto de las cuentas son
> inmediatas.

**Siguiente:** [02 — Crear la cuenta de Oracle sin sustos](02-cuenta-oracle.md)
