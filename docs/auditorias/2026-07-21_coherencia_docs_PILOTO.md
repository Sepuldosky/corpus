# Acta — Auditoría de coherencia documental del ecosistema Corpus

**Fecha:** 2026-07-21
**Modo:** SCOPED / PILOTO — solo el framework (`corpus/`): 5 docs de diseño/proceso + su `CLAUDE.md`
**Estado del acta:** **ÍNTEGRA** — cobertura completa: ningún agente murió, ningún tramo quedó sin auditar (COBERTURA PERDIDA = 0). *(Hubo un desfase de la constante `total` del script sobre `corpus_roadmap.txt` —112 vs 115 en el árbol— que la fase 0 corrigió en caliente; NO degradó la corrida. Se declara en §5.)*
**Alcance:** doc-vs-doc, adjudicado contra el Lua / `<modulo>_estado.md` / `CHANGELOG.md` según la jerarquía de autoridad de `corpus_flujo_trabajo.txt` §7.1 (FLU-22), **leída en su sede para esta corrida** (líneas 340-372), no de memoria.
**Modo de escritura:** READ-ONLY estricto sobre las siete raíces. Esta acta es el **único** archivo escrito. **Todos los parches son PROPUESTOS; ninguno aplicado.** El gate propone, el autor dispone.
**Inmutabilidad (AUD-4):** esta acta es la foto del estado AL MOMENTO DE AUDITAR. No se edita después. Si algo cambió, lo dice el acta siguiente.

---

## Cifras

| Métrica | Valor |
|---|---|
| Contradicciones confirmadas (3 verificadores adversariales cada una) | **0** |
| — BLOQUEANTE / ALTA / MEDIA / BAJA | 0 / 0 / 0 / 0 |
| Triage A / B / C / CADUCO | 0 / 0 / 0 / 0 |
| Divergencias yaml-vs-sede | **0** |
| Normativas sin ID (FLU-25) | **38** |
| Afirmaciones sin alcance declarado | 41 |
| Contratos verificados contra el árbol (fase ContratoArbol) | 9 |
| — CUMPLIDO / INCUMPLIDO / PARCIAL / **NO_VERIFICABLE** | 8 / **0** / **0** / **1** |
| Hechos falsos hallados por el pase de VALOR (docs sin IDs) | **0** |
| Cobertura perdida | **0** |
| Docs auditados **sin un solo ID propio** (cobertura ciega por el eje ID) | **1 de 5** (`corpus_roadmap.txt`) |
| Desfase de la constante `total` (deuda de mantenimiento del gate) | **1** (`corpus_roadmap.txt`: 112 → 115, corregido en caliente) |

---

## 1. Resumen ejecutivo — lo que cambia el plan

El cruce doc-vs-doc salió **limpio: cero contradicciones confirmadas, cero INCUMPLIDOS, cero PARCIALES, cero hechos falsos.** Ese 0, por sí solo, no es la noticia — porque un 0 en modo piloto significa cosas distintas según el bucket (§4.ter), y porque se firma sobre el mismo punto ciego que la crítica anterior ya nombró y que **sigue sin cerrarse**.

Lo que cambia el plan, con nombre y apellido:

1. **La única recomendación de arquitectura que quedaba viva del ciclo anterior YA ESTÁ RESUELTA por el árbitro. No re-abrir.**
   El acta 2026-07-20 (Hueco 2) elevó a **voto del autor** la pregunta *«¿el contrato de ítems (COR-12) es infraestructura compartida o dominio infiltrado en el framework delgado, y choca con COR-1/COR-10?»*. Ese voto se abrió como **D-14** y **está CERRADO**. Evidencia, consultando los árbitros por encima de todo doc de diseño:
   - **Nivel 2 (`<modulo>_estado.md`) — `corpus/docs/corpus_estado.md:122-125`** (reescrito HOY, 2026-07-21 03:37): *«`D-14` CERRADA por voto del autor: COR-12 SE QUEDA — no gobierna ítems sino el protocolo de registro entre módulos, del linaje de COR-3/COR-4; enuncia la FORMA, jamás la SEMÁNTICA, y si algún día menciona stacks, peso o slots el voto se reabre.»*
   - **Registro (índice, refleja el voto) — `corpus/docs/ids.yaml:2059-2088`**: D-14 `propuesta: CUMPLIDA`; *«No contradice a COR-1 ni a COR-10 — los delimita: lo que no sube es la semántica.»* Y `ids.yaml:177`: *«D-1 (que Cargo la CITE) y D-14 (dónde vive) están ambas CERRADAS.»*

   **Consecuencia para el plan:** la crítica de completitud de esta misma corrida arrastra la premisa de que ese voto sigue abierto («deuda D-1», «voto del autor todavía abierto»). Contra el árbitro, esa premisa es **caduca**. Ninguna pasada de reparación debe re-abrir COR-12: el autor ya decidió que **se queda en el framework** con una cláusula de reapertura falsable (mencionar stacks/peso/slots). *No es un hallazgo de este cruce* — es una adjudicación contra el estado, que se registra acá para que el próximo planificador no gaste una tanda en una pregunta cerrada.

