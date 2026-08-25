# Corpus — Estado de HOY

> **Foto del AHORA**, volátil. Es lo primero que se lee al retomar el proyecto —
> **antes** que el doc de arquitectura. Se actualiza **en sitio** (no se agregan
> secciones ni historial). El historial vive en `git` + [`CHANGELOG.md`](CHANGELOG.md).
> Si crece de una pantalla, está mal redactado: recortar.
> Cita **FLU-15**, cuya sede es [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt)
> §1 PASO 5 — este doc la aplica, no la define.

**Última actualización:** 2026-08-25 (**los TRES huecos de diseño que dejó la tanda 1 están
VOTADOS Y BAJADOS a código, doc e instrumento** — y los tres eran la misma clase de defecto: *el
diseño había resuelto el caso y no la clase*. (1) Las perillas pasan a **dos espacios de nombres
separados** —`corpus_interact_*` para la config del subsistema y `corpus_interact_action_<id>`
para la acción—, porque el prefijo por acción **contenía** al nombre de la maestra y ya había
**tres** colisiones nombrables (`enabled`, el cvar de filas de §6.bis, el `dump` de la tanda 2);
Cargo se salva de esto **por accidente**, que es por qué la #61 no lo enseñó al transferirse. Y
el guard **se borró**: no puede dispararse, y *un guard que no puede dispararse vuelve
inejercitable al check que lo cubre*. (2) El reparto alfabético es **parejo con techo 12** y no
un corte fijo: la misma cantidad de tandas (`ceil(n/12)` en los dos) sin fabricar una
subcategoría de **un solo ítem** al cruzar el umbral —13 hijos daban `[12, 1]` y ahora dan
`[7, 6]`—. (3) **Huérfano es todo lo que no se alcanza desde una raíz**, una regla donde había
dos y media: medido, un **ciclo** hacía desaparecer del menú a sus nodos **y a todo lo sano que
colgara debajo**, con `orphans` diciendo **0** — el defecto exacto que §3.a existe para impedir,
entrando por la puerta de al lado. ⚠ **Y actualizar el instrumento destapó que DOS de los tres
votos no se podían distinguir con los checks que ya había**: el reparto parejo y el corte fijo
daban 3 grupos, 34 ítems y máximo 12 en los dos, y el check del ciclo era `pcall ok` + un conteo
que salía verde con las dos conductas. El harness va en **456 checks** y el sabotaje en
**53/53 en rojo**, más **5 no-detectables declarados** —dos de ellos con etiqueta `[movido]`,
sabotajes viejos que la regla nueva **absorbió** y que se conservan porque el día que alguien
saque la alcanzabilidad vuelven a ser lo único que queda—. ⭐ **Y `corpus_selftest` AUDITA AHORA
A INTERACT** —once filas en los dos realms— **y devuelve su veredicto**, que hasta hoy no
hacía: sin retorno, un instrumento sólo podía preguntarle al `pcall` «¿corrió?» y jamás «¿salió
bien?», que es el nº 60 del catálogo y ya costó 179 checks en Cargo. El bloque **presta el
padrón y lo restaura**: sin eso, tipear el comando con módulos cargados les borraría sus
acciones con todas las filas en OK. **No se abre planilla todavía** y el motivo está medido:
ningún módulo registra acciones (mismo precedente que Cargo #60), el `REPLICATED` **no es
corrible en listen server** —mismo proceso—, y el estado no es inspeccionable hasta el
`corpus_interact_dump` de la tanda 2. La letra `AP` sigue **libre**. ⭐⭐ **Y EL VOTO DEL EJECUTOR ESTÁ DADO** —era la decisión que más
arrastraba del bloque y la única de las cuatro de §8.bis que frenaba a las **otras dos ramas**—:
`B + C`, o sea que **el ejecutor es ESTADO del server** (llega por el net propio de Cortex, no por
el commit del menú) **más un campo `subject` opaco de reserva**, gemelo de `component`. Con eso
**la tanda 2 queda DESTRABADA** —el commit, las tres puertas del server y el `corpus_interact_dump`—
y de las cuatro decisiones de `command` quedan **dos**, las dos enteramente suyas: qué es una
«puerta» y dónde viven las formaciones. ⚠ Queda escrito además lo que **leído de afuera parece un
bug**: `ent` significa **DESTINO** en una orden de escuadra y **SUJETO** en una individual, y el
`id` de la acción es el que sabe cuál de los dos es. Contexto previo: **el
framework tiene
SIETE primitivas: nació
`Corpus.Interact`, el registro del menú interactivo — y las seis viejas estrenan la cobertura
offline que hasta hoy era CERO.** Tanda 1 de cuatro, y su objetivo era chico a propósito: que el
árbol del menú **exista como DATO** —poblable, resoluble e inspeccionable— **sin dibujar nada y sin
ejecutar nada**. `Register` valida un spec, `Resolve` arma el árbol al ABRIRLO (el `parent` es un
`id` y no una referencia, así que un módulo puede colgar de un nodo que todavía no se registró),
ordena hermanos, reparte por régimen de rama (1-6 arco · 7-12 columna · 13+ subcategorías) y **dice
por `Corpus.Log` todo lo que rechaza y todo lo que queda huérfano** — una ausencia silenciosa se lee
como «el menú no funciona». Las perillas de admin las crea **el registro** y no una lista, heredado
del roadmap #61 de Cargo. La rama `command` **nace vacía y su árbol resuelve con un número**, que es
lo que prueba la forma sin comprometer nada: su escuadra vive en Cortex. **Instrumento nuevo:
`dev/harness_corpus.py`, el primero cuyo SUJETO es el framework** —456 checks en tres pasadas, y la
tercera carga las siete primitivas en **orden alfabético INVERSO**, que es lo que ejerce COR-9 por
primera vez—, más `dev/sabotaje_corpus_interact.py`, que nació con **49 sabotajes, 49 en rojo**
(hoy van 53), y **cada uno
declara qué familias de checks tiene que teñir**, así que el arnés también falla cuando el rojo se
PASA. Esa segunda mitad se pagó sola: de los 49, seis salieron mal en la primera corrida y **cuatro
eran defectos del instrumento, no del código** —entre ellos un sabotaje que no rompía lo que decía
romper y un check de idempotencia que salía verde con y sin el mecanismo—. **Sin pasada en juego, y
no es una deuda: la tanda no tiene superficie de runtime.** ⚠ Dejó **tres huecos de diseño**
—la colisión del `id` `enabled` con la perilla maestra, el tamaño de la tanda del reparto
alfabético y los ciclos de `parent`—, **votados y cerrados el 2026-08-25** (arriba).
Contexto previo: **arco B ronda 2: el cierre del 2026-08-08 estaba MAL y
queda REFUTADO. `InitPostEntity` SÍ se dispara en el realm CLIENTE** — lo que no corre es
**nuestro callback**, que no es la misma afirmación. Lo mide el `console.log` del autor, nueve
arranques: el callback CLIENTE de `InitPostEntity` de Quick Loadouts corre 11-12 líneas **antes**
de nuestra línea de `fallback`, en el mismo arranque en que el selftest dice que el nuestro no
corrió, y no puede venir de otra ruta porque el menú exige una tecla y la tecla exige el
`LocalPlayer()` que recién valida el paso siguiente. **El mecanismo está en la fuente del engine,
en disco** (`lua/includes/modules/hook.lua`): `hook.Call` **aborta la cadena entera** en cuanto un
hook devuelve un valor no-nil, así que un tercero deja sin evento a todos los de más abajo en un
`pairs()`, sin saber nuestro nombre y sin un error de Lua. **Quién corta: SIN IDENTIFICAR** — los
41 `hook.Add("InitPostEntity")` de `dev/other/` no devuelven valor, pero ahí no están los 380
suscritos. **La lección es de instrumento y es la cara:** `_initPostEntitySeen` la escribe el
propio callback, así que sólo puede medir «corrió nuestro hook»; se imprimía como
`initPostEntity=NO llegó` y **el nombre contrabandeó la conclusión** a tres docs y un header. Hoy
el rótulo es `hookIPE=corrió | NO corrió`. **Cero cambios de conducta**: el respaldo CLIENT-only
se queda y ahora se apoya en algo **estructural**, no en una rareza local. Contexto previo: **la primitiva 5, la ready barrier, NO DISPARABA
en el realm CLIENTE** — su callback de `InitPostEntity` no corría ahí, `Initialize` sí; se perdían **4.413 defs**
—4 médicas, 15 de comida, 4.394 de attachments ARC9— y las 3 barras del StatusPanel, **sin un solo
error de Lua y con el log en verde**. La barrera deja de colgar de un hook único: `Fire` idempotente
+ respaldo CLIENT-only, y ahora **habla siempre** —qué ruta disparó y cuántos wirings soltó, por
realm—. Restituye **COR-5** aplicada al propio framework. El harness **no puede** reproducirlo (su
stub dispara `InitPostEntity` en ambos realms por construcción): **falta la pasada en juego**.
Veredicto: `dev/VEREDICTO_ready_barrier_cliente.md`. Contexto previo: **el framework recibió código
por primera vez desde el 2026-07-09** — `Corpus.Data` gana `List`, `Delete` y el **scope** de COR-19, más **COR-18** acuñada
y COR-3 enmendada; el gancho de perfil queda puesto **sin mover un solo archivo**, y su primer
consumidor real es el comando de purga de `inst_*` legacy de Cargo. **Verificado en juego el
2026-07-26 — planilla T, la primera del framework: 9 de 9**. Hicieron falta tres rondas, y el
único ✗ destapó que el realm CLIENT del framework era **inverificable en juego**: le sumó el
alias `corpus_selftest_cl`. Harness 393 verdes. Contexto previo: banco de sonidos del ecosistema — `sound/corpus/`
con los ports de GAMMA ordenados por consumidor y **COR-17 acuñada** (assets fuera de git, régimen
STK-2); Cargo y Craving ya lo consumen, **confirmado en juego el 2026-07-24**. Framework Lua estable desde el
2026-07-09; **Block 4 cerrado**: Craving verificó su v1 en juego, sumándose a Cargo; **Block 3 CERRADO: Coagulant pasó la ronda 7 en juego 13/13 —la UI, el sway retuneado y el modo degradado— y sus fixes post-cierre ya se verificaron (mini-ronda 8 y check N1: CHANGELOG entero en `[APLICADO]`)**. Cortex sigue sin código, pero ya no está vacío: estrenó su doc de contratos entrantes. **Nuevo: el gate SCOPED post-D13 corrió ÍNTEGRO y su tanda de reparación está APLICADA** — cinco universales que el árbol desmentía, más la fase 0 del gate; **D-14 quedó CERRADA** por voto del autor el 2026-07-21 (COR-12 se queda: gobierna el protocolo de registro, no la semántica de los ítems); el **2.º COMPLETO ya corrió el 2026-07-22** —2 contradicciones y 9 hechos falsos, los 11 reparados el mismo día—. **Deuda de cadencia declarada:** desde entonces las tandas B1-B4 de la persistencia de Cargo escribieron normas (COR-18, COR-19, CRG-56 a CRG-60) y **ninguna disparó su SCOPED de AUD-1**)

---

## Qué existe hoy

- **Block 1 cerrado (diseño) y bajado a código, verificado en juego:** las 6
  primitivas de la API ([`CORPUS_Architecture.md`](CORPUS_Architecture.md) §3)
  implementadas en `lua/autorun/` — registro (con invariante by-ref, anotado en §3),
  persistencia, net, UI shell, ready barrier, log + comando `corpus_selftest`. Mapa
  archivo → rol en [`CLAUDE.md`](../CLAUDE.md). Todo shared salvo la UI (client).
  Verificación: **456 checks offline con stubs de GMod, en tres pasadas**
  ([`dev/harness_corpus.py`](../../dev/harness_corpus.py), 2026-08-24 — el número "46 checks" que
  este doc citó hasta esa fecha **no tenía archivo que lo respaldara**, y por eso se reemplaza por
  el de un instrumento que existe) +
  `corpus_selftest` en juego el 2026-07-09 (realm SERVER, todo OK) + check visual de
  UI cerrado el mismo día con el primer tab real (Caliber en menú Q → Utilities →
  Corpus). **Las 6 primitivas verificadas de punta a punta por un consumidor real.**
  **Persistencia ampliada el 2026-07-25** (Data es UNA, con
  más superficie): `Corpus.Data.Save/Load/List/Delete` + `opts.scope` — **COR-19** separa
  config de servidor de estado de partida y **COR-18** cierra la puerta a `file.*` para
  estado propio. Los dos scopes resuelven a la misma carpeta **a propósito**: el gancho
  está puesto, no activado.
- **La SÉPTIMA primitiva, `Corpus.Interact` (2026-08-24), y existe como DATO y nada más.**
  `lua/autorun/corpus_interact.lua`: el registro de acciones contextuales del menú estilo ACE3
  ([`Corpus_Interaccion_Arquitectura.md`](Corpus_Interaccion_Arquitectura.md), diseño cerrado y
  votado). **Lo que sube es el PROTOCOLO por el que un módulo cuelga una acción, jamás una acción**
  — es COR-12 una capa más arriba y hereda su criterio de reapertura textual: el día que la API
  mencione un ítem, un peso, una herida, un vehículo o un contenedor, bajó dominio al framework.
  Superficie: `Register(module, spec)` (valida, normaliza, devuelve el spec o `nil` **más el motivo
  exacto**), `Resolve(tree)` (árbol, huérfanos, regímenes, hojas alcanzables) y `Enabled(id)` (la
  composición maestra × acción en **una** función). **No dibuja, no manda net y no ejecuta nada:**
  el commit y las tres puertas del server son la tanda 2, el dibujado la 3 y las acciones la 4.
- **Cobertura offline del framework: de CERO a 456 checks (2026-08-24/25).**
  [`dev/harness_corpus.py`](../../dev/harness_corpus.py) es el primer instrumento cuyo **sujeto** es
  el framework — los tres harnesses de módulo ya lo cargaban, pero como **andamio**, sin assertearle
  nada. Cubre las siete primitivas en SERVER y CLIENT, más una tercera pasada con el **orden de
  carga invertido** que ejerce COR-9, más un **gate de fuentes presencial** para lo único que el
  comportamiento offline no puede ver: el `FCVAR_REPLICATED`. Su otra mitad es
  [`dev/sabotaje_corpus_interact.py`](../../dev/sabotaje_corpus_interact.py) — **53/53 en rojo**,
  cada uno **sólo en las familias que declara**. ⚠ La capa de stubs **no se factorizó** y es la
  cuarta copia a propósito: mover o renombrar rompe las anclas de los sabotajes **en silencio**.
  Gatillo declarado para factorizar: *el día que el mismo bug de stub aparezca en dos harnesses.*
- **Workspace multi-root + metodología:** **siete raíces** (`corpus/` + cinco módulos +
  `corpus-stalker/`, el addon de **contenido** de la Zona — consumidor puro, no un módulo)
  + `dev/` fuera de git; set de docs vivos portado de ADS/Kontrol, con el patrón doc
  general vs. particular ya formalizado en
  [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).
- **Anti-drift (2026-07-16, portado del SDD de Kontrol):** §7 del flujo es la
  **constitución** — jerarquía de autoridad (el código Lua manda sobre el doc), toda norma
  define o cita un ID, barrido de ratificación en el PASO 5, conducta `DETENTE`. El
  registro [`ids.yaml`](ids.yaml) indexa **213 IDs** de las siete raíces (10 familias; 26%
  INTENCION — subió porque la familia Workbench, acuñada el 2026-07-19, es intención pura
  por construcción: su bloque no está implementado). **Los votos del autor (2026-07-19) cerraron seis deudas** (D-1, D-4, D-6,
  D-9, D-10, D-11 — incluye acuñar COR-15/COR-16 para UI shell y log, y unificar la
  política git estricta en los siete repos) **y recortaron D-2/D-3** (los IDs de check
  rigen hacia adelante; quedan sedes en `.lua`/CHANGELOG por mover). El **checker** (§7.7)
  corre en `pre-commit` sobre las siete raíces (12/12 tests) y valida yaml, prefijos,
  duplicados, sedes, evidencia y huérfanos — **presencial, no semántico**. El **§8**
  formaliza la tanda como spec ejecutable. El **gate LLM** (§7.8) corrió **dos COMPLETO y cinco
  SCOPED** ([actas](auditorias/)); **las actas están triadas y las dos últimas —SCOPED 2026-07-21 y
  COMPLETO 2026-07-22— ya están reparadas** — COR-12/13/14 anclados por etiqueta y reconocidos por el `CLAUDE.md`, más
  cuatro universales que el árbol desmentía. **El gate propone y jamás aplica (AUD-4): las
  actas son inmutables y los parches van en tanda aparte.**
- **Banco de sonidos default (2026-07-24):** `sound/corpus/` — 201 ports de STALKER GAMMA
  ordenados por consumidor (`cargo/` con gasmask como su extra, `coagulant/`, `craving/`,
  `shared/`), `about.txt` por carpeta (mapa + renombres). Assets **fuera de git** (**COR-17**,
  contrato 10 del CLAUDE.md); solo los about.txt se versionan. Consumo por detección
  (`file.Exists`): Cargo (entry 35) y Craving ya cablean; Coagulant solo documentado (COA-28).
- **Los siete repos publicados en GitHub** (`github.com/Sepuldosky/<repo>`, públicos, MIT). Dos
  módulos ya viven sobre las primitivas: **Caliber** (Block 2, migración ADS 2.0 — cerrado y
  verificado, primer consumidor real; su boot diferido a `Initialize` es el patrón template)
  y **Cargo** (Block 1, inventario estilo STALKER — hoy el módulo más grande del ecosistema:
  UI fullscreen, munición, wheel, captura de armas y el slice 1 del comercio, todo en juego).
  **Coagulant cerró su Block 3 EN JUEGO** (ronda 7, 2026-07-20, 13/13: sangre/heridas/
  sangrado + tratamiento con tiempo y 4 ítems contra Cargo + debuffs zonales + la UI
  completa —silueta, menú médico, barra de tratamiento, StatusPanel y tab Q— y el modo
  degradado sin Cargo). **Ya no es scaffold: es el módulo médico real del ecosistema.** Le
  quedan dos decisiones de diseño del autor; su tramo de zonas está COMPLETO:
  `torso` partido en `chest` & `stomach` (COA-8/COA-7, ratificado, bajado a código y
  verificado en juego el 2026-07-21 — ronda O: 6/6).
  **Craving estrenó repo y cerró su Block 4 en dos días** (2026-07-13/14: diseño
  ratificado + código + tres rondas de verificación en juego — decay/umbrales, puente
  mock-first a Coagulant, 6 consumibles contra Cargo, entity de mundo con WALK+USE,
  barras; los 12 entries de su CHANGELOG en `[APLICADO]`, ya commiteados y pusheados).
  **Cortex se FUNDÓ el 2026-08-24** —dejó de ser repo semilla: nació su
  [`CLAUDE.md`](../../corpus-cortex/CLAUDE.md), o sea la sede de la familia `CTX`, que hasta
  ese día estaba reservada **sin poder acuñar una sola norma**, más su estado, roadmap y
  arquitectura— pero **sigue sin código**: lo que abrió es un bloque de DISEÑO, el de
  escuadrones. ⚠ Y el gate que este framework venía enunciando sin partir (*«Cortex arranca
  cuando Caliber exponga los eventos daño/limb»*) cubre **el afecto y no el módulo entero**:
  la táctica y el escuadrón no dependen de esa superficie. Desde el 2026-07-19 tiene además
  [`docs/Cortex_ContratosEntrantes.md`](../../corpus-cortex/docs/Cortex_ContratosEntrantes.md):
  las **seis** firmas que otros repos ya le congelaron, juntas y cruzadas entre sí por primera
  vez (no se contradicen). Es doc de RECEPCIÓN, no su diseño. Cada
  módulo con docs lleva su propia foto en `<repo>/docs/<modulo>_estado.md`; legacy ADS 2.0 en
  `dev/legacy/` (tag `v1.0`, congelado) ya migrado a Caliber (§7 de la arquitectura).

## Pendiente de verificar

- **El rebuild automático del spawnmenu** (primitiva 4, PARCHE 1 del 2026-08-17). La CAUSA está
  confirmada a mano —la categoría "Corpus" salía vacía y `spawnmenu_reload` hizo aparecer las
  cuatro entradas—, pero eso acredita el diagnóstico, **no el parche**: falta ver que el rebuild
  dispare solo al cargar mapa. Criterio y trampa (que no parpadee dos veces, señal de debounce
  roto) en el CHANGELOG.
- Nada de la ready barrier: **cerró en juego el 2026-08-08, 4/4** (selftest_cl verde con
  `fuente=fallback` y `_readyQueue=0`; las líneas `(…, client)` que nunca habían salido; 51 defs
  no-bulk en `cargo_dev_items_cl`; las 5 barras en el panel). **Ojo con lo que NO cerró:**
  `fuente=fallback` dice que **nuestro callback** de `InitPostEntity` sigue sin correr en el realm
  cliente — el respaldo lo cubre y el log lo hace visible. **El evento sí se dispara**; quién corta
  la cadena de hooks sigue sin identificarse. Ver la deuda de abajo.
- La tanda de `Corpus.Data` cerró con la **planilla T en 9/9** (2026-07-26) y sus seis
  parches en `[APLICADO]`. Planilla:
  https://claude.ai/code/artifact/fc204b66-e751-42a2-af8a-0c02429934bd
- El banco de sonidos se **confirmó en juego el 2026-07-24** desde sus consumidores
  (Cargo entry 35 a-e ✓, Craving ✓); ese CHANGELOG está todo en `[APLICADO]`.

## Remanentes / deuda conocida

- **Nuestro callback de `InitPostEntity` no corre en el realm CLIENTE — y el EVENTO SÍ SE
  DISPARA** (arco B ronda 2, 2026-08-09; el cierre del 2026-08-08, que decía lo contrario, queda
  **REFUTADO**). Medido en el `console.log` del autor, nueve arranques: el callback CLIENTE de
  `InitPostEntity` de Quick Loadouts (`cl_loadoutmenu.lua:1822`, `include` sólo en la rama CLIENT)
  corre 11-12 líneas **antes** de nuestra línea `disparados por fallback (client)`, en el mismo
  arranque en que el selftest dice que el nuestro no corrió. No puede ser la ruta del menú: el
  menú exige una tecla y la tecla exige el `LocalPlayer()` válido que recién habilita el paso
  siguiente, y el concommand no aparece en las 61.397 líneas.
  **Mecanismo, en la fuente del engine en disco** (`lua/includes/modules/hook.lua`, `Call`):
  `if ( a != nil ) then return … end` **aborta la cadena entera**, así que un tercero que devuelva
  algo deja sin evento a todos los que caigan después en el `pairs()` — sin saber nuestro nombre y
  sin un error de Lua. Eso **tumba** el argumento con que el arco se había cerrado («tendría que
  matarlo para todos, da igual quién sea»): el corte es sólo para los de más abajo en la fila.
  **Quién corta: SIN IDENTIFICAR** — los 41 `hook.Add("InitPostEntity")` de `dev/other/` no
  devuelven valor al nivel del handler, pero ahí no están los 380 suscritos.
  **Lo separaría una medición que hoy no existe:** si nuestro hook está en
  `hook.GetTable()["InitPostEntity"]` en runtime del cliente, el corte es por retorno; si no está,
  alguien nos borró por nombre. **No se escribió**: sigue siendo conocimiento, no funcionalidad.
  **Testigos:** Quick Loadouts sirve; **Better Movement NO** —su `bm_init` CLIENT sólo escribe NW2
  vars que el server reescribe en cada `PlayerSpawn` y replica, así que su ausencia no da síntoma:
  habría dado verde sin medir.
  **La lección, y es de instrumento:** `_initPostEntitySeen` la escribe el propio callback, o sea
  que sólo mide «corrió NUESTRO hook»; imprimirla como `initPostEntity=NO llegó` hizo que el
  **nombre** contrabandeara la conclusión a tres docs y un header. Hoy el rótulo es
  `hookIPE=corrió | NO corrió`. `mundoAlCargar` midió bien lo suyo y nunca autorizó el salto.
- **Sin `addon.json` todavía** — el repo aún no se puede empaquetar para Workshop
  (§8 de la arquitectura pide uno por raíz). No bloquea el testeo local en
  `garrysmod/addons/`.
- **`docs/Caliber_Architecture.md` movido a `corpus-caliber/docs/`** — el diseño del
  Block 2 vive ahora en el repo del módulo (junto a su doc particular de escudos),
  por el principio de que los docs de módulo viven en su repo. Ya no está acá.

## Próximo paso

1. **Módulos en curso (su propio frente):** Caliber va a su Block 3 (armadura de jugador,
   NPC→agnóstico); Cargo está en el **slice 2 del comercio** (el dinero como entidad). El
   detalle vive en sus roadmaps/estados, no acá.
2. **Coagulant:** Block 3 **CERRADO** y todo verificado (ronda 7, mini-ronda 8 y check
   N1; CHANGELOG entero en `[APLICADO]`). El tramo de zonas `chest`/`stomach` (COA-8/
   COA-7) está **completo**: ratificado, bajado a código y verificado en juego el
   2026-07-21 (ronda O, 6/6). Pendientes de su repo: dos decisiones de diseño del autor,
   y ratificar `ApplyExternalCondition` con Craving (deuda D-5 — el 2.º argumento es el
   id de condición clínica, no el stat).
   **Craving:** Block 4 cerrado, verificado, commiteado y pusheado.
   **Cortex** espera su Block (§9): depende de los eventos daño/limb que Caliber expondrá
   con el pipeline de jugador — mock-first si hace falta antes.
3. **Framework:** `Corpus.Data.Delete` **ya no es candidata: existe**, junto con `List` y el
   scope (2026-07-25), y subió cuando el consumo lo justificó — framework delgado (§1). Lo que
   **sigue** abierto de esa lista es el **gate de admin reutilizable que pide Cargo** (CRG-45,
   su sesión de diseño propia): mientras no exista, el comando de purga de Cargo va con
   dry-run por default. De las dos deudas que dejó la tanda, **el `dev/harness_corpus.py` propio
   se CERRÓ el 2026-08-24** (456 checks + 53 sabotajes; con él se cayó también el número fantasma
   de "46 checks" que no tenía archivo detrás); sigue abierta la de los dos sidecars JSON del caché
   de íconos de Cargo (nota de COR-18 en `ids.yaml`, con su motivo). **Nuevo desde el 2026-08-24:**
   la séptima primitiva pide sus tandas 2 a 4 —el commit y las tres puertas del server, el dibujado
   contra el mock v2, y las acciones baratas—, y **la 2 arrastra un voto del autor que no se puede
   tomar por él**: cómo se nombra al EJECUTOR en el mensaje de net (§8.bis del doc de interacción,
   cuatro opciones levantadas). La tanda 1 no lo tocó porque el registro pelado no manda mensajes.
4. **Anti-drift: LISTO PARA EL 2.º COMPLETO (2026-07-19).** El 1.er COMPLETO corrió ÍNTEGRO
   (29/29 docs, Opus 4.8, 8,3M tokens; acta:
   [`auditorias/2026-07-19_coherencia_docs.md`](auditorias/2026-07-19_coherencia_docs.md)),
   su tanda de reparación está APLICADA (25 bucket A + el voto B: **GC del cadáver looteado
   → CARGO**), y **las dos deudas que quedaban se cerraron**:
   - **D-12 —** existe [`dev/harness_coagulant.py`](../../dev/harness_coagulant.py) (voto
     del autor: materializar). 173 checks en ambos realms; el snapshot que produce el realm
     SERVER se inyecta en el CLIENT, así que la igualdad entre realms (COA-5) se verifica de
     verdad. Las **17** acreditaciones `tipo: harness` que apuntaban a un archivo inexistente
     —16 COA + COR-12, no las 4 que el acta nombraba— ya son citables.
   - **D-13 —** los 10 docs ciegos declaran IDs (**9 acuñados**, el resto citas: los roadmaps
     y las semillas son intención pura y no acuñan); nacieron los 3 docs que faltaban
     (arquitectura y convenciones de `corpus-stalker`, contratos entrantes de Cortex); y el
     gate tiene sus 4 mejoras: 18 buckets, fase **contrato-vs-árbol**, la jerarquía citada
     por ID en vez de duplicada, y la columna `total` re-derivada — **estaba mal en las 29
     filas, no en 5** (se había contado sin las líneas vacías, y los TRAMOS salen de ahí:
     la cola de cada doc quedaba sin leer).
   Registro: **213 IDs**, 26 % INTENCION (corrida del checker 2026-07-25). **D-3** quedó recortada a **once sedes en `.lua`**
   —cero en CHANGELOG, estado o roadmap—, y varias de esas once son legítimas.
   El **SCOPED del 2026-07-20** (AUD-1) cerró el ciclo: reparado, y el gate estrena **fase 0
   «Conteo»** —`total` pasó de constante a **checksum derivado del árbol**, el defecto que
   bloqueaba el COMPLETO— más cinco estados por bucket y un pase de VALOR.
   **Lo que sigue: correr el 2.º COMPLETO** (sesión fresca, Opus 4.8, su propio PROMPT —
   AUD-3; editar el `.js` invalidó el caché de resume, es esperable). **`D-14` CERRADA por
   voto del autor: COR-12 SE QUEDA** — no gobierna ítems sino el protocolo de registro entre
   módulos, del linaje de COR-3/COR-4; enuncia la FORMA, jamás la SEMÁNTICA, y si algún día
   menciona stacks, peso o slots el voto se reabre. Deudas de verificación **en juego, del
   autor**: la entry #27 de Cargo (`[PENDIENTE]` con código en árbol) y el **PARCHE 1 de la
   primitiva 4** del 2026-08-17 (el rebuild automático del spawnmenu; la CAUSA ya está
   confirmada a mano con `spawnmenu_reload`, falta que dispare solo) — Coagulant quedó
   sin ninguna (ronda 7, mini-ronda 8 y check N1, todo ✓).
5. **La primitiva 4 ya NO es la única sin check, y ahí vivió un bug** (2026-08-17): la categoría
   "Corpus" salía vacía porque el spawnmenu se arma en `OnGamemodeLoaded`, antes de que los
   módulos booteen en `Initialize`. El header de `corpus_ui.lua` afirmaba lo contrario **sin
   medición**, y el `corpus_selftest` declara que el tab "se verifica visual". **Desde el
   2026-08-24 tiene cobertura offline** —el orden alfabético de las entradas, el debounce del
   rebuild, que el tab tardío lo agende y el `pcall` del `buildFn`, los cuatro verificados en
   negativo—, así que **el bug de aquel día hoy saldría rojo antes de llegar al juego**. Lo que
   sigue sin cerrar es la mitad de MOTOR: `Corpus.UI._tabs` **no es inspeccionable en juego**
   (`lua_run_cl` gateado por `sv_allowcslua`), y un `corpus_ui_dump` de realm CLIENT la cierra —
   es hermano del `corpus_interact_dump` que la tanda 2 del menú ya tiene presupuestado.

---

*Rumbo / qué sigue → [`corpus_roadmap.txt`](corpus_roadmap.txt). Diseño de referencia →
[`CORPUS_Architecture.md`](CORPUS_Architecture.md). Metodología →
[`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).*
