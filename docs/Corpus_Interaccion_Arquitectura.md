# Corpus — Arquitectura del menú interactivo

> **Uso de este documento:** subsistema del **framework**, no de un módulo. Describe el registro de
> acciones contextuales al estilo del menú interactivo de ACE3 (Arma 3) y las **tres ramas** que lo
> dibujan. No se requiere el chat de diseño original para entenderlo.
>
> **Estado:** **diseño CERRADO.** Todas las decisiones están votadas y **la arquitectura del mock v2
> ya está plegada** acá — el mapa completo, con su fecha, está en **§11**. **El código no existe todavía**, y el primer parche que
> lo escriba arrastra tres cosas que §11 enumera. Este documento **no acuña
> ninguna norma `COR-nn` todavía**, a propósito: **FLU-30** manda que una norma nueva entre al registro
> *en el mismo parche*, y acuñar invariantes de framework para código inexistente sólo inflaría
> el conteo de `INTENCION`, que `ids.yaml` lleva como métrica de salud. Las normas se acuñan cuando se
> escriba el primer archivo.
>
> **Spec de referencia:** el menú interactivo de **ACE3**. ⚠ **La descripción de ACE3 que gobierna
> este diseño NO es una medición**: salió de una consulta a Claude Desktop el 2026-08-23, no de leer
> el mod. Sirve como referencia de forma y **no** como especificación. Todo detalle de ACE3 que vaya a
> decidir código se verifica contra el propio ACE3 o se le pregunta al autor, que lo usó — es CRG-24
> aplicado a un tercero que ni siquiera es de GMod.
>
> **Origen:** propuesto por el autor el 2026-08-23. La semilla con su pedido textual y el cruce contra
> el árbol vive en `dev/HANDOFF_menu_interactivo.md` (fuera de git).
>
> **Mock visual — v2, y es la que manda:**
> [`docs/mockups/corpus_interact_menu_mock_v2.html`](mockups/corpus_interact_menu_mock_v2.html), con su
> compañero [`corpus_interact_menu_v2_README.md`](mockups/corpus_interact_menu_v2_README.md),
> **15 fotocapturas** en `mockups/screenshots/` y **48 íconos** en `materials/corpus/icons/`.
> Cubre las **tres ramas**, la pantalla de administración de grupos, los tres niveles de LOD, los
> cuatro estados de acción y la tabla de motion. Sus escenas son `<div>` de **1280 px con todo en px
> absolutos**, así que **las medidas del dibujo son las medidas de la spec**.
>
> **Misma regla que el wheel de Cargo: el mock manda hasta que exista el código; en divergencia manda
> el código.** Sus colores son **espejo de `T.PALETTES`** (`corpus_cargo_theme.lua:52-83`).
>
> ✅ **Su arquitectura está PLEGADA en este documento** (§6, §6.bis, §8.bis, §8.ter; el mapa está en §11).
> Lo que sigue viviendo sólo en el paquete son **las medidas** y **la tabla de motion**.
>
> La **v1** ([`corpus_interact_menu_mock_v1.html`](mockups/corpus_interact_menu_mock_v1.html)) se
> conserva como registro: mostraba dos ramas y tenía elementos superpuestos.

---

## Índice

