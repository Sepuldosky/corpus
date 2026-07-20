# Acta — Auditoría de coherencia documental del ecosistema Corpus

**Fecha:** 2026-07-20
**Modo:** SCOPED / PILOTO — solo el framework (`corpus/`), 5 docs + 1 `CLAUDE.md`
**Estado del acta:** **ÍNTEGRA** — cobertura completa: ningún agente murió, ningún tramo quedó sin auditar (COBERTURA PERDIDA = 0)
**Alcance:** doc-vs-doc, adjudicado contra el Lua / `<modulo>_estado.md` / `CHANGELOG.md` según la jerarquía de autoridad de `corpus_flujo_trabajo.txt` §7.1 (FLU-22), **leída en su sede para esta corrida**, no de memoria
**Modo de escritura:** READ-ONLY estricto sobre las siete raíces. Este acta es el **único** archivo escrito. **Todos los parches son PROPUESTOS; ninguno aplicado.** El gate propone, el autor dispone.
**Inmutabilidad (AUD-4):** esta acta es la foto del estado AL MOMENTO DE AUDITAR. No se edita después. Si algo cambió, lo dice el acta siguiente.

---

## Cifras

| Métrica | Valor |
|---|---|
| Contradicciones confirmadas (3 verificadores adversariales cada una) | **1** |
| — BLOQUEANTE / ALTA / MEDIA | 0 / 0 / 0 |
| — BAJA | 1 |
| Triage A (REPARABLE: el árbol dirime) | 1 |
| Triage B (VOTO DEL AUTOR) | 0 |
| Triage C (bug de código) | 0 |
| CADUCO | 0 |
| Divergencias yaml-vs-sede | **0** |
| Normativas sin ID (FLU-25) | **48** |
| Afirmaciones sin alcance declarado | 20 |
| Contratos verificados contra el árbol (fase ContratoArbol) | 11 |
| — CUMPLIDO / INCUMPLIDO / PARCIAL / NO_VERIFICABLE | 7 / **0** / **2** / **2** |
| Cobertura perdida | **0** |
| Docs auditados **sin un solo ID propio** (cobertura ciega) | **1 de 5** (`corpus_roadmap.txt`) |

---

## 1. Resumen ejecutivo — lo que cambia el plan

El cruce doc-vs-doc salió casi limpio: **una sola contradicción confirmada, de gravedad BAJA y sin superficie de runtime**. Ese resultado, por sí solo, no es la noticia de esta corrida.

**Lo que cambia el plan está en la fase de completitud y en la fase ContratoArbol, no en el cruce.** Tres hallazgos, con nombre y apellido:

1. **`corpus/CLAUDE.md` se autodeclara sede de la familia `COR-nn` y no reconoce COR-12, COR-13 ni COR-14 — ni como propios ni como excepción.**
   El párrafo de cierre de §Contratos enumera las excepciones (COR-7 y COR-8 en §3 de la arquitectura; COR-10 y COR-11 en §1-4/§2/§6) y omite tres invariantes VIGENTES cuya sede es `CORPUS_Architecture.md` §5 (verificado: `docs/ids.yaml:158`, `:175`, `:184`, y la prosa en `docs/CORPUS_Architecture.md:172-174`). El ejecutor que lea el `CLAUDE.md` —el doc que todos leen primero— cree tener el mapa completo de la familia y le faltan tres. → **§5, Hueco 2**

2. **COR-12 vive en el framework y es dominio de ítems: eso tensiona COR-1 y COR-10 de frente, y hoy la tensión está archivada como deuda D-1 en vez de resuelta como voto.**
   COR-12 (`ids.yaml:157`, «la def de ítem **y** su `onUse` se registran en AMBOS realms») es, según su propia nota en `ids.yaml:166-172`, «LA NORMA MÁS CARA DEL ECOSISTEMA» y «la ÚNICA sede que enuncia las dos mitades». La nota admite: *«Vive en el framework y no en Cargo — ver deuda D-1, que es seria»*. Contra COR-1 y COR-10 (nada de lógica de dominio en Corpus; ni siquiera lo compartido por dos módulos sube), eso es una pregunta abierta de arquitectura, no una anotación. **Recomendación: elevarla a voto del autor explícito.** → **§5, Hueco 2**

3. **Dos contratos del `CLAUDE.md` del framework se cumplen en la ruta principal y se saltean en una rama, y el árbol —árbitro de nivel 1— ya decidió distinto que la letra del doc:** COR-15 (el stool de Caliber crea su propia categoría en la pestaña Tools) y COR-16 (el propio `corpus_selftest.lua` emite `print` crudo, contra la palabra «Única excepción»). Ninguno es un bug: son **enunciados universales del doc que el tree desmiente**. → **§4.bis**

Y un cuarto, de la misma clase que la única contradicción confirmada:

4. **Un valor caduco vivo, en tres sedes, que este cruce no cazó y la crítica de completitud sí:** `corpus_roadmap.txt:81` afirma que el repo de Cortex es semilla *«sin código **ni docs**»*. **Falso:** `corpus-cortex/docs/Cortex_ContratosEntrantes.md` existe, 129 líneas (verificado). → **§5, Hueco 3**

---

## 2. Contradicciones por gravedad

### 2.1 — BAJA · Triage **A (REPARABLE)** · tema `proceso` · el ejemplo de commit dice «seis raíces» y el workspace tiene siete repos

