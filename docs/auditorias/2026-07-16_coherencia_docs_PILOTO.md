# Acta de auditoría de coherencia documental — PILOTO

**Fecha:** 2026-07-16 · **Modo:** SCOPED / PILOTO (solo `corpus/`, el framework)
**Gate:** `.claude/workflows/auditoria-coherencia-docs.js` (§7.8 de `corpus_flujo_trabajo.txt`)
**Autoridad aplicada:** `corpus_flujo_trabajo.txt` §7.1 (código > estado.md > CHANGELOG > CLAUDE.md > arquitectura > roadmap; `ids.yaml` fuera de la jerarquía, es índice).

> **ESTA ACTA ES INMUTABLE.** Es la foto del estado **al momento de auditar**, no la de hoy.
> No se edita: si algo cambió, lo dice el acta siguiente.
> **READ-ONLY:** el único archivo que esta auditoría escribió es este acta. Todos los parches
> están **PROPUESTOS**, ninguno aplicado. El gate propone, el autor dispone.

**Sujetos auditados (4):** `docs/corpus_flujo_trabajo.txt`, `docs/CORPUS_Architecture.md`,
`docs/corpus_convenciones_commits.txt`, `docs/corpus_roadmap.txt`.
`docs/ids.yaml` se usó como **glosario**, nunca como sujeto. Ver §5 y §7.

**Resultado:** 7 contradicciones confirmadas (mayoría ≥2/3 verificadores adversariales),
1 divergencia yaml-vs-sede, 49 normativas sin ID, 41 afirmaciones con alcance no declarado.
**Cero BLOQUEANTES.**

---

## 1. Resumen ejecutivo — lo que cambia el plan

Tres cosas, en orden. Ninguna detiene construcción de runtime; las tres corrompen decisiones de proceso.

### 1.1 `corpus_estado.md` afirma que el gate LLM no existe — y el gate existe, en disco, corriendo esta auditoría

`docs/corpus_estado.md:37` dice, literal: **"El gate LLM (E) no existe."** y `:83` lo reitera como
pendiente. Pero `.claude/workflows/auditoria-coherencia-docs.js` existe (~35 KB, implementación
real: `PILOTO` en `:28`, `CORPUS_PILOTO` en `:140`, las seis fases en `:255/305/346/500/542`), y
`docs/auditorias/README.md` lo trata como operativo.

**Por qué cambia el plan:** `estado.md` es el doc que `CLAUDE.md` manda leer **PRIMERO** al retomar
("dice qué existe hoy"). La línea falsa se paga cada sesión nueva: induce a **reimplementar un gate
que ya está escrito**. Es el hallazgo con mayor costo esperado del lote, aunque su gravedad técnica
sea MEDIA. → **Hallazgo #3, bucket A.**

**Corolario grave, y es de esta auditoría contra sí misma:** `estado.md` fue usado como **árbitro**
(el "árbitro-historia" lo cita) en 3 de las 7 contradicciones, pero **jamás fue sujeto**. Se adjudicó
con una regla que esta misma acta demuestra torcida. No invalida los seis hallazgos restantes — el
árbitro decisivo en todos fue el árbol real (nivel 1) — pero es una debilidad metodológica que hay
que cerrar antes de la próxima pasada.

### 1.2 Construir según `corpus_roadmap.txt` §3 rompe el contrato de `corpus_flujo_trabajo.txt` §2

`corpus_roadmap.txt:81-82` ordena, al cerrar un Block de módulo: *"Nueva sección autocontenida en
CORPUS_Architecture.md"*. `corpus_flujo_trabajo.txt:191-194` (sede canónica) prohíbe exactamente eso:
*"la sección del doc general queda como resumen corto + link al particular; **el contenido nunca se
duplica entre ambos**"*. Y `CORPUS_Architecture.md:328` declara el patrón ya consumado.

**Ejecutar el roadmap literalmente produce la duplicación que la sede prohíbe.** El árbol dirime:
los cuatro módulos con Block cerrado desprendieron su doc particular en su propio repo, y
`CORPUS_Architecture.md` no contiene **ninguna** sección de módulo (9 secciones, ninguna de bloque).
El roadmap es el que está mal — es nivel 6 (intención), sin autoridad sobre lo que existe.
→ **Hallazgos #5, #6, #7 — tres sedes del mismo drift, bucket A.**

### 1.3 El framework-delgado, la regla que decide qué sube a Corpus, está enunciada con cuatro piezas donde el código tiene seis

`CORPUS_Architecture.md:39` — *"Solo aloja infraestructura demostrablemente compartida (registro,
persistencia, net, UI shell)"*. Cuatro. `:82` — *"Seis primitivas."* Y el Lua tiene seis
(`corpus_ready.lua:11`, `corpus_log.lua:7`). El `"Solo"` convierte la lista en normativa: un lector
literal de §1 **rechazaría una primitiva candidata legítima del tipo ready/log** que el framework ya
aloja y verificó en juego. Gravedad BAJA porque `CLAUDE.md` y §3 ya dicen lo correcto — pero §1 es
la sede que se cita al decidir qué sube. → **Hallazgo #1, bucket A.**

---

## 2. Contradicciones confirmadas, por gravedad

Ninguna BLOQUEANTE. 3 MEDIA, 3 BAJA (el lote de roadmap agrupa dos MEDIA y una BAJA).

---

### #3 — `estado.md` niega la existencia del gate LLM · **MEDIA** · tema `evidencia` · **TRIAGE A** · 3/3 votos

| | |
|---|---|
| **A** | `docs/corpus_estado.md:37` — **"El gate LLM (E) no existe."** (y `:83`, "queda el Bloque E") |
| **B** | `docs/corpus_flujo_trabajo.txt:443-448` (§7.6) y `:500-548` (§7.8) — el gate vive en `.claude/workflows/auditoria-coherencia-docs.js`, seis fases, dos modos, cadencia AUD-1/2/3 |
| **Gana** | **B**, por el árbol real (§7.1 nivel 1) |

**Evidencia que decide.** El archivo existe y no es semilla: `.claude/workflows/auditoria-coherencia-docs.js:4`
(`whenToUse: '... args: { fecha, piloto: true|false, destino }'`), `:28` (`const PILOTO = !!ARGS.piloto`),
`:111/:140/:142` (`CORPUS_COMPLETO` / `CORPUS_PILOTO = CORPUS_COMPLETO.filter(d => d.repo === 'corpus')`
/ `const CORPUS = PILOTO ? CORPUS_PILOTO : CORPUS_COMPLETO`), `:139` (la restricción D-7 **cableada** en
comentario), `:255/:305/:346/:500/:542` (las seis fases implementadas), `:604-615` (emite acta).
`docs/auditorias/README.md` existe y trae "Cómo se corre" + tracker de cobertura. `git status --porcelain`
los marca `??` (untracked, tanda en curso).

**Por qué A quedó viejo, datado.** `docs/CHANGELOG.md:224` (sesión anterior del mismo día): *"Bloques A
y B del plan; C (checker), D (template de PROMPT) y **E (gate LLM) NO se aplicaron**"* — nota de **alcance
de aquella sesión**, no afirmación permanente. Y `estado.md` se refrescó **a medias**: ya describe el
checker (Bloque C) y el §8 (Bloque D) como hechos, y arrastró la frase de E. Prueba independiente:
`estado.md:31` lleva "184 IDs" frente a los 178 de `CHANGELOG.md:254` — se refrescó **después** y no se
corrigió este punto.

**No es falso positivo:** es el vector **inverso** a "no implementado todavía" — el código existe y el
doc niega su existencia. Caso (b) del criterio.

**Parche PROPUESTO (no aplicado).** Doc perdedor: `docs/corpus_estado.md`. Ubicar por **contenido**, no
por línea (§7: "los números corren").

*(a)* En el bullet **"Anti-drift (2026-07-16, portado del SDD de Kontrol):"**, QUITAR el literal
`**El gate LLM (E) no existe.**` y escribir en su lugar:

> El **gate LLM (§7.8)** vive en `.claude/workflows/auditoria-coherencia-docs.js`: seis fases, tres
> verificadores adversariales (sobrevive por mayoría ≥2 de 3), READ-ONLY estricto — propone parches, no
> los aplica. Modo **SCOPED** (`piloto: true`, solo los docs del framework) operativo; el **COMPLETO**
> (los 19 docs de las siete raíces) queda **diferido por la deuda D-7** (sin IDs etiquetados en la prosa
> de los módulos, un "limpio" suyo significaría "no auditado", no "sano" — lección §10.8 de Kontrol, 22
> hallazgos post-limpio). Actas inmutables en [`auditorias/`](auditorias/); su README es el tracker de
> cobertura.

