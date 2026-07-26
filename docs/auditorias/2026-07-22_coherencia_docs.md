# Acta — Auditoría de coherencia documental del ecosistema Corpus

**Fecha:** 2026-07-22
**Modo:** COMPLETO — siete raíces, doc-vs-doc + pase de valor + contrato-vs-árbol
**Estado del acta:** ÍNTEGRA — cobertura completa: ningún agente murió, ningún tramo quedó sin auditar (COBERTURA PERDIDA = 0). El acta NO está degradada.
**Alcance:** doc-vs-doc, adjudicado contra el Lua / `<modulo>_estado.md` / `CHANGELOG.md` según la jerarquía de autoridad de `corpus/docs/corpus_flujo_trabajo.txt` §7.1 (leída en sede antes de adjudicar; el archivo manda sobre cualquier resumen).
**Modo de escritura:** READ-ONLY sobre las siete raíces. Este acta es el ÚNICO archivo escrito. **Todos los parches son PROPUESTOS, ninguno aplicado.** El gate propone, el autor dispone.
**Inmutabilidad:** esta acta es la foto del estado AL MOMENTO DE AUDITAR. No se edita después.

---

## Cifras

| Métrica | Valor |
|---|---|
| Contradicciones confirmadas (3 verificadores adversariales cada una) | **2** |
| — ALTA | 1 |
| — MEDIA | 1 |
| — BLOQUEANTE / BAJA | 0 |
| Hechos falsos hallados por el pase de VALOR (triage A por construcción) | **9** |
| Triage A (REPARABLE: el árbol dirime) | 11 (2 contradicciones + 9 hechos falsos) |
| Triage B (VOTO DEL AUTOR: el código no dirime) | 0 |
| Triage C (bug de código) | 0 |
| CADUCO | 0 |
| Divergencias yaml-vs-sede | **0** |
| Normativas sin ID (FLU-25) | 268 |
| Afirmaciones sin alcance declarado | 270 |
| Contrato-vs-árbol: CUMPLIDO / INCUMPLIDO / PARCIAL / NO_VERIFICABLE | 47 / 0 / **2** / 5 |
| Buckets con hallazgos / limpios (de 18) | 2 / 16 |
| Cobertura perdida | **0** |
| Docs auditados **sin un solo ID propio** (cobertura ciega por eje IDs) | **8** |

---

## 1. Resumen ejecutivo — lo que cambia el plan

Dos contradicciones confirmadas y nueve hechos falsos sobre el presente. Ninguno bloquea, pero **construir siguiendo el doc perdedor rompe un contrato vivo o hereda un número stale.** Nombre y apellido, lo que cambia el plan primero:

1. **`corpus-coagulant/docs/Coagulant_Block3_Semilla.md:28-29` presenta como contrato vigente "6 zonas con `torso` válido" — y el código, el CHANGELOG y `COA-8` ya lo derogaron: hoy son 7 zonas y `Zones.IsValid("torso")` es `false` a propósito.** (ALTA, triage A.) Quien lea la Semilla al pie de la letra construye contra un set de zonas que murió el 2026-07-21. El agravante: su bullet hermano (`onUse==ApplyBandage`, líneas 33-39) SÍ lleva nota "> DEROGADO", probando que dentro de este mismo doc un contrato congelado sin anotar se lee como vigente. → **Hallazgo 2.1**

2. **`corpus-caliber/docs/Caliber_Architecture.md:216` mete la "lectura de pools de limbs" DENTRO del subconjunto contratado de Caliber — y `CAL-12`, el Lua y `CORPUS_Architecture.md:133` dicen que lo ÚNICO bajo contrato es `HealLimbs`.** (MEDIA, triage A.) Consecuencia latente: un consumidor futuro (Cortex/Coagulant) que tome `:216` trataría los campos `npc.Caliber_HP_*` como superficie estable; podrían renombrarse sin romper contrato y romper al consumidor en silencio. Hoy no hay consumidor (pools NPC-only), por eso no es bloqueante. → **Hallazgo 2.2**

3. **Cuatro roadmaps afirman en PRESENTE hechos que el árbol ya movió** (pase de valor): `coagulant_roadmap.txt:33-38` dice que Coagulant "hoy funde `torso`" y que "falta la bajada a código" cuando las tres fases corrieron el 2026-07-21 con ronda O 6/6; `craving_roadmap.txt:40` habla de negociar con Coagulant "cuando su Block 3 cierre" con el Block 3 cerrado desde el 2026-07-20. Quien planee el próximo bloque leyendo estos roadmaps parte de un mapa temporal viejo. → **Hallazgos 2.5, 2.6, 2.9**