**Afirmación A** — `corpus/docs/corpus_convenciones_commits.txt:120` (el material de entrada la citaba en `:118`; la línea real, verificada abriendo el archivo, es la **120**):

```
    - chore(workspace): crea las seis raíces del multi-root workspace
```

**Afirmación B** — `corpus/docs/CORPUS_Architecture.md:298` y `corpus/CLAUDE.md:29-33`: el workspace tiene **siete repos git independientes** (framework + cinco módulos + `corpus-stalker`) **más `dev/`**, que no es repo.

**Quién gana según §7.1: gana B.** Y no por mayoría de docs, sino por dos árbitros que están por encima de ambos:

- **Nivel 1 (código / árbol real):** `corpus.code-workspace` declara **ocho** folders — siete repos (`corpus`, `corpus-cortex`, `corpus-caliber`, `corpus-coagulant`, `corpus-craving`, `corpus-cargo`, `corpus-stalker`) más `dev (no publicado)`.
- **Nivel 3 (CHANGELOG `[APLICADO]`, que **deroga** lo que un doc siga enunciando como vigente — §7.1 punto 3):** `corpus/docs/CHANGELOG.md:180`, PARCHE 1 — *«§8: seis raíces → ocho (siete repos + `dev/`), con `corpus-stalker` descrito como addon de contenido. **[APLICADO 2026-07-14]**»* (verificado abriendo el archivo).
- **Refuerzo:** `corpus/docs/corpus_flujo_trabajo.txt:158` — *«la pasada de veracidad del 2026-07-14 tuvo que limpiar — el framework decía "seis raíces"»*. Es decir: el barrido por VALOR (§7.3.a) ya pasó por este valor y este eco sobrevivió.

Encaja en el caso **(b)** del criterio de hallazgo: un doc afirma algo que el CHANGELOG ya resolvió distinto. Mismo eje MÓDULO, mismo objeto enumerado, sin distinción de realm, soft-dep ni slice.

**Contra-evidencia evaluada y descartada (las tres, abriendo las fuentes — §7.3.b):**

1. *«Es un commit histórico y el workspace SÍ nació con seis raíces»* — avalada por `CHANGELOG.md:22` (*«creación del workspace VSCode de seis raíces»*, verificado). **Cae:** `git log --oneline --all` **no contiene** ese commit; el de bootstrap real es `e8172ca chore(workspace): inicializa repositorio git con docs de bootstrap`. El ejemplo es **sintético**, está en imperativo presente como modelo a imitar, no como cita del historial. Compárese con `CHANGELOG.md:163`, que sí marca el pasado explícitamente (*«seis raíces privadas → hoy siete repos»*).
2. *«Seis es correcto en este mismo doc»* — cierto para `corpus_convenciones_commits.txt:9` (**GIT-6**, *«las seis raíces consumidoras (corpus-cortex, corpus-caliber, corpus-coagulant, corpus-craving, corpus-cargo y corpus-stalker)»*, verificado y **correcto**: 5 módulos + stalker). Pero es **otro referente**: la línea 120 dice *«las raíces del multi-root workspace»*, que son ocho.
3. *«Es solo un ejemplo de formato»* — cae contra §7.3.a: *«BARRER POR EL VALOR, NO POR LA LISTA. El grep va por la cifra o la frase vieja»*.

**Voto de los verificadores: 2 de 3 a favor.** El disidente no dudó de los hechos: sostuvo que el par **ya fue adjudicado y desestimado** por un gate anterior. Es cierto y se deja constancia, porque re-litigar sin decirlo sería el defecto que este gate existe para no cometer:

> `docs/auditorias/2026-07-16b_coherencia_docs_PILOTO_v2.md:448-452` (verificado abriendo el acta): *«**DESESTIMADO, y se deja constancia de por qué:** es un ejemplo que cita un commit histórico, no una norma vigente sobre el conteo de raíces. Cuando ese commit se hizo, eran seis. Parcharlo sería falsificar el ejemplo. Falso positivo.»*

**Esta corrida lo reabre con evidencia que aquella no tuvo: el commit no existe en `git log --all`.** La premisa fáctica sobre la que se desestimó («cita un commit histórico») es falsa. Las actas son inmutables y aquella no se corrige: la corrige ésta.

El disidente aporta además un dato que ninguna de las otras dos lentes trajo, y que **sube la confianza en el hallazgo en vez de bajarla**: el commit `eb88940` reabrió este archivo y corrigió la **línea 9** dejando la **120** intacta. El barrido por valor **llegó al archivo y omitió el ejemplo**. Eso es exactamente el modo de falla que §7.3.a describe.

**Parche PROPUESTO (NO APLICADO)** — archivo `corpus/docs/corpus_convenciones_commits.txt`, §4.2 «Estructura y docs», línea 120:

```diff
- - chore(workspace): crea las seis raíces del multi-root workspace
+ - chore(workspace): crea las raíces del multi-root workspace
```

**Recomendada la opción neutra, sin cifra.** §4.2 existe para ilustrar el FORMATO `<tipo>(<alcance>): <descripción>` (GIT-1/GIT-2), no para enumerar el árbol. Un ejemplo sin cifra deja de ser superficie normativa que el barrido por valor tenga que perseguir cada vez que el workspace crezca — y este valor ya derivó dos veces.