*(b)* En **"## Próximo paso"**, reescribir el punto 4 para que lo pendiente sea **D-7**, no el Bloque E:

> 4. **Anti-drift:** los tres anillos existen (constitución §7 + registro `ids.yaml`, checker §7.7 en
>    `pre-commit`, gate §7.8). Lo que queda es **D-7**: etiquetar los IDs en la prosa de los módulos,
>    cada repo en su próxima pasada — es el bloqueo del gate en modo **COMPLETO**, no una tarea suelta
>    (§10.8 de Kontrol: allá costó 22 hallazgos post-limpio). El **SCOPED** ya corre al cerrar cualquier
>    sesión que escriba normas (AUD-1), con la salvedad AUD-3: nunca con poco contexto remanente. Las
>    deudas **D-1** y **D-9** son trampas activas: se reparan en la próxima pasada de Cargo, y **D-6** es
>    un voto de una línea.

*(c)* **Barrido de ratificación (§7.3), fuera del estado:** falta la entrada del Bloque E en
`docs/CHANGELOG.md` (el gate + `docs/auditorias/README.md` + §7.6/§7.8 del flujo). Sin borrar ni
renumerar, y **sin editar** `CHANGELOG.md:224` — es inmutable; la entrada nueva la deroga (FLU-14).

**MATIZ contra el parche que un verificador propuso:** NO escribir "el SCOPED sí corre" como hecho
consumado con corridas previas. `docs/auditorias/README.md` cierra su tracker en *"(sin corridas
todavía)"*: al momento de auditar, el SCOPED está cableado y disponible, con **cero corridas**. Esta acta
es la primera. Afirmar lo contrario sería cambiar una deriva por otra.

---

### #2 — Los tipos de evidencia: la sede dice CUATRO, el `ids.yaml` opera con CINCO · **MEDIA** · tema `evidencia` · **TRIAGE B (VOTO DEL AUTOR)** · 3/3 votos "es real", ganador disputado

| | |
|---|---|
| **A** | `docs/corpus_flujo_trabajo.txt:413-420` (§7.4, **sede** de FLU-31) — enumeración cerrada de **CUATRO**: `selftest \| harness \| planilla \| INTENCION`. Ratificado literal por `docs/CHANGELOG.md:236` [APLICADO 2026-07-16]: *"el registro y sus **cuatro tipos** de evidencia (§7.4)"* |
| **B** | `docs/ids.yaml:17-25` y `:382` (título de FLU-31) + ~30-69 entradas con `tipo: codigo` — **CINCO**: `... \| codigo \| INTENCION`, donde `codigo` = *"el call site en Lua que ejerce la norma, cuando no hay check"* |
| **Gana** | **A por la letra** (§7.1: el yaml no litiga contra su sede) — **pero el ganador *material* no lo decide el código.** Ver abajo. |

**Es contradicción real, sin discusión** (3/3): dos enumeraciones **cerradas** del mismo conjunto, mismo
alcance exacto (transversal: sin realm, módulo, soft-dep ni slice que las separe), difieren en un miembro.
§7.4 no dice "entre otros". No es nivel de detalle.

**El árbitro alegado NO existe — refutación verificada.** La ficha original sostenía que "el checker acepta
`codigo` sin objetar, luego por §7.1 el código manda". **Falso como evidencia.** `.claude/check-ids/corpus_check_ids.ps1`
CHECK 3 (`:297-377`) **no tiene whitelist de tipos**. La única validación es `:341`:
`if (-not $tipo) { Add-Err 'EVIDENCIA_ROTA' ... }` — solo exige que `tipo` no esté vacío. Especializa
únicamente `INTENCION` (`:336`) y `planilla` (`:347`); todo lo demás cae al bloque genérico "Otros tipos"
(`:364-376`), que valida solo refs con forma de ruta. **`tipo: banana` pasaría idéntico.** El checker es
**agnóstico al tipo**: su silencio es permisivo, no ratificante. No hay nivel 1 detrás de B.

**El yaml se contradice a sí mismo, lo que lo hunde como fuente:** `ids.yaml:22` y `:382` enumeran cinco,
pero la nota de `salud` del **mismo archivo** (`ids.yaml:1552`) dice *"tres capas de evidencia (selftest +
harness offline + planilla en juego)"* — tres capas + INTENCION = los **cuatro** de §7.4. Y su propio
encabezado (`:10-12`) se subordina: *"la SEDE gana siempre; si el yaml contradice la prosa de la sede, el
yaml está DESACTUALIZADO"*.

**POR QUÉ ES BUCKET B Y NO A.** Formalmente gana A. Pero el parche a A es **destructivo y probablemente
contrario al intento del autor**, y ningún nivel 1-4 dirime el hecho de fondo — si el quinto tipo *nació*
o si el yaml *se lo inventó*. Es el corolario de §7.1: afirmación sobre algo no ejercido por código →
**voto del autor**, no parche unilateral.

**RUTA 1 — "`codigo` fue drift" (la que manda la letra de §7.1).** Borrar `ids.yaml:22`, reescribir el
título de FLU-31 a cuatro tipos (`ids.yaml:382`), y **reclasificar las entradas con `tipo: codigo`**
(conteo verificado divergente entre verificadores: ~30 en un barrido, **69 de 138 no-INTENCION** en otro
— el autor debe contar antes de decidir; ejemplos: `:79`, `:107`, `:378-379`, `:387`).
**Costo:** sube la métrica de salud de 25 % (44/178, `CHANGELOG.md:256`) a ~42 % o más, porque decenas de
normas hoy evidenciadas por call site pasarían a INTENCION. Además devuelve **FLU-25/FLU-30/FLU-31 a
INTENCION**, lo que choca de frente con `CHANGELOG.md:323-326` (PARCHE 5, [APLICADO 2026-07-16]).

**RUTA 2 — "`codigo` es un quinto tipo legítimo".** Entonces **no es una corrección de §7.4: es una
ACUÑACIÓN de norma nueva**, y es acto **autoral**, no de gate. Requiere tres sedes en el mismo parche:
- *(a)* `corpus_flujo_trabajo.txt:419`, insertar tras la línea de `planilla` el literal ya redactado en `ids.yaml:22`:
  `codigo    — el call site en Lua que ejerce la norma, cuando no hay check`
- *(b)* **entrada NUEVA `[PENDIENTE]` en `docs/CHANGELOG.md`** que acuñe el quinto tipo. **NO se edita
  `CHANGELOG.md:236`** ("cuatro tipos"): esa entrada es historia [APLICADO] y describe correctamente lo
  que se aplicó ese día. El CHANGELOG no se reescribe.
- *(c)* `ids.yaml:1552` (nota de `salud`, "tres capas") quedaría desactualizada.
- *(d)* barrido §7.3 **por el valor**: grep de `"cuatro tipos"` sobre las siete raíces + el espejo
  `.claude/desktop-sync/`.

**RECOMENDACIÓN DE INGENIERÍA (el gate propone).** La Ruta 2 parece el intento real: `codigo` resuelve un
vacío legítimo — normas ejercidas por un call site sin check, como el propio checker respecto de
FLU-25/FLU-30/FLU-31. **Pero el autor debe decidir con esto delante:** §7.4 define evidencia como **un
check que cita el ID**. `codigo` **no es un check** — es un puntero al call site. Admitirlo permite que una
norma declare evidencia sin que nada la ejerza, que es exactamente lo que **INTENCION** nombra. Y como el
conteo de INTENCION es **la métrica de salud**, decenas de entradas `codigo` podrían estar **deprimiendo
artificialmente la métrica** sin haber ganado mecanismo. Eso es diseño, no deriva.

**Fix de fondo, independiente del voto:** CHECK 3 no valida `tipo` contra ninguna lista. Un whitelist
**derivado del yaml** (no de la prosa — FLU-27) habría cazado esta divergencia sola el 2026-07-16.

**Ironía registrada:** FLU-27 dice que *"una norma que enumera se deriva del código, no de la prosa"*.
Acá el código no enumera nada, así que no hay de dónde derivar — y por eso el hecho no tiene árbitro.

---

### #5 — El roadmap ordena una sección autocontenida donde la sede prohíbe duplicar · **MEDIA** · tema `proceso` · **TRIAGE A** · 3/3 votos