4. **Dos números de contrato de Cargo están stale en la sede, no solo en el roadmap:** `Cargo_Architecture.md §13.1` arrastra "15 net.Receive / los otros 14" cuando el árbol tiene 22 (otros 21); `cargo_estado.md` repite "36 entradas de trivia" cuando el árbol tiene 40. El roadmap solo refleja el número de su sede. → **Hallazgos 2.4, 2.10**

**No hay voto abierto (bucket B):** en las dos contradicciones confirmadas el árbol dirime; ninguna cae en el corolario de §7.1 (afirmación sobre algo no construido sin árbitro).

---

## 2. Contradicciones y hechos falsos, por gravedad

Cada hallazgo lleva su **triage**: **A** = el ganador lo decide el Lua / estado / CHANGELOG (se parcha el doc perdedor); **B** = los docs chocan y el código no dirime (voto del autor, no se parcha); **C** = el doc tiene razón y el Lua está mal (pasada aparte); **CADUCO** = la frase ya no existe.

### 2.1 — [ALTA · triage A] `Coagulant_Block3_Semilla.md` presenta 6 zonas con `torso` como contrato vigente; el árbol dice 7 sin `torso`

**Tema:** dominio-medico.

- **Afirmación A (pierde)** — `corpus-coagulant/docs/Coagulant_Block3_Semilla.md:28-29`: las IDs de zona son las 6 estilo ACE3 (`head, torso, left_arm, right_arm, left_leg, right_leg`), contrato congelado por el scaffold (CHANGELOG 2026-07-13).
- **Afirmación B (gana)** — `corpus-coagulant/CLAUDE.md:59` (COA-8, enmendado 2026-07-21): los IDs son **7** (`head, chest, stomach, left_arm, right_arm, left_leg, right_leg`); `torso` se partió y murió **sin alias**, de modo que `Zones.IsValid("torso")` es `false`.

**Por qué chocan:** ambas fijan el MISMO contrato (el set canónico de zonas clínicas de Coagulant), mismo alcance en los cuatro ejes (REALM shared, MODULO Coagulant, sin soft-dep relevante — la nota "sin Caliber→hitgroup" es la vía de degradación, no la identidad de las zonas —, BLOCK 3). El set no puede ser a la vez "6 con `torso` válido" y "7 con `torso` inválido". No es diseño-por-delante (el doc va DETRÁS del código), ni distinto nivel de detalle, ni degradación honesta.

**Quién gana y evidencia (jerarquía §7.1):** los tres árbitros de mayor autoridad respaldan a B.
- Nivel 1 (Lua): `corpus-coagulant/lua/corpus_coagulant/shared/corpus_coagulant_zones.lua:17-25` — `Zones.LIST` tiene 7 entradas (`head/chest/stomach/left_arm/right_arm/left_leg/right_leg`); `:59-63` — `Zones.IsValid("torso")` devuelve `false` a propósito ("torso murió sin alias, COA-8").
- Nivel 3 (CHANGELOG): `corpus-coagulant/docs/CHANGELOG.md:1054-1069` `[APLICADO 2026-07-21]` "torso→chest&stomako… IsValid('torso') pasa a false — murió sin alias (COA-8). Header del archivo re-escrito (decía «6 zonas»)".
- Nivel 4 (CLAUDE.md): `corpus-coagulant/CLAUDE.md:59` COA-8 = 7 IDs, torso sin alias.

La Semilla es doc de diseño (nivel 5, LOS AUDITADOS): pierde. Es un drift que el "Barrido de drifts post-zonas" del 2026-07-21 dejó vivo (ese barrido corrigió hud.lua, CLAUDE.md, README, corpus_roadmap, corpus_estado, Cargo_Architecture.md y Craving_Architecture.md, pero no este bullet). Refuta la defensa "registro histórico": el bullet hermano `onUse==ApplyBandage` (Semilla:33-39) SÍ lleva nota "> DEROGADO por el slice 2" bajo el mismo encabezado "Contratos ya congelados" — dentro de este mismo doc un contrato congelado sin anotar se lee como vigente.

**Parche PROPUESTO (no aplicado)** a `corpus-coagulant/docs/Coagulant_Block3_Semilla.md`, insertar bajo la línea 29, análogo a la nota del bullet hermano:

