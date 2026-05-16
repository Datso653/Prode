# PRODE Solidario 2026 — Setup completo

Tres archivos:

- **`index.html`** — La página pública de inscripción (form de 3 pasos: datos → pago → comprobante).
- **`admin.html`** — Dashboard para que confirmes/rechaces inscripciones. **USO LOCAL ÚNICAMENTE.**
- **`schema.sql`** — Setup de la base de datos en Supabase.

---

## 1. Setup de Supabase (10 minutos)

1. Crear cuenta gratis en [supabase.com](https://supabase.com) y un proyecto nuevo.
2. Esperar a que aprovisione (1-2 min).
3. Abrir **SQL Editor** → **New query** → pegar todo `schema.sql` → **Run**.
   - Crea la tabla `inscripciones`
   - Crea el bucket `comprobantes` (privado)
   - Configura las policies de RLS

4. Ir a **Project Settings → API** y copiar:
   - `Project URL`
   - `anon public key` (la pública, va en `index.html`)
   - `service_role key` (la SECRETA, va en `admin.html` y solo localmente)

---

## 2. Configurar `index.html` (la página pública)

Abrir y reemplazar:

```js
const SUPABASE_URL = 'TU_PROJECT_URL_AQUI';
const SUPABASE_ANON_KEY = 'TU_ANON_KEY_AQUI';

const PAGO = {
  alias:   'prode.solidario.2026',       // ← TU alias
  cbu:     '0000003100000000000000',     // ← TU CBU
  titular: '[NOMBRE DEL ORGANIZADOR]',   // ← Nombre
  cuit:    'XX-XXXXXXXX-X'                // ← CUIT
};
```

La `anon key` **es pública por diseño**. Las policies de Supabase ya impiden que cualquiera lea datos sensibles.

---

## 3. Publicar `index.html`

Cualquier hosting estático sirve:

- **Vercel** / **Netlify**: arrastrás el archivo, listo.
- **GitHub Pages**: push y activá Pages.
- **Cloudflare Pages**: igual.

---

## 4. Usar `admin.html` (dashboard)

**⚠ IMPORTANTE: NO subir `admin.html` a internet.** Usa la `service_role` key
que tiene permisos totales sobre tu DB. Si alguien la consigue, te puede borrar todo.

Cómo usarlo:

1. Abrir `admin.html` directamente desde tu computadora (doble click, o `file://...`).
2. La primera vez te pide la URL del proyecto y la `service_role key`.
3. Las credenciales quedan guardadas **solo en tu navegador** (localStorage).
4. Cada vez que entra alguien nuevo lo ves en la lista.
5. Tocás **✓ Confirmar** una vez que verificás el comprobante.

### Flow de uso diario

1. Te avisás (mail/notif/refrescás) que hay inscripciones nuevas.
2. Abrís `admin.html` → filtrás "Pendientes".
3. Para cada una: **Ver** el comprobante → comparás contra tu home banking → **Confirmar** o **Rechazar**.
4. (Después, en la etapa 2 del proyecto, los confirmados reciben el link de carga de predicciones).

---

## 5. Próximas etapas (no incluidas todavía)

- **Pantalla de carga de predicciones** para los 72 partidos de fase de grupos, accesible solo con el ticket o un magic-link al email.
- **Tabla de posiciones** que se actualiza con resultados reales (cron + edge function).
- **Notificación automática al confirmar** (email o WhatsApp via API).
- **Integración Mercado Pago** si las inscripciones manuales se vuelven mucho trabajo.

---

## Cosas que tenés que editar antes de lanzar

- [ ] Alias, CBU, titular y CUIT en `index.html` (constante `PAGO`)
- [ ] Las credenciales de Supabase en `index.html`
- [ ] Subir `index.html` al hosting
- [ ] Probarlo vos primero (hacer una inscripción de prueba y borrarla desde Supabase)

Cualquier cosa que quieras sumar, me decís.
