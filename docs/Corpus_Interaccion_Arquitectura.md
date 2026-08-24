# Corpus — Arquitectura del menú interactivo

> **Uso de este documento:** subsistema del **framework**, no de un módulo. Describe el registro de
> acciones contextuales al estilo del menú interactivo de ACE3 (Arma 3) y las dos ramas de UI que lo
> dibujan. No se requiere el chat de diseño original para entenderlo.
>
> **Estado:** diseño abierto. **Seis decisiones votadas** (§2, §6, §7, §9.1, §9.2 y la sede), **tres
> abiertas** — ninguna de ellas bloquea escribir el registro, que es la pieza de la que todo cuelga.
> El detalle de las nueve está en **§11**. **El código no existe.** Este documento **no acuña
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

---

## Índice

1. [Visión general](#1-visión-general)
2. [Dónde vive: la séptima primitiva](#2-dónde-vive-la-séptima-primitiva)
3. [El registro — la API](#3-el-registro--la-api)
4. [Realms: qué se registra dónde y qué corre dónde](#4-realms-qué-se-registra-dónde-y-qué-corre-dónde)
5. [Los dos árboles y sus dos criterios de separación](#5-los-dos-árboles-y-sus-dos-criterios-de-separación)
6. [La entrada: hold, cursor y commit](#6-la-entrada-hold-cursor-y-commit)
7. [Las perillas de admin](#7-las-perillas-de-admin)
8. [El catálogo de acciones pedidas](#8-el-catálogo-de-acciones-pedidas)
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
| `tree` | `"self"` \| `"world"` | sí | Cuál de los dos árboles de §5 |
| `parent` | string \| nil | no | `id` del nodo padre. `nil` = nodo raíz. Es lo que hace que el árbol sea un árbol |
| `order` | number | no | Orden entre hermanos. Default 100, como `RegisterCategory` |
| `icon` | string \| nil | no | Ruta de material. `nil` = sólo etiqueta |
| `condition` | function \| nil | no | `condition(ply, ent) -> bool`. Ausente = siempre visible. **Se evalúa en vivo, en los dos realms** |
| `range` | number \| nil | no | Distancia máxima en unidades. Sólo tiene sentido en `tree = "world"` |
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

El cliente **no ejecuta nada**. Manda **un** mensaje de net nombrando `(id de acción, entidad
objetivo)` y el server, antes de correr `run`:

1. **Re-chequea la perilla** (la maestra y la de la acción — §7).
2. **Re-chequea `condition(ply, ent)`** con su propio estado.
3. **Re-chequea `range`** contra **las posiciones del server**, no las que dijo el cliente.

> ⚠ **Las comprobaciones del cliente evitan DIBUJAR de más; no autorizan nada.** Un cliente
> modificado puede mandar cualquier `id` con cualquier entidad. Las tres puertas de arriba son la
> autorización, y viven donde el jugador no llega.

---

## 5. Los dos árboles y sus dos criterios de separación

Dos entradas separadas, con teclas separadas, igual que ACE3:

| Árbol | Sobre qué | Se organiza por |
|---|---|---|
| **`self`** | Uno mismo | **DOMINIO funcional** — Equipo · Médico · Gestos · Arma |
| **`world`** | Lo que estás apuntando | **La ENTIDAD apuntada** |

**Que los dos criterios sean distintos es la enseñanza, no un descuido.** En ACE3 el árbol de entorno
no tiene una categoría «vehículo»: cada componente del modelo es su propio nodo, y *para llegar a las
acciones de una rueda hay que apuntar esa rueda*. La excepción son las **personas**, donde vuelven las
categorías abstractas (Médico, arrastrar, cargar, revisar inventario).

### ⚠ Voto de alcance ABIERTO: entidad abstracta vs. geometría

**Este documento diseña el árbol `world` anclado a la ENTIDAD**, no a la geometría: un punto por
entidad, con sus acciones colgando.

El modelo por geometría —un punto por puerta, uno por el maletero, uno por el motor, proyectados sobre
el modelo— **es lo que más cambia la sensación y también lo más caro**, y **no hace falta para que el
menú exista**. Queda declarado como extensión futura: el `spec` puede ganar un campo de anclaje
(`attachment` o `bone`) **sin romper nada de lo escrito acá**, porque el `parent` ya es un `id` y un
nodo de geometría es un nodo de rama más.

**Consecuencia que hay que decir en voz alta:** con el modelo abstracto, los bullets 8 y 9 del pedido
(maletero y puertas de un Glide) son **acciones hermanas de una misma entidad**, no puntos separados
sobre el vehículo. Es menos de lo que el pedido sugería. **Es votable, y no está votado.**

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

### LOD por distancia

De lejos, un punto; de cerca, el ícono con etiqueta. **Fuera de `range`, la acción no aparece.** Es
puramente cosmético salvo el corte por `range`, que además el server re-chequea (§4).

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
| 8 | Abrir el maletero de un Glide | Cargo + Glide | `Containers.Attach` sobre la entidad del vehículo. ⚠ Glide **no se forkea, se consume** |
| 9 | Abrir/cerrar puertas de un Glide | Glide | Nuevo. **Falta el modelo de llave** (§9.3) |
| 10 | Puertas del mapa, con generación de llave | Corpus / sin dueño | Nuevo. Mismo asset faltante que el 9 |
| 11 | Arrastrar a un inconsciente, subirlo a un vehículo o a la camilla | Coagulant | Nuevo. **La camilla no existe** (§9.3) |
| 12 | Abrir el menú de Coagulant de **otro** jugador | Coagulant | Nuevo. Es la forma ACE3 clásica, y cae en el árbol `world` sobre una persona |

**Ninguno de los doce es del framework.** Eso es la prueba de que §2 partió bien: si alguno lo fuera,
habría dominio subiendo a Corpus.

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

**Lo que sí queda por medir, y es más chico y OFFLINE:** si las masas de los props de HL2 son *sanas*
como peso de inventario. Un cajón de 30 kg contra un presupuesto de 54 significa **dos cajones y vas
sobrecargado** — puede ser lo correcto o puede volver inútil el saqueo. Se lee `GetMass()` sobre una
muestra y se mira la distribución contra los 54 kg; el *«¿se siente bien?»* sí necesita el juego.

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

- **Modelo de llave** (bullets 9 y 10). Phantasmagoria aporta **sonidos**, no modelo.
- **Máscara de gas propia** (#44). El autor la quiere 100 % propia; el banco de sonidos ya está en
  `corpus/sound/corpus/cargo/gasmask/`.
- **Camilla** (bullet 11), inexistente.

---

## 10. Verificación

**Corpus no tiene harness offline.** Existen `dev/harness_cargo.py`, `harness_coagulant.py` y
`harness_craving.py`, pero no uno del framework: lo que verifica a Corpus es
`corpus/lua/autorun/corpus_selftest.lua`, **en juego**. El primer parche que escriba código tiene que
decidir si abre `dev/harness_corpus.py` o si extiende el selftest, y **eso es una decisión del parche,
no de este documento**.

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

**Abierto:**

1. **§5 — entidad abstracta vs. geometría** en el árbol `world`. El documento diseña la abstracta; la
   geometría es extensión futura y **no está votada**. Es el voto que más arrastra de los tres.
2. **§10 — instrumento de verificación**: harness nuevo o extender el selftest. Lo decide el parche
   que escriba el primer archivo.
3. **§9.2 — la distribución de masas** de los props de HL2 contra el presupuesto de 54 kg. **No es
   bloqueante** (offline, y es calibración y no diseño), pero decide si el saqueo de props se siente
   bien o inútil.

**Nada de esto bloquea escribir el registro de §3 y §4**, que es la pieza que todo lo demás cuelga.