| | |
|---|---|
| **A** | `docs/corpus_roadmap.txt:81-82` — checklist al cerrar Block de módulo: *"Nueva sección autocontenida en CORPUS_Architecture.md"* |
| **B** | `docs/CORPUS_Architecture.md:328` (y `:5`, `:339`) — *"Los bloques de módulo, en la práctica, **no** se agregaron como secciones de este archivo... Acá queda el resumen y el link"* |
| **Gana** | **B**, por árbol real (nivel 1) + CHANGELOG [APLICADO] (nivel 3) |

**Evidencia que decide.** `grep '^## '` sobre `CORPUS_Architecture.md` da **exactamente 9 secciones**
(1.Visión, 2.Grafo, 3.Superficie, 4.Fronteras, 5.Contrato de ítems, 6.Orden de carga, 7.Migración
ADS→Caliber, 8.Workspace, 9.Estado) — **cero** secciones de bloque de módulo, pese a que los Blocks 2-4
cerraron. En paralelo, los cuatro docs particulares existen en sus repos dueños:
`corpus-caliber/docs/Caliber_Architecture.md`, `corpus-coagulant/docs/Coagulant_Architecture.md`,
`corpus-craving/docs/Craving_Architecture.md`, `corpus-cargo/docs/Cargo_Architecture.md`
(más `Caliber_EnergyShields_`, `Cargo_Trade_`, `Workbench_`, `Cargo_ItemImages_`).

Sede canónica: `corpus_flujo_trabajo.txt:176-183` — *"(a) se documenta como sección nueva en el
`<modulo>_Architecture.md` general **del repo afectado**"* (para un Block de módulo, el repo afectado es
el **hermano**, no `corpus/`), y `:191-194` — *"el contenido nunca se duplica entre ambos"*.

**Derogación ratificada:** `docs/CHANGELOG.md:170-181` — PARCHE 1, *"`CORPUS_Architecture.md` reconciliado
con el árbol real... **[APLICADO 2026-07-14]**"* — es el parche que **produjo el texto de B**.
`CHANGELOG.md:58-64` — PARCHE 7 [APLICADO 2026-07-08] formalizó el patrón general-vs-particular. La misma
pasada del 2026-07-14 editó el roadmap (`CHANGELOG.md:196+`, PARCHE 4) pero **solo su prosa de estado de
módulos**; el checklist de §3 quedó intacto **por omisión**. Es la causa raíz que el propio PARCHE 3
diagnostica: *"los docs del módulo quedaban al día y los del framework se pudrían porque nadie era su dueño"*.

**Descarte de la lectura benigna:** no cabe leer "CORPUS_Architecture.md" como abreviatura de
"`<Modulo>_Architecture.md`" — el roadmap nombra el archivo del framework por ruta exacta y consistente
(`:67` "La tabla §9 de CORPUS_Architecture.md"; `:93` "docs/CORPUS_Architecture.md → §9").

**Parche PROPUESTO (no aplicado).** Doc perdedor: `docs/corpus_roadmap.txt` §3, línea 82.

Texto actual:
```
  - Nueva sección autocontenida en CORPUS_Architecture.md.
```
Texto propuesto:
```
  - Nueva sección autocontenida en el <Modulo>_Architecture.md del repo afectado
    (se desprende a doc particular si el bloque lo amerita, flujo_trabajo §2).
  - Resumen + link en la fila del bloque en CORPUS_Architecture.md §9 (y en §7 si
    corresponde). El contenido nunca se duplica entre general y particular — FLU-18.
```

`corpus_flujo_trabajo.txt:176-177` **no se toca**: ya dice "del repo afectado" y es correcto. El roadmap
era el único que colapsaba "repo afectado" en "`corpus/`".

---

### #6 — La regla anti-deriva del §0 del roadmap contradice la sede del detalle de diseño · **MEDIA** · tema `proceso` · **TRIAGE A** · 3/3 votos

| | |
|---|---|
| **A** | `docs/corpus_roadmap.txt:13-16` — *"el detalle de diseño de cada bloque vive en CORPUS_Architecture.md (una sección nueva por bloque, ver §9); acá NO se duplica ese detalle"* |
| **B** | `docs/CORPUS_Architecture.md:5` — *"El diseño interno de cada módulo **no** vive acá: cada uno desprendió su doc particular autocontenido en su propio repo... Este documento conserva el resumen y el link (§9)"* |
| **Gana** | **B**, por árbol real + `corpus_flujo_trabajo.txt:176-178` (doc canónico) |

Misma raíz que #5, **sede distinta** dentro del mismo archivo → **necesita su propio parche**. Si se
flipea solo uno, el roadmap queda internamente inconsistente.

**Autorefutación interna del perdedor, decisiva:** `corpus_roadmap.txt:51` y `:57` **ya remiten** a
`Coagulant_Architecture.md` y `Craving_Architecture.md` como sede del detalle. El §0 quedó atrás **del
resto de su propio archivo**.

Registro: la norma es **FLU-18**, sede `flujo §2` (`ids.yaml:292-298`, VIGENTE). El roadmap **no es sede**
de FLU-18 y la enuncia distinto — es nivel 6 (intención) contra niveles 1 (árbol), 2 (`corpus_estado.md:26-30`),
3 (`CHANGELOG` [APLICADO 2026-07-14]) y 5 (la sede). Pierde en todos los ejes.

**Parche PROPUESTO (no aplicado).** `docs/corpus_roadmap.txt` §0 "CÓMO SE USA", líneas 13-16.

Texto actual:
```
Este doc ORDENA lo que sigue; corpus_estado.md dice en qué punto estamos. Ambos se
leen juntos al planear el próximo bloque. Regla anti-deriva: el detalle de diseño de
cada bloque vive en CORPUS_Architecture.md (una sección nueva por bloque, ver §9);
acá NO se duplica ese detalle — solo el orden y el criterio de entrada de cada tramo.
```
Texto propuesto:
```
Este doc ORDENA lo que sigue; corpus_estado.md dice en qué punto estamos. Ambos se
leen juntos al planear el próximo bloque. Regla anti-deriva (FLU-18): el detalle de
diseño de cada bloque vive en el <Modulo>_Architecture.md del repo dueño — o en el doc
particular (docs/<Subsistema>_Arquitectura.md) que ese repo desprenda, ver
corpus_flujo_trabajo.txt §2. CORPUS_Architecture.md §9 lleva solo el resumen y el link.
Acá NO se duplica ese detalle — solo el orden y el criterio de entrada de cada tramo.
```

**Nota:** el Block 1 (framework) es el único cuyo detalle vive en `CORPUS_Architecture.md`, y es así
porque **ese repo ES su dueño** — la regla nueva lo cubre sin excepción especial.

**Ajuste de coherencia (opcional, mismo parche):** `corpus_roadmap.txt:93` dice
`docs/CORPUS_Architecture.md → §9 (fuente del orden de bloques), diseño detallado`. Propuesto:
`→ §9 (fuente del orden de bloques) + resumen/link de cada bloque; el diseño detallado del framework`.

---

### #1 — Framework delgado: §1 enumera CUATRO primitivas, §3 y el Lua tienen SEIS · **BAJA** · tema `framework-delgado` · **TRIAGE A** · 2/3 votos

| | |
|---|---|
| **A** | `docs/CORPUS_Architecture.md:39` — *"**Solo aloja** infraestructura demostrablemente compartida (registro, persistencia, net, UI shell)"* |
| **B** | `docs/CORPUS_Architecture.md:82` — *"**Seis primitivas.** Nada de lógica de dominio."* (tabla §3, `Corpus.OnReady` en `:90`, `Corpus.Log` en `:91`) |
| **Gana** | **B**, por niveles 1 + 2 + 4 contra el 5 |

**Evidencia que decide.** El Lua: `lua/autorun/corpus_ready.lua:11` → `function Corpus.OnReady(fn)`;
`lua/autorun/corpus_log.lua:7` → `function Corpus.Log(module, ...)`. El árbol de `lua/autorun/` son
exactamente **6 primitivas + selftest** (registry, data, net, ready, log, `client/corpus_ui`). Ambas
aplicadas en `CHANGELOG.md:116-122` (PARCHE 5 `feat(ready)`, PARCHE 6 `feat(log)`, [APLICADO 2026-07-09]).
Foto de HOY: `docs/corpus_estado.md:22` — *"**Las 6 primitivas verificadas de punta a punta por un
consumidor real.**"* (y `:17` las lista). Contrato: `corpus/CLAUDE.md` enuncia **la misma regla cardinal
completa** con las seis: *"registro de módulos, persistencia, net, UI shell, ready barrier, log"*.