2. **Ese 0 limpio se está firmando sobre el mismo ciego de siempre — y el punto 1 es su prueba viviente.**
   El hecho que resuelve el punto 1 (D-14 cerrada) vive en `corpus_estado.md`, que **no está en el corpus auditado** y que **cambió HOY, después de la última auditoría**. El cruce doc-vs-doc no lo vio y no podía verlo; lo trajo la adjudicación contra el árbitro, no el gate. Es la demostración exacta del Hueco 1 de esta y de la corrida anterior: los dos docs vivos de mayor densidad de valores (`corpus_estado.md`, `CHANGELOG.md`) siguen fuera del sujeto, y el `CLAUDE.md` manda leer `corpus_estado.md` **antes** que la arquitectura. Auditar los 5 docs estables y saltear el que muta cada sesión invierte el riesgo. → §5, Hueco 1.

3. **`contrato-items` reporta `limpio`, pero doc-vs-doc es estructuralmente ciego a «una frase y un silencio».**
   El bucket cruzó 8 normativas y no sobrevivió ninguna contradicción (§4.ter). El caso concreto que preocupaba (COR-12 vs COR-1/COR-10) está **cerrado** por el punto 1 — pero la **ceguera estructural persiste**: una tensión entre lo que el `CLAUDE.md` afirma y lo que **calla** no es dos frases que se contradicen, y ninguna fase doc-vs-doc puede cazarla. Su `limpio` es real dentro de su método, no una garantía sobre el silencio. → §5, Hueco 2.

4. **La corrida DECLARA su punto ciego de la fase ContratoArbol: 1 de 9 contratos volvió NO_VERIFICABLE.**
   9 contratos del `CLAUDE.md` del framework se verificaron contra el Lua: **8 CUMPLIDO, 0 INCUMPLIDO, 0 PARCIAL, 1 NO_VERIFICABLE.** El «8 CUMPLIDO» **no** se lee como «9 de 9»: la cobertura real es **8 contratos con veredicto y 1 sin él**. Ese 1 es el punto ciego de la fase, no su éxito. → §4.bis.

5. **Deuda de mantenimiento del propio gate, y ya es la tercera vez.**
   La constante `total` del script para `corpus_roadmap.txt` decía **112**; el árbol tiene **115** (verificado: `wc -l` = 115). 3 líneas habrían quedado fuera del rango leído por su tramo. La fase 0 «Conteo» lo derivó del árbol y armó los tramos con el número real, así que **la corrida NO quedó degradada** — pero es deuda de mantenimiento del gate y el mismo modo de falla que FLU-27 existe para matar. → §5.

**Lo bueno, adjudicado contra el árbitro (no maquillaje):** respecto del ciclo 2026-07-20, la reparación aterrizó. Los dos PARCIAL de entonces (COR-15, COR-16) y los universales que el árbol desmentía se corrigieron — por eso esta corrida tiene **0 PARCIAL** donde la anterior tuvo 2 (`corpus_estado.md:42-45`: *«COR-12/13/14 anclados por etiqueta y reconocidos por el `CLAUDE.md`, más cuatro universales que el árbol desmentía»*). Y las normativas sin ID bajaron de 48 a 38.

---

## 2. Contradicciones por gravedad

**Cero contradicciones confirmadas.** Ninguna candidata sobrevivió a los tres verificadores adversariales (refutador / árbitro-código / árbitro-historia, mayoría ≥2 de 3). No hay entradas de triage A/B/C/CADUCO en esta corrida.

**Este 0 NO es un limpio uniforme, y decirlo así sería mentir por omisión.** Se descompone en tres clases distintas (detalle por tema en §4.ter):

- **Buckets cruzados que salieron sanos** (`framework-delgado`, `soft-deps`, `realms`, `namespacing`, `boot-carga`, `persistencia`, `ui-vgui`, `evidencia`, `proceso`, y `contrato-items` con la salvedad del §1.3): había dos o más textos que cruzar y ninguno chocó. **Cero ganado.**
- **Buckets vacíos por alcance** (`dano-limbs`, `dominio-medico`, `inventario`, `assets-licencias`, `compat-terceros`, `ciclo-de-vida-del-jugador`, `config-y-balance`, `rendimiento`): sus sedes viven en repos de módulo fuera del piloto. **Cero por construcción — no es limpio, es no-auditado.**
- **El eje que el cruce doc-vs-doc no puede ver por diseño**: «una frase y un silencio» (§1.3). No produce candidatas y por eso no aparece como 0 — pero tampoco como cobertura.