*Alternativa, si el autor prefiere conservar el número:* `crea las siete raíces git del multi-root workspace` (siete **repos**; el `.code-workspace` declara **ocho folders** porque suma `dev/`, que no es repo — si se enumeran folders, la cifra es ocho).

**NO TOCAR** (verificados correctos en esta pasada):
- `corpus_convenciones_commits.txt:9` — GIT-6, «las seis raíces consumidoras»: referente distinto, cifra correcta. **Confundirla con la 120 al aplicar el parche es el error probable.**
- `docs/CHANGELOG.md:22` y `:163` — historial inmutable (FLU-14), verdadero en su momento.
- `docs/ids.yaml:515` — cita la prosa de GIT-6, seis consumidoras, correcto.

**Nota de barrido (§7.3.a), no hallazgo aparte:** `.claude/desktop-sync/Corpus_convenciones_commits.txt:120` replica el eco. El espejo está **fuera de la jerarquía** por §7.1 (*«espejo divergente = espejo desactualizado»*) y lo regenera `sync.ps1`. **Pero la reparación no está cerrada hasta que el espejo se regenere:** ver Hueco 8.

**Gravedad BAJA.** Sin superficie de runtime. No amerita entrada propia de CHANGELOG salvo que se agrupe con otras reparaciones de valor caduco — y el Hueco 3 aporta exactamente esa compañía.

---

## 3. Patología del registro

### 3.1 Divergencias `ids.yaml`-vs-sede: **0**

El campo `titulo` de cada entrada se cruzó contra la prosa de su sede y **no hubo ninguna divergencia**. Es un resultado real, no un cero vacío: hubo textos que cruzar en ambos lados.

**Pero se auditó por un solo eje.** Ver Hueco 7: el campo `nota:` no se cruzó, y ahí hay contenido sustantivo que la sede no tiene.

### 3.2 Normativas sin ID (FLU-25): **48**

FLU-25 / §7.2 lo dice sin ambigüedad: *«una frase con SIEMPRE / NUNCA / DEBE / JAMÁS o bien DEFINE un ID o bien CITA uno. Una norma sin ID es una norma que va a derivar.»*

Distribución por doc:

| Doc | Normas sin ID |
|---|---|
| `corpus/docs/corpus_flujo_trabajo.txt` | 22 |
| `corpus/docs/CORPUS_Architecture.md` | 13 |
| `corpus/CLAUDE.md` | 6 |
| `corpus/docs/corpus_roadmap.txt` | 5 |
| `corpus/docs/corpus_convenciones_commits.txt` | 2 |
| **Total** | **48** |

Por tema: `proceso` 33, `assets-licencias` 4, `dano-limbs` 3, `evidencia` 3, `compat-terceros` 2, `contrato-items` 1, `soft-deps` 1, `dominio-medico` 1.

**Los cinco que más caro salen si derivan** (criterio: la norma gobierna conducta cross-repo o es sede única de un hecho verificable):

1. **`corpus_flujo_trabajo.txt:549-551`** — *«READ-ONLY ESTRICTO: el único archivo que escribe es su acta; el gate PROPONE y jamás aplica»*. Es la norma que gobierna a **este mismo documento** y no tiene ID. Si deriva, el gate empieza a escribir en los repos.
2. **`corpus_flujo_trabajo.txt:586-591`** — las tres cadencias, que **se autodenominan AUD-1/AUD-2/AUD-3 en la prosa** pero cuya sede no las declara con la sintaxis de definición. Están a medio camino: nombradas, no acuñadas.
3. **`corpus_flujo_trabajo.txt:515-518`** — *«FALLA RUIDOSO, NUNCA EN SILENCIO … un "limpio" que no corrió no es un limpio»*. Sede única de la garantía de integridad del anillo barato.
4. **`CORPUS_Architecture.md:138`** — *«la Limbs API debe ser agnóstica a la entidad»*. Es un **contrato cross-repo entre Caliber y Coagulant sobre algo no construido** — la categoría que §7.1 corolario dice que no tiene árbitro y no se repara sola. Sin ID, no hay nada que citar cuando el Block 3 de Caliber lo implemente.
5. **`corpus_roadmap.txt:82-84`** — *«Cortex está gated por la superficie de eventos daño/limb de Caliber»*. Es la **única condición de entrada** de un Block entero, y vive en el doc que el propio ecosistema declara intención pura.

**Lectura honesta de la cifra:** 33 de 48 son de `proceso`, y la mayor parte son normas de metodología del propio flujo. No es que el ecosistema tenga 48 bombas: es que el cuerpo normativo de **proceso** creció más rápido que su acuñación de IDs. La familia `FLU` cubre bien el diseño técnico y peor su propia metodología.

---

## 4. Ambigüedades de alcance — 20 afirmaciones

Afirmaciones normativas o descriptivas que **no declaran uno de los cuatro ejes** (realm / módulo / soft-dep / block-slice). No son hallazgos: son **ambigüedad latente**, el sustrato del que nace la contradicción futura.

El patrón es abrumadoramente uno solo: **17 de 20 omiten el REALM.**

Las tres que más pesan:

