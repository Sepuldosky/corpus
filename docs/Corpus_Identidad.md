# Corpus — Identidad Visual (Arquitectura)

> **Uso de este documento:** Referencia autocontenida para sesiones futuras de
> planificación (Claude Opus) e implementación (Claude Code). No se requiere el
> chat de diseño original.
>
> **Estado:** Bloque de diseño cerrado en sesión (Opus, con iteración sobre el
> glifo de Caliber) y ratificado por el autor. Documento **particular**, no una
> sección de `Corpus_Architecture.md` — gobierna los seis repos por igual y no es
> contenido técnico del framework.
>
> **Dependencia:** ninguna — es un artefacto de marca, no de código. No bloquea
> ni depende de ningún bloque de diseño en curso (Cargo Block 1, permisos de
> admin, Cortex).

---

## Índice

1. [Visión general](#1-visión-general)
2. [Marca madre — Corpus](#2-marca-madre--corpus)
3. [Familia de módulos](#3-familia-de-módulos)
4. [Paleta de acento](#4-paleta-de-acento)
5. [Niveles y formatos de archivo](#5-niveles-y-formatos-de-archivo)
6. [Regla de reducción](#6-regla-de-reducción)
7. [Tipografía del wordmark](#7-tipografía-del-wordmark)
8. [Ubicación de archivos por repo](#8-ubicación-de-archivos-por-repo)
9. [Embed en README (GitHub)](#9-embed-en-readme-github)
10. [Fronteras y pendientes declarados](#10-fronteras-y-pendientes-declarados)
11. [Estado del documento](#11-estado-del-documento)

---

## 1. Visión general

Identidad visual del ecosistema Corpus: una marca madre (el framework) y una
familia de cinco marcas de módulo que comparten contenedor y se diferencian por
glifo y color de acento. Inspirada en el lenguaje visual de ACE3/ARC9 (plano,
monocromo, angular, funcional) — **no** en sus marcas; ningún elemento de este
documento reproduce un emblema o wordmark existente.

Regla de fondo que ordena todo el sistema: **la coherencia de familia es el
activo**, no cada logo por separado. Seis estéticas distintas contarían la
historia contraria a lo que Corpus es (un framework que aloja un ecosistema
coherente, no seis addons sueltos). Por eso el contenedor, el grosor de trazo y
la tipografía son fijos; el glifo y el acento son lo único que cambia entre
módulos.

Naming note que condiciona el diseño: los cinco módulos empiezan con **C** (dos
con "Ca"), así que las iniciales no diferencian nada — el glifo es obligatorio,
no un adorno opcional.

---

## 2. Marca madre — Corpus

**Concepto:** **Hombre de Vitruvio** — figura humana en línea, inscrita
simultáneamente en un círculo y un cuadrado, con marcas de retícula en los cuatro
puntos cardinales del círculo.

- **Círculo y cuadrado:** el par canónico de Vitruvio. El círculo es el
  contenedor —el framework que aloja el ecosistema— y comparte lenguaje con la
  **C** abierta de los módulos (§3): misma familia, un anillo cerrado en la marca
  madre, abierto en cada módulo. El cuadrado inscrito aporta el registro de
  **medición**, no de adorno.
- **Retícula:** cuatro marcas cortas (N/S/E/W) sobre el círculo, más finas que el
  trazo del círculo. Referencia al lenguaje de mira/calibración de ARC9 —
  reinterpretado como marco de medición, no como mira de arma. Es el único
  elemento que sobrevive literal desde el primer boceto de la marca madre, y el
  que ancla la lectura "instrumento" del conjunto.
- **Figura:** Vitruvio de línea fina, con las dos posiciones de brazos y de
  piernas. Dice lo que decían los divisores de torso del boceto anterior, pero
  mejor: Corpus aloja un ecosistema que trata el **cuerpo por partes** —armadura
  zonal, heridas por zona, HP por extremidad— y el canon de proporciones es
  exactamente esa idea. La segmentación pasa de dibujarse a estar implícita en el
  canon.
- **Monocromo.** Sin color de acento — el color es propiedad de los módulos, no
  del framework que los aloja.
- **Wordmark:** `CORPUS` con tagline `FRAMEWORK` y subrayado neutro; versalitas,
  tracking amplio. Tipografía provisional, ver §7.

Los maestros son `1024×1024` (logo) y `1024×1280` (lockup), vectores del autor
hechos en Affinity Designer. La geometría exacta vive en el SVG y **manda sobre
este texto** — misma regla que §3.

> **Enmienda 2026-07-25 (Vitruvio, ratificada por el autor):** la marca madre
> pasa de la **figura humana segmentada** del boceto original —silueta simple con
> dos divisores de torso, viewBox 160×160, torso `17×30`— al Hombre de Vitruvio
> descrito arriba. Decisión del autor: la figura refinada dice lo mismo con más
> oficio. Se conserva la retícula cardinal; se pierden los divisores explícitos,
> cuya carga semántica absorbe el canon de proporciones. La geometría del boceto
> (anillo `r=58`, cabeza `r=7.5` en `(0,-34)`, brazos `6×24`, divisores en
> `y=-13`/`y=-3`) queda **muerta** — no describe ningún archivo vigente.
>
> Contrapartida declarada, no descubierta: el Vitruvio es el glifo con más línea
> fina del set y no reduce bien (a 24px empasta, a 220px sobre fondo oscuro se lee
> tenue). El autor la asume y deja una **versión simplificada de la marca madre**
> como trabajo posterior — ver §6 y §10.

---

## 3. Familia de módulos

Contenedor compartido: una **C abierta** (arco de círculo, apertura de ~70° hacia
la derecha) — mismo trazo que el anillo de la marca madre, mismo radio relativo
en los cinco módulos. El glifo de cada módulo vive centrado dentro de esa C, en
el color de acento del módulo (§4).

| Módulo | Glifo | Justificación |
|---|---|---|
| **Caliber** | Escudo con corte zonal (una línea horizontal + una vertical dividiéndolo en cuartos) | Cubre las dos capas de protección del módulo (placas + escudos de energía) en un solo glifo, y el cuarteado lo emparenta visualmente con las líneas de división de la marca madre — el único glifo de la familia con ese parentesco directo, lo cual tiene sentido siendo Caliber el módulo fundacional (ex-ADS). |
| **Cortex** | Cerebro estilizado (contorno + surco central + dos pliegues) | IA/comportamiento — lectura directa, sin ambigüedad. |
| **Coagulant** | Gota con cruz médica inscrita | Médico de jugador — gota por sangrado/vitales, cruz por tratamiento. |
| **Craving** | Estómago estilizado (tubo + bolsa) | Supervivencia/hambre — el único glifo sin acompañamiento geométrico adicional, se sostiene solo. |
| **Cargo** | Grilla 2×2 con una celda ocupada | El grid *es* el significante EFT/STALKER; un glifo anatómico no comunicaría inventario. Única excepción al criterio anatómico del set, deliberada. |

Geometría de referencia (viewBox 100×100, contenedor C con radio 32, origen del
grupo en `(50,50)`): ver los archivos maestro en §8, que ya contienen las rutas
exactas para los cinco glifos. No se documentan aquí para no duplicar la fuente
de verdad — el código (SVG) manda si hay divergencia futura.

---

## 4. Paleta de acento

| Módulo | Hex | Nota |
|---|---|---|
| Caliber | `#d97706` (ámbar) | — |
| Cortex | `#7c3aed` (violeta) | — |
| Coagulant | `#dc2626` (rojo) | **Propiedad exclusiva de Coagulant.** Ningún otro módulo usa rojo, aunque Caliber sea el módulo de daño — evita colisión semántica con sangrado/vitales cuando ambos íconos conviven en la misma UI. |
| Craving | `#16a34a` (verde) | — |
| Cargo | `#a16207` (oliva) | — |

Neutros del trazo (contenedor, figura, retícula):

| Variante | Hex | Uso |
|---|---|---|
| Ink (light) | `#21262c` | Trazo sobre fondo claro |
| Bone (dark) | `#e6e1d3` | Trazo sobre fondo oscuro |

**Estado:** valores v1, calibrables cuando los glifos aterricen en el UI shell
real de Corpus (misma disciplina que el resto del proyecto — la spec declara, el
juego confirma). El acento no cambia entre variantes light/dark; solo el neutro
del trazo del contenedor cambia.

---

## 5. Niveles y formatos de archivo

Dos niveles por marca, ambos derivados del mismo maestro SVG:

1. **Lockup completo** — glifo + wordmark, para portadas de documentos y
   workshop de Steam (512² o el tamaño que pida la superficie). Pendiente de
   tipografía final (§7); hasta entonces, el glifo solo + texto en Markdown
   normal cubre el caso de uso sin bloquear nada.
2. **Glifo pelado** — sin texto, para tabs del UI shell de Corpus (16–24px) y
   cualquier superficie chica. Es el nivel ya resuelto y entregado en esta
   sesión.

Cada marca existe en dos variantes de color, no dos archivos de escala distinta:

- `*_light.svg` — trazo ink, para fondos claros (README en tema claro, docs).
- `*_dark.svg` — trazo bone, para fondos oscuros (README en tema oscuro, UI
  shell in-game).

Formato maestro: **SVG**, fondo transparente. Para el consumidor GMod (tabs del
UI shell), exportar a PNG desde el mismo maestro cuando ese bloque de
implementación llegue — mismo principio que ya usa el pipeline de íconos de
Cargo (PNG directo, sin conversión a VTF).

---

## 6. Regla de reducción

A tamaño de tab (16–24px), el detalle interno de un glifo puede empastarse antes
que el contenedor. Regla general: si un glifo pierde legibilidad a 16px, se
simplifica **preservando el trazo más distintivo**, no todos.

Caso ya resuelto — **Caliber a 16px:** escudo + solo la línea horizontal (una
zona arriba, una abajo), se omite la línea vertical. Sigue leyendo "segmentado"
con la mitad de tinta.

Caso **comprometido, sin resolver — la marca madre:** el Vitruvio (§2) es el
glifo con más línea fina del set y el que peor reduce. El render de contacto del
2026-07-25 lo confirma: a 24px es una mancha y a 220px sobre fondo oscuro se lee
tenue, mientras los cinco módulos aguantan. El autor ratificó el Vitruvio para el
nivel 1 (lockup, portadas, README) **asumiendo** que hace falta una **versión
simplificada aparte** para el nivel 2 (glifo pelado, tabs de 16–24px). Esa
versión es trabajo posterior, no una enmienda a la marca: conviven, como conviven
el escudo cuarteado de Caliber y su reducción.

El resto de los glifos (cerebro, gota, estómago, grid, trébol) no tienen
reducción declarada todavía — se define si el gate de verificación en juego
(mismo principio que el resto de assets visuales del proyecto: no se asume, se
verifica) muestra empaste real a 16–24px.

---

## 7. Tipografía del wordmark

**Provisional: Rajdhani SemiBold (OFL).** Los lockups generados el 2026-07-13
vectorizan el wordmark a paths con Rajdhani SemiBold como cierre provisional —
intercambiable re-ejecutando la composición con otro TTF si el autor decide
otra fuente. La decisión estética final sigue siendo del autor.

Motivo técnico, no solo estético: GitHub renderiza SVG embebido en README sin
cargar fuentes externas, así que un `<text>` con `font-family` personalizada cae
al fallback del visor. La única forma de garantizar el wordmark en todas partes
(README, workshop, docs) es **convertir el texto a paths** una vez elegida la
fuente — trabajo mecánico de una sola pasada, no bloquea nada mientras tanto.

Dirección sugerida (no cerrada): sans geométrica condensada, caps, tracking
amplio — familia visual "mil-tech" coherente con ACE3/ARC9. Candidatas con
licencia OFL (uso libre en un asset público de Workshop): Rajdhani, Saira
Condensed, Orbitron para un registro más futurista. Decisión estética del autor,
no de arquitectura — no se cierra en este documento.

Mientras tanto: README y docs usan el glifo (§5, nivel 2) + el nombre en texto
Markdown normal junto al logo, no dentro del SVG.

---

## 8. Ubicación de archivos por repo

Cada marca aporta **4 archivos**: `_logo_` (glifo pelado, 1024×1024) y `_lockup_`
(glifo + wordmark, 1024×1280), cada uno en `_light` y `_dark`.

```
corpus/assets/                     28 archivos  ← 7 marcas × 4
  corpus_logo_light/dark.svg       corpus_lockup_light/dark.svg
  caliber_*    cortex_*    coagulant_*    craving_*    cargo_*     (copia)
  stalker_*                                                       (copia)

corpus-caliber/assets/             4 archivos   caliber_logo_*   caliber_lockup_*
corpus-cortex/assets/              4 archivos   cortex_*
corpus-coagulant/assets/           4 archivos   coagulant_*
corpus-craving/assets/             4 archivos   craving_*
corpus-cargo/assets/               4 archivos   cargo_*
corpus-stalker/assets/             4 archivos   stalker_*
```

`assets/` **sí se versiona**, y no colisiona con el régimen COR-17 / STK-2 de
"assets no versionados": ese régimen cubre los *ports* de GAMMA/STALKER
(`sound/`, `models/`, `materials/`, …), propiedad de terceros. Estos SVG son obra
propia del autor y quedan cubiertos por la licencia MIT del repo.

**Por qué `corpus/` duplica los cinco logos de módulo** en vez de enlazarlos vía
`raw.githubusercontent.com` a los repos hermanos: cada repo queda autocontenido
(precedente ya establecido para el resto del proyecto — sin dependencias
cruzadas entre repos salvo la dura de Corpus). Si un logo de módulo cambia, se
actualiza en su repo dueño y se re-copia a `corpus/assets/`; este documento es la
fuente de verdad de la geometría, no un symlink implícito.

---

## 9. Embed en README (GitHub)

El header de cada README lleva el **lockup** (nivel 1 de §5), no el glifo pelado:
el wordmark ya está vectorizado, así que el lockup se sostiene solo y no depende
de que GitHub cargue una fuente. Switch de tema vía `prefers-color-scheme`:

```html
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/<modulo>_lockup_dark.svg">
    <img src="assets/<modulo>_lockup_light.svg" width="200" alt="<Modulo>">
  </picture>
</p>
```

Anchos vigentes (los lockups son 4:5, así que el alto sale ×1.25):

| Superficie | Ancho |
|---|---|
| Lockup de módulo / addon (header de su README) | `200` |
| Lockup de Corpus (header de `corpus/`) | `220` |
| Glifo de módulo en la fila de familia de `corpus/` | `60` |
| Glifo del addon en la fila de familia de `corpus/` | `52` — un escalón menor, la jerarquía se lee sola |

Para el README de `corpus/` (escaparate del ecosistema), debajo del lockup va una
fila de los cinco glifos de módulo enlazando a su repo, y debajo el glifo del
addon — **cada imagen envuelta en su propio `<a>`**, no un único SVG combinado: un
logo embebido vía `<img>`/`<picture>` se aplana a imagen estática y cualquier link
interno del SVG deja de ser clickeable.

```html
<p align="center">
  <a href="https://github.com/Sepuldosky/corpus-caliber"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/caliber_logo_dark.svg"><img src="assets/caliber_logo_light.svg" width="60" alt="Caliber"></picture></a>
  &nbsp;&nbsp;&nbsp;
  ... (uno por módulo, en el orden de la tabla del ecosistema)
</p>
```

Dos detalles que la primera redacción daba por buenos y el render desmintió:

- **La fila también lleva `<picture>` por glifo.** La versión anterior la dejaba
  fija en modo claro "para no inflar el markup", pero el trazo ink `#21262c` sobre
  el fondo oscuro de GitHub (`#0d1117`) queda casi invisible — y el tema oscuro es
  el que ve la mayoría. Markup verboso vale menos que una fila que no se ve.
- **Separadores explícitos.** Los saltos de línea entre `<a>` colapsan a un solo
  espacio y los glifos quedan pegados; hacen falta `&nbsp;` entre ellos.

---

## 10. Fronteras y pendientes declarados

| Pendiente | Nota |
|---|---|
| Tipografía del wordmark (§7) | Rajdhani SemiBold **provisional**, ya vectorizada en los 7 lockups. Cambiarla es re-generar los lockups, no re-dibujar glifos |
| ~~Lockup completo (glifo + wordmark vectorizado)~~ | **Cerrado 2026-07-13** — los 7 lockups existen y están en los READMEs |
| Reducción a 16px de Cortex/Coagulant/Craving/Cargo | Se define si el gate en juego muestra empaste (§6). El render de contacto a 16px empasta **todo el set**, marca madre incluida |
| Versión simplificada de la marca madre | **Comprometida por el autor (2026-07-25), sin fecha.** El Vitruvio se queda para el nivel 1; el nivel 2 (tabs 16–24px) pide un glifo aparte con menos línea. Ver §6 |
| Colisión ámbar Caliber `#d97706` / Stalker `#d88b1b` | Declarada en la enmienda de Stalker (§11), sin resolver. En la fila de familia de `corpus/` los dos ámbar conviven y la diferencia es sutil |
| Calibración final de hex de acento contra el UI shell real | v1 declarado en §4, ajuste empírico pendiente |
| Exportación PNG para tabs del UI shell (GMod) | Espera implementación del UI shell — mismo pipeline que íconos de Cargo |

---

## 11. Estado del documento

Bloque de diseño cerrado en sesión (Opus, iteración sobre glifo de Caliber:
liso → zonal) y ratificado por el autor. Los doce archivos SVG maestro (marca
madre + cinco módulos × dos variantes) ya existen y son la fuente de verdad
geométrica — este documento describe y justifica, no redefine.

> **Enmienda 2026-07-13 (v2 — maestros de producción):** los maestros pasan a
> ser los vectores finales del autor (glifos de módulo generados en Recraft,
> marca madre en Affinity Designer), con QC aplicado: tintas de contenedor y
> acentos normalizados a la paleta §4 — el drift de generación se corrigió por
> swap de hex, geometría intocada. Se materializa el nivel 1 de §5: lockups
> `<modulo>_lockup_light/dark.svg` (icono + nombre + subrayado de acento;
> CORPUS lleva tagline FRAMEWORK y subrayado neutro). Wordmark vectorizado con
> Rajdhani SemiBold **provisional** (§7). Séptima marca "Stalker" recibida
> fuera de spec — tratamiento y ubicación pendientes de definición del autor.

> **Enmienda 2026-07-13 (definición de Stalker):** `Corpus_Stalker` queda
> definido por el autor como **addon de integración** — tercer nivel del
> sistema (framework → módulos → addons). Consume todos los módulos para
> portar funcionalidades de STALKER GAMMA a GMod. Identidad: mismo contenedor
> C de la familia (pertenece al ecosistema), glifo de trébol de radiación —
> registro funcional, no anatómico, misma excepción deliberada que la grilla
> de Cargo, coherente con que un addon no es un órgano del cuerpo. Acento
> ámbar `#D88B1B` **provisional**: colisión declarada con el ámbar de Caliber
> (`#d97706`), resolución pendiente del autor. Assets en
> `corpus-stalker/assets/`, condicional a la existencia del repo.

> **Enmienda 2026-07-25 (bajada a los repos + QC de variantes light):** el bloque
> deja de ser papel — los 28 archivos están en los siete repos y los siete READMEs
> llevan su lockup centrado. Cuatro cosas cambiaron respecto de lo escrito arriba:
>
> 1. **La marca madre es un Hombre de Vitruvio**, no la figura segmentada que
>    describía §2. Cambio ratificado por el autor —"más refinado"— y §2 quedó
>    reescrita en consecuencia; la geometría del boceto viejo está muerta. Con él
>    viene un compromiso declarado: una **versión simplificada** para tabs, porque
>    el Vitruvio no reduce (§6, §10).
> 2. **Las dos variantes light de la marca madre venían rotas y se regeneraron.**
>    `corpus_logo_light.svg` no declaraba `fill` en ninguno de sus 86 paths, así
>    que renderizaba en **negro puro `#000`** —no en ink `#21262c`— y era la única
>    marca del set fuera de la paleta §4. `corpus_lockup_light.svg` además traía el
>    dibujo como **PNG de 965px embebido en base64** (150 KB) en vez de vector: se
>    habría pixelado en cualquier superficie grande (Workshop 512², portadas). Las
>    dos se regeneraron **desde sus maestros dark por swap de neutro**
>    (bone `rgb(230,225,211)` → ink `rgb(33,38,44)`, muted `rgb(154,151,140)` →
>    `rgb(107,112,120)`): misma disciplina que el QC de la v2, **geometría
>    intocada** — ni una coordenada se tocó, los paths son literalmente los del
>    maestro dark. Verificado por render comparativo antes/después.
> 3. **Los READMEs llevan lockup, no glifo pelado**, y la fila de familia de
>    `corpus/` sí conmuta de tema. §9 reescrita con los anchos reales y el porqué.
> 4. **`corpus/assets/` incluye ahora también a Stalker** (§8), y la fila de
>    familia lo muestra un escalón más chico y separado de los cinco módulos: el
>    ecosistema se lee entero, la jerarquía framework → módulos → addon también.
>
> Verificación: render de contacto de las 28 piezas en fondo claro y oscuro, a
> 120/220px y a 64/32/24/16px, más preview de los siete headers de README en ambos
> temas. Las 26 referencias `assets/…` de los READMEs resuelven a un archivo real.

| Sección | Estado |
|---|---|
| Marca madre (§2), familia de módulos, paleta, niveles, ubicación de archivos, embed README | **Cerrado — este documento** |
| Versión simplificada de la marca madre para tabs | **Abierto** — comprometido por el autor el 2026-07-25, sin fecha (§6) |
| Tipografía del wordmark | **Abierto** — decisión estética pendiente del autor; Rajdhani SemiBold vectorizada como provisional |
| Reducción a 16px fuera de Caliber | **Abierto** — pendiente de gate en juego |
| Colisión de ámbar Caliber / Stalker | **Abierto** — pendiente del autor |