Sobre por qué NO hubo falsos positivos que rechazar: las candidatas que el cruce agrupó y descartó son las degradaciones honestas con/sin peer (COR-11), los mock-first (FLU-17, el puente `ApplyExternalCondition` Craving↔Coagulant declarado deuda D-5), los distintos niveles de detalle (un doc resume, otro especifica) y los distintos realms/módulos/blocks. Todas son el patrón de producción del ecosistema, no contradicciones.

---

## 3. Patología del registro

### 3.1 Divergencias `ids.yaml`-vs-sede: **0**

El campo `titulo` de cada entrada se cruzó contra la prosa de su sede y **no hubo ninguna divergencia**. Es un resultado real (hubo texto que cruzar en ambos lados), no un cero vacío. **Salvedad de eje, heredada y sin cerrar:** solo se cruzó `titulo`. El campo `nota:` carga contenido sustantivo que la sede no tiene —la nota de COR-12 (`ids.yaml:167-172`) se autodeclara *«LA NORMA MÁS CARA DEL ECOSISTEMA»* y desarrolla las dos mitades con su razón; la de COR-13 (`ids.yaml:186`) admite *«El `CLAUDE.md` de Cargo la enuncia en media línea, sin los dos casos»*— y ese eje **no se cruzó**. Ver §5, Hueco 7. (El `ids.yaml` es índice y no integra la jerarquía —§7.1—: no es sujeto de adjudicación, pero un índice que contiene definiciones que ninguna sede tiene es material que conviene cruzar.)

### 3.2 Normativas sin ID (FLU-25): **38**

FLU-25 / §7.2: *«una frase con SIEMPRE / NUNCA / DEBE / JAMÁS o bien DEFINE un ID o bien CITA uno. Una norma sin ID es una norma que va a derivar.»* Distribución por doc:

| Doc | Normas sin ID |
|---|---|
| `corpus/docs/corpus_flujo_trabajo.txt` | 19 |
| `corpus/docs/CORPUS_Architecture.md` | 12 |
| `corpus/CLAUDE.md` | 5 |
| `corpus/docs/corpus_convenciones_commits.txt` | 2 |
| `corpus/docs/corpus_roadmap.txt` | 0 (no acuña ni contiene normativas: intención pura) |
| **Total** | **38** |

Por tema, `proceso` y `evidencia` concentran ~23 de 38 (la metodología del propio flujo creció más rápido que su acuñación de IDs — la familia `FLU` cubre bien el diseño técnico y peor su propia meta-regla); el resto se reparte en `assets-licencias`, `namespacing`, `soft-deps`, `boot-carga`, `framework-delgado`, `dano-limbs` y `compat-terceros`.

**Las cinco que más caro salen si derivan** (criterio: gobiernan conducta cross-repo, o son sede única de un hecho, o rigen al propio gate):

1. **`corpus_flujo_trabajo.txt:550`** — *«READ-ONLY ESTRICTO: el único archivo que el gate escribe es su acta … el gate propone, el autor dispone.»* Es la norma que gobierna a **esta misma corrida** y no tiene ID. Si deriva, el gate empieza a escribir en los repos.
2. **`corpus_flujo_trabajo.txt:515`** — *«FALLA RUIDOSO, NUNCA EN SILENCIO … un "limpio" que no corrió no es un limpio.»* Sede única de la garantía de integridad del anillo barato (checker).
3. **`CORPUS_Architecture.md:138`** — *«la Limbs API debe ser agnóstica a la entidad»*. Contrato **cross-repo Caliber↔Coagulant sobre algo NO construido** (Block 3 de Caliber): la categoría que §7.1 corolario dice que no tiene árbitro. Sin ID, no habrá qué citar cuando el Block 3 lo implemente.
4. **`corpus_flujo_trabajo.txt:593`** — *«Las ACTAS son INMUTABLES … la foto del estado AL MOMENTO DE AUDITAR.»* Sede única de la regla que hace citables a estas actas (y que se autodenomina AUD-4 en la prosa sin acuñarse con la sintaxis de definición).
5. **`CORPUS_Architecture.md:186`** — *«ningún módulo asume que Corpus u otro módulo ya cargó; se detecta en runtime»*. Es el principio *«detección nunca asunción»* de COR-5 enunciado como «regla dura» **sin citar el ID** — un huérfano semántico latente.