**Ninguna entrada de CHANGELOG derogó a A:** `CHANGELOG.md:170-182` (PARCHE 1, [APLICADO 2026-07-14])
reconcilió §2, §4, §5, §6, §7, §8 y §9 contra el árbol real y **no tocó §1** — la enumeración de `:39`
quedó fuera del barrido.

**Sobre el voto disidente (1 de 3).** El refutador sostuvo que el complemento del "Solo" es *lógica de
dominio*, no "toda primitiva fuera de estas cuatro", y que la sede de COR-10 es §3-4 (`ids.yaml:136-138`,
ratificado en `CORPUS_Architecture.md:122`), no §1. **Es un argumento serio y el autor debe conocerlo.**
Pierde por dos razones: (i) el `"Solo aloja"` seguido de enumeración cerrada **es** normativo con
independencia de dónde esté la sede formal, y §1 es lo que un lector lee al decidir; (ii) `CLAUDE.md`
enuncia la **misma** regla con las seis, o sea que no es empate §1-vs-§3 sino **2-contra-1 con la sede
canónica del lado de las seis** — dato que la adjudicación original no tuvo delante porque
**`CLAUDE.md` no fue sujeto** (ver §5.2). Eso refuerza al ganador, no lo cambia.

**Parche PROPUESTO (no aplicado).** Doc perdedor: `docs/CORPUS_Architecture.md:39`.

Texto actual:
```
**Regla cardinal:** Corpus es un framework **delgado**. Solo aloja infraestructura
demostrablemente compartida (registro, persistencia, net, UI shell). Ningún módulo sube
lógica de dominio a Corpus — ni siquiera algo compartido por dos módulos, como el pool de
HP de extremidades, que se queda en su dueño (Caliber) y se consume vía registro. Esa
línea es lo que evita que Corpus se vuelva un god-object con el tiempo.
```
Texto propuesto:
```
**Regla cardinal (COR-10, sede en §3-4):** Corpus es un framework **delgado**. Solo aloja
infraestructura demostrablemente compartida — hoy, las seis primitivas de [§3](#3-superficie-de-corpus--la-api-del-framework):
registro, persistencia, net, UI shell, ready barrier y log. Ningún módulo sube lógica de
dominio a Corpus — ni siquiera algo compartido por dos módulos, como el pool de HP de
extremidades, que se queda en su dueño (Caliber) y se consume vía registro. Esa línea es lo
que evita que Corpus se vuelva un god-object con el tiempo.
```

**Tres cambios y su porqué:** (1) la enumeración pasa a las seis reales — **único cambio obligatorio**;
(2) `"(...)"` → `"— hoy, las seis primitivas de §3: ..."` con puntero: deja la lista como **derivada** de
su sede en vez de segunda definición, para que una séptima primitiva legítima obligue a tocar §3 y no deje
a `:39` mintiendo otra vez (§7.2: toda norma define o cita un ID); (3) la etiqueta `(COR-10, sede en §3-4)`
hace visible que `:39` **cita** y no **define** — hoy el lector no tiene forma de saberlo, y es exactamente
lo que hizo verosímil esta contradicción.

**Alternativa mínima** para el autor: cambiar solo el paréntesis por `(las seis primitivas de §3)`. Cuesta
menos y mata el choque; pierde el señalamiento de sede.

**NO se tocan** `CORPUS_Architecture.md:82` ni `:122` (§3 ya dice seis y ya es la sede), ni
`ids.yaml:136-138` (COR-10 ya apunta a §3-4: el índice está correcto).

---

### #4 — El `ids.yaml` usa `tipo: planilla` de un modo que su sede prohíbe y su propia deuda D-2 declara imposible · **BAJA** · tema `evidencia` · **TRIAGE A** · 2/3 votos

| | |
|---|---|
| **A** | `docs/corpus_flujo_trabajo.txt:418-419` (§7.4) — *"`planilla` — un check de la planilla de verificación EN JUEGO, **por su ID estable**: 'planilla Caliber, check J4'"*; `:422-424` — *"Sus IDs no se reciclan entre rondas justamente para poder citarse desde acá"* |
| **B** | `docs/ids.yaml:214-215` (FLU-05) — `{ tipo: planilla, ref: "las planillas de Caliber, Cargo, Coagulant y Craving" }`; `:240-241` (FLU-09) — `{ tipo: planilla, ref: "pagado en Coagulant, ronda 3" }` — refs en prosa, **sin ningún ID de check** |
| **Gana** | **A**, por la regla no negociable: el yaml es índice, jamás segunda definición |

**El propio yaml se desmiente.** `ids.yaml:1603-1607` (deuda D-2): *"Tres de los cuatro módulos verificados
no tienen un solo ID de check: **su evidencia en juego no es citable**... Solo Coagulant usó IDs (A/E/G/H/I,
rondas 1-6)"*; y `:1558-1562`: *"Caliber, Cargo y Craving verificaron en juego SIN IDs de check: sus rondas
existen, pero **no dejaron nada citable**"*. FLU-05 cita como evidencia `planilla` **exactamente las
planillas que D-2 declara no citables**. No puede a la vez ser evidencia válida y ser no-citable.

Peor: `ids.yaml:1612` (D-2, "ACTUALIZADO 2026-07-16") **sobre-promete**: *"cualquier `planilla` que se
escriba sale EVIDENCIA_ROTA, con razón"*. En los hechos **se saltea**.

**El hueco presencial, confirmado en código.** `.claude/check-ids/corpus_check_ids.ps1:349` —
`if ($ref -match '^\s*([A-Za-z]+)\s+([A-Z][0-9]+)\b') {` ... y `:359-361`, cierre del `if` seguido de
`continue` pelado. Un ref `planilla` que **no** matchea el patrón **se ignora en silencio**: nunca llega a
`Add-Err 'EVIDENCIA_ROTA'` (`:357`), que existe justamente para *"la planilla no dejó rastro citable
(deuda D-2)"*. Los refs en prosa de FLU-05/FLU-09 no matchean, y por eso pasan. **El "limpio" acá no
prueba nada** — §7.6 desde el otro lado.

**Precedente correcto en el mismo archivo:** `ids.yaml:612` (CAL-10) —
`{ tipo: codigo, ref: "verificación en juego del autor, 2026-07-09 — sin IDs de check (ver deuda D-2)" }`.
Misma situación fáctica, tipada honestamente.

**Caso adyacente detectado de paso, no imputado como hallazgo propio:** `ids.yaml:227` (FLU-07) —
`{ tipo: planilla, ref: "Coagulant, rondas 1-7: cada ronda agregó sección nueva" }`. Mismo defecto de clase,
tampoco matchea. Si se parcha (a)/(b), corresponde barrer también éste.

**Sobre el voto disidente (1 de 3).** El refutador citó `corpus_check_ids.ps1:364-369`, que **documenta el
ignore-on-no-match como diseño**: *"El resto del ref es prosa a propósito: el checker valida lo que es
checkeable y no inventa. La calidad de la cita la cubre la curaduría (§7.4)"*, concordante con
`corpus_flujo_trabajo.txt:426-428` (*"La evidencia es PRESENCIAL, no semántica"*). **Y advirtió algo que el
autor debe sopesar antes de parchar:** `corpus_flujo_trabajo.txt:429-430` dice *"**No se impone evidencia
retroactiva por decreto**: la deuda se baja por pasadas"* — degradar FLU-05/FLU-09 a INTENCION para mover la
métrica **es ese decreto**, y D-2 es el canal declarado, ya abierto. Pierde 2-1 porque el choque literal
(tipo definido "por su ID estable" vs. refs sin ID) subsiste con independencia de si el checker lo caza; pero
**la objeción es legítima y el parche (a)/(b) no es urgente**.

**Parche PROPUESTO (no aplicado).** Doc perdedor: `docs/ids.yaml`.

