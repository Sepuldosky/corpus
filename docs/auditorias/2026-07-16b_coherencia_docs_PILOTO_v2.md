# Acta — Auditoría de coherencia documental · PILOTO v2 (SCOPED al framework)

- **Fecha:** 2026-07-16 (segunda corrida del día; la primera es
  [`2026-07-16_coherencia_docs_PILOTO.md`](2026-07-16_coherencia_docs_PILOTO.md))
- **Modo:** SCOPED (`piloto: true`) — solo los docs de diseño del framework (`corpus/docs/`)
- **Docs auditados (4):** `corpus_flujo_trabajo.txt` (696 líneas), `CORPUS_Architecture.md` (339),
  `corpus_convenciones_commits.txt` (138), `corpus_roadmap.txt` (100)
- **Resultado:** 2 contradicciones CONFIRMADAS (ambas MEDIA, ninguna BLOQUEANTE), 0 divergencias
  yaml-vs-sede, 62 normativas sin ID, 18 afirmaciones sin alcance declarado, 7 huecos de cobertura
- **Régimen:** READ-ONLY estricto sobre las siete raíces. El único archivo escrito por esta
  corrida es esta acta. **Todos los parches de abajo están PROPUESTOS, ninguno aplicado.**
  El gate propone, el autor dispone.

> **Acta inmutable.** Es la foto del estado **al momento de auditar**, no la de hoy. No se
> edita: si algo cambió, lo dice el acta siguiente. La foto de hoy es `corpus_estado.md`.

---

## 1. Resumen ejecutivo — lo que cambia el plan

**Nada de lo encontrado bloquea código.** Las dos contradicciones son de *proceso*: viven entre
docs de metodología, no entre contratos de runtime. Ningún módulo construido según estos docs
rompe un contrato de otro. Dicho eso, hay tres cosas que sí cambian el plan, en este orden:

### 1.1 — El resultado de este piloto es, por su propia norma, parcialmente "no auditado"

Es el hallazgo que manda, y es sobre el gate mismo, no sobre los docs. §7.6 del flujo
(`corpus/docs/corpus_flujo_trabajo.txt:461-465`) dice, literal:

> *"un gate que cruza IDs es CIEGO a un documento SIN IDs. Un 'limpio' suyo sobre un doc sin IDs
> no es evidencia de nada — es 'no auditado'. La cobertura se mide en NORMAS CON ID, no en
> archivos leídos."*

Fui a contarlo al árbol. De los cuatro docs auditados, **dos no declaran ni un solo ID en su
prosa**:

| Doc auditado | IDs con **sede** ahí (según `ids.yaml`) | IDs **etiquetados** en su prosa |
|---|---|---|
| `corpus/docs/corpus_roadmap.txt` | **0** | **0** |
| `corpus/docs/corpus_convenciones_commits.txt` | 5 (GIT-1, GIT-2, GIT-3, GIT-6, +1) | **0** |
| `corpus/docs/CORPUS_Architecture.md` | 9 | 4 (COR-7, COR-8, COR-10, COR-11) |
| `corpus/docs/corpus_flujo_trabajo.txt` | 44 | 14 (11 FLU de 38 · 3 AUD de 5) |
| **Total** | **58** | **18 — el 31%** |

Comandos de la medición (reproducibles, read-only):
`grep -c 'sede: "corpus/docs/<doc>' docs/ids.yaml` para la columna de sedes;
`grep -oE '\b(COR|FLU|GIT|AUD|CRG)-[0-9]+\b' <doc> | sort -u` para la de etiquetas.
Se descartó `COR-01` (`corpus_flujo_trabajo.txt:476`): no es una etiqueta, es el ejemplo
ilustrativo de la categoría DUPLICADO del checker.

**Consecuencia, dicha sin adornos:** sobre `corpus_roadmap.txt` y `corpus_convenciones_commits.txt`
este gate es **ciego**. Su "cero contradicciones" ahí significa **"no auditado"**, no "sano".
Sobre `CORPUS_Architecture.md` y `corpus_flujo_trabajo.txt` la cobertura por ID es del 44% y del
32% respectivamente; lo demás se cubrió por lectura de prosa, que es peor instrumento y no es el
que la norma acredita.

**El corolario que cambia el plan: D-7 está mal enunciada.** §7.6 y `corpus_estado.md` la definen
como *"la prosa de los **módulos** todavía no lleva sus IDs etiquetados"*
(`corpus_flujo_trabajo.txt:464-465`). El árbol lo desmiente: **la prosa del framework tampoco los
lleva, en un 69%** (40 de 58 sedes sin etiqueta). D-7 describe la mitad de su propio agujero, y
este piloto se corrió sobre la premisa implícita de que "SCOPED al framework = ahí sí hay IDs".
Esa premisa es falsa.

Esto no es un hallazgo de contradicción entre docs (por eso no está en §2): es un hallazgo de
**cobertura**, y se registra en §5. Se nombra acá porque **el orden de trabajo depende de él**:
etiquetar antes de volver a correr cualquier gate.

### 1.2 — El gate COMPLETO tiene dos normas que no se pueden obedecer a la vez

`corpus_flujo_trabajo.txt:465` (§7.6) declara que el COMPLETO **no corre** mientras viva D-7.
`corpus_flujo_trabajo.txt:552` (§7.8, CADENCIA) ordena, **sin salvedad**, correr el COMPLETO al
cerrar un Block de módulo. El escenario está vivo: Coagulant cierra su Block 3 en la ronda 7 con
D-7 impaga. Obedecer AUD-2 al pie de la letra produce exactamente el "limpio" sobre prosa sin IDs
que §7.6 prohíbe llamar evidencia. Detalle y parche en **§2.1**. Bucket **A**.

### 1.3 — El roadmap manda el diseño de módulo a un archivo que, por norma, no lo recibe