- **`CORPUS_Architecture.md:133`** — describe `hook.Run("Caliber_LimbsUpdated", npc, reason)` como *«aviso de refresh heredado de ADS, off-contract y sin consumidor»* **sin declarar realm**. El hook es server en su origen ADS; el doc no lo dice. Un consumidor futuro que lo enganche client-side no encuentra nada en el doc que lo frene. (Esta afirmación **además** no tiene ID: aparece en ambas listas.)
- **`CORPUS_Architecture.md:138`** — la Limbs API agnóstica, sin realm. Ver §3.2 punto 4.
- **`corpus_roadmap.txt:56-60`** — el slice 4 de Coagulant es UI, *presumiblemente client*, y el doc no lo declara. «Presumiblemente» es precisamente el problema.

**No son hallazgo, y se dice por qué:** las 20 pasan el filtro de falsos positivos. Ninguna contradice a otra; describen estados de diseño legítimos, varias de ellas mock-first (FLU-17) correctamente declarado — `corpus_roadmap.txt:64-66` nombra el puente `ApplyExternalCondition` como mock-first y **lo declara deuda (D-5)**, que es el doc haciendo su trabajo, no mintiendo.

---

## 4.bis CONTRATO-VS-ÁRBOL

Fase que **no es doc-vs-doc**: cada contrato numerado del `CLAUDE.md` se verificó contra el Lua. Cuando un `CLAUDE.md` (nivel 4) choca con el árbol (nivel 1) **no hay deliberación** — el `CLAUDE.md` está mal, y es el doc que todo ejecutor lee primero.

| Repo | Contratos | CUMPLIDO | INCUMPLIDO | PARCIAL | NO_VERIFICABLE |
|---|---|---|---|---|---|
| `corpus` (framework) | 11 | 7 | **0** | **2** | **2** |

**Cero INCUMPLIDOS.** El framework obedece sus propios contratos en la ruta principal. Los dos PARCIALES son el hallazgo útil de esta fase, y los dos NO_VERIFICABLE son su punto ciego — no su éxito.

### PARCIAL 1 — Contrato 8 / **COR-15** (UI shell vía la primitiva)

**Enunciado:** una sola entrada por módulo en el menú Q vía `Corpus.UI.RegisterTab`, bajo la categoría única «Corpus» (Utilities); ningún módulo abre un menú propio en el spawnmenu, y las ventanas adicionales se abren por botón/concommand desde su tab.

**La ruta principal CUMPLE, y está enforceada, no solo prometida:**
- `lua/autorun/client/corpus_ui.lua:33` — `spawnmenu.AddToolCategory("Utilities", "Corpus", "Corpus")`, categoría única (verificado).
- `lua/autorun/client/corpus_ui.lua:26-29` — `_tabs` está keyed por `module` y el re-registro **reemplaza** en vez de duplicar, con log por la primitiva (verificado).
- Grep de `AddToolCategory` / `AddToolMenuOption` sobre los seis consumidores: **cero** llamadas directas. Los cuatro módulos con código client registran **exactamente un tab cada uno** vía la primitiva (`corpus_caliber_client_options.lua:232`, `corpus_cargo_options.lua:98`, `corpus_coagulant_options.lua:58`, `corpus_craving_options.lua:8`).

**La rama que se saltea, con archivo:línea:**
- `corpus-caliber/lua/weapons/gmod_tool/stools/corpus_caliber_config.lua:4` — `TOOL.Category="Caliber"` (verificado). Caliber tiene una **segunda superficie propia en el spawnmenu**: su stool de debug crea la categoría «Caliber» en la pestaña Tools.

El `CLAUDE.md` carga **una sola** excepción — *«las ventanas adicionales se abren por botón/concommand desde su tab»* — y un modo de toolgun no es ni una ventana ni un botón desde el tab.

**Parche PROPUESTO al `CLAUDE.md` (NO aplicado)** — contrato 8, ampliar la cláusula de excepción:

> «…las ventanas adicionales se abren por botón/concommand desde su tab, **y los modos de toolgun (stools) quedan fuera de esta norma: viven en la pestaña Tools bajo la categoría del módulo, no en el menú Q.**»

*Alternativa estricta (no recomendada):* mover el stool de Caliber bajo una categoría común. Rompe la convención nativa de GMod y no aporta nada.

**Triage: A.** El árbol es árbitro de nivel 1 y ya decidió; se parcha el doc. *(El material de origen sugería mandarlo a voto de autor; se corrige acá: la instrucción de esta fase es explícita en que un contrato que el Lua dirime no va a voto. Lo que sí queda a criterio del autor es cuál de las dos redacciones adopta, que es preferencia editorial dentro de un triage A ya decidido.)*

### PARCIAL 2 — Contrato 9 / **COR-16** (log vía la primitiva)

**Enunciado:** toda salida de consola de un módulo va por `Corpus.Log(<module>, ...)` → prefijo `[Corpus:<module>]`; nada de `print` crudo. **Única excepción:** el fallback ruidoso del boot cuando el framework mismo falta.

**La ruta principal CUMPLE, y se verificó buscando el contraejemplo, no el caso favorable:**
- `lua/autorun/corpus_log.lua:7-8` — el `print` de la implementación, el único legítimo por construcción.
- Grep de `print(` sobre los seis consumidores: solo wrappers `dprint` locales, y los dos revisados enrutan a la primitiva (`corpus_caliber_browser.lua:16-18`, `corpus_caliber_core.lua:41-44`, ambos `Corpus.Log("caliber", ...)`).
- El fallback de boot está bien **y usa `MsgN`, no `print`** — `corpus-cargo/lua/autorun/corpus_cargo_init.lua:143-144`, con el comentario *«Corpus.Log is not used here: Corpus does not exist»*.