1. [Visión general](#1-visión-general)
2. [Dónde vive: la séptima primitiva](#2-dónde-vive-la-séptima-primitiva)
3. [El registro — la API](#3-el-registro--la-api)
4. [Realms: qué se registra dónde y qué corre dónde](#4-realms-qué-se-registra-dónde-y-qué-corre-dónde)
5. [Las TRES ramas de primer nivel](#5-las-tres-ramas-de-primer-nivel)
6. [La entrada: hold, cursor y commit](#6-la-entrada-hold-cursor-y-commit)
7. [Las perillas de admin](#7-las-perillas-de-admin)
8. [El catálogo de acciones pedidas](#8-el-catálogo-de-acciones-pedidas)
6.bis. [Cuántos hijos aguanta una rama](#6bis-cuántos-hijos-aguanta-una-rama--votado-2026-08-24)
8.bis. [El catálogo de órdenes de `command`](#8bis-el-catálogo-de-órdenes-de-command)
8.ter. [La pantalla de administración de grupos](#8ter-la-pantalla-de-administración-de-grupos--y-no-es-parte-del-menú)
9. [Lo que este bloque NO resuelve](#9-lo-que-este-bloque-no-resuelve)
10. [Verificación](#10-verificación)
11. [Estado del documento](#11-estado-del-documento)

---

## 1. Visión general

Apuntas a algo, mantienes una tecla, se abre un árbol de acciones **sobre eso**, y eliges una con el
mouse. Es el gesto del menú interactivo de ACE3.

**Las dos propiedades que el autor puso por delante de todo lo demás**, textuales, y que gobiernan
cada decisión de abajo:

1. **Expandible por diseño.** *«Siempre podemos expandir el menú interactivo, esa es la idea, que
   puedas hacer funcionalidades con él»*. O sea: un **registro** al que cualquier módulo cuelga
   acciones. **No una lista de casos.**
2. **Apagable por un admin, con una convar general del servidor.** *«Estas funciones deben ser
   desactivables por un admin con un cvar general para el servidor»*.

Las dos son la misma propiedad vista de los dos lados: **el conjunto de acciones es ABIERTO**. Todo lo
que sigue se deriva de ahí, y cada vez que una decisión tuvo dos salidas ganó la que sobrevive a que
un addon registre una acción mañana.

### Lo que este bloque NO es

**No es un lanzador de binds.** Se midió el mod que el autor propuso reciclar —**Arctic's Radial
Binds**, `2391301431`, desempacado y leído entero el 2026-08-23 en `dev/other/arctic radial binds/`—
y resultó ser exactamente eso: tres listas planas de comandos de consola que el jugador **tipea a
mano** en un `DTextEntry`, sin registro, sin API, sin entidad objetivo y **sin una sola línea de
server**. No se recicla. Lo único que aportó está en §6, y es una técnica de cursor que sirvió para
**descartarla con motivo** en vez de por costumbre. El detalle vive en `dev/mods_workshop_mapa.md` §2.

---

## 2. Dónde vive: la séptima primitiva

**Votado por el autor el 2026-08-23: el registro sube a `corpus/`; las acciones se quedan en cada
módulo.** Sede propuesta: `corpus/lua/autorun/corpus_interact.lua`, junto a las otras seis.

Esto toca un invariante, así que se justifica explícito. `CORPUS_Architecture.md` §3 abre diciendo
**«Seis primitivas. Nada de lógica de dominio.»** Pasar a siete no es un detalle de conteo.

**Por qué pasa el filtro de COR-10** (*«solo sube infraestructura demostrablemente compartida; ni
siquiera una pieza de dominio compartida por dos módulos sube»*): porque lo que sube **no es una
acción**, es el protocolo por el que se registran acciones. Cargo, Coagulant y Glide cuelgan las
suyas; el framework no sabe qué hace ninguna.

**El precedente es COR-12, y es exacto.** Su propia nota en `ids.yaml` explica por qué una norma de
ítems vive en el framework:

> *«porque NO gobierna ítems — gobierna el **PROTOCOLO DE REGISTRO** entre módulos, del linaje de
> COR-3 y COR-4. Enuncia la FORMA del contrato, jamás la SEMÁNTICA del ítem: si algún día menciona
> stacks, peso o slots, bajó dominio al framework y el voto se reabre.»*

Ese voto ya lo dio el autor el 2026-07-20 (deuda D-14, cerrada). Este registro es el mismo caso una
capa más arriba, y hereda su **criterio falsable**:

> ⭐ **CRITERIO DE REAPERTURA.** Si la API de `Corpus.Interact` llega a mencionar un ítem, un peso,
> una herida, un vehículo, un contenedor o cualquier otro sustantivo de dominio, **bajó dominio al
> framework y este voto se reabre**. El framework transporta `id`, `label`, `condition`, `range` y
> `run`; qué significan es asunto del módulo que los registró.

Los tres precedentes vivos con esta forma exacta, que además dan el estilo de firma:
`StatusPanel.RegisterBar`, `Wheel.RegisterLightSource` y `Capture.RegisterWorldPickup`.

---

## 3. El registro — la API

```lua
-- Corpus.Interact.Register(module, spec) -> spec | nil
--
-- module: el nombre del módulo dueño, como en el resto de las primitivas.
-- Devuelve el spec normalizado, o nil si fue rechazado (y entonces lo dice por
-- Corpus.Log; una ausencia silenciosa se lee como "el menú no funciona").
```

| Campo | Tipo | Obligatorio | Qué es |
|---|---|---|---|
| `id` | string | sí | Único en todo el ecosistema. **Tiene que ser tipeable en consola** (`[%w_]`): pasa a ser parte de un nombre de convar — ver §7 |
| `label` | string | sí | Texto de cara al jugador ⇒ **en inglés** (CRG-48) |
| `tree` | `"interaction"` \| `"self"` \| `"command"` | sí | Cuál de las **tres ramas** de §5 |
| `parent` | string \| nil | no | `id` del nodo padre. `nil` = nodo raíz. Es lo que hace que el árbol sea un árbol |
| `order` | number | no | Orden entre hermanos. Default 100, como `RegisterCategory` |
| `icon` | string \| nil | no | Ruta de material. `nil` = sólo etiqueta |
| `category` | string \| nil | no | Subcategoría, **para ramas de 13+ hijos** (§6.bis). Ausente ⇒ el árbol reparte alfabéticamente en tandas. **Lo que nunca hace es dibujar 34 en arco** |
| `condition` | function \| nil | no | `condition(ply, ent) -> bool`. Ausente = siempre visible. **Se evalúa en vivo, en los dos realms** |
| `range` | number \| nil | no | Distancia máxima en unidades. Sólo tiene sentido en `tree = "interaction"` |
| `run` | function | sí | `run(ply, ent)`. **La acción.** Se registra en los dos realms, **corre sólo en server** — ver §4 |

**Un nodo puede ser sólo estructura.** Un `run` que no hace nada y unos hijos colgando de su `id` es
un nodo de rama: así se arma «Médico» sin que «Médico» sea una acción.

### Tres decisiones de forma, y las tres tienen motivo escrito

**(a) El `parent` es un `id`, no una referencia.** Un módulo puede colgar de un nodo que todavía no se
registró — el orden de carga entre addons no está garantizado y COR-11 dice que todo salvo Corpus es
soft-dep. El árbol **se resuelve al abrirlo**, no al registrar. Un `parent` que nunca aparece deja al
nodo **huérfano y sin dibujar**, y eso **se dice por `Corpus.Log`**: un nodo que no aparece y no avisa
es indistinguible de un nodo cuya `condition` dio `false`.

**(b) `condition` y `range` son parte de la firma mínima, no un extra.** En ACE3 *«la misma camioneta
te muestra opciones distintas si el motor está encendido, si el estanque está vacío o si la rueda está
pinchada»*. Sin los dos campos el árbol no se puede armar en tiempo real, y el registro se degrada a
una lista estática — que es justo lo que la propiedad 1 del autor prohíbe.

**(c) Se registra por acción, no por proveedor.** La alternativa era que un módulo registrara un
*callback* que devolviera su rama entera al abrir el menú. Se descarta: con acciones sueltas, la
perilla de admin de §7 nace por acción sin que nadie mantenga una tabla, y **apagar un módulo apaga
sus acciones sin ninguna coordinación** — que es como ACE3 lo hace (si desactivas ACE Medical, su rama
deja de existir).

---

## 4. Realms: qué se registra dónde y qué corre dónde

**Esta sección es COR-12 aplicada una capa más arriba, y por eso no se vuelve a discutir: ya se pagó.**

> COR-12 — *«La def de ítem Y su onUse se registran en AMBOS realms (shared); el onUse solo CORRE en
> server.»* Su nota la llama **«la norma más cara del ecosistema»**, y son dos mitades pagadas por
> separado: una def solo-server no existe en el cliente y no se renderiza; y la UI exige
> `isfunction(def.onUse)` client-side para habilitar «Use», así que un `onUse` solo-server deja el
> ítem **visible pero inusable**.

El menú interactivo tiene exactamente esas dos mitades:

- **El spec se registra en los dos realms (shared).** El **cliente dibuja el árbol**: necesita `id`,
  `label`, `parent`, `order`, `icon`, `condition` y `range`, o no puede armar nada.
- **`run` se registra en los dos realms y corre sólo en server.** El cliente lee `isfunction(run)`
  para saber que el nodo es accionable y no una rama muerta — la misma prueba que la UI de Cargo ya
  hace sobre `onUse`.

### El commit, y las tres puertas del server

El cliente **no ejecuta nada**. Manda **un** mensaje de net nombrando
`(id de acción, entidad objetivo, component)` y el server, antes de correr `run`:

> El tercer campo, **`component`, va siempre `nil` hoy**: es el campo reservado que vota §5 para que el
> anclaje a geometría del modelo no obligue nunca a migrar el protocolo. Se escribe desde el primer
> día justamente porque agregarlo después es lo caro.

1. **Re-chequea la perilla** (la maestra y la de la acción — §7).
2. **Re-chequea `condition(ply, ent)`** con su propio estado.
3. **Re-chequea `range`** contra **las posiciones del server**, no las que dijo el cliente.

> ⚠ **Las comprobaciones del cliente evitan DIBUJAR de más; no autorizan nada.** Un cliente
> modificado puede mandar cualquier `id` con cualquier entidad. Las tres puertas de arriba son la
> autorización, y viven donde el jugador no llega.

---

## 5. Las TRES ramas de primer nivel

> **⚠ ENMENDADO 2026-08-24 por el autor.** Este documento decía **dos** árboles, copiando a ACE3. El
> autor votó **tres**, y la tercera —`command`— **no es una rama más: es de otra especie.** Lo de abajo
> ya está reescrito; lo que cambió y por qué está en §5.4.

| Rama | Sobre qué | Se organiza por | Estado |
|---|---|---|---|
| **`interaction`** | Lo **externo** que estás apuntando | La **ENTIDAD** apuntada | diseñada acá |
| **`self`** | **Uno mismo** | **DOMINIO** funcional | diseñada acá |
| **`command`** | **Tu escuadra**, actuando sobre un punto o una puerta | **La ORDEN** | ⚠ **front-end de un bloque de Cortex que NO EXISTE** — §5.4 |

### 5.1 `interaction` — tocar algo externo

Todo lo que toca otra cosa: las funciones de un Glide, examinar a otro jugador por Coagulant, pedirle
un trade, tomar props, examinar un prop en el suelo sin levantarlo, saquear un cadáver, abrir una
puerta del mapa.

**Que su criterio sea distinto al de `self` es la enseñanza, no un descuido.** En ACE3 el árbol de
entorno no tiene una categoría «vehículo»: cada componente es su propio nodo, y *para llegar a las
acciones de una rueda hay que apuntar esa rueda*. La excepción son las **personas**, donde vuelven las
categorías abstractas (Médico, arrastrar, cargar, revisar inventario).

### 5.2 `self` — sobre uno mismo

Cambiar la munición, el equipo, lo médico, y los **gestos**.

**Los gestos existen como assets.** `[GCAL] BOCW Gestures` (Workshop `3759136661`, en
`dev/other/[gcal] bocw gestures/`) registra **34 gestos**, cada uno con su concommand
`gcal_bocw_gesture_<nombre>`. Es **CLIENT-only** y abre con `if not GCAL then return end`: depende de la
base **«Garry's Mod Compliant Armature Layer»** (`3727245204`, desempacada 45/45 en
`dev/other/garry's mod compliant armature layer/`).

#### ⚠⚠ Pero un gesto de GCAL NO LO VE NADIE MÁS. Medido el 2026-08-24

La primera redacción de esta sección decía que *«la rama sólo tiene que tirar del cable»*. **Es falso, y
leer la base lo desmiente en tres puntos:**

1. **`GCAL:Play` está partida por realm.** La de **CLIENTE** (`gcal_core.lua:1377`, dentro del
   `if CLIENT then` de `:794`) reproduce **local y no toca la red**. La de **SERVER** (`:2841`) sí hace
   `net.Start("GCAL_Play")` + `Broadcast`.
2. **No hay camino cliente → server.** Los únicos `net.Start` del addon son los dos del bloque
   `if SERVER then`. El concommand del pack está registrado en el cliente ⇒ **su gesto muere ahí**.
3. **Y el net del server no dice DE QUIÉN es el gesto**: manda `name` y `trackID`, nada más. O sea que
   un broadcast hace que **cada cliente se lo reproduzca a SÍ MISMO** — es una primitiva de *«que todos
   toquen esta animación»*, no de *«el jugador X hizo un gesto»*.

**Y el remate:** `gcal_tpik.lua` son **521 líneas con CERO `net`, CERO NW vars** y una sola mención a
`LocalPlayer()`. GCAL es un sistema de **manos y viewmodel del jugador local** —tiene compat con
VManip, del mismo linaje— **no un sistema de emotes en tercera persona.**

> **Consecuencia de alcance:** el cable del concommand alcanza para que **tú** veas tu propio gesto.
> Para que **lo vean los demás**, la red la tendría que poner **Corpus**, y no es un cable: el
> `run(ply, ent)` de §4 corre en server y sabe **quién**, pero **la `Play` de cliente de GCAL le anima
> al jugador LOCAL**, así que dibujar el gesto de X en la pantalla de Y **es algo que GCAL no hace hoy**.
>
> ⚠ **Esto contradice lo que el autor observó en juego** (*«todos pueden ver en thirdperson»*), y el
> código es fuerte pero él tiene el juego. **Antes de escribir nada, se confirma con dos clientes.**
> Lo más probable, si el código manda, es que lo que vio sea **su propio** cuerpo en tercera persona.
>
> El propio autor de GCAL lo dice en su descripción de Workshop, y calza con lo medido:
> *«TPIK is in beta state since this is my first time doing TPIK anything and I'm not the best»*.

#### ⭐ Cómo se hace ver por los demás — dos rutas MEDIDAS, y ninguna necesita net propio

El contraste con **ARC9** contesta la pregunta, porque ARC9 **sí** se ve. Su TPIK entero son seis
líneas (`Arc9 Base/lua/arc9/client/cl_tpik.lua`):

```lua
hook.Add("PrePlayerDraw", "ARC9_TPIK", function(ply, flags)
    local wpn = ply:GetActiveWeapon()
    if !wpn.ARC9 then return end
    wpn:DoTPIK()
end)
```

`PrePlayerDraw` corre para **cada jugador que dibujas** y **no hay filtro de `LocalPlayer`**;
`DoTPIK` (`arc9_base/cl_tpik.lua:1137`) opera sobre `self:GetWM()`, el **world model**.

> ⭐ **EL PRINCIPIO, y es lo que hay que llevarse:** un efecto se ve en los demás si **se DERIVA de
> estado que ya está replicado**. ARC9 **no networkea nada del TPIK** — se cuelga del arma, que ya es
> una entidad replicada, así que cada cliente calcula la pose solo. **GCAL anima manos que no cuelgan
> de nada replicado**, y por eso no hay de dónde derivarlas en el cliente de al lado.

Las dos rutas que eso abre, en orden de costo:

1. **La del engine, y es la barata.** `ply:AddGestureSequence(seq)` / `ply:AddGesture(act)` en
   **server**: el engine replica la capa de gesto solo. Verificado en uso real en `dev/other/`
   —`drgbase/.../animations.lua:321` y `weapons.lua:481-491`, y el Terminator en `motion.lua:306-309`—
   así que no es API de memoria. **Anima el PLAYER MODEL, que es lo que ven los demás**, y no toca GCAL.
2. **La de ARC9, si hace falta la mano fina.** Poner el gesto en algo replicado (una NW var en el
   jugador) y dibujarlo desde `PrePlayerDraw` sobre **ese** jugador. Más caro y más control.

**Reparto que sale de esto:** GCAL se queda con **la primera persona** —tus manos, tu viewmodel, que es
lo que sabe hacer y hace bien— y **lo que ven los demás sale del engine**. No compiten: cubren mitades
distintas del mismo gesto.

#### ✅ VOTADO 2026-08-24 — la rama entrega el DISPARO, y ahí termina su alcance

**El autor cerró el asunto:** Corpus expone la funcionalidad de **hacer** el gesto; que la animación la
vean todos *«es cosa del autor de GCAL»*, y **su mod no se toca**.

Es la política que el ecosistema ya aplica a **Glide, ARC9 y VJ Base**, y por el mismo motivo: son mods
**vivos y bien hechos**, se consumen por su API y se sigue su upstream. **No es una restricción de
licencia** — es una decisión del proyecto.

**Lo que eso fija, y hay que respetarlo al escribir:**

- La acción de gesto es **un cable al concommand** de GCAL, y nada más. Diez líneas.
- **Ninguna de las dos rutas de arriba se implementa.** Quedan escritas porque el día que GCAL agregue
  la mitad de tercera persona —o el día que el autor cambie de opinión— el análisis ya está hecho y no
  hay que volver a medirlo.
- **Se cae la pasada con dos clientes**: ya no decide nada. Lo que el jugador vea de su propio gesto es
  todo lo que este bloque promete.
- ⚠ **Y por lo tanto no se promete de más en el texto de cara al jugador.** Una etiqueta que sugiera que
  el gesto es una señal *para otros* estaría mintiendo, y eso sí es asunto nuestro.

### 5.3 `command` — órdenes tácticas a la escuadra

Estilo **Ready or Not / SWAT 4**: el jugador hace de *Team Leader* y manda a sus NPCs. El catálogo
está en §8.bis.

### 5.4 ⚠⚠ Por qué `command` NO es una rama más

Las otras dos **exponen acciones que ya existen o son chicas**. `command` no expone nada: **la cosa que
tendría que ejecutar no está escrita.** Y tiene tres propiedades que ninguna otra rama tiene:

1. **Tiene DOS objetivos, no uno.** *Quién* actúa (la escuadra, o parte de ella) y *dónde* (un punto,
   una puerta, una habitación). ⚠ **El mensaje de net de §4 lleva `(id, entidad, component)` y no tiene
   dónde poner el primero.**
2. **Tiene ESTADO que sobrevive al menú.** El comando *delay* encadena acciones, y `stack` deja a la
   escuadra en una postura que dura. Eso es una **cola de órdenes por escuadra**, que el server guarda.
   Ninguna acción de las otras dos ramas guarda nada.
3. **Su lógica es dominio puro de IA**: formaciones, tomar una puerta, despejar una habitación,
   suprimir. **`COR-1` y `COR-10` la dejan afuera del framework sin discusión.**

> **⇒ El registro de §3 sirve como FRONT-END de `command`, y nada más. La escuadra vive en Cortex.**
> Eso **ya no es sólo una adjudicación de esta sección: es CTX-3**, con sede en
> `../../corpus-cortex/CLAUDE.md`. Hasta el 2026-08-24 la frontera estaba enunciada acá y **sin sede**,
> porque el repo que la recibe no tenía dónde acuñarla.

> ⚠ **Ese bloqueante existió y se pagó, y conviene dejarlo escrito porque es la clase de trampa que
> vuelve.** Mientras `corpus-cortex` no tuvo `CLAUDE.md`, `ids.yaml` declaraba su familia con
> `pendiente: true` y el checker **se ponía rojo el día que alguien acuñara la primera norma sin haber
> creado ese archivo**. Y no era teoría: la primera redacción de esta sección **citaba el ID literal como
> ejemplo** y `check-ids` la rechazó con `HUERFANO_DOC` ×2 — **el checker no distingue citar de acuñar**,
> y no debería. Por eso durante meses la familia se nombró en prosa y nunca por su token.
> **El repo se fundó el 2026-08-24**, la familia tiene sede y cinco entradas, y desde entonces citarla
> —como hace el párrafo de arriba— no dispara nada.

**Consecuencia de alcance, y hay que decirla:** `interaction` y `self` se pueden escribir ya.
**`command` no**, y el motivo cambió de forma: ya no es que Cortex no tenga dónde acuñar una norma —eso
se resolvió—, sino que **el escuadrón todavía no está diseñado**. Su rama puede nacer **vacía y
registrada** —para que el árbol tenga su tercer nodo y la forma quede probada— pero sus órdenes son un
bloque aparte, del tamaño del Workbench, y **es el bloque que Cortex abrió el 2026-08-24**
(→ `../../corpus-cortex/docs/cortex_roadmap.txt`).

### El anclaje — VOTADO 2026-08-24: entidad, descubrimiento por proximidad, campo reservado

**El nodo de la rama `interaction` se ancla a una ENTIDAD**, y los candidatos salen de una **consulta de
proximidad** acotada por `range`, **no de un trace**.

#### Por qué no es una renuncia: lo que quieres apuntar YA son entidades

La pregunta original era «entidad abstracta vs. geometría del modelo», con la geometría como la opción
fiel y cara. **Medido, esa disyuntiva estaba mal planteada**, porque casi todo lo que los doce bullets
quieren apuntar ya es una entidad separada:

| Objetivo | Clase |
|---|---|
| Props del suelo | `prop_physics` |
| Ítems botados / efectivo | `corpus_cargo_item`, `corpus_cargo_cash` |
| Cadáveres, jugadores | — |
| Puertas **del mapa** | `prop_door_rotating`, `func_door` |
| Asientos de Glide | `prop_vehicle_prisoner_pod` (`base_glide/init.lua:588`) |
| **Ruedas de Glide** | **`glide_wheel`, entidad real** (`base_glide/sv_wheels.lua:19`) |

La última es la que decide: **el ejemplo canónico de ACE3 —*«para llegar a las acciones de una rueda
hay que apuntar esa rueda»*— sale gratis con anclaje por entidad.** No hacía falta geometría para eso.

#### ⚠⚠ Y el obstáculo real no es la geometría: es el TRACE

**`glide_wheel` es `SOLID_NONE`** (`glide_wheel/init.lua:8`, verificado en la fuente del mod). **Un
`util.TraceLine` desde el ojo la atraviesa** y pega en el chasis.

> Si el árbol de entorno se construyera sobre `ply:GetEyeTrace().Entity`, las ruedas serían
> **inalcanzables para siempre**, y el síntoma se leería exactamente como *«no soporta geometría»*
> siendo otra cosa completamente. **El error mentiría sobre la causa.**

Por eso el descubrimiento es una **consulta de proximidad** (`ents.FindInSphere` acotada por el `range`
máximo de las acciones registradas, filtrada por distancia en pantalla al centro). Da tres cosas que
el trace no da:

1. Encuentra hijos `SOLID_NONE`, como las ruedas.
2. Devuelve **varios candidatos a la vez**, que es lo que hace que *se vea* como ACE3 — un trace
   devuelve uno solo.
3. Convierte «entidad hija» y «geometría del modelo» en **el mismo mecanismo** el día que haga falta
   la segunda.

#### El campo reservado, que es la parte barata

**El mensaje de net lleva un campo `component` opcional desde el primer día, y hoy va siempre `nil`.**
Cuesta un campo. El día que un nodo se ancle a un attachment o a un hueso del modelo, **el protocolo ya
lo aguanta y no hay migración**.

#### La geometría verdadera queda para cuando tenga un consumidor

Y hoy **no tiene ninguno**. El único caso que se invocaba para justificarla —los bullets 8 y 9,
maletero y puertas de un Glide— **no existe en Glide en ninguna forma**: sus 195 archivos Lua no tienen
entidad, bodygroup ni mecanismo de puerta, y las únicas tres menciones de `door`/`trunk`/`hood` son
**rutas de sonido** de la latch del lock más un chequeo de nombre de tool. No hay dónde poner el punto.

*La opción cara se justificaba con un caso que, medido, no existe.*

---

## 6. La entrada: hold, cursor y commit

**Votado por el autor el 2026-08-23: screen clicker + click izquierdo, como el wheel de Cargo.**

O sea `gui.EnableScreenClicker(true)` + `gui.MousePos()`, mantener la tecla para abrir, click izquierdo
para comitear, soltar sin elegir no hace nada.

### Por qué se votó eso, y qué se descartó

Hay **dos familias** de cursor y la elección **decide si el clic puede comitear**. Eso no era obvio
hasta que se leyó el mod de Arctic, y es lo único que ese mod aportó:

| | Cargo (elegida) | Arctic (descartada) |
|---|---|---|
| Técnica | `gui.EnableScreenClicker` + `gui.MousePos()` | `InputMouseApply` + `cmd:SetMouseX/Y(0)` y cursor virtual propio |
| Los clics | Los **traga** el clicker ⇒ **el arma no dispara** | Van al juego ⇒ **el arma dispara** |
| Comitear | **Click izquierdo** (el gesto de ACE3) | Obliga a una **segunda tecla** |
| Riesgo | El clicker es **estado GLOBAL** con otros consumidores | Inmune por construcción: no hay perilla global que otro toque |

Se eligió la de Cargo porque **el gesto de ACE3 es click**, y porque su riesgo conocido **ya está
pagado**: `corpus_cargo_wheel.lua:1315-1332` documenta que el `Deploy` de ARC9 llama a
`gui.EnableScreenClicker(false)` incondicionalmente, y que re-encenderlo **cada frame** lo
re-inicializa y hace parpadear el cursor. La cura es leer el estado antes de escribirlo
(`vgui.CursorVisible()`), y está medida en juego (planilla V, rondas 3 y 4).

> **La técnica de Arctic queda anotada como RESPALDO**, no descartada del todo: si algún día aparece
> un tercero nuevo que vuelva a apagar el clicker y el guard no alcance, está leída y descrita en
> `dev/HANDOFF_menu_interactivo.md` §1.

### Qué se reusa del wheel de Cargo, y qué no

El wheel (`corpus_cargo_wheel.lua`, 1492 líneas) **no sirve como está** —es de **un** nivel, sin árbol,
sin anclaje en mundo y sin rango por acción— pero **su infraestructura sí**, y está toda pagada en
juego:

- El **`pcall` de pintado** (CRG-25: un error en `HUDPaint` desengancha la superficie la sesión
  entera), con el reporte deduplicado por mensaje.
- El **`render.SetScissorRect`** (CRG-28).
- La **primitiva de círculo del theme** (CRG-26) y el teñido DGL4 (§15.5 de Cargo, roadmap #29), que
  es lo que hace que la UI vaya acorde a DGL4 sin texturas horneadas.
- El **cierre defensivo**: `gui.IsGameUIVisible()` y `ply:Alive()` cancelan sin comitear.

Lo que se estrena es el **árbol anidado** —desplegar un arco hacia afuera unido por una línea, y bajar
varios niveles sin soltar— y el **anclaje a la entidad apuntada**.

### El vocabulario visual — tres niveles de detalle y cuatro estados

*Plegado del mock v2, secciones A y B (2026-08-24).*

**Los tres niveles los elige la DISTANCIA, no el estado**, y **tienen que distinguirse de un vistazo**:
si el punto lejano y el cercano se ven igual, la decisión del LOD desaparece del dibujo.

| Nivel | Qué se dibuja |
|---|---|
| **LOD 0 · lejos** | **Punto pelado.** Hay algo interactuable y nada más: sin ícono, sin nombre y **sin ancho de etiqueta que reservar** |
| **LOD 1 · cerca** | **Chip con ícono y etiqueta.** Ya se sabe qué es. **La etiqueta se voltea al lado con espacio** en vez de salirse de pantalla — y la regla es *del lado libre, no del punto* |
| **LOD 2 · bajo el cursor** | El **padre queda anclado** y sus hijos salen en arco, unidos por línea. Se baja de nivel sin soltar la tecla. **El arco punteado es el RADIO DE LA RAMA**: marca hasta dónde llega antes de tener que recorrerla con la rueda (§6.bis) |

**Y los cuatro estados de una acción son tres causas distintas con tres consecuencias distintas:**

| Estado | Cómo se dibuja | Qué significa |
|---|---|---|
| **Normal** | relleno `panel`, borde `border` | se dibuja y se ejecuta |
| **Bajo el cursor** | relleno `cellHover`, borde `accent`, texto a **700** | es la que el click ejecuta |
| **Gris** | atenuado, **pero presente** | su `condition(ply, ent)` dio `false`. **Se dibuja y no se ejecuta: el jugador ve que existe** |
| **Ausente** | **no hay fila** | fuera de rango, o apagada por el admin. En pantalla **no hay nada** |

> ⭐ **NINGUNO DE LOS CUATRO SE DISTINGUE SÓLO POR COLOR.** Cada uno cambia además de **relleno, de
> borde o de presencia**. Es un invariante de legibilidad, no una preferencia — y sobrevive a que un
> operador tiña la UI con DGL4.

**Gris no es ausente**: *gris dice «no puedes ahora», ausente dice «no existe»*. Y hay un **quinto**
tratamiento que no es un estado de acción sino de sistema — ver `data-ghost` en §8.bis.

⚠ **El anillo punteado del `range` en el mock NO es un estado del HUD**: es el dibujo señalando algo
que el HUD **no dibuja**. El `range` es por acción y el server lo re-chequea al ejecutar (§4).

---

## 6.bis Cuántos hijos aguanta una rama — VOTADO 2026-08-24

*Plegado del mock v2, sección G. **Toca la API de §3**: sale de acá el campo `category`.*

> ⭐ **Sí hay un máximo, y es DEL ARCO, no del árbol.** Seis hijos es lo que cabe alrededor de un punto
> sin que las etiquetas se toquen. **Gestures con sus 34 no es un caso raro: es el caso que fija la
> regla.**

**Tres regímenes, y el nodo elige el suyo por la CUENTA DE HIJOS, no por quién sea:**

| Hijos | Régimen |
|---|---|
| **1–6** | **Arco alrededor del padre** |
| **7–12** | **Columna con espina, sin paginar.** Misma línea de padre y misma jerarquía; **sólo cambia la geometría**. La fila baja a 28 px de alto y 13 px de texto porque hay diez a la vez |
| **13+** | **Subcategorías obligatorias**, y cada una es una columna |

**De dónde sale el 6, y por qué importa que se sepa:** de la **geometría** — un chip de **218 × 36 px**
alrededor de un punto sin que dos etiquetas se toquen. **Si cambia el ancho del chip, cambia el techo.**
No es una preferencia y no se negocia por gusto.

### Las tres reglas que cuelgan de esto

**(a) El número ámbar cuenta HOJAS ALCANZABLES, no hijos directos.** En Gestures dice **34**, no los 4
hijos que se ven, **así que el jugador sabe si vale la pena entrar**. Las subcategorías cantan el suyo
igual.

**(b) Las subcategorías las declara el MÓDULO que registra la acción, con un campo `category`.**

> ⚠ **Esto agrega un campo a la firma de §3** — `category`, opcional, string. Y trae su propio
> fallback: **si el módulo no lo declara, el árbol reparte alfabéticamente en tandas.** *Lo que el árbol
> nunca hace es dibujar 34 en arco.*

**(c) SIN PAGINADO.** El scroll es **discreto, una fila por tick**, así que **el blanco no se mueve
mientras apuntas** y no hay una mecánica de páginas que aprender. **Cuántas filas se ven es
CONFIGURACIÓN y no HUD**: sale de un **cvar, default 10**, y **no se toca desde el menú**.

⚠ **El 10 no es un umbral**: los umbrales son **6 y 12**. El 10 es el default de una perilla.

---

## 7. Las perillas de admin

**Derivadas del roadmap #61 de Cargo**, no votadas a ciegas: su bloque de comentarios en
`corpus-cargo/lua/corpus_cargo/shared/corpus_cargo_items.lua:22-57` resolvió este problema exacto para
las categorías de ítem y transfiere casi línea por línea.

```lua
corpus_interact_enabled          -- maestra. 0 apaga el menú entero.
corpus_interact_<id>             -- una por acción, creada POR EL REGISTRO.
```

Las dos `FCVAR_ARCHIVE + FCVAR_REPLICATED`, default `1`.

**Las seis reglas que se heredan de la #61:**

1. **La perilla la crea el REGISTRO, no una lista.** El conjunto de acciones es abierto (propiedad 1
   del autor): una tabla escrita a mano cubre exactamente las acciones que existían el día que se
   escribió, y el hueco aparece **lejos y sin un solo error**.
2. **La composición vive en UNA sola función** — `Corpus.Interact.Enabled(id)`, del mismo linaje que
   `Trade.ValueMult`. Un segundo sitio que componga a mano es cómo un lector y un escritor se separan
   sin dar error.
3. **Se entrega el objeto ConVar, no el nombre.** `GetConVar` de un nombre inexistente devuelve `nil`,
   y un `nil` **se lee igual que «la perilla no aplica»**. Con el objeto, el string vive en un solo
   archivo.
4. **Un `id` que la consola no puede tipear no recibe perilla, y se dice en voz alta** por
   `Corpus.Log`. Una ausencia silenciosa se lee como «la perilla está rota».
5. **Re-registrar reusa el objeto ya construido.** Un `lua_refresh` no le puede borrar al operador el
   valor que puso.
6. **`REPLICATED` no es opcional.** El **cliente dibuja el árbol** y el server ejecuta: con una convar
   de sólo server, el cliente pinta una acción que el server va a rechazar. Es la misma falla que «la
   celda muestra un número y el `Confirm` cobra otro», una capa más arriba.

> ⚠⚠ **`REPLICATED` es INVISIBLE para un harness offline.** El stub de convars de `dev/harness_cargo.py`
> guarda **nombre y valor** y **no mira los flags**: sacar el `FCVAR_REPLICATED` deja **todos** los
> checks en verde y el defecto sale recién en juego. **Si esto se verifica, se verifica por
> COMPORTAMIENTO** — el valor puesto en el server tiene que leerse desde el cliente— **nunca leyendo el
> flag.**

---

## 8. El catálogo de acciones pedidas

Los doce bullets del pedido del autor, con **dueño** y **estado real medido**. La columna que importa
es la última: **seis de los doce no son features nuevas, son una PUERTA a algo que ya existe o que ya
está en el roadmap.**

| # | Acción | Dueño | Estado |
|---|---|---|---|
| 1 | Levantar ítems y **props** del suelo | Cargo | **Parcialmente abierto** — ver §9 |
| 2 | Recargar el arma y **vaciar el cargador** | Cargo | **Ya existe**: `cargo_unload` es concommand (`client/corpus_cargo_ui.lua:1664`) y el roadmap #26 está cerrado. El menú sólo lo **expone**. Cambiar de munición es lo único nuevo |
| 3 | Abrir el inventario sin la tecla I | Cargo | **Ya existe**: concommand `cargo_inventory` (`client/corpus_cargo_ui.lua:1659`). Es un cable |
| 4 | NVG y máscara de gas | Cargo | NVG **ya existe** (#47 cerrada, compat Neosun). Máscara de gas = **entrada #44, abierta**; su banco de sonidos ya está en disco |
| 5 | Examinar un ítem sin levantarlo, y **quitar el nombre flotante** | Cargo | **Acotado y medido**: `lua/entities/corpus_cargo_item.lua:183-194` dibuja la etiqueta con `cam.Start3D2D`, y la corta a 200 u (`:186`, `DistToSqr > 200*200`). ⚠ `corpus_cargo_cash` dibuja **la misma clase de etiqueta** y hay que decidir qué hace |
| 6 | Lootear un ragdoll | Cargo | Cruza la **#15** (loot on death, abierta). El primitivo **ya existe**: `Containers.Attach` (`server/corpus_cargo_containers.lua:124`), y CRG-21 dice que el cadáver es ese mismo primitivo |
| 7 | Tradear con otro jugador (request / accept / **cooldown**) | Cargo | Es el **slice 3** del comercio (`Cargo_Trade_Arquitectura.md` §6). ⚠ El request/accept/cooldown es **aporte nuevo del autor**: §6 describe la sesión y el doble confirm, **no cómo se ABRE** |
| 8 | Abrir el maletero de un Glide | Cargo + Glide | `Containers.Attach` sobre la **entidad del chasis** — Glide no tiene entidad de maletero, así que es **una acción sobre el vehículo**, no un punto sobre él. ⚠ Glide **no se forkea, se consume** |
| 9 | ~~Abrir/cerrar puertas de un Glide~~ → **el LOCK de Glide** | Glide | **Reescrito 2026-08-24, votado.** Medido: **Glide no tiene puertas** — ni entidad, ni bodygroup, ni mecanismo; las únicas menciones de `door` en sus 195 archivos Lua son **rutas de sonido**. Lo que sí existe es el **lock** (`isLocked`, con su latch sound en `base_glide/init.lua:409`), que es lo que de verdad gatea quién puede usar el vehículo. Se expone eso: una acción sobre el chasis, **sin assets nuevos y sin tocar Glide**. Las puertas animadas serían un bloque aparte, no una acción |
| 10 | Puertas del mapa, con generación de llave | Corpus / sin dueño | Nuevo. Mismo asset faltante que el 9 |
| 11 | Arrastrar a un inconsciente, subirlo a un vehículo o a la camilla | Coagulant | Nuevo. **La camilla no existe** (§9.3) |
| 12 | Abrir el menú de Coagulant de **otro** jugador | Coagulant | Nuevo. Es la forma ACE3 clásica, y cae en `interaction` sobre una persona |

**Ninguno de los doce es del framework.** Eso es la prueba de que §2 partió bien: si alguno lo fuera,
habría dominio subiendo a Corpus.

**Reparto por rama (§5):** los bullets **1 y 5-10** son `interaction`; los **2, 3, 4** y los gestos son
`self`; los **11 y 12** son `interaction` sobre una persona. **Ninguno de los doce es `command`** — esa
rama es enteramente nueva y va abajo.

---

## 8.bis El catálogo de órdenes de `command`

> **Fuente:** la guía de comandos de SWAT de *Ready or Not* que indicó el autor
> (`steamcommunity.com/sharedfiles/filedetails/?id=3494083514`), leída el 2026-08-24, **más** su propio
> pedido. ⚠ **La guía cubre las ÓRDENES pero NO la mecánica del menú**: no describe niveles, hold, ni
> cómo se apunta una orden. Todo lo de *forma* sale del pedido del autor y de la convención de SWAT 4,
> **no de la fuente** — misma regla que la advertencia de ACE3 en la cabecera.

### Órdenes base

| Orden | Qué hace la escuadra | Precondición |
|---|---|---|
| **Move To** | Se mueve a un punto y **asegura el área sola** | línea de visión al punto |
| **Fall In** | Reagrupa sobre el jugador, **con formación**: fila simple (pasillos), fila doble (espacios anchos), diamante (amenaza multiángulo), cuña (entrada frontal) | — |
| **Cover** | Fija la atención en un **ángulo** y aguanta la posición | línea de visión al área |
| **Hold** | Para todo; sólo se defiende | — |
| **Deploy** | Tira una granada o un dispositivo al punto apuntado | **equipo en el inventario** + línea de visión |
| **Search and Secure** | Restringe sospechosos, junta armas y revisa escondites | — |
| **Delay / Synced** | **Encadena** para que dos entradas ocurran a la vez | — |

### Órdenes de puerta

| Orden | Qué hace | Nota |
|---|---|---|
| **Stack Up** | Se alinea en la puerta: izquierda, derecha o partida; el primero revisa si está trabada | |
| **Scan** | **Slide** (rápido, pasa de largo) · **Pie** (lento, rebana la sala) · **Peek** (vistazo) | ⚠ **no disponible en stack partido** |
| **Breach** | **Open** (sin trabar, puede ser sigiloso) · **Kick** (trabada, puede costar varios intentos) · **Escopeta** (rápida, a distancia) · **Ariete** (abre entera y aturde a quien esté detrás) · **C2** (explosivo) | |
| **Wedge** | Traba una puerta para bloquear una sala sin despejar; **las cuñas se reusan** | |
| **Open / Close** | Abre o cierra a mano mientras el jugador mira a otro lado | |

### La combinación que el autor pidió, y lo que arrastra

**«Throw flashbang and clear»** (o *breach*). No es una orden: es una **secuencia**, y el autor ya
enumeró sus partes: el NPC **se mueve**, **tiene visión de dónde tirar**, tira, y **vuelve a su
posición original para no comerse el destello**.

⚠ **Tres dependencias reales, y ninguna está resuelta:**

1. **El NPC necesita inventario.** La flash sale de una granada **ARC9 / ARC9 EFT**, así que hace falta
   que un NPC pueda **tener** ítems de Cargo. Hoy no puede:
   `Inventory.OwnerKey` (`server/corpus_cargo_inventory.lua:101-104`) hace
   `ply:SteamID64() or ("bot" .. ply:EntIndex())`, y **`SteamID64` es un método de `Player`, no de
   `Entity`** — con un NPC **no cae en el `or`: revienta**. O sea que la puerta no está entornada, no
   existe, y abrirla es una decisión de Cargo (¿el dueño de un inventario deja de ser un jugador?), no
   un parche de una línea.
2. **El efecto de flash sobre NPCs es pobre** — el autor lo midió jugando: *quedan ciegos unos segundos
   solamente*. Habría que mejorarlo. Sede a leer: `dev/other/Arc9 EFT explosives/`.
3. **Volver a la posición original** implica que la orden guarda un punto de retorno, o sea otra vez
   **estado por escuadra** (§5.4, punto 2).

### La forma de la pantalla — plegada del mock v2, secciones E y F

**Los dos objetivos parten la pantalla, y ninguna mitad se puede leer sin la otra:**

- **WHO — la columna de escuadra, fija a la izquierda.** ⭐ **No es un menú: es ESTADO, y no se cierra
  al elegir.** `ALL` es el grupo amarillo; los demás van por color. Cada miembro lleva **tecla,
  callsign, rol, grupo, salud, distancia y la orden que está ejecutando**.
- **WHERE — el árbol de órdenes, colgado del marcador de destino en el mundo.** ⚠ **El WHERE no es una
  coordenada: es LO QUE ESTÁS TOCANDO** —un punto del suelo, una puerta o un NPC— **y el rótulo dice
  cuál de los tres.**

**Y la segunda columna es FUNCIÓN DEL TIPO DE OBJETIVO:**

| Objetivo | Qué agrega |
|---|---|
| **Puerta** | sus cinco de puerta — **sólo si comunica dos lados navegables.** Decorativa, tapiada o sin sala detrás no las trae; **abierta o cerrada da igual** |
| **NPC** | *Attack · Follow · Look at · Heal* |
| **Punto del suelo** | **ninguna.** El destino es la posición y nada más |

> **Las siete de `ORDERS` no cambian nunca.** Lo que varía es la segunda columna.

**La selección se lee sin mirar el panel:** **relleno = seleccionado, contorno = no**, y la cifra del
marcador **es la misma tecla de la columna**.

### `Delay` es un MODIFICADOR, no una orden

Con Delay armado, **cada orden que das se va a la cola en vez de ejecutarse**. Y ⭐ **la cola vive
DEBAJO DE LA COLUMNA WHO, porque es estado de la ESCUADRA y no del árbol.** `Execute` las manda todas
juntas: **es la única forma de que dos grupos entren al mismo tiempo.**

⚠ **Cada fila guarda su PROPIO objetivo**, así que el destino **se resuelve cuando diste la orden, no
cuando disparas**.

### `Deploy` es un OBJETO, no una acción

**Por terminología: se despliega *algo*, así que sus hijos son objetos y no verbos.** Y de ahí sale una
consecuencia de dueño: **la lista de hijos la arma el módulo que registra cada objeto, no el árbol** —
o sea que **`Deploy` no existe sin Corpus Cargo**: sin inventario no hay nada que sacar.

Estado de sus seis hijos: **las tres granadas existen** en ARC9 EFT · el **chemlight** viene de
Phantasmagoria y está en desarrollo · el **breach charge** queda pendiente hasta saber para qué se
usaría · y **`Cover` salió de acá**: ya está en `ORDERS` y **es una acción, no un objeto**.

> ⚠ **El `Ammo box` es el único de los seis que depende de una decisión de SIMULACIÓN y no de
> inventario**, y es **pregunta abierta para Cortex**: si los NPC de HL2 y VJ pasan a tener munición
> finita —y a depender de la tuya o de un **Ammo Bearer** del grupo— el `Ammo box` y una orden de
> reabastecer **se justifican solos**. Sin eso, no tiene para qué existir.

### El segundo caso: apuntar a un MIEMBRO

Con un NPC apuntado, **el mismo árbol resuelve sobre ese NPC**: gestión rápida del grupo y órdenes
individuales, **sin pasar por la columna**. Es el atajo; la administración completa vive en §8.ter.

**Y ahí aparece una frontera que vale la pena nombrar:**

- *Sacar, unir, designar, transferir* son **acciones sobre ese NPC** ⇒ resuelven **por anclaje**, como
  cualquier entidad. El chip padre es el NPC, con su grupo y su rol en la etiqueta.
- *Crear, fusionar, renombrar, disolver* **no tienen entidad apuntada ni destino** ⇒ **no son órdenes,
  son administración**, y por eso viven en otra pantalla.

### El tratamiento `data-ghost`, y por qué NO es el gris

**Borde punteado y trama diagonal = el sistema que ejecutaría esto no existe.** ⚠ **Es otra cosa que el
gris de §6**: allá el sistema existe y la **condición** dio `false`. Acá **no hay sistema**.

**Toda la escena de `command` está en fantasma.** *La escena dibuja el objetivo, no el alcance.*

### Lo que hay que decidir antes de escribir una línea de `command`

1. ~~**Fundar Cortex.**~~ **HECHO el 2026-08-24** — el repo tiene su `CLAUDE.md` (la sede de su familia
   de normas), estado, roadmap y arquitectura, y acuñó sus cinco primeras normas. El bloque de
   escuadrones está abierto del otro lado; lo que sigue de esta lista **no se destrabó con eso**.
2. **Cómo se nombra al ejecutor.** El net de §4 no tiene campo para *quién*: ¿toda la escuadra, un
   elemento, una selección? Es la decisión que más arrastra.
3. **Qué es una «puerta» para el sistema.** `prop_door_rotating` y `func_door` son entidades del
   engine; el mod *Immersive Door Openable* de `dev/other/` ya mapeó sus **siete keyvalues de sonido**
   en dos familias, y es la referencia.
4. **Si las formaciones son de la orden o del escuadrón.** *Fall In* trae cuatro; si la formación es un
   estado persistente, es otra pieza de estado.

---

## 8.ter La pantalla de administración de grupos — y NO es parte del menú

*Plegado del mock v2, sección H.*

> ⭐ **No es un árbol contextual, y la diferencia es de naturaleza:** no hay entidad apuntada, no hay
> destino, **la cámara no está congelada y el mouse es un mouse**. Es una pantalla de administración,
> **y por eso vive FUERA del menú.**

**Lo que se hace acá es lo que no cabe en un arco:** crear, fusionar, renombrar, disolver y **mover NPC
entre grupos de a varios**.

| Pieza | Cómo funciona |
|---|---|
| **Los cuatro grupos** | Amarillo, rojo, azul y verde: **los cuatro colores señalizables que hay en la paleta**. Un quinto **no tendría color propio** — el techo es del **theme**, no de la UI. ⚠ Y llevan **letra R·B·G·Y además del color**, porque **`olive` no declara `green`**: cae en `accent` y GREEN colisionaría con BLUE |
| **La fila** | **Cuatro casillas**; la rellena es la actual y **la última saca del grupo**. Un clic mueve al NPC |
| **⚠ La asimetría** | **Sobre un JUGADOR el mismo clic manda INVITACIÓN, no lo mueve.** *Al NPC se lo asigna, al jugador se lo invita* |
| **`Unassigned`** | Lista lo que hay **en rango** y no es de nadie: **NPC por clase, jugadores por nombre**. Es el *Add to group* del árbol, **en lote** |

> ⭐ **Y un detalle de honestidad que el dibujo codifica:** la tabla **se dibuja SÓLIDA porque el estado
> que muestra YA EXISTE en el juego** (quién hay en rango, su clase, su nombre). **El punteado y la
> trama están sólo en lo que ejecutaría el sistema que falta.** El mock distingue *«esto todavía no se
> escribió»* de *«esto no existe»* — y esa distinción es la que hay que mantener al implementar.

**Abierto:** el **binding** para abrir esta pantalla.

---

## 9. Lo que este bloque NO resuelve

### 9.1 El ícono de un prop capturado — **RESUELTO 2026-08-24, sin código nuevo**

**Votado: se usa el pipeline propio de Cargo, no los spawnicons de GMod.**

Lo medido el 2026-08-24, porque la pregunta era si servía el spawnicon del spawnmenu:

- GMod **sí shipea** un set base de spawnicons, pero en **`fallbacks_dir.vpk`** (271 carpetas), no en
  `garrysmod_dir.vpk`, que trae **cero** (verificado con control positivo). Ese set **sí cubre** los
  props de HL2: `props_c17/oildrum001` está adentro del bloque de spawnicons del vpk.
- Encima hay **21.621 generados localmente** en `materials/spawnicons/`, que son los de addons.
- O sea: **para props vanilla el ícono existe; para props de addon existe sólo si ESE cliente lo
  renderizó alguna vez.** Es caché por jugador, no contenido del addon.
- **Leer** uno es barato (`Material("spawnicons/models/<ruta>.png")`, sin VGUI). **Generar** el que
  falta no: el panel que los renderiza, `ModelImage`, **no existe en Lua** — es C++.

**Y lo que decidió el voto:** Cargo ya tiene este pipeline y es mejor para este trabajo.
`client/corpus_cargo_icons.lua` hace `ClientsideModel → RT → PNG en data/ → Material`, **lazy con
presupuesto por frame** (`cargo_icon_budget`), encuadrado con `PositionSpawnIcon`, con captura de alfa
y cuantización de la huella en celdas. Y ya declara una jerarquía de tres fuentes: `def.icon` (arte a
mano) → render generado → **primera letra como último recurso, explícitamente una señal de error**.

**Dos consecuencias:**

- El argumento decisivo es la **consistencia visual**: media grilla encuadrada por Cargo y media por
  el spawnmenu de GMod se ve mal, y el spawnicon no trae ni el encuadre ni la cuantización de celda.
- **La «imagen única no pregenerada» del pedido original deja de hacer falta.** Su motivo era *«no
  generar mil íconos»*, y el pipeline **ya es lazy**: sólo renderiza lo que efectivamente se dibuja.

### 9.2 Qué props se pueden levantar — **VOTADA 2026-08-24; el filtro es el PESO, no el engine**

**La regla del autor:** *lo que puedes levantar con USE puede entrar al inventario; si no lo puedes
levantar, no tiene sentido que esté en tu inventario.* **Se acepta** — pero lo que la implementa **no
es el límite del engine**, y esa distinción es la entrada entera.

**La puerta ya existe con esa semántica exacta.** `server/corpus_cargo_capture.lua:996`, en su propio
comentario: *«Plain USE = HL2 carry; WALK+USE = deliberate take»*, con debounce de 0,4 s y una regla de
soltar medida en juego el 2026-07-11. **No hay puerta que construir.**

**Lo que NO calza es la forma del registro:** `Capture.RegisterWorldPickup(class, spec)` mapea **una
clase → un id de ítem fijo**, y `prop_physics` es **una sola clase que cubre miles de modelos**. El def
tiene que ser **derivado del modelo** (CRG-41/42: *los defs se derivan, no se catalogan*), igual que
las 61 NVG y las armas autogeneradas. **Ése es el trabajo real, no la puerta.**

**Y por qué el filtro no puede ser el del engine:** `GM:AllowPlayerPickup` devuelve `true`
incondicionalmente en `gamemodes/base/gamemode/player.lua:793` y **Sandbox no lo pisa**, así que todo
el «se puede levantar» es el límite de masa y tamaño del engine — **C++, ilegible desde Lua e
inverificable offline**.

**El peso de Cargo da la misma propiedad y es del proyecto:**

- **Cargo pesa en KILOS y `PhysicsObject:GetMass()` también.** Mapean directo, sin constante de
  conversión que inventar. (Un AK-47 son 4,79 kg — `server/corpus_cargo_weapon_weights.lua:148`; una
  bala, 0,012 — `shared/corpus_cargo_ammo.lua:44`.)
- **Ya hay tope duro**: `CARGO.Weight.MAX_FRACTION = 2.0` (`shared/corpus_cargo_weight.lua:13`), y el
  gate que lo aplica está en `server/corpus_cargo_inventory.lua:533`. Con `cargo_capacity_base` en
  **54 kg** (`shared/corpus_cargo_weight.lua:37`), el techo es **108 kg**. **Un auto no entra por
  construcción** —que es exactamente el principio del autor— pero con **un número que el proyecto
  controla con una convar**.
- Es **verificable offline**: la curva es matemática pura. Una constante del engine no lo es en
  absoluto.
- **No puede derivar**: si Facepunch cambia el límite de carga, acá no se mueve nada.
- Compone con lo que ya está: **#58** (peso efectivo) y **#59** (marca de sobrellenado).

> El límite del engine sigue siendo un filtro **externo y gratis** —no puedes hacer WALK+USE sobre algo
> que no alcanzas— pero **ya no carga peso en el diseño**, así que no frena escribir.

### ⚠ Y la masa de un prop NO se puede usar cruda — medido el 2026-08-24

Esto se anotó primero como *«calibración, no diseño»*. **Al medirlo resultó ser diseño**, y por eso
está acá y no en una nota al pie.

Se leyeron las masas reales de **765 props de HL2** —`props_junk`, `props_c17`, `props_lab`,
`props_interiors`, `props_wasteland`— parseando el VPK. Instrumento reproducible:
`dev/leer_masas_phy.py` (no usa `vpk.exe`: el de `GarrysMod/bin` dice *«extracting»* y **no escribe
nada**, probado con el directorio destino ya creado).

| Rango | Props | Contra los 54 kg |
|---|---|---|
| **= 1,00 kg (el PISO)** | **89 (11,6 %)** | **Source no sabe cuánto pesan** |
| 1–5 kg | 65 (8,5 %) | entran de a montones |
| 5–15 kg | 152 (19,9 %) | 3 a 10 |
| 15–54 kg | 195 (25,5 %) | uno o dos y vas cargado |
| 54–108 kg | 59 (7,7 %) | uno solo sobrecarga |
| > 108 kg | 205 (26,8 %) | **no entran nunca** (techo) |

**La mediana es 25 kg** — el prop mediano de HL2 es media mochila. `wood_crate001a` pesa exactamente
**30 kg**.

> ⭐ **`1.0` ES UN PISO DE SOURCE, NO UNA MEDICIÓN.** De los 765, **cero** están por debajo de 1,0 y
> **89 valen exactamente 1,00**: entre ellos una **lata de bebida**, un **diario**, botellas plásticas
> y un **frasco de vidrio**. Una lata no pesa un kilo. El piso se confirmó contra contenido que no es
> de Valve — en el addon *props mexicanos* el mínimo también es `1.000000`.
>
> **`GetMass()` es fiable ARRIBA del piso y ciego ABAJO**, o sea justo en el rango que más le importa a
> un inventario: un diario, una lata y un frasco son **el mismo número**, y la lata está ~65×
> sobreestimada. **Escalar no lo arregla**: todo lo clavado en 1,0 sigue igual entre sí.

**Resuelto así:** se usa `GetMass()` crudo, **con un piso propio para los que están clavados en el piso
de Source**. Una línea, **derivada y no catalogada** (CRG-41/42 intacto): si la masa es exactamente
`1.0`, el motor está diciendo *«no sé»*, y ahí vale más un nominal chico —del orden de **0,2 kg**— que
aceptar su número.

**Lo que se descartó, y por qué:** derivar el extremo liviano del **volumen del bbox** distinguiría la
lata del frasco, pero `GetModelBounds()` devuelve **el hull y no la malla** — una trampa que este
proyecto ya pagó en el port de equipamiento, y cuyo modo de falla es **invisible**. El de la salida
elegida es visible: cargas demasiados diarios.

**Y la parte que no hay que tocar:** el saqueo *interesante* —el 25,5 % que cae entre 15 y 54 kg—
**funciona bien con la masa cruda**. El defecto es sólo el escalón de la chatarra.

**Dos trampas para cuando se escriba:**

- ⚠ **`GetMass()` es propiedad de la INSTANCIA física, no del modelo.** Un prop sin `PhysicsObject`
  válido no devuelve nada usable (hace falta fallback), y la masa **es mutable en runtime**.
- ⚠ **`AllowPlayerPickup` es un punto de veto libre** (grepeado: cero usos en Cargo y en Corpus). Si
  Cargo lo engancha, tiene que devolver **`false`** para vetar y **`nil`** en cualquier otro caso,
  **nunca `true`**: `hook.Call` corta la cadena cuando un hook devuelve un valor, y un `true` se comería
  los vetos de todos los addons de más abajo en la fila.

Cruza además con la **#80** (hoy **no existe** ningún límite ni ninguna limpieza de props botados:
medido, es cero) y con la **#15**.

### 9.3 Assets que no los tapa ningún diseño

- **Modelo de llave** — ~~bullets 9 y 10~~ **sólo el 10** desde que el 9 pasó a ser el lock de Glide,
  que no necesita asset. Phantasmagoria aporta **sonidos**, no modelo.
- **Máscara de gas propia** (#44). El autor la quiere 100 % propia; el banco de sonidos ya está en
  `corpus/sound/corpus/cargo/gasmask/`.
- **Camilla** (bullet 11), inexistente.

---

## 10. Verificación

**VOTADO 2026-08-24: los dos, y la repartija no es arbitraria.**

La pregunta estaba planteada como *«harness nuevo vs. extender el selftest»*, y **eso asumía que la
maquinaria no existe. Existe tres veces.**

- `corpus_selftest.lua` son **144 líneas**, corre **en juego** y cubre las seis primitivas. Ya pagó lo
  difícil: tiene **dos nombres de comando** porque el archivo es shared y en un listen server gana el
  del SERVER — sin `corpus_selftest_cl` el realm CLIENTE del framework era **inverificable**, y así fue
  como un check verde reportó dos veces el mismo realm (planilla T4, dos rondas).
- Los tres harnesses (`cargo` 10.836 líneas, `coagulant` 1.579, `craving` 720) corren sobre **lupa con
  LuaJIT 2.1, el mismo motor que GMod embebe**: no analizan el Lua, **lo ejecutan**.
- Y **los tres ya cargan el autorun de Corpus** (`FRAMEWORK_FILES` + `corpus_ui.lua`) antes de su
  módulo.

> ⇒ **El Lua del framework ya se ejecuta offline tres veces; lo que falta es que alguien le asserte
> algo.** Corpus entra como andamio, nunca como sujeto — y la consecuencia excede a este bloque:
> **hoy las seis primitivas tienen CERO cobertura offline.**

### La repartija: lógica offline, motor en juego

| Offline (lógica pura) | Sólo en juego (motor) |
|---|---|
| Validar el `id`; que uno no tipeable no reciba perilla **y lo diga** | **Que `REPLICATED` replique de verdad** — el stub ignora los flags, es invisible offline |
| Resolver el `parent`, loguear huérfanos, ordenar hermanos | Que la consulta de proximidad **encuentre hijos `SOLID_NONE`** |
| Perilla nacida del registro; entregar el objeto; re-registrar reusa | El LOD y el filtrado en pantalla (visual) |
| La composición maestra × acción en **una** función | |
| Las tres puertas del server (§4) | |
| Que los hooks devuelvan `nil` y no `true` | |

### Lo que hay que hacer, en orden

1. **Abrir `dev/harness_corpus.py`, sembrado desde `harness_craving.py`** (720 líneas, el más chico),
   **no** desde las 10.836 de Cargo. Su sujeto es el framework: la séptima primitiva **y las seis que
   hoy no tienen nada**.
2. **Extender `corpus_selftest.lua`** con la mitad de motor, reusando su patrón de dos realms.
3. ⚠ **NO factorizar todavía la capa de stubs compartida.** Sería la cuarta copia y tienta, pero es
   refactorizar 13.000 líneas de instrumentos que funcionan, y mover o renombrar **rompe las anclas de
   los sabotajes en silencio** (`ANCLA x0`, sin reventar) — pasó **cuatro veces en una sola tanda**.
   Queda como deuda con **gatillo concreto**: *el día que el mismo bug de stub aparezca en dos
   harnesses, se factoriza.*

Lo que sí se puede dejar escrito, porque son las trampas ya conocidas:

1. **El `REPLICATED` no se verifica leyendo el flag** (§7). Va por comportamiento o no va.
2. **Un check que no puede fallar no mide nada.** Toda tanda va con su **suite de sabotaje** en `dev/`,
   que tiene que dar el total **en rojo**.
3. **Antes de escribir cualquier check**, leer `memory/controles-que-premian-su-modo-de-falla.md`
   (numerado hasta el **122**; las últimas viven arriba de todo, una línea cada una).
4. **El árbol vacío tiene que ser una medición.** Si el menú abre y no muestra nada, un check que sólo
   pregunta «¿abrió?» sale verde. La forma correcta es contar nodos contra un número esperado — y que
   el caso de **cero nodos** sea un resultado distinguible de **no se evaluó**.
5. **La cadena de hooks.** Todo hook que este bloque agregue devuelve un valor **sólo cuando quiere
   cortar**, nunca para decir que sí.

---

## 11. Estado del documento

**Escrito el 2026-08-24.** El código no existe. No acuña normas todavía (ver la cabecera).

**Votado por el autor:**

| Decisión | Voto | Fecha |
|---|---|---|
| ¿Wheel nuevo, o el de Cargo con otro proveedor? | **Ninguno**: se reusa la infraestructura, se estrena el árbol y el anclaje | 2026-08-23 |
| ¿El mod de Arctic hace falta? | **No.** Medido y refutado el motivo por el que se trajo | 2026-08-23 |
| ¿Dónde vive el registro? | **`corpus/`**; las acciones en cada módulo (§2) | 2026-08-23 |
| ¿Con qué se comitea? | **Screen clicker + click**, como el wheel (§6) | 2026-08-23 |
| Forma de las perillas de admin | **Derivada de la #61** — registro + maestra (§7) | 2026-08-24 |
| Ícono de un prop capturado | **Pipeline propio de Cargo**, no spawnicons (§9.1) | 2026-08-24 |
| Qué props se pueden levantar | Se acepta la regla del autor, **pero la implementa el PESO de Cargo**, no el límite del engine (§9.2) | 2026-08-24 |
| Anclaje de la rama `interaction` | **Entidad + descubrimiento por proximidad + campo `component` reservado** (§5) | 2026-08-24 |
| El bullet 9 (puertas de Glide) | **Reescrito como el LOCK de Glide** — las puertas no existen (§8) | 2026-08-24 |
| Instrumento de verificación | **Los dos**: `dev/harness_corpus.py` nuevo para la lógica + el selftest para el motor, **sin factorizar los stubs** (§10) | 2026-08-24 |
| La masa como peso de inventario | **`GetMass()` crudo con piso propio** para los clavados en el piso de Source (§9.2) | 2026-08-24 |

### ✅ EL MOCK v2, PLEGADO — 2026-08-24

Las decisiones que el paquete del mock trajo **ya están en el cuerpo de este documento**, no en una
lista de pendientes:

| Decisión | Dónde quedó |
|---|---|
| Tres niveles de LOD y **cuatro estados de acción** (ninguno distinguido sólo por color) | **§6** |
| Umbrales de rama **1-6 / 7-12 / 13+**, el 6 derivado de la geometría del chip, sin paginado, el cvar de filas | **§6.bis** |
| El campo **`category`** y su fallback alfabético | **§3** y §6.bis |
| WHO como **estado** y WHERE como **lo que tocas**; la segunda columna función del tipo de objetivo | **§8.bis** |
| **`Delay` como modificador**, con su cola bajo WHO y el objetivo resuelto al dar la orden | **§8.bis** |
| **`Deploy` como objeto** y su dependencia de Cargo; el `Ammo box` como pregunta de simulación | **§8.bis** |
| El tratamiento **`data-ghost`**, distinto del gris | **§8.bis** |
| La **pantalla de administración**, que NO es parte del menú, y la asimetría NPC/jugador | **§8.ter** |
| La puerta que trae sus cinco sólo si **comunica dos lados navegables** | **§8.bis** |

**Lo que sigue viviendo sólo en el paquete del mock** son las MEDIDAS (el chip de 218 × 36, la fila de
28 px) y la **tabla de motion** de su sección I — beats, duraciones, easings y stagger. Sus dos reglas
duras sí conviene tenerlas acá: **nada pasa de 260 ms** (el jugador tiene la tecla abajo esperando para
actuar, no mirando una animación) y **cada cosa entra o sale DESDE SU ANCLA** — el punto del mundo, el
hub del jugador, el borde de la pantalla —, que es *lo que hace legible que el criterio de anclaje
cambió al pasar de rama*.

**Y lo que el mock declara pendiente:** `Breach charge` (para qué se usaría), `Chemlight` (viene de
Phantasmagoria), el **binding** de la pantalla de administración, y la **munición finita de NPC HL2/VJ
+ el rol *Ammo Bearer*** — pregunta para Cortex.

### ⚠ ENMIENDA DEL 2026-08-24 — la tercera rama

El autor votó **tres ramas** en vez de dos (§5), y con eso **el alcance dejó de ser uno solo**:

| | `interaction` + `self` | `command` |
|---|---|---|
| Estado del diseño | **cerrado**, las diez decisiones votadas | **abierto**: 4 decisiones sin votar (§8.bis) |
| Lo que ejecuta | acciones que **ya existen** o son chicas | **no existe nada** |
| Se puede escribir | **sí, ya** | **no** — antes hay que fundar Cortex |

**Lo que sigue firme, y no lo tocó la enmienda:** el registro de §3, los realms de §4, la entrada de
§6, las perillas de §7 y las dos decisiones de §9. La tercera rama **entra por la puerta que el
registro ya tenía** —`tree` pasó de dos valores a tres— y eso es exactamente lo que la propiedad 1 del
autor pedía: que el conjunto fuera abierto. *La enmienda ejercitó el diseño en vez de romperlo.*

**Lo que la enmienda SÍ desfasó:** el **mock v1** muestra dos ramas y tiene elementos superpuestos.
Hay que rehacerlo.

### Lo que el primer parche arrastra, y conviene saberlo antes de empezar

- Toca `CORPUS_Architecture.md` §3, que hoy dice **«Seis primitivas»**.
- **Acuña las normas `COR-nn`**, y **FLU-30** las quiere en el registro **en el mismo parche**.
- Abre `dev/harness_corpus.py`, que es el primer instrumento offline cuyo sujeto es el framework.
- **Registra la rama `command` VACÍA.** Que el tercer nodo exista y no tenga hijos prueba la forma del
  árbol sin comprometer nada — y un árbol con una rama vacía es justo el caso que un check de «el árbol
  vacío tiene que ser una medición» (§10) sabe distinguir.

### Lo que estas dos rondas de votos enseñaron

Las dos decisiones que parecían más caras se abarataron **midiendo la premisa en vez del costo**:

- La geometría de la rama `interaction` se justificaba con las puertas y el maletero de un Glide. **Ninguno
  de los dos existe en Glide.** La opción cara se defendía con un caso que no está.
- «Lo que puedes levantar con USE» parecía necesitar el límite de masa del engine. **Lua no restringe
  nada** ahí, y el filtro que el proyecto ya tiene —el peso— da la misma propiedad y **sí** es
  verificable.

Y a cambio apareció un obstáculo que ninguna de las dos preguntas mencionaba: **`glide_wheel` es
`SOLID_NONE`**, así que un trace no la toca. *El costo real no estaba donde las dos opciones lo
discutían.*