`corpus_roadmap.txt:13-16` ordena que el detalle de diseño de cada bloque viva en
`CORPUS_Architecture.md` como sección nueva. `CORPUS_Architecture.md:328` y el árbol real dicen
lo contrario: no hay ni una sección de módulo ahí, cada módulo desprendió su doc particular en su
propio repo. Es el eco de una reparación del 2026-07-16 que corrigió §3 del roadmap y dejó vivo
§0. Detalle y parche en **§2.2**. Bucket **A**.

---

## 2. Contradicciones, por gravedad

Ninguna BLOQUEANTE. Ninguna ALTA. Dos MEDIA. Ninguna BAJA.

Ambas sobrevivieron a los tres verificadores adversariales (refutador / árbitro-código /
árbitro-historia) por mayoría ≥2/3, según §7.8 (`corpus_flujo_trabajo.txt:516-522`).

---

### 2.1 — MEDIA · `evidencia` · AUD-2 ordena correr un gate que §7.6 declara bloqueado

**TRIAGE: A — REPARABLE.** El ganador lo decide el nivel 2 de la jerarquía (`corpus_estado.md`),
no el gate. · **Votos: 2/3 real** · **Gana: A (§7.6)**

**Afirmación A** — `corpus/docs/corpus_flujo_trabajo.txt:461-465` (§7.6):

> *"un gate que cruza IDs es CIEGO a un documento SIN IDs. Un 'limpio' suyo sobre un doc sin IDs
> no es evidencia de nada — es 'no auditado'. La cobertura se mide en NORMAS CON ID, no en
> archivos leídos. Hoy eso tiene nombre y número: la deuda D-7 del registro (la prosa de los
> módulos todavía no lleva sus IDs etiquetados), **y es por eso que el COMPLETO no corre
> todavía**."*

**Afirmación B** — `corpus/docs/corpus_flujo_trabajo.txt:552` (§7.8, bloque CADENCIA):

> *"AUD-2 — COMPLETO al cerrar un Block de módulo, antes de abrir el siguiente."*

Sin condición, sin salvedad, sin referencia a D-7.

#### Por qué chocan

**Alcance verificado idéntico en los cuatro ejes** — mismo artefacto (el gate en modo COMPLETO),
mismas siete raíces, sin soft-dep de por medio, mismo ancla temporal (el cierre de un Block de
módulo). No es distinto nivel de detalle: AUD-2 no resume a §7.6, la **ordena al revés**.

**No es el falso positivo "todavía no implementado":** el gate existe
(`.claude/workflows/auditoria-coherencia-docs.js`, `corpus_flujo_trabajo.txt:512`) y ya corrió su
piloto el 2026-07-16 (`docs/CHANGELOG.md`, PARCHE 4 **[APLICADO 2026-07-16]**). Lo que se
contradice no es la existencia, es la **cadencia obligatoria contra un bloqueo declarado**.

**El escenario es vivo, no hipotético:** `corpus_roadmap.txt:47-51` pone a Coagulant cerrando su
Block 3 en la ronda 7, y `corpus_estado.md:88-90` pone el pago de D-7 como trabajo *pendiente*.
Si ese Block cierra antes de que D-7 se pague, las dos normas se piden cosas incompatibles.

#### Evidencia que decide

**No hay Lua que arbitre** (nivel 1 vacío): el gate LLM es un proceso sobre docs, no runtime. El
único artefacto ejecutable del anillo es `corpus/.claude/check-ids/corpus_check_ids.ps1`, el
checker MECÁNICO de §7.7, que no toca la cadencia del gate.

**Decide el nivel 2 — la foto de HOY.** `corpus/docs/corpus_estado.md:40`, literal:

> *"**El COMPLETO (AUD-2) sigue bloqueado** por la deuda D-7."*

Nombra a AUD-2 **por su ID** y la declara bloqueada. Ratificado en `corpus_estado.md:88-90`:
*"bajar la deuda D-7 para poder correr el COMPLETO. Ojo con el orden: sin IDs en la prosa […] el
gate sobre esos docs no probaría nada — es la lección §10.8 de Kontrol, que allá costó 22
hallazgos post-limpio."*

**Coincidente (índice, no autoridad).** `corpus/docs/ids.yaml:454-460`, entrada `AUD-2`:
- `titulo:` *"El gate COMPLETO corre al cerrar un Block de módulo, antes de abrir el siguiente."*
- `sede:` `"corpus/docs/corpus_flujo_trabajo.txt §7.8"`
- `nota:` *"BLOQUEADO por la deuda D-7 hasta que la prosa de los módulos lleve sus IDs: sobre un
  doc sin IDs el gate es ciego, y su 'limpio' significaría 'no auditado' (§7.6)."*

El yaml es índice y no dirime (§7.1). Pero acá **no contradice a su sede: la completa** — señal de
que la sede es la que quedó corta. Su `nota` no es una segunda definición: es el registro
apuntando a una condición que la prosa de §7.8 debería enunciar y no enuncia.

**Corroboración (acta inmutable).** El acta del primer piloto,
`docs/auditorias/2026-07-16_coherencia_docs_PILOTO.md:816-817`, ya **leía** AUD-2 con la
condición: *"El modo COMPLETO (los 19 docs de las siete raíces) queda diferido hasta saldar D-7,
por AUD-2."* La condición es la intención; el literal es lo que falta.

**No hubo derogación.** `docs/CHANGELOG.md`, PARCHE 2 **[APLICADO 2026-07-16]** escribió *"§7.8
del flujo (el gate, sus modos, su cadencia, su triage)"* y *"§7.6 reescrita como 'los dos anillos,
y por qué son dos'"* **en la misma tanda**. No es deriva entre versiones: ninguna de las dos es
"más nueva". Es una **omisión de redacción interna a un solo parche**.

#### El voto disidente, y por qué no ganó