**La rama que se saltea, con archivo:línea:**
- `corpus/lua/autorun/corpus_selftest.lua:55, 58-59, 63, 65` — el bloque de reporte emite **`print` crudo**, sin pasar por `Corpus.Log`, y con prefijo `"[Corpus]"` a secas en vez de la forma `[Corpus:<module>]` que el contrato fija (verificado abriendo el archivo).

**Precisión importante:** el sujeto de COR-16 es *«un módulo»*, y el selftest **no es un módulo**. Formalmente **no hay violación de conducta**. Lo que el árbol desmiente es la palabra **«Única»**: hay un segundo sitio de `print` crudo que ninguna excepción del contrato cubre. Es una afirmación universal-negativa del doc contradicha por el tree — exactamente lo que FLU-25 quiere que no derive.

**Parche PROPUESTO al `CLAUDE.md` (NO aplicado)** — contrato 9, reemplazar la cláusula de excepción:

> «**Dos excepciones, ambas del framework y ninguna de un módulo:** (a) el fallback ruidoso del boot cuando el framework mismo falta —no hay `Corpus.Log` que usar; **se emite con `MsgN`**—, y (b) el bloque de reporte de `corpus_selftest.lua`, que imprime con prefijo `[Corpus]` a secas porque reporta sobre el framework entero, no sobre un módulo.»

**Nota de precisión que va en el mismo parche:** el doc dice «fallback ruidoso» sin fijar el medio, y el árbol usa `MsgN`. Conviene nombrarlo, para que nadie lo «corrija» a `print`.

**Triage: A.**

### Los 2 NO_VERIFICABLE — el punto ciego de esta fase

**Dos de once contratos volvieron NO_VERIFICABLE, y eso no es un limpio.** Son contratos cuya conformidad no puede probarse contra el árbol actual: o bien su superficie todavía no existe, o bien la norma es de conducta de agente y no deja huella en el Lua. **Sobre ellos esta fase no dice nada** — ni que se cumplen ni que no. Se declaran acá para que el conteo `7 CUMPLIDO` no se lea como `9 de 11`. La cobertura real de esta fase es **9 de 11 contratos con veredicto**, y 2 sin él.

---

## 5. Huecos de esta auditoría — honestidad sobre lo NO cubierto

**COBERTURA PERDIDA: 0.** Ningún agente murió; ningún tramo ni tema quedó sin auditar por caída. Esta acta **no** es DEGRADADA. Es el primer piloto que lo consigue junto con el `_v3` del 2026-07-16.

Dicho eso, la cobertura fue **completa dentro de un corpus que dejó cosas afuera**. Los ocho huecos, en orden de prioridad de reparación.

### Hueco 1 (crítico) — dos de los tres «docs vivos» nunca entraron al corpus

`corpus/CLAUDE.md` manda leer **`docs/corpus_estado.md` ANTES que la arquitectura**, y pone `docs/CHANGELOG.md` como tercer doc vivo. **Ninguno de los dos está entre los 5 auditados.** No son pasivos: `corpus_estado.md` (121 líneas) cita AUD-3, COA-5, COR-12, COR-15, COR-16, FLU-15, GIT-1; `CHANGELOG.md` (808 líneas) cita **76 IDs distintos**.

Son, además, los dos docs con **mayor densidad de valores** (conteos, fechas, estados) — exactamente la clase de la única contradicción que esta pasada confirmó. **Auditar los 5 estables y saltear los dos que cambian todas las semanas invierte el riesgo.**

Peor: en `CHANGELOG.md` conviven **`COR-1` y `COR-01`**, y **`FLU-14` y `FLU-07`**. El checker canoniza y no se queja; un lector humano lee dos IDs distintos. Es un bicéfalo de superficie que solo se ve leyendo el doc que nadie leyó.

**Para taparlo:** incorporar `corpus_estado.md` y `CHANGELOG.md` al corpus del gate, aunque sea con un pase acotado al eje **VALOR** (§7.3.a) en lugar del cruce semántico completo; y normalizar `COR-01`/`FLU-07` a su forma canónica en la misma pasada.

### Hueco 2 (crítico) — COR-12, COR-13 y COR-14 no existen para el `CLAUDE.md`

**El hallazgo más caro de la corrida.**

`corpus/CLAUDE.md` §Contratos declara: *«Esta es la **sede** de la familia `COR-nn`: la definición canónica de cada contrato vive acá»*, y enumera las excepciones — COR-7 y COR-8 en §3 de la arquitectura, COR-10 y COR-11 en §1-4/§2/§6. **Omite COR-12, COR-13 y COR-14**, que existen, están VIGENTES y tienen sede en `CORPUS_Architecture.md` §5.

Verificado en esta pasada, abriendo las fuentes:
- `docs/ids.yaml:156-160`, `:173-177`, `:182-186` — los tres, `estado: VIGENTE`, `sede: "corpus/docs/CORPUS_Architecture.md §5"`.
- `docs/CORPUS_Architecture.md:172-174` — la prosa de las tres normas está ahí, en §5 «Contrato de ítems generalizado».

**Tres contratos del framework que el doc que se autodeclara sede de la familia no reconoce ni como propios ni como excepción.** El cruce doc-vs-doc no lo ve porque no hay dos frases que se contradigan: hay **una frase y un silencio**.