> **DEROGADO por la enmienda de zonas del 2026-07-21** (CHANGELOG `[APLICADO 2026-07-21]`, sesiones «Enmienda de zonas» y «Bajada de zonas a código»): `torso` se partió en `chest` y `stomach` (el Source ya separaba esos hitgroups). Las zonas clínicas hoy son **7** (`head`, `chest`, `stomach`, `left_arm`, `right_arm`, `left_leg`, `right_leg`); `torso` murió **sin alias** — `Zones.IsValid("torso")` es `false`. Sede vigente: **COA-8** (`CLAUDE.md` §Contratos #4 y `Coagulant_Architecture.md` §3).

---

### 2.2 — [MEDIA · triage A] `Caliber_Architecture.md:216` mete la lectura de pools de limbs dentro del contrato; `CAL-12` dice que solo `HealLimbs` está bajo contrato

**Tema:** dano-limbs.

- **Afirmación A (gana)** — `corpus/docs/CORPUS_Architecture.md:133`: la única superficie bajo contrato de Caliber hoy es `CALIBER.HealLimbs(npc, amount, target)` — "lo único bajo contrato hoy".
- **Afirmación B (pierde)** — `corpus-caliber/docs/Caliber_Architecture.md:216`: la superficie mínima expuesta de `CALIBER` es "`HealLimbs` + lectura de pools de limbs", metiendo un SEGUNDO ítem dentro del subconjunto contratado y contraponiéndolo a "el resto off-contract".

**Por qué chocan:** mismo alcance en los cuatro ejes (REALM server, MODULO Caliber, sin soft-dep, BLOCK 2) y ambas definen el mismo objeto: el contrato público de Caliber en Block 2. No es summary-vs-spec: son afirmaciones de MEMBRESÍA mutuamente excluyentes. `:133` dice que `HealLimbs` es EL ÚNICO ítem; `:216` declara que la lectura de pools cae DENTRO del subconjunto documentado. Un ítem no puede ser a la vez off-contract y contratado.

**Quién gana y evidencia (jerarquía §7.1):**
- Nivel 1 (Lua): `corpus-caliber/lua/autorun/corpus_caliber_init.lua:11-17` — bloque CONTRATO PÚBLICO: única superficie es `CALIBER.HealLimbs`; `CALIBER.Limbs.*` "vacío en Block 2: sin superficie de contrato"; todo lo demás interno/off-contract. `corpus-caliber/lua/corpus_caliber/server/corpus_caliber_limbs.lua:216-220` — los pools se leen por acceso directo a campos de entidad `npc.Caliber_HP_*`, SIN getter expuesto; grep de `CALIBER.Limbs`/`GetPool` no devuelve API pública.
- Nivel 3 (CHANGELOG): `corpus/docs/CHANGELOG.md:170-182` — la "Pasada de veracidad — 2026-07-14", PARCHE 1 `[APLICADO]`, reescribió `CORPUS_Architecture.md:133` a "lo único bajo contrato hoy". `corpus-caliber/docs/CHANGELOG.md:165-168` PARCHE 3 tocó §8 pero solo corrigió la línea de EVENTOS, dejando intacto "lectura de pools de limbs": `:216` es el residuo rancio.
- Nivel 4 (CLAUDE.md): `corpus-caliber/CLAUDE.md:63` (CAL-12) — "Solo `CALIBER.HealLimbs` … es superficie pública; el resto … off-contract por convención".

`:216` es doc de arquitectura (nivel 5): pierde. Su propio code-block de `:228-234` ya muestra solo `HealLimbs` con `Limbs.*` vacío, así que el parche lo alinea con su propio cuerpo.

**Nota de reconciliación de sede (ver Hueco 2):** la adjudicación cita `CLAUDE.md:63` como sede de CAL-12, pero `ids.yaml` ancla CAL-12 a un `.lua`. La discrepancia NO altera el veredicto (Lua y CLAUDE.md concuerdan en el lado A), pero el registro y el arbitraje deben reconciliar cuál es la sede real de CAL-12; se anota como deuda, no como falla del hallazgo.

**Parche PROPUESTO (no aplicado)** a `corpus-caliber/docs/Caliber_Architecture.md:216`, reemplazar:

> "Superficie mínima expuesta de `CALIBER` (subconjunto documentado, el resto off-contract por convención): `HealLimbs` + lectura de pools de limbs."

por:

> "Superficie mínima expuesta de `CALIBER` (subconjunto documentado, el resto off-contract por convención): **solo `HealLimbs`** — lo único bajo contrato hoy (CAL-12). Los pools de limbs (`npc.Caliber_HP_*`) son el dominio sobre el que `HealLimbs` opera, NO una superficie de lectura contratada: son campos NPC-only internos que pueden renombrarse sin romper contrato. `CALIBER.Limbs.*` está **vacío en Block 2** (sin superficie de contrato)."

---

### 2.3–2.11 — Hechos falsos hallados por el pase de VALOR (9)

Afirmaciones sobre el PRESENTE que el árbol desmiente. Son hallazgos de pleno derecho, **triage A por construcción** (el árbol es árbitro de nivel 1). Van con su parche PROPUESTO al doc, no escondidos en los huecos. Todos sobre **docs sin IDs propios** (roadmaps, semillas, Cortex), que es la única vía por la que se los puede auditar.

| # | Ref | Afirma (FALSO) | Lo que dice el árbol | Parche propuesto |
|---|---|---|---|---|
| **2.3** | `cargo_roadmap.txt:160` | "espejado como cross-ref en `caliber_roadmap.txt §2[5]`" | No existe `[5]` en el doc (grep `\[5\]` → 0); el cross-ref al cargo_roadmap §16-22 vive en `[4]` (líneas 68-73) | "Espejado como cross-ref en `caliber_roadmap.txt §2[4]`." |
| **2.4** | `cargo_roadmap.txt:508` | "`corpus_cargo_weapon_trivia.lua` es la excepción con **36** entradas" | La tabla `CARGO.Capture.WeaponTrivia` tiene **40** claves (9 arc9_eft + 19 arc9_cod2019 + 12 weapon_ HL2). `cargo_estado.md` repite el 36 stale | "…la EXCEPCIÓN (**40** entradas)…" (y corregir la misma cifra en `cargo_estado.md`) |
| **2.5** | `coagulant_roadmap.txt:33-37` | "Coagulant hoy los funde en el mapa de Zones" (presente: aún fusiona chest/stomach en torso) | El código ya los separa: `corpus_coagulant_zones.lua` rutea `[HITGROUP_CHEST]="chest"` y `[HITGROUP_STOMACH]="stomach"` por separado (:43-44); `IsValid("torso")=false` (:59-62) desde el 2026-07-21 | "…el motor Source ya separa HITGROUP_CHEST/STOMACH — Coagulant los fundía en el mapa de Zones (torso) **hasta el 2026-07-21**." |
| **2.6** | `coagulant_roadmap.txt:34-38` | "la PRIMERA fase ya corrió… falta la bajada a código y la ronda O" (solo diseño ratificado) | Las tres fases corrieron el 2026-07-21: CHANGELOG.md:1020 «Enmienda (diseño)» y :1054 «Bajada a código» `[APLICADO 2026-07-21]`, ronda O 6/6 selftest 170/132. `CORPUS_Architecture.md:353` lo confirma completo | "…las TRES fases ya corrieron el 2026-07-21… el tramo está **COMPLETO**." |
| **2.7** | `cargo_roadmap.txt:136` | "el único net.Receive que espera gate es NET_ICON_OVERRIDE; los otros **14**" (⇒ 15 total) | grep `net.Receive` en `corpus-cargo/lua/corpus_cargo/server/` → **22** (ammopool 1 + containers 3 + holster 1 + icons 1 + inventory 14 + trade 2). La sede `Cargo_Architecture.md §13.1:388` arrastra el "15/14" stale | "…los otros **21**…" (y actualizar `Cargo_Architecture.md §13.1`: **22** net.Receive, otros 21) |
| **2.8** | `craving_roadmap.txt:40` | "negociar `ApplyExternalCondition` con Coagulant **cuando su Block 3 cierre**" (presupone abierto) | El Block 3 de Coagulant está CERRADO desde 2026-07-20 (`coagulant_estado.md:13,20`). Los docs de Craving ya lo corrigieron en commit f1c4801 pero NO el roadmap. §7.1: estado.md (nivel 2) gana al roadmap (nivel 6) | "…negociar con Coagulant, **ahora que su Block 3 cerró** (4 slices verificados en juego, 2026-07-20)." |
| **2.9** | `STALKER_Arquitectura.md:112` | "cinco de los **ocho** IDs STK- siguen con sede en el CLAUDE.md" | `ids.yaml:1699-1766` define STK-1..STK-9, los **nueve** VIGENTE. STK-9 se acuñó en la misma tanda del 2026-07-19. El subconjunto "cinco con sede en CLAUDE.md" es correcto; el total está desfasado en uno | "cinco de los **nueve** IDs `STK-` (STK-1,2,4,5,8) siguen con sede en el `CLAUDE.md`…" |
| **2.10** | `Cortex_ContratosEntrantes.md:7` | las firmas entrantes "vivían dispersas en **cuatro repos**" | Las 6 filas (§2:35-40) tienen sede en solo TRES repos: corpus-cargo (filas 1-3), corpus-caliber (filas 4,6), corpus-stalker (fila 5). El 4 coincide con la cantidad de DOCUMENTOS, no de repos | "…dispersas en **tres repos** (corpus-cargo, corpus-caliber, corpus-stalker), repartidas en cuatro documentos…" |
| **2.11** | `Cortex_ContratosEntrantes.md:7` | "`corpus-cortex/` contiene **solo LICENSE y README.md**" | `find` devuelve TRES: LICENSE, README.md y `docs/Cortex_ContratosEntrantes.md` (el propio doc audita). Baja severidad, autorreferencial: describe el estado pre-doc | "…contiene LICENSE, README.md y este mismo documento —ni una línea de código, ni CLAUDE.md—…" |

---

## 3. Patología del registro

### 3.1 Divergencias yaml-vs-sede: **0**

El registro `docs/ids.yaml` no contradice la prosa de ninguna sede auditada. Recordatorio de §7.1 / §7.4: `ids.yaml` es ÍNDICE, jamás segunda definición; si contradijera a su sede, el desactualizado sería el yaml. No hubo caso.

**Salvedad (no es divergencia yaml-vs-sede formal, pero se anota):** CAL-12 tiene sede en un `.lua` según `ids.yaml`, y el arbitraje de la contradicción 2.2 citó `CLAUDE.md:63` como sede. Es reconciliación pendiente de sede, tratada en el Hueco 2, no una divergencia yaml-contra-prosa.

### 3.2 Normativas SIN ID (FLU-25): **268**

FLU-25 / §7.2: una frase con SIEMPRE / NUNCA / DEBE / JAMÁS o bien DEFINE un ID o bien CITA uno; una norma sin ID va a derivar. Se detectaron **268** afirmaciones normativas que no citan ningún ID del glosario. No son contradicciones — son deuda de normalización: el vector por el que nace el próximo drift. Concentración por sede (muestra representativa de las enumeradas por el gate):

- **`corpus/docs/corpus_flujo_trabajo.txt`** — reglas de proceso/espejo sin ID: `:8-10` (doc canónico de metodología), `:41-43` (no hay test runner: verificar en juego), `:169-171` (planificación densa por bloques), `:257-258` y `:264-270` (deslinde planificador/ejecutor, criterio de entrada, actualización única), `:292-307` (prefijo del espejo desktop-sync, helper de siete raíces), `:515-518` (el checker falla ruidoso).
- **`corpus/docs/CORPUS_Architecture.md`** — restatea contratos sin citar el ID por token: `:41,48` (hard-dep única = Corpus; COR-5/9), `:82` (seis primitivas), `:133,138` (contrato Caliber/Limbs; CAL-12), `:140,146,173,178` (frontera Cargo/dominio de items; COR-11/12/14), `:186,190,194,234,235,282,284` (boot/registro by-ref; CAL-1/2/5/6/7, COR-2/7), `:293` (legacy ADS congelado; CAL-11), `:329,335,358` (stalker consumidor, git público MIT, cierre de bloque).
- **`corpus/CLAUDE.md`** — `:33,35,37` (assets stalker no versionados, carpeta dev/, mapa de mods RECICLAR/COMPAT-RUNTIME).
- **`corpus-cargo/CLAUDE.md`** — `:7,19,21,22,27,39,43,62,68,80,114,115,116,120,130,132,138,140` (grid solo-render, orden de lectura, changelog, VGUI Dock/Paint, soft-deps, manifest, hotkeys slot1-7, refresh en sitio, spawn desarmado, commits GIT-5/7 sin citar).
- **`corpus-caliber/CLAUDE.md`** — `:3,7,17,19,21,22,29,33` (orden de lectura, detección runtime COR-5, estado ≤1 pantalla FLU-15, changelog FLU-14, español/inglés GIT-4, stalker consumidor COR-10).
- **`corpus-coagulant/CLAUDE.md`** — varias líneas de proceso/soft-dep que restatean COR-5/10/11, FLU-14/15, GIT-4 sin token.

El detalle completo de las 268 (ref, tema, afirmación, alcance, fuerza) vive en la salida de la fase FLU-25 del gate. **No se parchean en esta acta** (no son contradicciones): se listan para que el autor decida acuñar o citar. La mayoría son *restatements* de un ID existente cuya sede está en otro doc — el arreglo canónico es citar el ID, no inventar uno nuevo.

---

## 4. Ambigüedades de alcance: **270**

Afirmaciones sin los cuatro ejes de alcance declarados (REALM / MODULO / SOFT-DEP / BLOCK-SLICE) — ambigüedad latente, no hallazgo. §7.1 recuerda que confundir alcance es el 90% del ruido; una afirmación sin alcance explícito es donde un lector futuro lo confunde. Se detectaron **270**. Reparto grueso por doc (muestra enumerada por el gate): `corpus/CLAUDE.md:3,15,17` (proceso de lectura, sin block); `CORPUS_Architecture.md:41,329,335,336,337,338,339` (soft-deps, stalker, git, infra COR-10, prefijo COR-6, colección Workshop); `corpus_roadmap.txt:39,45,50,52,56,65,83,88` (próximos grandes de cada módulo, block/slice declarado pero realm no); los CLAUDE.md de Caliber/Coagulant (`:3,7,9,11,17,19,20,26,27,28,32,36,41,44,47,48`) con REALM o BLOCK sin especificar.

Muchas de estas **sí citan IDs** (COR-5/10/11/14, COA-4/5/7/8/28, CAL-1/4/6/7/18, FLU-14/15, GIT-1/4), lo que reduce el riesgo de derivación: el ID ancla el hecho aunque el alcance no esté escrito en la frase. Recomendación de ingeniería: no es urgente; al tocar cada doc, completar los ejes faltantes (sobre todo BLOCK/SLICE, el más omitido) evita que un lector aplique una regla de un slice a otro. Detalle completo en la salida de la fase de alcance.

---

## 4.bis CONTRATO-VS-ÁRBOL

Fase distinta del doc-vs-doc: compara cada contrato numerado de los CLAUDE.md (nivel 4) contra el árbol Lua real (nivel 1). Cuando chocan **no hay deliberación** — el CLAUDE.md está mal, y es el doc que todo ejecutor lee primero. 54 contratos de 6 CLAUDE.md verificados.

| Veredicto | N |
|---|---|
| CUMPLIDO | 47 |
| INCUMPLIDO | 0 |
| **PARCIAL** | **2** |
| NO_VERIFICABLE (punto ciego de la fase, no su éxito) | 5 |

**0 INCUMPLIDOS:** ningún contrato de CLAUDE.md fue directamente falsado por el árbol. Los 5 NO_VERIFICABLE son el punto ciego: contratos cuya superficie no pudo cruzarse contra el Lua en esta corrida (típicamente los que tienen sede en un `.lua` que el doc-audit no abrió — ver Hueco 2). No cuentan como limpios.

### PARCIAL 1 — Caliber, contrato #1 (namespace / COR-2, COR-7)

**Evidencia:** `corpus-caliber/lua/corpus_caliber/server/corpus_caliber_core.lua:3`.
La cláusula NORMATIVA (ningún global suelto, by-ref) **se cumple íntegramente**: los seis archivos que consumen la tabla la cachean por `GetModule` (armor.lua:3, core.lua:3, limbs.lua:5, shields.lua:36, scavenger.lua:35, browser.lua:7), el init la registra antes (init.lua:72), y el único símbolo sospechoso de global (`StyleManualSlider`, browser.lua:1619) es un upvalue file-local con forward-decl en browser.lua:595. Lo que el árbol contradice es la **generalización literal** "Cada archivo abre con `local CALIBER=…`": `shared.lua` no la abre (solo registra decals/partículas) y `client_options.lua` tampoco (solo `Corpus.UI.RegisterTab`, :232); el stool `corpus_caliber_config.lua` la resuelve lazy dentro de funciones (:79,101), no al tope.
**Corrección sugerida al CLAUDE.md** (triage A, el Lua dirime): cambiar "Cada archivo abre con…" por "Cada archivo **que consume la tabla del módulo** la cachea vía `local CALIBER=Corpus.GetModule("caliber")` (lazy en el stool); los que no la consumen —shared, client_options— no la piden". La protección (no-globals) queda intacta; solo se ajusta el alcance de la frase.

### PARCIAL 2 — Coagulant, contrato #5 (COA-2: presencia = HasItem, nunca CountItem)

**Evidencia:** `corpus-coagulant/lua/corpus_coagulant/server/corpus_coagulant_treatment.lua:148`.
La ruta principal cumple: `onUse` devuelve siempre `false` (items.lua:25), el consumo es al completar vía `TakeItem` (treatment.lua:152), y el chequeo que gatea el ARRANQUE usa `HasItem`, nunca `CountItem` (treatment.lua:98) — que es donde el torniquete unique debe verse. **PERO** la re-validación AL COMPLETAR usa `if cargo.Inventory.CountItem(ply, t.item) < 1` (treatment.lua:148), la función que COA-2 declara "nunca". No es bug: esa rama está guardada por `if tr.kind ~= "tourniquet"` (:147), así que `CountItem` solo toca stackables (bandage/medkit/bloodbag), donde el conteo es exacto y no hay ceguera a uniques.
Es el hallazgo más útil de esta fase: **el contrato se cumple en la ruta principal y se saltea en una rama.** Por §7.1 el código manda. **Corrección sugerida** (triage A): ablandar el absoluto de COA-2 en el CLAUDE.md a "la presencia que gatea un tratamiento (y todo chequeo sobre uniques) usa `HasItem`; la re-validación de consumo al completar puede usar `CountItem` sobre stackables"; o bien pasar treatment.lua:148 a `HasItem` para que el "nunca" sea literal. Como está, el contrato es universal en el doc pero se deriva en una rama del código.

---

## 4.ter ESTADO POR BUCKET (18 temas)

Una fila por tema. Un cero de contradicciones significa cosas distintas según el estado: `limpio` (se cruzó y salió sano) NO es lo mismo que `N/A por alcance`, `sin normas que cruzar` o `NO CRUZADO`. Ningún bucket quedó NO CRUZADO en esta corrida.

| Tema | Estado | Normativas | Hallazgos | Por qué |
|---|---|---|---|---|
| framework-delgado | limpio | 34 | 0 | cruzadas entre sí, nada sobrevivió a la adjudicación |
| soft-deps | limpio | 87 | 0 | idem |
| realms | limpio | 15 | 0 | idem |
| namespacing | limpio | 39 | 0 | idem |
| contrato-items | limpio | 46 | 0 | idem |
| boot-carga | limpio | 34 | 0 | idem |
| **dano-limbs** | **1 hallazgo** | 37 | **1** | contradicción 2.2 (Caliber_Architecture.md:216 vs CAL-12) |
| **dominio-medico** | **1 hallazgo** | 48 | **1** | contradicción 2.1 (Semilla:28-29 vs COA-8) |
| inventario | limpio | 104 | 0 | cruzadas entre sí (ver salvedad Hueco 5: re-peinado numérico recomendado) |
| ui-vgui | limpio | 81 | 0 | idem |
| persistencia | limpio | 26 | 0 | idem |
| evidencia | limpio | 26 | 0 | idem |
| proceso | limpio | 240 | 0 | idem |
| assets-licencias | limpio | 30 | 0 | idem (fuente única: ver Hueco 5) |
| compat-terceros | limpio | 47 | 0 | idem (fuentes en `dev/` fuera del audit: ver Hueco 5) |
| ciclo-de-vida-del-jugador | limpio | 18 | 0 | idem |
| config-y-balance | limpio | 34 | 0 | idem (ver salvedad Hueco 5: drift numérico) |
| rendimiento | limpio | 18 | 0 | idem |

**Docs sin IDs propios (8) — etiqueta `N/A - sin IDs propios`, jamás `limpio`:** ver Hueco 1. Sobre ellos el cruce de IDs es CIEGO; su cobertura vino del PASE DE VALOR (que produjo los 9 hechos falsos de §2.3-2.11), no del cruce de IDs.

---

## 5. Huecos de esta auditoría — honestidad sobre lo NO cubierto

**Cobertura perdida: 0.** Ningún agente murió, ningún tramo quedó sin auditar. El acta NO está degradada. Dicho eso, hay puntos ciegos estructurales que un "0 contradicciones" no debe disfrazar:

### 5.1 Ocho docs auditados NO son sede de ningún ID propio — sobre ellos el gate es CIEGO por el eje de IDs

Para estos ocho, un "limpio" en el cruce de IDs significaría **"no auditado"**, no "coherente":

1. `corpus/docs/corpus_roadmap.txt`
2. `corpus-cargo/docs/cargo_roadmap.txt`
3. `corpus-coagulant/docs/coagulant_roadmap.txt`
4. `corpus-caliber/docs/caliber_roadmap.txt`
5. `corpus-craving/docs/craving_roadmap.txt`
6. `corpus-craving/docs/Craving_Block4_Semilla.md`
7. `corpus-stalker/docs/STALKER_Arquitectura.md`
8. `corpus-cortex/docs/Cortex_ContratosEntrantes.md`

**Lo que tapa el hueco (parcialmente):** se les corrió el **PASE DE VALOR** — la única vía por la que se los puede auditar: verificar cada afirmación sobre el presente contra el árbol (árbitro nivel 1). Ese pase encontró **9 hechos falsos** (§2.3-2.11), todos triage A. Es evidencia de que el pase funciona y de que estos docs SÍ driftan: 6 de los 9 caen en roadmaps/semillas/Cortex de esta lista. **Asimetría reveladora:** `Coagulant_Block3_Semilla.md` SÍ es sede (COA-10, COA-29) y por eso su drift de zonas se cazó como contradicción 2.1; su gemela `Craving_Block4_Semilla.md` **no es sede de nada** — si driftó como driftó la de Coagulant, el cruce de IDs no la agarra. Recomendación: correr sobre `Craving_Block4_Semilla.md` un pase de valor focalizado.

### 5.2 Once normas con sede en un `.lua`, citadas por docs, que el doc-vs-doc no pudo abrir

`ids.yaml` ancla 11 entradas a un archivo de código, no a prosa: **CAL-12, CAL-15, CAL-20, COA-30, CRV-14, CRG-2, CRG-4, CRG-5, CRG-13, CRG-40, CRG-46**. Cuando un doc de arquitectura cita CRG-2 o CAL-12, el gate doc-vs-doc lo comparó contra nada (el texto canónico vive en un header de Lua fuera del set). Es el NO_VERIFICABLE real. **Ojo con CAL-12:** es el corazón de la contradicción 2.2 y su sede según `ids.yaml` es un `.lua`, pero el arbitraje la resolvió citando `CLAUDE.md:63`. O el registro está desactualizado o el arbitraje citó la sede equivocada — reconciliar cuál es la sede real de CAL-12 antes de dar 2.2 por cerrada (el veredicto no cambia: Lua y CLAUDE.md concuerdan en el lado A). Recomendación: para estas 11, extraer la prosa del header Lua y cruzarla contra todo doc que las cite.

### 5.3 Desfase de la columna `total` del script (3) — deuda de mantenimiento del gate

La constante de conteo del script estaba desincronizada con el árbol en tres docs. **La corrida NO quedó degradada** (el conteo real se derivó en la fase 0 y los tramos se armaron con él, no con la constante):

- `corpus/docs/corpus_roadmap.txt`: constante 112, árbol 115 (3 líneas).
- `corpus-coagulant/docs/Coagulant_Architecture.md`: constante 341, árbol 378 (37 líneas).
- `corpus-coagulant/docs/coagulant_roadmap.txt`: constante 70, árbol 75 (5 líneas).

Es la tercera vez que pasa: deuda de mantenimiento del gate. Ningún doc reportó "NO DERIVADO", así que ninguno se auditó por una constante sin verificar.

### 5.4 Buckets con fuente única o fuentes fuera del audit — su "limpio" es débil, no falso

- **`compat-terceros`**: su contenido real (DRGBase/VJBase/ZBase/NEAD, ACE3) vive en `dev/*_Referencia.md`, fuera del audit. "Limpio" sobre un tema cuyas fuentes no estaban cargadas es vacío, no validado.
- **`assets-licencias`**: lo sostiene esencialmente `stalker/ASSETS.md` (STK-3/6/7). Un tema de fuente única no puede auto-contradecirse: "limpio" trivial.
- **`inventario`** y **`config-y-balance`**: superficie enorme (Cargo entero; pools HP, pesos, precios, tasas). El drift numérico casi nunca se pilla doc-vs-doc salvo que el mismo número esté reescrito en dos sedes — y de hecho el pase de valor SÍ pilló dos (trivia 36→40, net.Receive 15→22). Recomendación: re-peinar ambos con foco numérico (extraer cada constante y buscar la misma magnitud con valor distinto entre docs).

### 5.5 Temas transversales sin bucket propio

- **net-protocolo / autoridad-de-servidor**: no hay bucket que cubra el protocolo de red ni la validación server-authority (client `net.Start` → server valida antes de confiar). `namespacing` cubre el nombre del mensaje (COR-4), no el contrato de confianza. Es superficie presente en casi todos los architecture docs y el vector clásico de exploits en GMod. Recomendación: abrir el bucket y re-extraer.
- **versionado/migración de save-data**: `persistencia` cubre el *dónde*, no el *cómo evoluciona el schema*.

### 5.6 Cortex casi entero fuera del audit

Solo se auditó `Cortex_ContratosEntrantes.md` (que además no es sede de nada). Cortex no tiene CLAUDE.md; su diseño real vive en `dev/Cortex_DRGBase_Referencia.md`, `Cortex_VJBase_*`, `Cortex_ZBase_*`, `Cortex_NEAD_*`, fuera del audit. Cortex es el consumidor futuro que la contradicción 2.2 identifica como víctima potencial; auditar solo sus contratos-entrantes deja ciego justo al que más importa cuando arranque.

---

## 6. Qué NO se auditó y por qué

- **doc-vs-código general** queda FUERA de alcance. Este acta NO afirma que nada esté implementado ni sin implementar. "Todavía no está implementado" NO es un hallazgo (§7.1): acá se diseña por delante del código a propósito (mock-first, FLU-17). Las únicas comparaciones contra el árbol que sí se hicieron son las que la jerarquía exige para **adjudicar** (§2, §4.bis) y el **pase de valor** sobre docs sin IDs (§2.3-2.11), donde el árbol es árbitro de nivel 1.
- **Huérfanos, bicéfalos y sedes rotas** no son de este gate: los prueba el checker determinista (`.claude/check-ids/`), que corre en cada commit que toca superficie normativa.
- **El espejo desktop-sync** (§6) está fuera de la jerarquía por diseño: espejo divergente = espejo desactualizado, no contradicción.
- **`ids.yaml`** no integra la jerarquía: es índice. Cero divergencias yaml-vs-sede en esta corrida (§3.1).

---

*Acta generada en modo READ-ONLY. Único archivo escrito: este. Todos los parches son PROPUESTOS; el gate propone, el autor dispone. Foto del estado al 2026-07-22 — inmutable.*