El refutador sostuvo que no hay contradicción: *"norma vigente + deuda declarada viva"* es el
patrón estándar del ecosistema (el mismo molde que D-5 / MOCK-FIRST, FLU-17), que §7.6 y §7.8
viven en el **mismo archivo a 90 líneas de distancia** dentro de la cadena §7.6→§7.8 —así que
ningún lector llega a AUD-2 sin haber leído el bloqueo—, y que "el COMPLETO no corre **todavía**"
es tiempo verbal de precondición impaga, no de prohibición.

**Es un argumento serio y queda registrado.** No prosperó por dos razones: (a) el bloque CADENCIA
es precisamente la superficie que se lee suelta —es una tabla de disparo, se consulta por su ID al
cerrar un Block, no se lee en prosa corrida desde §7.6—; y (b) el propio `corpus_estado.md:40`
trata el bloqueo como una propiedad **de AUD-2**, no del contexto que la rodea. Si la condición es
de AUD-2, va en AUD-2.

#### Parche PROPUESTO (no aplicado)

**Doc perdedor:** `corpus/docs/corpus_flujo_trabajo.txt`, §7.8, bloque CADENCIA.
**Ubicación por CONTENIDO, no por número de línea** (per FLU-27):

**BUSCAR:**
```
      AUD-2 — COMPLETO al cerrar un Block de módulo, antes de abrir el siguiente.
```

**REEMPLAZAR POR:**
```
      AUD-2 — COMPLETO al cerrar un Block de módulo, antes de abrir el siguiente. BLOQUEADO
        mientras viva la deuda D-7: sobre prosa sin IDs el gate es ciego y su "limpio" sería
        un "no auditado" disfrazado de sano (§7.6). Hasta que D-7 se pague, al cerrar un Block
        corre el SCOPED y el COMPLETO queda DIFERIDO explícito — el mismo diferimiento que
        AUD-3 fija para el contexto degradado.
```

**§7.6 NO se toca:** es el lado que gana, su texto ya es correcto.

**Nota de coordinación (opcional, recomendada).** Si se abre `ids.yaml` para reflejar esto,
conviene revisar en la misma pasada el enunciado de la `nota` de AUD-2, que hoy dice *"la prosa de
los **módulos**"* — el §1.1 de esta acta muestra que el framework está en la misma condición. Una
sola pasada, no dos. (Corrección al acta previa: `AUD-1`, `AUD-2` y `AUD-3` **sí** están
etiquetadas en la prosa de su sede, `corpus_flujo_trabajo.txt:550-553`; verificado por grep. Lo
que falta no es la etiqueta, es la condición.)

---

### 2.2 — MEDIA · `proceso` · El roadmap manda el diseño de módulo al doc general; el árbol dice que no va ahí

**TRIAGE: A — REPARABLE.** El ganador lo decide el árbol real (nivel 1). · **Votos: 3/3** ·
**Gana: B (`CORPUS_Architecture.md` + el árbol)**

**Afirmación A** — `corpus/docs/corpus_roadmap.txt:13-16`:

> *"Regla anti-deriva: el detalle de diseño de cada bloque vive en CORPUS_Architecture.md (una
> sección nueva por bloque, ver §9); acá NO se duplica ese detalle — solo el orden y el criterio
> de entrada de cada tramo."*

**Afirmación B** — `corpus/docs/CORPUS_Architecture.md:328`:

> *"Los bloques de módulo, en la práctica, **no** se agregaron como secciones de este archivo:
> cada módulo desprendió su **doc particular** autocontenido en su propio repo (el patrón que
> formaliza `corpus_flujo_trabajo.txt` §2). Acá queda el resumen y el link."*

#### Por qué chocan

Mismo alcance exacto (doc; framework; transversal; sin eje de realm, módulo, soft-dep ni slice que
los separe) y **destinos mutuamente incompatibles para la misma cosa** —el detalle de diseño de un
Block de módulo—: el roadmap lo manda a una sección nueva del general; el general dice que ahí no
va. **O hay sección de módulo en `CORPUS_Architecture.md` o no la hay.** No pueden ser ambas.

#### Evidencia que decide

**ÁRBOL REAL (nivel 1) — decisivo.** `corpus/docs/CORPUS_Architecture.md` tiene exactamente nueve
secciones `##`: Índice · 1 Visión general · 2 Grafo de dependencias · 3 Superficie de Corpus ·
4 Fronteras de módulo · 5 Contrato de ítems · 6 Orden de carga · 7 Migración ADS→Caliber ·
8 Workspace multi-root · 9 Estado y próximos bloques. **Ninguna es una sección de Block de
módulo.** No hay una sección Caliber, ni Coagulant, ni Craving, ni Cargo.

**El árbol también confirma dónde SÍ vive el detalle** (verificado con `ls` sobre las siete
raíces):
- `corpus-caliber/docs/Caliber_Architecture.md` (+ `Caliber_EnergyShields_Arquitectura.md`)
- `corpus-coagulant/docs/Coagulant_Architecture.md` (+ `Coagulant_Block3_Semilla.md`)
- `corpus-craving/docs/Craving_Architecture.md` (+ `Craving_Block4_Semilla.md`)
- `corpus-cargo/docs/Cargo_Architecture.md` (+ `Cargo_Trade_Arquitectura.md`,
  `Cargo_ItemImages_Arquitectura.md`, `Workbench_Arquitectura.md`)
- `corpus-cortex/` — sin `docs/`: repo semilla (`.git`, `LICENSE`, `README.md` y nada más),
  coherente con `corpus_roadmap.txt:71-75`.

**§9 es literalmente lo que B describe:** `CORPUS_Architecture.md:330-335` es una tabla resumen de
cuatro filas cuyas celdas linkean **hacia afuera** — *"doc particular:
`corpus-caliber/docs/Caliber_Architecture.md`"*, *"Doc particular:
`corpus-coagulant/docs/Coagulant_Architecture.md`"*, *"doc particular:
`corpus-craving/docs/Craving_Architecture.md`"*. Resumen + link, no detalle.