**Dato adicional hallado al verificar, que el material de entrada no traía:** la cadena `COR-12` / `COR-13` / `COR-14` **no aparece literalmente en `CORPUS_Architecture.md`**. Su §5 enuncia la prosa de las tres normas sin etiquetarlas con su ID. La sede existe y es correcta en contenido, pero **no está anclada por ID en el texto**. Eso es territorio del checker determinista (§7.7) y de la deuda D-3, no de este gate — se deja constancia porque explica por qué el silencio del `CLAUDE.md` no tenía nada que lo cazara.

**Y el silencio tapa algo más grave.** COR-12 —*«la def de ítem Y su `onUse` se registran en AMBOS realms»*— es, según su propia nota en `ids.yaml:166-172`, **«LA NORMA MÁS CARA DEL ECOSISTEMA»** y *«la ÚNICA sede que enuncia las dos mitades con su razón»*. La nota cierra: *«Vive en el framework y no en Cargo — ver deuda D-1, que es seria»*.

Eso choca de frente con **COR-1** y **COR-10**: nada de lógica de dominio en Corpus, ni siquiera lo compartido por dos módulos sube. **El contrato de ítems es dominio, y está alojado en el framework delgado.**

La tensión queda entre COR-12 y COR-1/COR-10 — **los tres del framework, los tres dentro del alcance de este piloto** — y aun así no salió del cruce, porque un cruce doc-vs-doc lee «§5 de la arquitectura desarrolla lo que `CLAUDE.md` resume» como **distinto nivel de detalle**, no como violación. Es el filtro de falsos positivos funcionando correctamente y costando un hallazgo real.

**Para taparlo:**
1. Añadir COR-12/13/14 al párrafo de excepciones de `CLAUDE.md` (parche mecánico, triage A por analogía).
2. **Abrir explícitamente la adjudicación COR-12 vs COR-10 como voto del autor** — *¿el contrato de ítems es infraestructura demostrablemente compartida, o dominio infiltrado en el framework?* — en vez de dejarla latente como deuda D-1. Es un hecho **sin árbitro de código** (§7.1 corolario): ambas lecturas son implementables, y el árbol no dirime cuál es la correcta.

### Hueco 3 (alto) — la contradicción confirmada tiene un gemelo vivo, en un doc sin IDs

La misma clase de valor caduco reaparece con Cortex:

- `corpus/docs/corpus_roadmap.txt:81` — *«el repo es semilla (README + LICENSE, **sin código ni docs**)»*.
- `docs/ids.yaml`, comentario de la familia `CTX` — *«Cortex tiene solo LICENSE + README»*.

**Falso.** Verificado: `corpus-cortex/docs/Cortex_ContratosEntrantes.md` existe, **129 líneas**; `ls corpus-cortex/` devuelve `LICENSE`, `README.md`, **`docs`**.

**Corrección al material de entrada, hecha abriendo la fuente (§7.3.b):** el material afirmaba que `corpus/CLAUDE.md:85` cargaba el mismo hecho vencido. **No lo carga.** El texto real dice *«Cortex sigue con el repo semilla: README + LICENSE, **sin código**»* — y eso es **verdadero**: Cortex no tiene Lua. El eco caduco está en **dos** sedes, no en tres. Se corrige acá para que el parche no toque una línea sana.

Ninguna de las dos salió en el cruce: el roadmap porque no tiene IDs propios (ver Hueco 4), el `ids.yaml` porque solo se cruzó su campo `titulo` (ver Hueco 7).

**Para taparlo:** parche de valor en las **dos** sedes reales, y reconocer `Cortex_ContratosEntrantes.md` como el primer doc de diseño de Cortex — hoy no figura en ninguna lista del framework. Agrupar con el parche de §2.1: misma clase, mismo barrido.

### Hueco 4 (alto) — un doc auditado no tiene un solo ID propio, y sobre él este gate es ciego

**De los 5 docs auditados, exactamente UNO no declara ningún ID propio: `corpus/docs/corpus_roadmap.txt`.** Cita FLU-18 y FLU-22; no es sede de nada. Los otros cuatro sí son sede: `CLAUDE.md` (13 entradas), `corpus_flujo_trabajo.txt` (44 FLU + los 5 AUD), `CORPUS_Architecture.md` (9), `corpus_convenciones_commits.txt` (4 GIT + GIT-4..7).

**Con todas las letras: cualquier «limpio» que este cruce reporte sobre `corpus_roadmap.txt` no es evidencia de nada — significa «no auditado», no «sano».**

El propio doc lo anticipa en su §0 (*«NO-AUDITABLE POR DISEÑO»*, `corpus_roadmap.txt:24-25`) y es voto del autor registrado. **Pero el Hueco 3 demuestra que la etiqueta se leyó como permiso para no mirarlo, en vez de como instrucción de mirarlo por otro eje.** El roadmap **sí** carga hechos verificables contra el árbol —estado de cada módulo, qué existe y qué no— y **uno de ellos está mal hoy** (`:81`). Intención pura en el nivel 6 de §7.1 no es lo mismo que inauditable.

**Para taparlo:** el reporte debe emitir **`N/A — sin IDs propios`** en vez de `limpio` para el roadmap, y el gate debe correrle un **pase de VALOR contra el árbol** aunque no le corra el cruce de IDs.