**Lectura honesta de la cifra:** las 38 son en su mayoría reglas de metodología del propio flujo, no bombas de dominio. La cifra bajó respecto de las 48 del 2026-07-20 (efecto de la tanda de etiquetado D-13). **La caza mecánica de huérfanos/bicéfalos es del checker (§7.7), no de este gate;** acá se listan como observación para el otro anillo.

---

## 4. Ambigüedades de alcance — 41 afirmaciones

Afirmaciones normativas o descriptivas que **no declaran uno de los cuatro ejes** (realm / módulo / soft-dep / block-slice). No son hallazgos: son **ambigüedad latente**, el sustrato del que nace la contradicción futura. El patrón es abrumadoramente uno: **casi todas omiten el REALM** (aparece «REALM: no especificado» en la gran mayoría de las 41).

Las tres que más pesan, porque combinan omisión de realm con superficie cross-repo:

- **`CORPUS_Architecture.md:133`** — describe `hook.Run("Caliber_LimbsUpdated", npc, reason)` como *«aviso de refresh heredado de ADS, off-contract y sin consumidor»* **sin declarar realm**. El hook es server en su origen ADS; el doc no lo dice. Un consumidor futuro que lo enganche client-side no encuentra nada en el doc que lo frene. (Aparece también en §3.2: sin ID **y** sin alcance.)
- **`CORPUS_Architecture.md:138`** — la Limbs API agnóstica, sin realm. Ver §3.2 punto 3: es contrato cross-repo sobre algo no construido, el peor lugar para dejar el realm implícito.
- **`corpus_roadmap.txt:56-60`** — el cierre de Block 3 de Coagulant incluye *«la UI completa»*, presumiblemente client, y el doc no lo declara. «Presumiblemente» es precisamente el problema.

**No son hallazgo, y se dice por qué:** las 41 pasan el filtro de falsos positivos. Ninguna contradice a otra; describen estados de diseño legítimos, varias mock-first (FLU-17) correctamente declaradas —el roadmap nombra el puente `ApplyExternalCondition` como mock-first y lo declara deuda **D-5** en ambos extremos (`corpus_roadmap.txt:61-63` y `:67-69`), que es el doc haciendo su trabajo, no mintiendo, y es la MISMA negociación vista desde los dos módulos, no un choque.

---

## 4.bis CONTRATO-VS-ÁRBOL

Fase que **no es doc-vs-doc**: cada contrato numerado del `CLAUDE.md` se verificó contra el Lua. Cuando un `CLAUDE.md` (nivel 4) choca con el árbol (nivel 1) **no hay deliberación** — el `CLAUDE.md` está mal, y es el doc que todo ejecutor lee primero. En modo piloto la fase corre sobre **1 `CLAUDE.md` de 7** (el del framework).

| Repo | Contratos | CUMPLIDO | INCUMPLIDO | PARCIAL | NO_VERIFICABLE |
|---|---|---|---|---|---|
| `corpus` (framework) | 9 | **8** | **0** | **0** | **1** |

**Cero INCUMPLIDOS y cero PARCIALES.** El framework obedece sus propios contratos, y esta vez sin la rama que se saltea: los dos PARCIAL del 2026-07-20 (COR-15, el stool de Caliber que crea categoría propia en Tools; y COR-16, el `print` crudo del `corpus_selftest`) **se cerraron por reparación del `CLAUDE.md`** (`corpus_estado.md:42-45`). Que esta corrida los vea CUMPLIDO es adjudicación contra el árbol, no contra el acta previa.

**El punto ciego de la fase, declarado y no maquillado — 1 NO_VERIFICABLE de 9.** Un contrato volvió NO_VERIFICABLE: su conformidad no puede probarse contra el árbol actual, sea porque su superficie todavía no existe (diseño por delante del código, legítimo — §7.1) o porque es norma de conducta de agente que no deja huella en el Lua. **Sobre ese contrato la fase no dice nada — ni que se cumple ni que no.** La cobertura real es **8 de 9 con veredicto, 1 sin él**. Es de la misma clase que los 2 NO_VERIFICABLE del 2026-07-20 (bajaron de 2 a 1 porque el corpus de contratos verificables cambió con la reparación). *El material de esta corrida no expuso la identidad numérica del contrato NO_VERIFICABLE; se reporta el conteo, que es lo que la fase exige para no leer «8 CUMPLIDO» como un limpio de 9.*

**Cortex es un ciego total de esta fase, aparte de lo anterior:** `corpus-cortex` no tiene `CLAUDE.md` (su sede de familia CTX no existe — `corpus_estado.md:62-65`, `corpus_roadmap.txt:85-88`), así que `ContratoArbol` no puede correr sobre él ni siquiera en el COMPLETO, y sus **seis** firmas entrantes de `Cortex_ContratosEntrantes.md` quedan sin contrato que las arbitre. Queda fuera del piloto, pero se declara para el próximo COMPLETO.