**SEDE DE LA REGLA (nivel canónico).** `corpus/docs/corpus_flujo_trabajo.txt:176-177`: *"Al cerrar
un bloque: (a) se documenta como sección nueva en el `<modulo>_Architecture.md` general del **REPO
AFECTADO**"*; y `:193`: *"la sección del doc general queda como resumen corto + link al particular;
el contenido nunca se duplica"*. El roadmap **colapsa "repo afectado" en `corpus/`** — ese es el
error puntual.

**AUTO-DESMENTIDO DEL PERDEDOR.** El mismo `corpus_roadmap.txt:85-92` ya dice:

> *"(Reparación 2026-07-16, hallazgos #5/#6/#7 del piloto del gate. Este tramo ordenaba 'nueva
> sección autocontenida en CORPUS_Architecture.md' cuando §2 prohíbe exactamente eso […] El árbol
> ya había dirimido —los cuatro módulos con Block cerrado desprendieron su doc en su propio repo,
> y CORPUS_Architecture.md no tiene ninguna sección de módulo—, así que el roadmap era el que
> estaba mal: es nivel 6, intención, sin autoridad sobre lo que existe.)"*

**Ese párrafo es la prueba, no el problema.** La reparación del 2026-07-16 corrigió §3 del roadmap
y **dejó vivo el eco en §0:13-16**. Es un fallo del **barrido de ratificación (FLU-28, regla (a):
barrer por el VALOR, no por la lista de destinos del hallazgo)**. El valor era *"el detalle va al
repo dueño"*; se barrió un destino y quedó otro.

**Lectura benigna descartada:** el roadmap nombra el archivo del framework **por ruta exacta y de
forma consistente** (`:67`, `:98`), no como abreviatura de `<Modulo>_Architecture.md`. Y se
autorrefuta: `corpus_roadmap.txt:51` y `:57` ya remiten a `Coagulant_Architecture.md` y
`Craving_Architecture.md` como sede del detalle.

**Jerarquía (§7.1):** el árbol (1) y el doc de arquitectura (5) mandan sobre el roadmap (**6 —
intención, sin autoridad sobre lo que existe**). El que está mal es `corpus_roadmap.txt:13-16`.

#### Parche PROPUESTO (no aplicado)

**Doc perdedor:** `corpus/docs/corpus_roadmap.txt`, líneas 13-16.

**ANTES:**
```
Este doc ORDENA lo que sigue; corpus_estado.md dice en qué punto estamos. Ambos se
leen juntos al planear el próximo bloque. Regla anti-deriva: el detalle de diseño de
cada bloque vive en CORPUS_Architecture.md (una sección nueva por bloque, ver §9);
acá NO se duplica ese detalle — solo el orden y el criterio de entrada de cada tramo.
```

**DESPUÉS:**
```
Este doc ORDENA lo que sigue; corpus_estado.md dice en qué punto estamos. Ambos se
leen juntos al planear el próximo bloque. Regla anti-deriva (FLU-18): el detalle de
diseño de cada bloque NO se duplica acá — vive en el doc de arquitectura del REPO
DUEÑO (<Modulo>_Architecture.md, o el doc particular que el Block desprenda; ver
corpus_flujo_trabajo.txt §2, que es su sede). CORPUS_Architecture.md §9 solo lleva el
resumen + link de cada Block de módulo. Acá: solo el orden y el criterio de entrada
de cada tramo.
```

**`corpus_flujo_trabajo.txt` NO se toca:** `:176-177` ya dice *"del repo afectado"* y es correcto.

#### Barrido de ratificación asociado (FLU-28, regla (a))

Se barrió por el **VALOR** —"el detalle de diseño va al repo dueño"— sobre todo el archivo. Un
solo candidato adicional, y **se DESESTIMA**:

`corpus_roadmap.txt:98` — *"`docs/CORPUS_Architecture.md` → §9 (fuente del orden de bloques),
diseño detallado"*. **NO es eco y no requiere parche.** §1-§8 de `CORPUS_Architecture.md` **sí**
son el diseño detallado del framework (Block 1); la línea es correcta tal como está. Parcharla
sería un falso positivo. *(Los tres verificadores coincidieron en desestimarla; se registra el
desacuerdo de redacción: dos de ellos proponían igual retocarla por claridad. Se descarta: retocar
una línea correcta es deriva, no reparación.)*

#### Nota de encuadre, previa al parche

El autor debería decidir **antes** si `corpus_roadmap.txt` se declara formalmente **NO-NORMATIVO**.
Es nivel 6 de §7.1 (pura intención), **no declara ni cita un solo ID** (verificado:
`grep -oE '\b[A-Z]{3}-[0-9]+\b' docs/corpus_roadmap.txt` → 0 resultados) y **no es sede de
ninguna familia** (`grep -c 'sede: "corpus/docs/corpus_roadmap.txt' docs/ids.yaml` → 0). Hoy no es
ninguna de las dos cosas: es un **doc normativo fuera del sistema de IDs**.

Si se declara no-normativo, este hallazgo deja de ser "contradicción entre normas" y pasa a ser
deriva de un doc sin autoridad: el triage sigue siendo A y el parche sigue valiendo — cambia el
encuadre, no el trabajo. Si en cambio el roadmap acuña IDs, la cita a FLU-18 del texto propuesto
queda como **cita**, no como segunda definición (FLU-25 / §7.2).

---

## 3. Patología del registro

### 3.1 — Divergencias yaml-vs-sede: **0**

Cero casos en que el `titulo:` de una entrada de `ids.yaml` afirme algo distinto de la prosa de su
sede, dentro del alcance auditado.

**Este 0 lleva asterisco, y es grande.** §7.8 define esa comparación como *el* trabajo que solo el
gate puede hacer. Pero se emitió sobre un conjunto donde **el 69% de los IDs con sede en el
framework no tiene etiqueta en su prosa** (§1.1): localizar el fragmento a comparar dependió de
resolver un `§` a mano, doc por doc. **Este 0 mide menos de lo que aparenta.** No es falso; es
menos fuerte de lo que su forma sugiere.