### Hueco 5 (alto) — el modo piloto vació de contenido 4 a 6 buckets, y sus ceros se reportan igual que los demás

Las sedes de `dano-limbs`, `dominio-medico`, `inventario`, `contrato-items` y `assets-licencias` viven en CAL / COA / CRG / STK — **todas fuera del piloto**. Un «0 contradicciones» ahí **no significa limpio: significa que no había dos textos que cruzar**. Son **ceros vacíos por construcción**, hoy indistinguibles en el reporte de un cero ganado.

Dos sospechosos más, de naturaleza distinta: **`rendimiento` y `config-y-balance` tienen cero contradicciones porque tienen cero normas.** En las cuatro familias del framework (COR 1-16, FLU, GIT, AUD) no hay un solo ID de performance ni de configuración. Y sin embargo hay superficie real: el único artefacto de config del ecosistema, `corpus-caliber/lua/weapons/gmod_tool/stools/corpus_caliber_config.lua`, es justamente el que salió como contraejemplo de COR-15 en la fase ContratoArbol. **Tema con superficie y sin norma = tema donde el gate no puede fallar y tampoco puede servir.**

**Para taparlo:** el reporte debe distinguir **tres estados por bucket** — `limpio` / `N/A por alcance` / `sin normas que cruzar` — y nunca colapsarlos en un conteo de cero.

### Hueco 6 (medio) — cinco ejes transversales que la taxonomía de 18 buckets no tiene

1. **Migración/versionado de datos persistidos.** `persistencia` cubre *dónde* escribe COR-3 (`data/corpus/<module>/<key>.json`); nadie normó qué pasa cuando el **shape** del JSON cambia entre versiones. Con inventarios de Cargo y heridas de Coagulant ya persistiendo en juego, el primer cambio de esquema rompe saves reales y **no hay una sola línea de doc que lo gobierne**.
2. **Confianza cliente→servidor / validación de net.** `namespacing` cubre colisión de nombres (COR-4), **no autoridad**. Cargo mueve dinero e ítems por `net`; no existe un eje donde una contradicción sobre «quién valida qué» pudiera siquiera aparecer.
3. **Meta-proceso auditor (familia AUD).** Los 5 IDs AUD gobiernan al gate mismo y hoy caen en el bucket `proceso`: **el gate se audita con el instrumento que se está auditando.** AUD-3 («ningún gate corre con poco contexto») es autorreferente — si se viola, el reporte que lo detectaría es el degradado.
4. **Ciclo de vida del addon** (mount/unmount, `lua_refresh`, hot-reload). `boot-carga` cubre el orden de carga inicial y la sonda diferida de COR-6; no cubre la **re-ejecución**, que es cómo el autor itera en la práctica.
5. **El eje genérico-vs-contenido.** COR-10 tiene un gemelo no escrito: *«el framework y los módulos no saben nada de la Zona»*. Hoy solo vive en prosa de `CLAUDE.md`, **sin ID**, y es transversal a los seis consumidores.

### Hueco 7 (medio) — `ids.yaml` se auditó por un solo eje

Se cruzó `titulo` contra la prosa de la sede: **0 divergencias**. **No se cruzó el campo `nota:`**, que es prosa larga y sustantiva.

Y ahí hay drift, verificado en esta pasada:

- **`ids.yaml:166-172`** (nota de COR-12) enuncia las dos mitades de la norma con su razón y **se autodeclara** *«Ésta es la ÚNICA sede que enuncia las dos mitades con su razón»*. Es decir: el registro que su propio encabezado define como *«ÍNDICE, jamás segunda definición»* contiene, **por escrito y admitiéndolo**, una definición que ninguna sede tiene.
- **`ids.yaml:180`** (nota de COR-13) dice *«El `CLAUDE.md` de Cargo la enuncia en media línea, sin los dos casos»*. **El yaml sabe que su sede es más pobre que él, y lo documenta en vez de repararlo.**

Formalmente §7.1 dice que si el yaml contradice a su sede, **el desactualizado es el yaml**. Pero acá el yaml no *contradice*: **excede**. Es un modo de falla que la regla no contempla, y es el mismo caso que §7.4 ya resolvió una vez a favor del yaml (voto del autor 2026-07-16 sobre `tipo: codigo`, donde *«cedió la sede, que era la que había nacido corta»*).

**Para taparlo:** extender el cruce a `nota:` y `familias:`. **Toda nota que agregue contenido no presente en la sede es drift, no anotación** — y la reparación es mover el contenido a la sede, no borrar la nota.

### Hueco 8 (medio) — dos cuerpos de docs fuera del corpus, sin declararse

Los `docs/` de las siete raíces están completos y la exclusión de módulos es legítima y declarada. Lo que **no** está declarado son dos superficies que sí llevan normas:

- **`dev/`** (fuera de todo git): 5 handoffs, 5 prompts operativos, 6 mapas de referencia. El propio §7.8 del flujo cita `dev/HANDOFF_corpus_sdd_workflow.md` como origen de los bloques A-E del sistema anti-drift, y `ids.yaml` registra evidencia `tipo: harness` apuntando a `dev/harness_*.py` — verificado en esta pasada: la entrada COR-12 acredita `dev/harness_craving.py` y `dev/harness_coagulant.py`. **Hay IDs cuya evidencia vive en una carpeta que ni el checker ni el gate escanean.**
- **`corpus/.claude/desktop-sync/`** — el espejo que siembra el RAG de Desktop. Verificado: `Corpus_convenciones_commits.txt:120` reproduce **la misma cifra caduca** que es la única contradicción confirmada. Es downstream (lo regenera `sync.ps1`), así que el parche a la fuente lo arregla — **pero es un segundo consumidor de estos docs que ningún gate audita, y donde el drift se materializa como respuestas de un asistente.**