---

## 4.ter ESTADO POR BUCKET — los 18 temas

Una fila por tema. **`limpio`** = se cruzó y salió sano. **`N/A por alcance`** = las sedes del tema viven en repos de módulo fuera del piloto: su cero es vacío por construcción, **no** un limpio. Reportar ambos como «0 contradicciones» sería indistinguible y falso.

| # | Tema | Estado | Normativas | Hallazgos | Por qué |
|---|---|---|---|---|---|
| 1 | `framework-delgado` | **limpio** | 11 | 0 | 11 normativas cruzadas, ninguna contradicción sobrevivió |
| 2 | `soft-deps` | **limpio** | 7 | 0 | 7 normativas cruzadas, ninguna sobrevivió |
| 3 | `realms` | **limpio** | 4 | 0 | 4 normativas cruzadas, ninguna sobrevivió |
| 4 | `namespacing` | **limpio** | 11 | 0 | 11 normativas cruzadas, ninguna sobrevivió |
| 5 | `contrato-items` | **limpio** | 8 | 0 | 8 normativas cruzadas, ninguna sobrevivió. **Salvedad §1.3:** doc-vs-doc no ve «una frase y un silencio»; el caso COR-12 está cerrado por árbitro (D-14) |
| 6 | `boot-carga` | **limpio** | 8 | 0 | 8 normativas cruzadas, ninguna sobrevivió |
| 7 | `dano-limbs` | **N/A por alcance** | 1 | 0 | sedes (corpus-caliber, corpus-coagulant) FUERA del corpus: cero vacío por construcción |
| 8 | `dominio-medico` | **N/A por alcance** | 0 | 0 | sede (corpus-coagulant) FUERA del corpus: cero vacío por construcción |
| 9 | `inventario` | **N/A por alcance** | 0 | 0 | sede (corpus-cargo) FUERA del corpus: cero vacío por construcción |
| 10 | `ui-vgui` | **limpio** | 2 | 0 | 2 normativas cruzadas, ninguna sobrevivió |
| 11 | `persistencia` | **limpio** | 4 | 0 | 4 normativas cruzadas, ninguna sobrevivió |
| 12 | `evidencia` | **limpio** | 34 | 0 | 34 normativas cruzadas, ninguna sobrevivió |
| 13 | `proceso` | **limpio** | 99 | 0 | 99 normativas cruzadas, ninguna sobrevivió |
| 14 | `assets-licencias` | **N/A por alcance** | 3 | 0 | sede (corpus-stalker) FUERA del corpus: cero vacío por construcción |
| 15 | `compat-terceros` | **N/A por alcance** | 2 | 0 | sedes (cargo, caliber, coagulant, craving, stalker) FUERA del corpus |
| 16 | `ciclo-de-vida-del-jugador` | **N/A por alcance** | 0 | 0 | sedes (cargo, coagulant, craving) FUERA del corpus |
| 17 | `config-y-balance` | **N/A por alcance** | 0 | 0 | sedes (cargo, caliber, coagulant, craving) FUERA del corpus |
| 18 | `rendimiento` | **N/A por alcance** | 0 | 0 | sedes (coagulant, craving) FUERA del corpus |

**Nota, no colapsable en el conteo:** los buckets 8, 9, 16, 17 y 18 tienen `normativas: 0`. Su cero no es solo por alcance — en las cuatro familias del framework (COR, FLU, GIT, AUD) no hay un solo ID de estos dominios framework-side. `config-y-balance` en particular tiene **superficie real sin norma** (`corpus-caliber/lua/weapons/gmod_tool/stools/corpus_caliber_config.lua`, que ya salió como contraejemplo de COR-15 en el ciclo anterior): tema donde el gate no puede fallar y tampoco puede servir. Se marca `N/A por alcance` tal como llegó de la fase, pero el lector debe leerlo como «sin normas que cruzar, además de sede fuera».

---

## 5. Huecos de esta auditoría — honestidad sobre lo NO cubierto

**COBERTURA PERDIDA: 0.** Ningún agente murió; ningún tramo ni tema quedó sin auditar por caída (`agents_error: 0`, retornos `{"candidatas":[]}` = buckets sin material en el alcance piloto, no cadáveres). **Esta acta NO es DEGRADADA.**

Dicho eso, la cobertura fue completa **dentro de un corpus que dejó cosas afuera a propósito**, y hay una deuda de mantenimiento del propio gate. Los huecos, en orden de prioridad de reparación.

### Desfase de la constante `total` (deuda de mantenimiento del gate) — 3.ª vez