### 3.2 — Normativas sin ID: **62** (violan FLU-25)

FLU-25 es explícita: una norma sin ID va a derivar. Sesenta y dos afirmaciones de fuerza
NORMATIVA, con `archivo:linea` verificado, circulan hoy sin ID propio en los cuatro docs
auditados. **No se listan una por una acá** —el detalle crudo está en el material de la corrida—
pero sí su forma, porque la forma es la que informa el parche:

**Por doc:**

| Doc | Normativas sin ID detectadas | IDs con sede ahí sin etiquetar en prosa |
|---|---|---|
| `corpus_flujo_trabajo.txt` | 18 | **30** (27 FLU + 2 AUD… ver nota) |
| `CORPUS_Architecture.md` | 40 | 5 (COR-12, COR-13, COR-14, + 2 CRG) |
| `corpus_roadmap.txt` | 4 | 0 (no es sede de nada) |
| `corpus_convenciones_commits.txt` | 0 normativas nuevas | 5 (GIT-1, GIT-2, GIT-3, GIT-6, +1) |

*Nota sobre AUD:* de los 5 AUD, **3 están etiquetados** en `corpus_flujo_trabajo.txt:550-553`
(AUD-1, AUD-2, AUD-3); **AUD-4 y AUD-5 no aparecen en la prosa** de su sede. Verificado por grep.

**Dos casos merecen nombre propio**, porque son normas de peso circulando sin ancla:

1. **§7.7 completo — el checker.** `corpus_flujo_trabajo.txt:482-509` fija cinco normas duras sin
   un ID que las nombre: que corre solo en `pre-commit` y solo si el commit toca superficie
   normativa (`:482-486`); que su único escape consciente es `--no-verify` y que **no hay CI que
   lo cace después** (`:487-489`); que **falla ruidoso, nunca en silencio** —si falta `pyyaml`
   sale con error y la línea de instalación, y jamás se saltea a sí mismo: *"un 'limpio' que no
   corrió no es un limpio"* (`:502-505`); y que tiene tests propios con fixture por categoría
   porque *"un checker que nadie vio en ROJO no es evidencia de nada"* (`:507-509`). Son las
   normas que sostienen la credibilidad del anillo barato entero. **Ninguna tiene ID.**

2. **El patrón de boot — `CORPUS_Architecture.md:184-233`.** Ocho normativas encadenadas (sonda +
   boot diferido a `Initialize`; `AddCSLuaFile` en file-scope fuera del `Boot()`; la sonda cubre
   **todas** las primitivas usadas en file-scope, no solo el registro; fallo ruidoso con `MsgN` y
   no con `Corpus.Log` porque Corpus no existe) cuelgan todas de **COR-5**, que es un ID sobre
   *"detección, nunca asunción"*. COR-5 es el principio; el patrón template de los cuatro módulos
   con código no tiene ID propio. Es mucha norma para un solo ancla.

**Recomendación (no un parche — es trabajo de acuñación, del autor):** el etiquetado de los ~40
huérfanos del framework es **precondición de cualquier gate futuro**, no una tarea de higiene. Ver
§5, Hueco 1.

### 3.3 — Familia `CTX`: sede declarada que **no existe en el árbol**

`corpus/docs/ids.yaml:47` declara:

```yaml
  CTX: { dominio: cortex,     sede: "corpus-cortex/CLAUDE.md" }
```

Fui a mirar el árbol: **`corpus-cortex/` contiene `.git`, `LICENSE` y `README.md`. Nada más.**
No hay `CLAUDE.md`. No hay `docs/`. **La sede de la familia CTX no existe.**

**El registro es consciente y lo dice** — `corpus/docs/ids.yaml:1534-1536`:

> *"── CTX — Cortex ── / Sin entradas: el repo tiene solo LICENSE + README y su README es
> descriptivo, no normativo. La familia queda declarada para que su Block la use al abrirse."*

**Por eso esto NO se cuenta como hallazgo de contradicción:** es deuda declarada, del mismo molde
que D-5 / MOCK-FIRST (FLU-17) — la familia está reservada a propósito, adelantándose al Block de
Cortex. Rechazarlo como contradicción es correcto.

**Lo que sí queda en pie, y es un hallazgo real sobre el checker:** el cabezal de `ids.yaml`
afirma que el checker valida *"sedes"*. Para `CTX` eso es **falso por vacuidad** — el checker
valida la sede de las **entradas**, y CTX no tiene entradas, así que la validación nunca se
ejerce. Existe hoy una `sede:` apuntando a un archivo inexistente y **ningún anillo lo caza**. Lo
cazó esta acta por `ls`, que no es un instrumento del sistema.

**Recomendación (no parche):** que el checker de §7.7 valide las sedes de `familias:` además de las
de `entradas:`. Es una línea de PowerShell y cierra un agujero probado. Alternativa: `pendiente:
true` explícito en la familia. **Es del checker, no del gate** — ver §6.

---

## 4. Ambigüedades de alcance: **18**

Dieciocho afirmaciones normativas o descriptivas que no declaran su alcance en uno o más de los
cuatro ejes. **No son hallazgos** —ninguna contradice a nadie hoy— pero son **ambigüedad latente**:
son exactamente el material del que nacen las contradicciones de alcance que el gate después tiene
que arbitrar.

**El patrón dominante, con nombre: `corpus_roadmap.txt` no declara REALM en ninguna de sus
afirmaciones.** Diez de las 18 son suyas (`:26-28`, `:31-34`, `:36-45`, `:43`, `:47-51`, `:50-51`,
`:53-57`, `:55-57`, `:71-75`, `:73-74`, `:74-75`), todas con *"REALM: no especificado"*. Es
coherente con lo que el doc es (un ordenador de tramos, no una especificación) y refuerza la
recomendación de §2.2: **declararlo formalmente no-normativo resuelve las diez de un saque.**

