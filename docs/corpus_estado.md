# Corpus — Estado de HOY

> **Foto del AHORA**, volátil. Es lo primero que se lee al retomar el proyecto —
> **antes** que el doc de arquitectura. Se actualiza **en sitio** (no se agregan
> secciones ni historial). El historial vive en `git` + [`CHANGELOG.md`](CHANGELOG.md).
> Si crece de una pantalla, está mal redactado: recortar.
> Cita **FLU-15**, cuya sede es [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt)
> §1 PASO 5 — este doc la aplica, no la define.

**Última actualización:** 2026-08-09 (**arco B ronda 2: el cierre del 2026-08-08 estaba MAL y
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
  Verificación: harness offline con stubs de GMod (46 checks, ambos realms) +
  `corpus_selftest` en juego el 2026-07-09 (realm SERVER, todo OK) + check visual de
  UI cerrado el mismo día con el primer tab real (Caliber en menú Q → Utilities →
  Corpus). **Las 6 primitivas verificadas de punta a punta por un consumidor real.**
  **Persistencia ampliada el 2026-07-25** (siguen siendo **6** primitivas: Data es UNA, con
  más superficie): `Corpus.Data.Save/Load/List/Delete` + `opts.scope` — **COR-19** separa
  config de servidor de estado de partida y **COR-18** cierra la puerta a `file.*` para
  estado propio. Los dos scopes resuelven a la misma carpeta **a propósito**: el gancho
  está puesto, no activado.
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
   dry-run por default. Deudas que dejó la tanda: los dos sidecars JSON del caché de íconos de
   Cargo (nota de COR-18 en `ids.yaml`, con su motivo) y un `dev/harness_corpus.py` propio —
   hoy la primitiva se acredita contra `harness_cargo.py`, que ya carga el framework real, y
   los "46 checks" que este doc cita más arriba no tienen archivo que los respalde.
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
5. **La primitiva 4 es la única sin check, y ahí vivió un bug** (2026-08-17): la categoría
   "Corpus" salía vacía porque el spawnmenu se arma en `OnGamemodeLoaded`, antes de que los
   módulos booteen en `Initialize`. El header de `corpus_ui.lua` afirmaba lo contrario **sin
   medición**, y el `corpus_selftest` declara que el tab "se verifica visual". Además
   `Corpus.UI._tabs` **no es inspeccionable en juego** (`lua_run_cl` gateado por
   `sv_allowcslua`): un `corpus_ui_dump` de realm CLIENT cierra las dos deudas.

---

*Rumbo / qué sigue → [`corpus_roadmap.txt`](corpus_roadmap.txt). Diseño de referencia →
[`CORPUS_Architecture.md`](CORPUS_Architecture.md). Metodología →
[`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).*