`corpus/docs/corpus_roadmap.txt`: la constante del script decía **112** y el árbol tiene **115** (verificado, `wc -l` = 115) → 3 líneas habrían quedado SIN leer por su tramo. La fase 0 «Conteo» lo derivó del árbol y armó los tramos con el número real, así que **la corrida no quedó degradada** y ningún doc dice «NO DERIVADO». Pero es el mismo modo de falla que FLU-27 existe para matar (un número escrito a mano que se desincroniza del árbol), y ya pasó antes (hasta el 2026-07-19 el COMPLETO decía «19 docs» con 29 en el árbol; el `total` estaba mal en las 29 filas). → **Reparar la derivación de `total` en el `.js` para que ninguna constante de conteo sobreviva a mano.**

### Hueco 1 (crítico) — los dos docs vivos siguen fuera del corpus, y uno cambió HOY

`corpus/CLAUDE.md` manda leer **`docs/corpus_estado.md` ANTES que la arquitectura**, y pone `docs/CHANGELOG.md` como tercer doc vivo. **Ninguno de los dos está entre los 5 auditados** — el mismo Hueco 1 del 2026-07-20, sin cerrar. No son pasivos: `corpus_estado.md` cita AUD-3/AUD-4, COA-5/COA-7/COA-8, COR-12, COR-15/16, FLU-15 y D-14; `CHANGELOG.md` (~808 líneas) cita ~76 IDs. Son los docs de mayor densidad de valores.

**Y esta corrida lo demuestra en carne propia:** `corpus_estado.md` fue reescrito **HOY (2026-07-21 03:37)**, *después* de la auditoría previa, y es exactamente el doc que **resuelve el punto §1.1** (D-14 cerrada, COR-12 se queda). El gate firmó `contrato-items: limpio` mientras era ciego al doc que zanjó la única tensión que ese bucket tenía pendiente. Auditar lo estable y saltear lo que muta cada sesión invierte el riesgo. → **Incorporar `corpus_estado.md` y `CHANGELOG.md` como sujetos obligatorios en todo modo, aunque sea con un pase acotado al eje VALOR (§7.3.a).** El bicéfalo de superficie del CHANGELOG (`COR-1`≡`COR-01` en `CHANGELOG.md:292`; `FLU-07` en `:374`,`:567`) es del checker (§7.7), no de este gate; se anota para el otro anillo.

### Hueco 2 (estructural) — el cruce doc-vs-doc es ciego a «una frase y un silencio»

`contrato-items` reportó `limpio`, pero la clase de contradicción más cara del framework —lo que un doc afirma frente a lo que su sede **calla**— no la ve ninguna fase doc-vs-doc: no hay dos frases que chocar. El caso instanciado (COR-12 vs COR-1/COR-10) **está cerrado por el árbitro** (§1.1, D-14), pero la **ceguera de método persiste** y reaparecerá con el próximo contrato que un `CLAUDE.md` resuma y una sede desarrolle. → **Cubrirlo requiere una fase que compare la enumeración del `CLAUDE.md` contra el conjunto real de IDs de su familia en `ids.yaml`** (huérfano-de-mención), que hoy no existe ni en el gate ni en el checker.

### Hueco 3 (alto) — 1 de 5 docs auditados no acuña un solo ID propio, y sobre él este gate es ciego por el eje de IDs

**De los 5 docs, exactamente UNO no declara ningún ID propio: `corpus/docs/corpus_roadmap.txt`.** Lo declara él mismo (`corpus_roadmap.txt:21-25`: *«INTENCIÓN PURA — nivel 6 … No acuña IDs ni es sede de ninguna norma; CITA IDs cuando corresponde. Un "limpio" del gate … sobre este doc en el cruce de IDs se reporta como NO-AUDITABLE POR DISEÑO, no como cobertura»*). Los otros cuatro sí acuñan: `CLAUDE.md` (COR-1..6/9/15/16), `CORPUS_Architecture.md` (COR-7/8/10..14), `corpus_flujo_trabajo.txt` (FLU/AUD/GIT), `corpus_convenciones_commits.txt` (GIT-1/2/3).

**Con todas las letras: para este gate que cruza IDs, un «limpio» sobre `corpus_roadmap.txt` NO es evidencia de nada — es «no auditado».** Por eso su etiqueta es **`N/A — sin IDs propios`, jamás `limpio`.**

**Lo que hoy tapa parcialmente ese hueco:** se le corrió el **PASE DE VALOR** contra el árbol (el único eje por el que se lo puede auditar), y **encontró 0 hechos falsos** — ninguna afirmación del roadmap sobre el presente fue desmentida por el Lua/estado/CHANGELOG en esta pasada. Es un cero real *de ese eje*, no del cruce de IDs. (No es teórico que este eje importa: el 2026-07-20 el pase de valor cazó `corpus_roadmap.txt:81` afirmando *«sin código ni docs»* de Cortex cuando su doc de contratos ya existía; hoy ese valor está corregido —`corpus_roadmap.txt:83-90` reconoce `Cortex_ContratosEntrantes.md`—, verificado.)