**Las que sí conviene mirar**, porque viven en docs que sí son normativos:

- **`CORPUS_Architecture.md:64`** — *"Cargo no es hoja: consume Coagulant (encumbrance) y Cortex
  (facción en su panel de estado)."* Realm no especificado, y los dos edges **están en realms
  distintos**: el panel de estado es client, el encumbrance es server. Es la frase que más
  se beneficia de un realm explícito, porque describe dos cosas que no comparten el suyo.
- **`CORPUS_Architecture.md:132`** — la frontera de Cortex (*"posee la táctica de combate de NPC y
  el afecto"*) es server por naturaleza y el doc no lo dice. **Cortex no tiene código todavía**:
  es el momento barato de fijarlo, antes de que haya algo que contradiga.
- **`corpus_convenciones_commits.txt:8-13`** — enumera **cinco** repos hermanos que deben definir
  su tabla de alcances y **omite `corpus-stalker`**, que según `corpus/CLAUDE.md` es la séptima
  raíz, tiene su propio git y ya lleva commits. **No se eleva a contradicción**: es una omisión de
  una lista, no una afirmación incompatible —el doc no dice "y stalker no"—. Pero es deriva
  sembrada, del mismo tipo exacto que §2.2.
- **`corpus_convenciones_commits.txt:118`** — el ejemplo *"crea las **seis** raíces del multi-root
  workspace"* contra las **siete** de `CORPUS_Architecture.md:281` y `corpus/CLAUDE.md`.
  **DESESTIMADO, y se deja constancia de por qué:** es un **ejemplo que cita un commit histórico**,
  no una norma vigente sobre el conteo de raíces. Cuando ese commit se hizo, eran seis. Parcharlo
  sería falsificar el ejemplo. Falso positivo.

---

## 5. Huecos de esta auditoría — lo que NO cubrió

Honestidad sobre la cobertura. Ordenados por prioridad.

### Hueco 1 (PRIORIDAD 1) — Dos de los cuatro docs auditados no declaran un solo ID: sobre ellos este gate es CIEGO

**Dicho con todas las letras, como §7.6 exige:**

> **Sobre `corpus/docs/corpus_roadmap.txt` y `corpus/docs/corpus_convenciones_commits.txt`, este
> gate es ciego. Su "cero contradicciones" NO significa "sano". Significa "NO AUDITADO".**

Y sobre los otros dos, la cobertura por ID es parcial: 44% en `CORPUS_Architecture.md` (4 de 9),
32% en `corpus_flujo_trabajo.txt` (14 de 44). La tabla completa está en §1.1.

**La prueba de que esto muerde, y no es teoría:** la contradicción §2.2 —una de las dos
confirmadas— vive en `corpus_roadmap.txt`, el doc con **cero** IDs. Se cazó por **lectura de
prosa**, no por cruce de IDs. En ese doc **no hay ID que cruzar**. El gate la encontró *a pesar*
de su instrumento, no *gracias* a él. Cuántas más hay en esos dos docs, esta acta **no lo sabe y
no lo afirma**.

**D-7 está mal enunciada** (§1.1): `corpus_flujo_trabajo.txt:464-465` y `corpus_estado.md` la
limitan a *"la prosa de los módulos"*. El framework está igual o peor.

**Para taparlo** (recomendaciones, ninguna aplicada):
1. Reescribir el enunciado de D-7 en `corpus_estado.md` y en §7.6 para que **cubra las siete
   raíces, framework incluido**, con el número real medido (40 de 58 sin etiqueta en el framework).
2. Enseñarle al checker de §7.7 el **chequeo inverso**: hoy valida *"la sede existe"*; debe validar
   *"la sede **etiqueta** el ID"*. Ese chequeo es exactamente lo que convierte al gate en no-ciego,
   y hoy no existe.
3. **Parche de etiquetado de los ~40 huérfanos del framework antes de volver a correr ningún
   gate.** Es precondición, no higiene.
4. Darle familia y sede al roadmap, **o** declararlo NO-NORMATIVO explícito en
   `familias_excluidas`. Hoy no es ninguna de las dos: es un doc normativo fuera del sistema.

### Hueco 2 (PRIORIDAD 2) — Los `CLAUDE.md` son sede de IDs y este gate no los miró

`corpus/docs/ids.yaml` declara **11 IDs con sede en `corpus/CLAUDE.md`** (verificado:
`grep -c 'sede: "corpus/CLAUDE.md' docs/ids.yaml` → 11), **incluida la familia COR entera** — los
contratos no negociables. Este piloto auditó `CORPUS_Architecture.md` y **no auditó
`corpus/CLAUDE.md`**: es decir, **auditó el resumen y no la sede**.

Agravante de jerarquía: **§7.1 pone `CLAUDE.md` en el nivel 4, por encima de arquitectura (5) y de
roadmap (6)**. El piloto se saltó el doc de **mayor autoridad** de los que estaban a su alcance.
Cualquier contradicción `CLAUDE.md`-vs-arquitectura habría tenido **ganador automático** y no se
buscó.

**Un dato a favor, y hay que decirlo:** `corpus/CLAUDE.md` es el doc **mejor etiquetado del
framework** — 11 IDs con sede, **11 etiquetados en prosa** (COR-1 a COR-11). Es el único al 100%.
Si el alcance lo hubiera incluido, la cobertura por ID del piloto habría sido sustancialmente
mejor, no peor. **El alcance dejó afuera al mejor doc.**

**Para taparlo:** meter los siete `CLAUDE.md` en el alcance del gate como **docs de primera clase,
nivel 4**. Son sede de IDs, no metadata.

### Hueco 3 (PRIORIDAD 3) — El COMPLETO declara un alcance de "19 docs" que no existe

`corpus_flujo_trabajo.txt:547`: *"COMPLETO (`piloto: false`) — los **19** docs de diseño de las
siete raíces."*

Los conté sobre el árbol (`ls` por raíz, excluyendo `CHANGELOG.md`, `<modulo>_estado.md`,
`ids.yaml` y `auditorias/`):

| Raíz | Docs de diseño | Cuáles |
|---|---|---|
| `corpus/` | 4 | Architecture, flujo, convenciones, roadmap |
| `corpus-caliber/` | 4 | Architecture, EnergyShields, convenciones, roadmap |
| `corpus-coagulant/` | 4 | Architecture, Block3_Semilla, convenciones, roadmap |
| `corpus-craving/` | 4 | Architecture, Block4_Semilla, convenciones, roadmap |
| `corpus-cargo/` | **6** | Architecture, Trade, ItemImages, Workbench, convenciones, roadmap |
| `corpus-stalker/` | 1 | ASSETS.md |
| `corpus-cortex/` | 0 | repo semilla |
| **Total** | **23** | + los 7 `CLAUDE.md` (Hueco 2) = **30** |

**El alcance del gate caro es un número sin lista.** AUD-2 ordena correr "el COMPLETO" contra un
conjunto que **ningún doc enumera** y cuyo cardinal **está mal**. Los cuatro que se caen del 19 se
caen **en silencio**: no hay contra qué comparar.

Y hay docs de diseño que **ningún ID toca en ninguna dirección** —ni etiquetados, ni citados como
sede—: `corpus-cargo/docs/Workbench_Arquitectura.md`, `corpus-craving/docs/Craving_Block4_Semilla.md`,
`corpus-coagulant/docs/Coagulant_Block3_Semilla.md`, `corpus-caliber/docs/Caliber_EnergyShields_Arquitectura.md`
y **los cinco `*_convenciones_commits.txt` de módulo**. Puntos ciegos perfectos, en el sentido
exacto de §7.6.

**Para taparlo:** reemplazar *"los 19 docs"* por una **lista enumerada** en §7.8 — o mejor,
**derivarla por grep del árbol** (como manda FLU-27) y que el checker falle si el árbol tiene un
doc de diseño que la lista no nombra. El número hardcodeado es deriva garantizada: **ya derivó**.

### Hueco 4 (PRIORIDAD 4) — Temas transversales que la taxonomía de buckets no captura

Tres, en orden de riesgo:

1. **Autoridad servidor↔cliente / confianza en el input del cliente.** El bucket `realms` cubre
   *dónde corre* el código; `namespacing` cubre *cómo se llama* el mensaje. **Ninguno cubre *quién
   decide*.** Grepeé `autoridad|authoritative|valida.*server|exploit` sobre los docs: **todos** los
   hits son sobre la jerarquía de autoridad **documental** (§7.1). **Cero hits sobre autoridad de
   runtime.** Con Cargo Trade, el peso, los iconos y el Workbench moviendo estado por
   `Corpus.Net`, *"el cliente pide"* vs. *"el cliente ordena"* es exactamente la clase de contrato
   que se contradice entre un doc particular y el general sin que nadie lo note. **Sus
   contradicciones nunca se buscaron porque no hay bucket.** Es el hueco con más superficie de
   runtime real y cero cobertura.
2. **Idioma / convenciones de redacción.** GIT-4 (comentarios en español) tiene sede en
   `corpus/CLAUDE.md`; el bucket `proceso` no lo caza porque apunta a flujo de trabajo, no a
   redacción.
3. **COMPAT-RUNTIME vs. RECICLAR.** `assets-licencias` cubre la licencia; **no cubre la decisión
   de integración** (detectar por API vs. copiar código), que es la distinción que
   `dev/mods_workshop_mapa.md` existe para sostener y que atraviesa Cortex entero.

### Hueco 5 — Los "cero contradicciones" sospechosos

Un bucket limpio es creíble en proporción a las normas **con ID** que pudo cruzar. Con ese filtro:

- **`assets-licencias`** — su masa vive en `corpus-stalker/docs/ASSETS.md` y
  `corpus-stalker/CLAUDE.md`, **ambos fuera del piloto**. Un limpio acá es literalmente "no
  auditado".
- **`dano-limbs`, `dominio-medico`, `inventario`, `ui-vgui`, `contrato-items`** — son buckets **de
  módulo**. Sus sedes son `Caliber_Architecture.md`, `Coagulant_Architecture.md`,
  `Cargo_Architecture.md`, `Craving_Architecture.md` — **todas fuera del alcance del piloto por
  diseño**. Que salgan "sin contradicciones" **no es una señal: no se miraron.**

**Regla que esta acta se aplica a sí misma:** un bucket cuya sede está fuera del alcance **no se
declara corrido**. Declararlo sería sobre-declarar cobertura, que es la falla exacta que §7.6
nombra. Los buckets de arriba quedan marcados **NO CUBIERTOS**, no "limpios".

### Hueco 6 — El README de `docs/auditorias/` es "el tracker de cobertura" y no tiene con qué trackear

§7.8 (`corpus_flujo_trabajo.txt:558`) le asigna esa función: *"Su README es el tracker de
cobertura."* Pero sin lista enumerada de docs (Hueco 3), sin métrica de normas-con-ID por doc
(Hueco 1) y con buckets que se declaran corridos sin haber tocado su sede (Hueco 5), el tracker
solo puede registrar **archivos leídos** — que es **exactamente la métrica que §7.6 prohíbe**:
*"La cobertura se mide en NORMAS CON ID, no en archivos leídos."*

**Para taparlo:** que el README trackee, por doc: `IDs con sede aquí` / `IDs etiquetados` /
`última acta que lo cubrió`. **Las dos primeras columnas el checker ya las puede emitir — hoy
tiene los datos y no los reporta.**

### Hueco 7 — Causa raíz compartida por las dos contradicciones

Las dos confirmadas comparten causa con lo de arriba, y conviene decirlo:

- **§2.1 (AUD-2)** nace de una **tanda apurada**: el PARCHE 2 escribió §7.6 y §7.8 **el mismo día**
  y no cerró el círculo entre ambas. No es deriva temporal: es omisión de redacción intra-parche.
  El anillo que debería cazar eso —revisar que dos secciones escritas juntas concuerden— **no
  existe en ningún lado**.
- **§2.2 (roadmap)** sobrevivió al barrido de ratificación porque **`corpus_roadmap.txt` no tiene
  un solo ID por el cual barrer**. FLU-28 manda barrer por el VALOR justamente porque el barrido
  por ID no alcanza; en el roadmap el barrido por ID **no es que no alcance: no existe**.

---

## 6. Qué NO se auditó, y por qué

Delimitación explícita, para que nadie lea de esta acta más de lo que dice:

1. **Doc-vs-código está FUERA DEL ALCANCE.** Este gate cruza **prosa contra prosa**. Cuando invocó
   el nivel 1 de la jerarquía (§2.2) fue sobre el **árbol** —qué archivos y secciones existen—, no
   sobre el comportamiento del Lua. **Esta acta NO afirma que nada esté implementado, ni que nada
   funcione.** Un `[APLICADO]` en el CHANGELOG y un "verificado en juego" en un `estado.md` son
   afirmaciones **de esos docs**, citadas como evidencia documental, no ratificadas por esta
   corrida.
2. **"Esto no está implementado todavía" NO fue tratado como hallazgo, jamás.** El corpus es
   diseño por delante del código, **a propósito**. Se rechazaron sistemáticamente: MOCK-FIRST
   (FLU-17) —Craving congelando `COAGULANT.ApplyExternalCondition` antes de que Coagulant la
   ratifique es **deuda declarada (D-5)**, no un choque—; la degradación honesta (COR-11) —"sin
   Cargo la vía es X, con Cargo es Y" es el patrón de producción, no una contradicción—; las
   reglas de slice cerrado conviviendo con slice pendiente; y la familia CTX reservada sin
   entradas (§3.3).
3. **Huérfanos, bicéfalos y sedes rotas NO son de este gate.** Los prueba el **checker
   determinista** (`corpus/.claude/check-ids/corpus_check_ids.ps1`), que corre en cada commit
   (§7.7). Los dos anillos **no se solapan a propósito** (§7.6, `:454-459`): el gate no re-deriva
   lo que el checker ya probó, y el checker no opina sobre significado. Las tres observaciones de
   §3.3 y §5 que apuntan al checker (validar sede de `familias`, validar que la sede **etiquete**
   el ID, emitir la métrica por doc) están registradas acá **como insumo para él**, no como
   hallazgos de este anillo. Se anotan porque las cazó esta corrida; su reparación no es acá.
4. **Los tres repos con más superficie normativa quedaron fuera** por el modo (§7). Los buckets de
   módulo se marcan **NO CUBIERTOS**, no "limpios" (Hueco 5).
5. **Ningún archivo de las siete raíces fue modificado, creado ni borrado.** Ni un doc, ni el
   CHANGELOG, ni `ids.yaml`, ni Lua, ni el espejo `desktop-sync`. Los parches de §2 están
   **PROPUESTOS**. **El gate propone, el autor dispone.**

---

## 7. Modo PILOTO — por qué solo el framework

Esta corrida fue **SCOPED** (`piloto: true`): **solo los cuatro docs de diseño de `corpus/docs/`**.
Las otras seis raíces —Cortex, Caliber, Coagulant, Craving, Cargo y `corpus-stalker`— **no se
auditaron**.

**La razón, según §7.6** (`corpus_flujo_trabajo.txt:461-465`): un gate que cruza IDs es ciego a un
doc sin IDs, y su "limpio" sobre un doc sin IDs significa "no auditado". Esa condición **tiene
nombre y número: la deuda D-7** — *"la prosa de los módulos todavía no lleva sus IDs
etiquetados"*—, *"y es por eso que el COMPLETO no corre todavía"*.

`corpus/docs/corpus_estado.md:40` lo ratifica: *"**El COMPLETO (AUD-2) sigue bloqueado** por la
deuda D-7."* El modo COMPLETO —los 23 docs reales de las siete raíces, no 19 (Hueco 3)— **queda
DIFERIDO explícito** hasta saldar D-7.

**Y acá está la ironía que esta acta no puede omitir:** el piloto se limitó al framework bajo la
premisa de que *"la deuda es de los módulos; en el framework sí hay IDs"*. **El árbol desmiente esa
premisa.** El framework tiene **40 de sus 58 IDs sin etiquetar (69%)** y **dos de sus cuatro docs
de diseño con cero IDs** (§1.1). El SCOPED se corrió sobre terreno que **también** es parcialmente
ciego.

**Eso no invalida los dos hallazgos de §2** —ambos tienen evidencia `archivo:linea` verificada
contra el árbol, y ambos se sostienen solos—. **Lo que invalida es cualquier lectura de esta acta
como "el framework está limpio".** El framework **no está limpio**: **está parcialmente
auditado**, y esta acta mide cuánto: **31% de cobertura por ID**.

D-7, tal como está enunciada hoy, **describe la mitad de su propio agujero**.

---

### Cierre — orden de trabajo recomendado

1. **Etiquetar los ~40 huérfanos del framework** y **reescribir D-7** para que cubra las siete
   raíces. Precondición de todo lo demás.
2. **Meter los siete `CLAUDE.md` en el alcance** (nivel 4, sede de la familia COR).
3. **Enumerar el alcance del COMPLETO** por grep del árbol; enterrar el "19".
4. Aplicar (si el autor los aprueba) los dos parches de §2.1 y §2.2.
5. Decidir el encuadre del roadmap: acuña IDs **o** se declara NO-NORMATIVO.
6. Insumos para el checker (§7.7, no para el gate): validar sede de `familias`; validar que la
   sede **etiquete** el ID; emitir la métrica por doc que el README necesita.

**Ninguno de estos pasos fue ejecutado por esta corrida.** El gate propone, el autor dispone.
