# Corpus — menú interactivo · mock v2 (paquete de entrega)

Fecha: 2026-08-24. Reemplaza a `corpus/docs/mockups/corpus_interact_menu_mock_v1.html`.

**Regla de la casa:** el mock manda hasta que exista el código; en divergencia manda el código.
Este paquete es la especificación visual: alguien lee el HTML y escribe Lua contra él.

---

## Qué hay acá y dónde va en el repo

| Archivo | Sugerencia de ruta |
|---|---|
| `corpus_interact_menu_mock_v2.html` | `corpus/docs/mockups/` |
| `screenshots/*.png` | `corpus/docs/mockups/screenshots/` |
| `icons/*.png` (48) | `materials/corpus/icons/` |
| `icons/_index.html`, `icons/_contact_sheet.png` | `corpus/docs/mockups/icons/` (referencia, no material) |

Los iconos se cargan con `Material("corpus/icons/<nombre>.png", "smooth")`.

---

## Cómo leer el HTML

Es un solo archivo, sin dependencias locales (sólo Google Fonts). Ábrelo y léelo: el comentario
del `<head>` repite todo esto.

- Cada escena del HUD es un `<div id="stage-*">` de **1280 px de ancho** y posición relativa. Todo
  lo de adentro está en px absolutos sobre ese sistema, así que **las medidas del dibujo son las
  medidas de la spec**.

      stage-interaction         rama interaction (por entidad apuntada)
      stage-self-interactions   rama self-interactions (por dominio)
      stage-command             rama command (dos objetivos: WHO / WHERE)
      stage-command-npc         command, segundo caso: apuntar a un miembro
      stage-branch-size         cuántos hijos aguanta una rama
      stage-squad-management    pantalla de administración de grupos (NPC + jugadores)
      ladder-lod / ladder-states   vocabulario: 3 niveles de LOD, 4 estados de acción

- **Idioma:** la UI del juego va en **inglés** (idioma por defecto de Corpus) y en **Roboto**. Las
  anotaciones van en **español** y en **IBM Plex**. Si está en IBM Plex, no está en pantalla.
- **Atributos que valen como contrato:**
  - `data-ghost` — dibujado pero inerte: el sistema que lo ejecutaría no existe todavía.
  - `data-anno` — marca de callout. Capa de anotación, no es HUD.
  - `data-world` — masa borrosa del fondo. Es contexto, no contenido.
- **Colores:** espejo de `T.PALETTES` en `corpus_cargo_theme.lua:52-83`. Viven en los dos bloques
  `[data-pal]` del `<style>`. **Ningún color está hardcodeado en el markup**: todo es `var(--*)`.
  Los botones de arriba conmutan las dos paletas runtime (`spawnmenu` / `olive`).
  Si un color cambia, el mock miente: no tocar.

---

## Secciones

| | |
|---|---|
| **A** | Vocabulario — tres niveles de LOD (punto · chip · nodo desplegado) |
| **B** | Vocabulario — cuatro estados de una acción (normal · cursor · gris · ausente) |
| **C** | Rama `interaction` — se organiza por la entidad apuntada |
| **D** | Rama `self-interactions` — se organiza por dominio |
| **E** | Rama `command` — dos objetivos (WHO / WHERE), columnas contextuales, cola de delay |
| **F** | `command`, segundo caso — apuntar a un miembro |
| **G** | Cuántos hijos aguanta una rama — **VOTADO 2026-08-24** |
| **H** | Pantalla de administración de grupos — NPC y jugadores |
| **I** | Motion — beats, duraciones, easings |
| **J** | Referencia — glifos y tabla de tokens |

---

## Estado de cada decisión

**Votado / especificado**

- **Umbrales de rama (G).** 1–6 arco · 7–12 columna · 13+ subcategorías obligatorias. El padre canta
  el total real y las subcategorías también. **Sin paginado:** la rueda corre la lista fila por fila.
  Cuántas filas se ven sale de un **cvar** (default 10) y no se toca desde el HUD. El 6 no es
  preferencia: sale de la geometría del chip (218 × 36 px alrededor de un punto).
- **Cuatro estados de acción (B).** Gris (`condition` dio `false`) ≠ ausente (fuera de rango o
  apagada por el admin, que no se dibuja). Confundirlos es confundir *no puedes ahora* con *no existe*.
- **`command` tiene dos objetivos.** WHO es la columna de escuadra (estado, no menú); WHERE es **lo
  que estás tocando** — punto del suelo, puerta o NPC — y la segunda columna **es función del tipo
  de objetivo**. Las siete de `ORDERS` no cambian nunca.
- **La puerta trae sus cinco** sólo si comunica dos lados navegables. Decorativa, tapiada o sin sala
  detrás no las trae; abierta o cerrada da igual.
- **`Delay` es un modificador, no una orden.** Con Delay armado cada orden se va a la cola, abajo de
  la columna WHO, con su propio objetivo; `Execute` las manda todas juntas.
- **Al NPC se lo asigna, al jugador se lo invita.** Y un jugador **no ejecuta órdenes: las recibe**
  como marcador y aviso — por eso su columna ORDER está vacía.
- **Cuatro grupos** (amarillo/rojo/azul/verde) porque son los cuatro colores señalizables de la
  paleta. El techo es del theme, no de la UI. Cada grupo lleva **letra además de color**: `olive` no
  declara `green` y ahí Blue y Green colisionan.

**Pendiente**

- `command` **no tiene sistema**: todo lo de esa rama está en fantasma. La escena dibuja el objetivo,
  no el alcance.
- `Breach charge` (hijo de `Deploy`): pendiente hasta saber para qué se usaría.
- `Chemlight`: viene de *Phantasmagoria*, en desarrollo.
- Binding para abrir la pantalla de administración: a definir.
- Munición finita de NPC HL2/VJ + rol *Ammo Bearer*: abierto para Cortex. Es lo que justificaría el
  `Ammo box`.

**Dependencia dura:** `Deploy` no existe sin **Corpus Cargo**. Sin inventario no hay nada que
desplegar, y la lista de hijos la arma el módulo que registra cada objeto, no el árbol.

---

## Iconos

48 PNG de **64 × 64, trazo blanco sobre transparente**. Blancos a propósito: el color lo pone el
runtime.

    surface.SetDrawColor(Theme.text)   -- o Theme.textDim para el estado gris
    surface.DrawTexturedRect(x, y, w, h)

El mismo archivo sirve en las dos paletas y en los tres estados. Salieron de los glifos del mock, así
que la forma es exactamente la que dibuja la spec. Son vectoriales de origen: si hace falta otro
tamaño, se re-exportan sin perder nitidez. `_index.html` los muestra tintados; `_contact_sheet.png`
es la hoja de contacto.

---

## Motion

La tabla de la **sección I** es la spec: beat, duración, easing, stagger y qué se mueve.

Dos reglas que no son números: **nada pasa de 260 ms** (el jugador tiene la tecla abajo esperando
para actuar, no mirando una animación) y **cada cosa entra o sale desde su ancla** — el punto del
mundo, el hub del jugador, el borde de la pantalla, el marcador de destino. El movimiento es lo que
hace legible que el criterio de anclaje cambió al pasar de rama.

Los fotogramas están en `screenshots/11..15-motion-*.png`. La simulación corre en el proyecto de
diseño (motor de animación en JS, con timeline y export a video); no está acá porque no es código
del juego.