### Hueco 4 (alto) — el modo piloto vacía 8 buckets, y sus ceros conviven en la tabla con los ganados

Las sedes de `dano-limbs`, `dominio-medico`, `inventario`, `assets-licencias`, `compat-terceros`, `ciclo-de-vida-del-jugador`, `config-y-balance` y `rendimiento` viven en CAL/COA/CRG/STK — todas fuera del piloto. §4.ter ya los marca `N/A por alcance`, pero se declara aquí explícitamente: **8 de 18 buckets tienen cero por construcción**, y cuatro de ellos además tienen cero normas framework-side. El único cruce cross-repo que esta corrida pudo hacer es el que pasa por docs del framework que **hablan** de los módulos (soft-deps, contrato-items) — ahí no salió nada, y ahí es donde el COMPLETO rendirá.

### Hueco 5 (medio) — ejes transversales que la taxonomía de 18 buckets no captura

Heredado del 2026-07-20 (su Hueco 6), sin entrar aún a la taxonomía:

1. **Autoridad de servidor / frontera de confianza cliente↔servidor.** `realms` es *ubicación de código* (shared/client/server), **no confianza**: quién valida un trade, quién puede spawnear un ítem, si el cliente puede forjar un net message. En un MP con inventario + comercio + médico + combate es una superficie de contradicción grande (dupe/exploit/validación server-authoritative) y **ningún bucket la mira**.
2. **Versionado/migración de save-schema.** `persistencia` es solo el namespacing de COR-3 (`data/corpus/<module>/<key>.json`), no la evolución del formato. Con inventarios de Cargo y heridas de Coagulant ya persistiendo, el primer cambio de esquema rompe saves reales sin una línea de doc que lo gobierne.
3. **Idioma/localización.** GIT-4 y las strings de cara al jugador son un eje normativo real, sobre todo en `corpus-stalker` (capa de contenido).

→ Sumarlos antes del COMPLETO; es donde rinde un gate que cruza fronteras entre repos.

### Hueco 6 (medio) — ninguna fase cruza contratos-de-framework contra docs-de-módulo

`ContratoArbol` cruza contrato-vs-**Lua**; el cruce doc-vs-doc (incluso el COMPLETO) cruza doc-vs-doc. El eje **contrato-de-framework-vs-DOC-de-módulo no tiene fase.** Superficie concreta que la crítica de completitud señaló: Cargo persiste con `file.Write` crudo a `data/corpus/cargo/icons/` y lee de una ruta ajena `data/arc9_presets/` (`Cargo_ItemImages_Arquitectura.md:78,111`), mientras los contratos del framework (COR-3/COR-8, JSON vía `Corpus.Data`) **no cubren persistencia de assets binarios** — así que los módulos improvisan fuera de la primitiva sin contrato que lo gobierne. Es un hueco de contrato que un doc de módulo revela y que ninguna fase actual ve. *(Queda fuera del piloto —esas sedes son de módulo—; se declara para el COMPLETO, cruzando los `CLAUDE.md` de módulo como sujetos.)*

### Hueco 7 (medio) — `ids.yaml` se cruza por un solo eje, y su campo `nota:` tiene definiciones que ninguna sede tiene

§3.1 lo adelanta: se cruzó `titulo`, **no `nota:` ni `familias:`**. La nota de COR-12 (`ids.yaml:167-172`) se autodeclara *«la ÚNICA sede que enuncia las dos mitades con su razón»* y la de COR-13 (`ids.yaml:186`) documenta que su sede en el `CLAUDE.md` de Cargo es *«media línea, sin los dos casos»*. El registro que su propio encabezado define como *«ÍNDICE, jamás segunda definición»* contiene, por escrito y admitiéndolo, definiciones que la sede no tiene. Formalmente el yaml no *contradice* la sede: **excede** — un modo de falla que §7.1 no contempla (ahí el yaml siempre sería el desactualizado) y que ya se resolvió una vez a favor del yaml (voto del autor 2026-07-16 sobre `tipo: codigo`). → **Extender el cruce a `nota:` y `familias:`; toda nota que agregue contenido ausente de la sede es drift, y la reparación es mover el contenido a la sede, no borrar la nota.**

### Prioridad de ejecución