*(a)* `ids.yaml:214-215` — FLU-05. Reemplazar por la opción honesta del precedente CAL-10:
```yaml
    evidencia:
      - { tipo: codigo, ref: "planillas de Caliber, Cargo, Coagulant y Craving — entregadas como Artifact; solo Coagulant dejó IDs de check (ver deuda D-2)" }
```
*(condicionado al voto de #2: si `codigo` se retira, va `evidencia: INTENCION`.)*

*(b)* `ids.yaml:240-241` — FLU-09. Si existe el ID del check de la ronda 3:
`{ tipo: planilla, ref: "Coagulant <ID> — ronda 3, el check que ejerce el concommand corto" }`.
`<ID>` lo fija el autor entre los IDs **reales** de Coagulant (A/E/G/H/I; las letras J/K/L/M del ejemplo del
handoff **no existen** — ver el bug (a) de `CHANGELOG.md:330-335`). Si ningún check de la ronda 3 ejerce la
norma → `evidencia: INTENCION`.

*(c)* **El fix de raíz** — `.claude/check-ids/corpus_check_ids.ps1:349-361`: que un ref `planilla` que no
matchee el patrón emita `Add-Err 'EVIDENCIA_ROTA'` en vez de caer al `continue`. Con fixture nueva en
`.claude/check-ids/test/fixtures/` (`evidencia-planilla-sin-id.yaml`, `Expect = 'EVIDENCIA_ROTA'`) y su fila
en `test/run_tests.ps1` — por la norma de la casa: *un checker que nadie vio en ROJO no es evidencia de nada*
(`CHANGELOG.md:313-315`). Esto además **vuelve verdadero** el texto de D-2:1612, en vez de bajarle la promesa.

**ORDEN OBLIGATORIO (FLU-04):** (a)(b)(c-de-FLU-07) van **ANTES** que (c-el-fix). Al cerrar el hueco, FLU-05
y FLU-09 pasan a fallar el `pre-commit` si no se retiparon antes — el parche bloquearía su propia tanda.

---

### #7 — El checklist de docs del primer Block: el roadmap enumera cuatro, la sede canónica cinco · **BAJA** · tema `proceso` · **TRIAGE A** · 2/3 votos

| | |
|---|---|
| **A** | `docs/corpus_roadmap.txt:84-87` — primer contenido real ⇒ `CLAUDE.md` + `docs/{<modulo>_estado.md, <modulo>_roadmap.txt, CHANGELOG.md, <modulo>_convenciones_commits.txt}` — **cuatro**, sin `<modulo>_Architecture.md` |
| **B** | `docs/corpus_flujo_trabajo.txt:179-183` — mismo disparo, **cinco**: los cuatro + `<modulo>_Architecture.md` |
| **Gana** | **B**, por CHANGELOG [APLICADO] (nivel 3) + árbol real (nivel 1) |

**Derogación explícita, con fecha.** `docs/CHANGELOG.md:61-65` (PARCHE 7): *"Se agrega
`<modulo>_Architecture.md` a la plantilla de docs que recibe un repo hermano al cerrar su primer Block
(**antes faltaba**)... **[APLICADO 2026-07-08]**"*. El `"(antes faltaba)"` **fecha la lista corta como estado
PREVIO**, no como set alternativo. Y el alcance declarado del mismo parche (`CHANGELOG.md:58-59`):
*"`corpus_flujo_trabajo.txt` y `CLAUDE.md` reconocen ahora..."* — **`corpus_roadmap.txt` no figura**, y por
eso conserva la enumeración pre-parche.

**Árbol real.** Los cuatro repos con contenido tienen su quinto doc, sin excepción:
`corpus-caliber/docs/Caliber_Architecture.md`, `corpus-coagulant/docs/Coagulant_Architecture.md`,
`corpus-craving/docs/Craving_Architecture.md`, `corpus-cargo/docs/Cargo_Architecture.md`.

**CHANGELOGs de los hermanos** registran el set de **cinco** llegando:
`corpus-craving/docs/CHANGELOG.md:21-22` (*"...`craving_convenciones_commits.txt}` + `Craving_Block4_Semilla.md`
(histórico) + `Craving_Architecture.md` (ratificado)"*); `corpus-caliber/docs/CHANGELOG.md:36-37`
(*"...+ traslado de `Caliber_Architecture.md` desde `corpus/docs/`"*); `corpus-coagulant/docs/CHANGELOG.md:29-31` ídem.

**Sobre el voto disidente (1 de 3).** Sostuvo que `corpus_roadmap.txt:81` encabeza con *"Checklist repetible,
ver corpus_flujo_trabajo.txt §2"* (remisión, no set autónomo) y que el bullet `:82` ya cubre el doc de
arquitectura por separado. Pierde: el `"(antes faltaba)"` del PARCHE 7 fecha la lista corta como pre-parche,
y el bullet `:82` es precisamente el que el hallazgo #5 declara **también roto**. Dos bullets rotos no se
cubren mutuamente.

**Parche PROPUESTO (no aplicado).** `docs/corpus_roadmap.txt:84-87`:
```
  - Si es la primera vez que ese módulo recibe contenido real: CLAUDE.md +
    docs/{<modulo>_estado.md, <modulo>_roadmap.txt, CHANGELOG.md,
    <modulo>_convenciones_commits.txt, <modulo>_Architecture.md} propios en su repo,
    mismo template que corpus/, apuntando a corpus/docs/corpus_flujo_trabajo.txt en
    vez de duplicarlo. La sede canónica de esta checklist es
    corpus_flujo_trabajo.txt §2 (GIT-6); esta enumeración la refleja, no la define.
```
`corpus_flujo_trabajo.txt` **no se toca**: ya es correcto.

---

### Nota de triage sobre el lote del roadmap (#5, #6, #7)

Los tres son **A (reparable)**. Pero ver §5.3: **`corpus_roadmap.txt` no declara ni cita un solo ID**. Si el
autor decide (recomendado, §5.3) declararlo formalmente **no-normativo** — es nivel 6 de la §7.1, pura
intención — entonces #5/#6/#7 dejan de ser "contradicciones entre normas" y pasan a ser **deriva de un doc
sin autoridad**. El triage sigue siendo A y los parches siguen valiendo; cambia el **encuadre**, no el
trabajo. **Vale la pena decidirlo antes de parchar.**

---

## 3. Patología del registro

### 3.1 Divergencias yaml-vs-sede (1)

| ID | Sede | Diverge en |
|---|---|---|
| **FLU-31** | `corpus/docs/corpus_flujo_trabajo.txt` §7.4 | Su `titulo` en `ids.yaml:382` enumera **cinco** tipos de evidencia (`selftest \| harness \| planilla \| codigo \| INTENCION`); §7.4 enumera **cuatro** — `codigo` **no existe en la sede** |

Es la misma cuestión que el hallazgo **#2**, vista desde el registro. **Divergencia de significado, no de
redacción:** es una norma que **ENUMERA** (FLU-27) y el yaml agrega un miembro que su sede no reconoce —
mientras que en el propio registro `codigo` es de hecho el tipo **más usado** (COR-1, COR-5, COR-6, COR-9,
COR-10, COR-11, COR-14, FLU-14, FLU-17, FLU-18, FLU-21, FLU-22, GIT-1, GIT-2, GIT-5 y casi toda la familia CAL).

**Dirección de la reparación — atención.** Por §7.1 el yaml no litiga contra el doc, así que **formalmente el
yaml está desactualizado**. Pero acá la reparación honesta es probablemente **al revés**: el registro y el
encabezado del propio `ids.yaml` (`:17-23`) ya operan con cinco, y es **§7.4 la que quedó corta**. Es un hecho
sin árbitro de un solo lado → **va al voto del autor (#2, bucket B)**, no a parche unilateral.

**Higiene detectada de paso** (no es divergencia yaml-vs-sede, es el yaml contra sí mismo):
`ids.yaml:1543-1547` (bloque `salud`) declara `total: 178` / `intencion: 44`, pero un barrido del árbol al
momento de auditar dio **189 IDs y 51 INTENCION**; PARCHE 5 además declaró 43/178, y `estado.md:31` dice 184.
**Cuatro cifras distintas para el mismo hecho.** El bloque `salud` quedó sin ratificar. No se parcha desde acá
— es un conteo que el autor debe rehacer.

### 3.2 Normativas sin ID (49) — violan FLU-25: *una norma sin ID va a derivar*

Distribución por doc:

| Doc | Sin ID | Nota |
|---|---:|---|
| `corpus_flujo_trabajo.txt` | 23 | **22 de ellas en §7.6-§7.8** — la constitución anti-drift recién escrita |
| `CORPUS_Architecture.md` | 14 | |
| `corpus_convenciones_commits.txt` | 10 | Sede de 5 IDs (familia GIT) y **no tiene ni uno tagueado** |
| `corpus_roadmap.txt` | 2 | **Cero IDs en todo el doc** |

**El patrón es una sola cosa y hay que decirla:** la tanda que escribió §7 (la constitución) **acuñó las
normas del gate y del checker sin darles ID**. AUD-1, AUD-2 y AUD-3 se **citan por nombre** en `flujo_trabajo.txt:538-544`
y en el `whenToUse` del gate, pero **no existen como entradas del registro**: `ids.yaml` no las tiene. Son
normas con nombre propio, invocadas por otros docs, **fuera del registro que ellas mismas gobiernan**. Es FLU-25
violado por la propia sede de FLU-25.

**Muestra de las más caras** (referencia completa en el material de la pasada; se listan las que arbitran algo):

- `corpus_flujo_trabajo.txt:8-10` — *"`corpus_flujo_trabajo.txt` es el documento **CANÓNICO** de metodología del
  ecosistema... aplica por igual a las siete raíces"*. **La norma que funda la autoridad de todo el resto no
  tiene ID.**
- `corpus_flujo_trabajo.txt:443-448` (§7.6) — LOS DOS ANILLOS (barato/caro, no se solapan a propósito). Cita
  FLU-25/FLU-29 pero **no define ID propio**. Es la norma que enmarca ambos gates.
- `corpus_flujo_trabajo.txt:512-515` — **READ-ONLY ESTRICTO del gate** (*"el gate propone, el autor dispone"*).
  Es la regla dura que esta acta obedece, y no tiene ID.
- `corpus_flujo_trabajo.txt:538-544` — **AUD-1 / AUD-2 / AUD-3**. Nombradas, citadas, sin entrada.
- `corpus_flujo_trabajo.txt:546-548` — **actas inmutables en `docs/auditorias/`**. La norma que rige este
  archivo. Sin ID.
- `corpus_flujo_trabajo.txt:560-561` — *"cada punto de un hallazgo se ubica por CONTENIDO, nunca por número de
  línea"*. Sin ID.
- `corpus_flujo_trabajo.txt:471-478` — el hook `pre-commit`, su gatillo por superficie normativa, y el escape
  `--no-verify`. Tres normas operativas, sin ID.
- `corpus_flujo_trabajo.txt:491-498` — *"FALLA RUIDOSO, NUNCA EN SILENCIO"* y *"un checker que nadie vio en ROJO
  no es evidencia de nada"*. **Las dos normas que los hallazgos #4 y §5.5 demuestran incumplidas** — y ninguna
  tiene ID con el que citarlas.
- `CORPUS_Architecture.md:274` — el legacy ADS congelado, sin retro-port. Sin ID.
- `CORPUS_Architecture.md:281`, `:310`, `:312`, `:316`, `:317` — las cinco reglas del workspace (ocho raíces,
  assets de stalker no versionados, `dev/` fuera de git, MIT por repo, addon completo por raíz). **Ninguna
  tiene ID.**
- `corpus_convenciones_commits.txt:8-13, :20-25, :31-33, :39-42, :48-49, :64-65, :79, :104-106` — diez normas
  del estándar de commits. **Citan** GIT-1/2/3/6 en el análisis pero **no los llevan tagueados en la prosa**.
- `corpus_roadmap.txt:4-6` — *"el roadmap fija el RUMBO, `corpus_estado.md` dice dónde estamos; se leen JUNTOS"*.
  Sin ID.
- `corpus_roadmap.txt:73-74` — **"Cortex está gated por la superficie de eventos daño/limb de Caliber"**. Es la
  norma que **ordena el próximo Block del ecosistema** y no tiene ID en ningún lado.

**Recomendación (no parche):** acuñar, en una tanda dedicada, al menos: la canonicidad del flujo, los dos
anillos, el READ-ONLY del gate, AUD-1/2/3, la inmutabilidad de las actas, y el gating Cortex←Caliber. Las diez
de convenciones son **baratas**: el yaml ya dice cuáles son GIT-1..5; solo falta taguearlas en la prosa.

---

## 4. Ambigüedades de alcance (41)

Afirmaciones normativas o descriptivas cuyo alcance quedó **sin declarar en al menos un eje**. No son
hallazgos: son **ambigüedad latente** — la materia prima de la contradicción futura.

**El patrón dominante, y es uno solo: `REALM: no especificado`.** Aparece en **~20** de las 41, y se concentra
en el bloque de **soft-deps** de `CORPUS_Architecture.md` (`:51`, `:53-55`, `:57-58`, `:60-61`, `:64`, `:72`,
`:74`, `:75`, `:76`, `:132`, `:133`, `:134`, `:135`, `:136`, `:138`, `:140`, `:275`).

Eso importa **específicamente** porque REALM es **uno de los cuatro ejes que §7.8 manda usar para descartar
falsos positivos**. Una degradación honesta declarada sin realm es una regla que **no se puede adjudicar**: no
hay forma de saber si choca con otra o si simplemente vive en el otro lado del cliente/servidor. **El eje que
mata candidatas está indefinido justo donde más se usaría.** Ver §5.4 — sospecho que ahí hay supresión, no salud.

Ejemplos concretos de lo que queda sin decidir:
- `CORPUS_Architecture.md:74` — *"Sin Coagulant ni Cortex, Cargo degrada a: sin línea de facción en el panel de
  estado y sin volcado de encumbrance"*. El panel es **client**, el encumbrance es **server**. La afirmación
  mezcla ambos y no lo dice.
- `CORPUS_Architecture.md:76` — *"Sin Cargo, Craving degrada a entity de mundo (`corpus_craving_food`, gate
  WALK+USE)"*. La entity es server; el gate se ejerce donde no está dicho.
- `CORPUS_Architecture.md:138` — la `Limbs` API agnóstica **además no tiene ID** (aparece en las dos listas).
- `corpus_flujo_trabajo.txt:222-228` — **MOCK-FIRST (FLU-17)**, la norma más citada del ecosistema para
  defender diseño-por-delante: *"REALM: no especificado (el patrón aplica donde viva el call site)"*.

**Nota metodológica, contra el sesgo de esta acta:** el material trae `CORPUS_Architecture.md:138`
(*"La `Limbs` API que expone Caliber debe ser agnóstica a la entidad"*), `:176` y `:310` **duplicados** entre
la lista de sin-ID y la de sin-alcance. No es un error del árbol: es la misma afirmación fallando en dos ejes.
Se cuenta una vez por lista.

**Recomendación (no parche):** al parchar cualquier línea del bloque §2/§4 de `CORPUS_Architecture.md`,
declarar el realm **en la misma pasada**. No abrir una tanda solo para esto.

---

## 5. Huecos de esta auditoría — lo que NO quedó cubierto

Honestidad sobre el alcance real. Esta sección es tan parte del resultado como los hallazgos.

### 5.1 El piloto no cumplió su propia definición de SCOPED: auditó 4 de ~9 sujetos del framework

`corpus_flujo_trabajo.txt` §7.8 y `docs/auditorias/README.md` definen **SCOPED = "solo los docs del
framework"**. El framework tiene **más de cuatro**:

| Sujeto | ¿Auditado? | IDs de los que es sede |
|---|:---:|---:|
| `docs/corpus_flujo_trabajo.txt` | ✅ | 44 |
| `docs/CORPUS_Architecture.md` | ✅ | 9 |
| `docs/corpus_convenciones_commits.txt` | ✅ | 5 |
| `docs/corpus_roadmap.txt` | ✅ | **0** |
| **`CLAUDE.md`** | ❌ | **11** |
| **`docs/corpus_estado.md`** | ❌ | 1 |
| **`docs/CHANGELOG.md`** | ❌ | 0 (cita 16) |
| **`docs/ids.yaml`** | ❌ (glosario, nunca sujeto) | — |
| **`docs/auditorias/README.md`** | ❌ | 0 |

**Lo grave no es el conteo, es quiénes quedaron fuera.** `corpus_estado.md` y `docs/CHANGELOG.md` fueron
usados como **árbitros** en 3 de las 7 contradicciones (el "árbitro-historia" los cita para decidir quién
gana), pero **jamás fueron medidos como sujetos**. Se usó una regla que nadie verificó que estuviera derecha.
Y el hallazgo **#3 demuestra que `estado.md:37` está desactualizado** — o sea: **el árbitro ya se sabe roto y
se lo siguió usando para adjudicar los otros seis**.

**Mitigación honesta:** en las siete contradicciones el árbitro **decisivo** fue el árbol real (nivel 1), no
`estado.md`. Los hallazgos se sostienen. Pero la metodología no.

### 5.2 `corpus/CLAUDE.md` — sede de once contratos cardinales — **nunca se leyó**. Es el peor punto ciego del lote

`ids.yaml` declara que **COR-1..COR-6 y COR-9 tienen su sede en `corpus/CLAUDE.md`** — **11 IDs**, incluidos
los que la arquitectura cita como regla cardinal. Y §7.8 declara, textual, cuál es el **valor único** del gate
frente al checker:

> *"Lo que el gate SÍ hace y el checker no puede: verificar que el `titulo` del yaml coincida con la PROSA de
> su sede."*

**Once sedes de la familia COR nunca se contrastaron contra su título.** Cruzando el ecosistema entero,
**32 IDs tienen un `CLAUDE.md` como sede** (corpus 11, coagulant 10, cargo 9, stalker 5, craving 4, caliber 3)
y **ni uno entró como sujeto**. El gate está construido exactamente para eso y no lo hizo sobre el archivo que
más lo necesita.

**Y hay carne ahí. Dos que se ven a simple vista:**

- **COR-6 tiene el alcance podrido.** Dice: *"Prefijo de archivo por addon: `corpus_<addon>_*.lua` **en
  `lua/autorun/...`**"*. Pero el árbol real de los cinco módulos **ya no vive en `lua/autorun/`**: vive en
  `lua/corpus_caliber/{client,server,shared}/`, `lua/corpus_cargo/…`, etc. — decenas de archivos. La cláusula
  de alcance del contrato quedó atada a una **topología que el código abandonó**. Por §7.1 (el código manda)
  el contrato es el que está viejo. Nadie lo vio porque `CLAUDE.md` no era sujeto.
- **El hallazgo #1 tiene una tercera pata invisible.** `CORPUS_Architecture.md:39` dice cuatro, `:82` dice seis
  — pero `CLAUDE.md` (sede de COR-1) dice *"registro, persistencia, net, UI shell, ready barrier, log"*, o sea
  **seis**. El parche de #1 es correcto, pero la adjudicación se hizo **a ciegas de la sede canónica**: no era
  un empate 1-1 entre dos secciones, era **2-contra-1 con la sede del lado de las seis**.

**Para taparlo:** meter los siete `CLAUDE.md` como **sujetos obligatorios de todo modo, SCOPED incluido**. Un
`CLAUDE.md` no es "contexto": es la sede de 32 normas.

### 5.3 **DOS DE LOS CUATRO DOCS AUDITADOS NO DECLARAN NINGÚN ID PROPIO. Sobre ellos este gate es CIEGO, y su "limpio" significa "NO AUDITADO", no "sano".**

Verificado a grep sobre el árbol:

- **`corpus_roadmap.txt` — CERO IDs.** No es sede de ninguna entrada del yaml, y **no cita ni un solo ID en su
  prosa** (`grep -cE '\b[A-Z]{3}-[0-9]+\b'` → **0**). Punto ciego perfecto: el gate lee `ids.yaml` como
  glosario, y el roadmap es **invisible** para ese glosario.
- **`corpus_convenciones_commits.txt` — CERO IDs etiquetados.** El yaml dice que es sede de **5 IDs** (familia
  GIT), pero su prosa **no lleva ni uno tagueado** (grep → **0**). El registro apunta al doc; **el doc no sabe
  que es sede**.

Compárense con los otros dos: `corpus_flujo_trabajo.txt` (44 IDs) y `CORPUS_Architecture.md` (9).
**La mitad del piloto corrió sobre docs sin IDs.**

**El detalle que lo vuelve urgente:** **3 de las 7 contradicciones confirmadas son roadmap-vs-otro** (#5, #6,
#7). Un doc **sin un solo ID** produjo el **43 % de los hallazgos** — y los produjo **por lectura de prosa, no
por cruce de IDs**. En el roadmap, **el gate encontró lo que encontró a pesar de su mecanismo, no gracias a
él**. Tres hallazgos ahí son el **piso, no el techo**.

La deuda **D-7** está escrita para los docs de módulo, y `auditorias/README.md` advierte exactamente esto
(*"un gate que cruza IDs es **ciego** a un doc sin IDs... un 'limpio' significaría *no auditado*, no *sano*"*).
**Nadie notó que la deuda ya aplica DENTRO del framework, hoy, a dos de los cuatro docs del piloto.**

**Para taparlo:** (a) esta acta lo declara, arriba, con todas las letras; (b) **extender D-7** para nombrarlos;
(c) **taguear GIT-1..5** en la prosa de convenciones — es barato, el yaml ya dice cuáles son; (d) **decidir si
el roadmap acuña IDs o se declara formalmente NO-NORMATIVO** — que sería lo honesto: es nivel 6 de la §7.1,
pura intención. Ver la nota de triage al pie de §2.

### 5.4 Once de los catorce buckets volvieron con cero, y **todos los ceros son estructurales, no limpieza**

Los hallazgos aterrizaron en **3 buckets**: `framework-delgado` (1), `evidencia` (3), `proceso` (3). Los otros
**once** dieron cero: `soft-deps`, `realms`, `namespacing`, `contrato-items`, `boot-carga`, `dano-limbs`,
`dominio-medico`, `inventario`, `ui-vgui`, `persistencia`, `assets-licencias`.

**`dano-limbs`, `dominio-medico`, `inventario`, `ui-vgui`, `assets-licencias` son dominios de módulo.** Sus
docs sede son `Coagulant_Architecture.md`, `Cargo_Architecture.md`, `ASSETS.md` — **todos excluidos por el modo
piloto**. La taxonomía de 14 buckets **se diseñó para el COMPLETO y se corrió sobre el SCOPED**. Esos buckets
no estaban limpios: estaban **VACÍOS POR CONSTRUCCIÓN**.

**Los sospechosos de verdad**, donde sí había material en los 4 docs y aun así dio cero:

- **`soft-deps` y `realms`** — `CORPUS_Architecture.md` §2 y §5 los tratan largo, y COR-11/COR-12 viven ahí.
  Cero es raro. **Y hay un sesgo estructural:** §7.8 lista **REALM y SOFT-DEP como dos de los cuatro ejes de
  alcance** que el gate usa para **descartar** falsos positivos. Un eje que se usa para **matar** candidatas y
  que **además es un tema a auditar**: el sesgo va todo en la misma dirección. **Sospecho supresión, no
  ausencia** — y §4 lo refuerza: ~20 de las 41 ambigüedades de alcance son `REALM: no especificado`, casi todas
  en el bloque de soft-deps.
- **`persistencia` y `namespacing`** — COR-2/COR-3/COR-4 son cortos y precisos; plausible que estén sanos. Pero
  **su sede es `CLAUDE.md`, que no se leyó** → el cero acá es literalmente **"no mirado"**.

**Etiquetado de los once ceros** (un cero sin razón se lee como salud y no lo es):

| Bucket | Razón del cero |
|---|---|
| `dano-limbs` | **VACÍO-POR-PILOTO** (sede: `Caliber_Architecture.md`) |
| `dominio-medico` | **VACÍO-POR-PILOTO** (sede: `Coagulant_Architecture.md`) |
| `inventario` | **VACÍO-POR-PILOTO** (sede: `Cargo_Architecture.md`) |
| `ui-vgui` | **VACÍO-POR-PILOTO** |
| `assets-licencias` | **VACÍO-POR-PILOTO** (sede: `ASSETS.md` de stalker) |
| `contrato-items` | **VACÍO-POR-PILOTO** (parcial: §5 del general sí se leyó) |
| `boot-carga` | **PARCIAL** — §6 se leyó; las sedes COR-5 en `CLAUDE.md`, no |
| `namespacing` | **NO-MIRADO** — sede en `CLAUDE.md` |
| `persistencia` | **NO-MIRADO** — sede en `CLAUDE.md` |
| `soft-deps` | **SOSPECHOSO** — había superficie; posible supresión por el eje SOFT-DEP |
| `realms` | **SOSPECHOSO** — había superficie; posible supresión por el eje REALM |

**Para la próxima pasada:** registrar **cuántas candidatas murieron por "distinto alcance"** en `soft-deps` y
`realms`. Si murieron varias, **el eje se está usando como matamoscas**.

### 5.5 La taxonomía no tiene bucket para el nivel **meta-normativo** — y ahí es donde está el daño

Los 14 buckets son todos de **contenido** (armor, ítems, realms, licencias) más dos comodines (`proceso`,
`evidencia`). **No hay bucket para las normas sobre las normas**: la jerarquía §7.1, qué es una sede, qué es
una familia, qué tipos de evidencia existen, quién gana cuando el yaml y la sede chocan, la cadencia AUD-1/2/3.

Se nota en el resultado: **4 de 7 hallazgos cayeron en `evidencia` + `proceso`**. Esos dos no ganaron porque el
proceso sea lo más roto — ganaron porque son **el desagüe** de todo lo que no encajaba en los otros doce.
**Un bucket sobrecargado esconde tanto como uno vacío.**

Faltan, nombrados:
- **`meta-registro`** — el yaml, familias, sedes, tipos de evidencia, el checker y sus límites. Hoy repartido
  entre `evidencia` y `proceso`.
- **`deudas`** — las D-1..D-9 son un cuerpo normativo cruzado (**D-2 arbitra el hallazgo #4**, **D-7 gobierna el
  modo del gate**) y **ninguna tiene bucket**. Una deuda declarada cerrada en un doc y abierta en otro es una
  clase de contradicción entera **que nadie buscó**. **Las deudas están arbitrando y nadie las auditó.**
- **`estado-de-bloques`** — qué Block está cerrado. `estado.md`, `roadmap` y `CORPUS_Architecture §9` lo
  enumeran **los tres**. Tres enumeraciones del mismo hecho, sin bucket propio.

**Y un hallazgo suelto que ningún bucket iba a agarrar — verificado en el árbol al momento de auditar:**

> **`docs/ids.yaml:47` declara la familia `CTX` con sede `corpus-cortex/CLAUDE.md` — ese archivo NO EXISTE.**
> `ls -a corpus-cortex/` → `.git`, `LICENSE`, `README.md`. Nada más.

El checker no lo agarra porque su CHECK de sedes valida las sedes de las entradas **`ids:`**, no las del bloque
**`familias:`** — y CTX **no tiene entradas todavía**, así que la sede rota **nunca se toca**.

Es un **hueco presencial del mismo tipo exacto que el hallazgo #4** (regex/validación que ignora en silencio en
vez de fallar), **en el mismo archivo**, y es **la segunda instancia en una sola tanda**:

> **El patrón "el checker pasa limpio porque no mira, no porque esté bien" ya tiene dos instancias y merece ser
> tratado como CLASE, no como bug suelto.** Y contradice de frente dos normas de la casa que además **no tienen
> ID** (§3.2): *"FALLA RUIDOSO, NUNCA EN SILENCIO"* (`flujo_trabajo.txt:491-494`) y *"un checker que nadie vio
> en ROJO no es evidencia de nada"* (`:496-498`).

**Para taparlo:** sumar `meta-registro` y `deudas` a la taxonomía; hacer que el checker **valide las sedes de
`familias` igual que las de `ids`**; y **auditar el checker mismo como sujeto** — sus dos huecos conocidos
salieron por **lectura humana, no por sus tests**.

### 5.6 Resumen ejecutable de los huecos

1. **Rehacer el SCOPED con los ~9 sujetos reales**, no 4. Prioridad máxima: **`CLAUDE.md`** (11 sedes COR sin
   verificar, y COR-6 con el alcance podrido a la vista) y **`estado.md` / `CHANGELOG.md`** (se usaron de
   árbitro sin ser medidos).
2. **Declarar** (hecho, §5.3): dos de los cuatro docs auditados no declaran ningún ID propio; sobre ellos el
   gate no tuvo cobertura de IDs y su resultado es **"no auditado", no "sano"**. **D-7 ya aplica dentro del
   framework.**
3. **Etiquetar los 11 ceros** (hecho, §5.4): `VACÍO-POR-PILOTO` / `NO-MIRADO` / `SOSPECHOSO`.
4. **Sumar buckets `meta-registro` y `deudas`**; `evidencia`+`proceso` funcionan de desagüe.
5. **Arreglar `ids.yaml:47`** (sede CTX inexistente) y hacer que el checker valide sedes de `familias`.
   Segundo hueco presencial en la misma tanda: **tratar el patrón como clase**.

---

## 6. Qué NO se auditó, y por qué

Delimitación explícita. Lo que sigue **está fuera del alcance de este gate por diseño**, y su ausencia acá
**no es evidencia de nada**:

- **Doc-vs-código (implementación).** Este gate cruza **prosa contra prosa**, y usa el Lua solo como **árbitro**
  cuando dos docs chocan. **Esta acta NO afirma que nada esté implementado.** El ecosistema **diseña por delante
  del código a propósito** (FLU-17, mock-first): "esto no está implementado todavía" **jamás fue un hallazgo**
  acá, y no debe leerse ninguno de estos siete como tal.
- **Huérfanos, bicéfalos y sedes rotas.** Los prueba el **checker determinista** (`.claude/check-ids/`), que
  corre en cada `pre-commit` sobre las siete raíces (§7.7). El gate **no re-deriva lo que el checker ya prueba**
  — §7.6: los dos anillos **no se solapan a propósito**.
  **Salvedad registrada:** el checker tiene al menos **dos huecos presenciales conocidos** (§5.5) — refs
  `planilla` sin ID que se ignoran en silencio, y sedes de `familias` que nunca se validan. **Su "limpio" no
  cubre esos dos casos.** Ambos salieron por lectura, no por sus tests.
- **Contradicciones dentro de un repo de módulo, y cross-repo.** Excluidas por el modo PILOTO. Ver §7.
- **Corrección técnica del diseño.** El gate mide **coherencia**, no si una decisión de ingeniería es buena.
- **Bugs de código (bucket C).** **Cero hallazgos** en este bucket, porque el alcance no incluyó Lua como
  sujeto. Los tres arreglos propuestos que tocan código (`corpus_check_ids.ps1` en #4 y §5.5) **no son bucket
  C**: son fixes del **anillo barato**, y van a **pasada aparte**.
- **Entradas CADUCAS.** **Cero.** Las siete frases citadas existían en el árbol al momento de auditar; las
  load-bearing se re-verificaron línea por línea antes de escribir esta acta.

---

## 7. MODO PILOTO — qué se auditó y por qué solo eso

**Se auditó únicamente el repo `corpus/` (el framework): 4 docs, ~1.188 líneas.** Los otros seis repos
(`corpus-cortex`, `corpus-caliber`, `corpus-coagulant`, `corpus-craving`, `corpus-cargo`, `corpus-stalker`)
**quedaron enteramente fuera**.

**La razón es la deuda D-7**, y está **cableada** en el gate, no solo enunciada:
`.claude/workflows/auditoria-coherencia-docs.js:140` filtra `d.repo === 'corpus'`, y `:139` lleva el comentario
*"allá costó 22 hallazgos post-limpio). Por eso el piloto no los toca"*.

**El fundamento:** la prosa de los docs de módulo **no tiene IDs etiquetados**. El gate cruza IDs. **Un gate que
cruza IDs es ciego a un doc sin IDs** — un "limpio" sobre ellos significaría **"no auditado"**, no **"sano"**.
Es la lección **§10.8 del SDD de Kontrol**, donde correrlo antes de saldar la deuda costó **22 hallazgos
post-limpio**.

**El modo COMPLETO** (los 19 docs de las siete raíces) **queda diferido hasta saldar D-7**, por **AUD-2** (corre
al cerrar un Block de módulo, antes de abrir el siguiente).

**Y la ironía que esta acta registra contra sí misma (§5.3):** la premisa del piloto — *"el framework sí tiene
IDs, los módulos no"* — **es falsa en la mitad**. `corpus_roadmap.txt` (0 IDs) y `corpus_convenciones_commits.txt`
(0 tagueados) **son exactamente el caso que D-7 describe, dentro del framework**. El piloto se corrió sobre dos
docs que **ya estaban bajo D-7 sin que nadie lo hubiera notado**. **D-7 debe extenderse para nombrarlos** antes
de que se lea este resultado como salud del framework.

**Cadencia aplicada:** **AUD-1** — esta corrida cierra una sesión que escribió normas (§7 del flujo, el
registro, el checker, el gate). **AUD-3** — se ejecutó con contexto suficiente; no hubo diferimiento.

**Cobertura al momento de auditar:** el tracker `docs/auditorias/README.md` registraba **cero corridas previas**.
**Esta acta es la primera.**

---

*Acta cerrada. Ningún archivo de los siete repos fue modificado, creado ni borrado. El único archivo escrito por
esta auditoría es este documento. Los 8 parches propuestos están sin aplicar: el gate propone, el autor dispone.*