**Para taparlo:** declarar `dev/` como punto ciego acotado, en la línea de D-3 (que ya cubre las sedes en `.lua`/CHANGELOG/estado/roadmap); y **verificar que el parche de §2.1 dispare una regeneración del espejo antes de dar la reparación por cerrada**.

### Prioridad de ejecución

1. **Hueco 2** (COR-12/13/14 y su choque con COR-10) — es una **contradicción normativa real**, no un valor caduco. Su mitad mecánica es triage A; su mitad de arquitectura es voto del autor.
2. **Huecos 1 y 3 juntos**, con **§2.1** — mismo tipo de parche, mismo barrido de valor, una sola pasada.
3. **Huecos 4 y 5** — son cambios al **reporte** del gate. Baratos, y evitan que el próximo «limpio» vuelva a mentir.
4. **Huecos 6, 7 y 8** — taxonomía y alcance, para la corrida COMPLETO.

Los dos PARCIALES de §4.bis son triage A independiente y pueden ir en cualquier tanda.

---

## 6. Qué NO se auditó, y por qué

- **Doc-vs-código queda fuera del alcance del cruce.** **Este acta NO afirma que nada esté implementado ni que nada falte.** El ecosistema **diseña por delante del código a propósito** (§7.1: *«"Todavía no está implementado" NO ES UN HALLAZGO»*; el mock-first de FLU-17 lo institucionaliza). El Lua se abrió únicamente como **árbitro** de nivel 1 para adjudicar, y en la fase ContratoArbol (§4.bis), que es la única que compara doc contra árbol por diseño.
- **Huérfanos, bicéfalos, sedes rotas y evidencia rota tampoco son de este gate.** Los prueba el **checker determinista** (`.claude/check-ids/`, §7.7), que corre en cada commit sobre superficie normativa y es exhaustivo. Este gate existe para lo único que un script no puede ver: la **contradicción semántica entre prosa**. Donde esta acta menciona un bicéfalo de superficie (Hueco 1) o una sede sin ancla (Hueco 2), lo hace **como observación para el otro anillo**, no como hallazgo propio.
- **Los árbitros no se auditaron como sujetos.** El Lua, los `<modulo>_estado.md` y los `docs/CHANGELOG.md` se consultaron para adjudicar y **nunca se auditaron**. Que `CHANGELOG.md` haya salido nombrado en el Hueco 1 es precisamente el punto: **no fue auditado, y debería serlo.**
- **`docs/ids.yaml` no integra la jerarquía.** Es **índice**, jamás segunda definición (§7.1). Se usó como glosario y se cruzó por `titulo`; el Hueco 7 declara el eje que quedó sin cruzar.
- **Los seis repos consumidores quedaron fuera** — ver §7.

---

## 7. MODO PILOTO — declaración de alcance

**Esta corrida auditó únicamente el framework** (`corpus/`): 5 docs de diseño y proceso más su `CLAUDE.md`. **Los seis repos consumidores** —`corpus-cortex`, `corpus-caliber`, `corpus-coagulant`, `corpus-craving`, `corpus-cargo`, `corpus-stalker`— **quedaron fuera del corpus auditado.**

**Por qué:** el modo SCOPED / piloto (`piloto: true`) existe para correr barato al cerrar una sesión que escribió normas (cadencia AUD-1), sin pagar el costo de un COMPLETO —medido el 2026-07-19 en 145 agentes / 8,31M tokens / ~44 min para 29 docs—. El COMPLETO tiene su propia cadencia: **AUD-2, al cerrar un Block de módulo, antes de abrir el siguiente**.

**Qué implica para leer estas cifras, sin maquillaje:**

- El **1** de contradicciones confirmadas es sobre el framework, **no sobre el ecosistema**. No dice nada sobre la coherencia de los docs de Caliber, Cargo, Coagulant, Craving o `corpus-stalker`.
- Los buckets `dano-limbs`, `dominio-medico`, `inventario`, `contrato-items` y `assets-licencias` tienen sus sedes fuera del piloto: **sus ceros son vacíos por construcción** (Hueco 5).
- La fase **ContratoArbol cubrió 1 `CLAUDE.md` de 7**. Los seis restantes son sede de decenas de contratos que esta corrida **no verificó contra su Lua**.
- El único cruce cross-repo que esta corrida pudo hacer es el que pasa por docs del framework que **hablan** de los módulos — y ahí salió el Hueco 3.

**Recomendación de cadencia:** los Huecos 1, 2 y 3 justifican una **pasada de reparación documental** antes del próximo COMPLETO. El Hueco 2 en particular no debería esperar a AUD-2: es una pregunta de arquitectura abierta sobre el framework delgado, y el framework es de lo que cuelga todo lo demás.

---

*Acta generada por el gate de coherencia (§7.8 del flujo). READ-ONLY sobre las siete raíces: este archivo es el único escrito. Ningún parche fue aplicado.*