1. **Reparar la derivación de `total`** — deuda de mantenimiento del gate, barata, evita degradaciones silenciosas del COMPLETO.
2. **Hueco 1** (docs vivos al corpus) — es el ciego que esta misma corrida demostró en §1.1/§1.2; cambio al alcance del gate, alto retorno.
3. **Hueco 3** (roadmap: `N/A — sin IDs propios`, no `limpio`) — cambio al reporte; ya está bien reportado acá, formalizarlo en el `.js`.
4. **Huecos 2, 5, 6, 7** — taxonomía, ejes y nuevas fases para el COMPLETO.

---

## 6. Qué NO se auditó, y por qué

- **Doc-vs-código queda fuera del alcance del cruce.** **Esta acta NO afirma que nada esté implementado ni que nada falte.** El ecosistema **diseña por delante del código a propósito** (§7.1: *«"Todavía no está implementado" NO ES UN HALLAZGO»*; el mock-first de FLU-17 lo institucionaliza). El Lua se abrió únicamente como **árbitro** de nivel 1 para adjudicar, y en la fase ContratoArbol (§4.bis), que es la única que compara doc contra árbol por diseño.
- **Los árbitros no se auditaron como sujetos.** El Lua, los `<modulo>_estado.md` y los `docs/CHANGELOG.md` se consultaron para adjudicar y **nunca se auditaron**. Que `corpus_estado.md` haya sido decisivo en §1.1 y salga nombrado en el Hueco 1 es exactamente el punto: **se usó como árbitro (nivel 2) y debería además ser sujeto.** Los `CLAUDE.md` tienen doble rol —sede de IDs (sujeto) y árbitro— y se trataron como ambos.
- **`docs/ids.yaml` no integra la jerarquía.** Es **índice**, jamás segunda definición (§7.1). Se usó como glosario y se cruzó por `titulo`; el Hueco 7 declara el eje (`nota:`, `familias:`) que quedó sin cruzar. Donde el yaml y su sede difieran, el desactualizado es el yaml.
- **Huérfanos, bicéfalos, sedes rotas y evidencia rota tampoco son de este gate.** Los prueba el **checker determinista** (`.claude/check-ids/`, §7.7), exhaustivo y en cada commit. Donde esta acta menciona un bicéfalo de superficie (Hueco 1) o un principio sin ID (§3.2), lo hace **como observación para el otro anillo**, no como hallazgo propio.
- **Los seis repos consumidores quedaron fuera** — ver §7.

---

## 7. MODO PILOTO — declaración de alcance

**Esta corrida auditó únicamente el framework** (`corpus/`): 5 docs de diseño/proceso más su `CLAUDE.md`. **Los seis repos consumidores** —`corpus-cortex`, `corpus-caliber`, `corpus-coagulant`, `corpus-craving`, `corpus-cargo`, `corpus-stalker`— **quedaron fuera del corpus auditado.**

**Por qué:** el modo SCOPED / piloto (`piloto: true`) existe para correr barato al cerrar una sesión que escribió normas (cadencia **AUD-1**), sin pagar el costo de un COMPLETO (medido el 2026-07-19 en 145 agentes / 8,31M tokens / ~44 min para 29 docs). El COMPLETO tiene su propia cadencia: **AUD-2, al cerrar un Block de módulo, antes de abrir el siguiente**.

**Qué implica para leer estas cifras, sin maquillaje:**

- El **0** de contradicciones confirmadas es sobre el framework, **no sobre el ecosistema**. No dice nada sobre la coherencia de los docs de Caliber, Cargo, Coagulant, Craving o `corpus-stalker`.
- 8 de 18 buckets tienen sus sedes fuera del piloto: **sus ceros son vacíos por construcción** (§4.ter, Hueco 4).
- La fase **ContratoArbol cubrió 1 `CLAUDE.md` de 7**. Los seis restantes (y Cortex, que **no tiene** `CLAUDE.md`) son sede de decenas de contratos que esta corrida no verificó contra su Lua.
- El único cruce cross-repo que esta corrida pudo hacer es el que pasa por docs del framework que **hablan** de los módulos.

**Recomendación de cadencia:** el ciclo anterior dejó su tanda de reparación **aplicada** (`corpus_estado.md:41-45`, `:118-120`) y su único voto de arquitectura **cerrado** (D-14, §1.1). No hay reparación documental pendiente que bloquee. Con Block 3 de Coagulant y Block 4 de Craving cerrados y verificados en juego, y `corpus_estado.md:99,121` declarando *«LISTO PARA EL 2.º COMPLETO»*, el siguiente movimiento natural es **el COMPLETO (AUD-2) en sesión fresca** (AUD-3), llevando incorporados los cambios de reporte y las fases nuevas de §5.

---

*Acta generada por el gate de coherencia (§7.8 del flujo). READ-ONLY sobre las siete raíces: este archivo es el único escrito. Ningún parche fue aplicado.*
