# Acta — Auditoría de coherencia documental del ecosistema Corpus

**Fecha:** 2026-07-19
**Modo:** COMPLETO (primera corrida) — 29 docs, siete raíces
**Estado del acta:** ÍNTEGRA (cobertura completa: ningún agente murió, ningún tramo quedó sin auditar)
**Alcance:** doc-vs-doc, adjudicado contra el Lua / `<modulo>_estado.md` / CHANGELOG según la jerarquía de autoridad de `corpus_flujo_trabajo.txt` §7.1
**Modo de escritura:** READ-ONLY sobre las siete raíces. Este acta es el único archivo escrito. **Todos los parches son PROPUESTOS, ninguno aplicado.** El gate propone, el autor dispone.
**Inmutabilidad:** esta acta es la foto del estado AL MOMENTO DE AUDITAR. No se edita después.

---

## Cifras

| Métrica | Valor |
|---|---|
| Contradicciones confirmadas (3 verificadores adversariales cada una) | **26** |
| — ALTA | 6 |
| — MEDIA | 13 |
| — BAJA | 7 |
| — BLOQUEANTE | 0 |
| Triage A (REPARABLE: el árbol dirime) | 25 |
| Triage B (VOTO DEL AUTOR: el código no dirime) | 1 |
| Triage C (bug de código) | 0 |
| CADUCO | 0 |
| Divergencias yaml-vs-sede | 1 |
| Normativas sin ID (FLU-25) | 844 |
| Afirmaciones sin alcance declarado | 197 |
| Cobertura perdida | **0** |
| Docs auditados **sin un solo ID** (cobertura ciega) | **10 de 29** |

---

## 1. Resumen ejecutivo — lo que cambia el plan

Diez hallazgos en los que **construir siguiendo el doc rompe un contrato vivo**. Nombre y apellido:

1. **Cargo_Architecture.md:7 manda cablear un lazy-check `Cargo → Craving` que viola CRV-13.**
   Craving es quien se registra contra el StatusPanel de Cargo (`corpus_craving_bars.lua:11-18`), no al revés. El árbol de Cargo tiene **cero** consultas a `"craving"`. Quien implemente según la línea 7 duplica el registro de barras. → **Hallazgo 2.1 (ALTA)**

2. **Cargo_Architecture.md:65 dice que un stackeable persiste "solo un `count`" — y el Lua persiste `condition` en la entry, con la identidad de línea `id + condición`.**
   Esa condición es lo que impide el **lavado de desgaste** (una placa gastada que vuelve a un stack de fábrica sería una reparación gratis, `corpus_cargo_inventory.lua:202-222`). Implementar §3 al pie de la letra borra el anti-lavado y rompe el comercio, que factura por `id + condición`. → **Hallazgo 2.2 (ALTA)**

3. **corpus-cargo/CLAUDE.md:68 dice que Cargo "NUNCA veta `PlayerCanPickupWeapon`" — y el world gate del mismo archivo lo veta, verificado en juego.**
   Quien "restaure el contrato" borra el gate del frente #16 y devuelve el touch-hoovering de armas. La lección L4D vale para la ruta de **give**, no para el mundo. → **Hallazgo 2.3 (ALTA)**

4. **corpus-craving/CLAUDE.md:60 (CRV-7) afirma que "el último candidato de cada lista es SIEMPRE HL2 vanilla" — y `Assets.STOMACH` no tiene fallback por diseño.**
   Quien "arregle" la excepción le agrega un fallback HL2 al rugido de estómago, que la arquitectura §6 prohíbe explícitamente. Además `Assets.Sound` devuelve `nil`, cosa que el universal niega. → **Hallazgo 2.4 (ALTA)**

5. **corpus-cargo/CLAUDE.md:128 manda tratar el harness offline como descartable ("vive en el scratchpad, se reconstruye fácil") — y es `dev/harness_cargo.py`, 355 checks acumulados, sede de ~20 acreditaciones `tipo: harness` en `ids.yaml`.**
   Obedecer esa línea **borra evidencia citable** y manda esas normas CRG a INTENCION, justo la métrica que FLU-31 existe para bajar. → **Hallazgo 2.5 (ALTA)**

6. **corpus_flujo_trabajo.txt:461-465 sigue prohibiendo correr el gate COMPLETO por la deuda D-7 — que el CHANGELOG cerró el 2026-07-19.**
   Con Block 4 cerrado, seguir §7.6 obliga a saltear AUD-2 indefinidamente; seguir AUD-2 obliga a correr un gate que §7.6 declara sin significado. **Esta acta existe porque se siguió AUD-2.** → **Hallazgo 2.6 (ALTA)**

7. **Cargo_Architecture.md:141 dice "ítem stackeable de clase «placa»" — y `Items.Register` hace `error()` con cualquier `class` que no sea `stackable`/`unique`.**
   Quien implemente placas leyendo §4 escribe `class = "placa"` y el registro **revienta en el arranque**. El eje real es la categoría (`category:plates`). → **Hallazgo 2.13 (BAJA por gravedad, pero es un crash)**

8. **Cargo_Architecture.md:42 (§1, el enunciado de cabecera del doc) sigue diciendo "grid uniforme, cada ítem ocupa una celda" — el grid es de gradas `w × h` desde el 2026-07-12.**
   Quien construya el grid de contenedores o de loot leyendo §1 hace celdas uniformes contra el componente de gradas que §15.1 declara compartido entre columnas. → **Hallazgo 2.8 (MEDIA)**

9. **Cargo_Architecture.md:467 reserva un slot "Health" para Coagulant que Coagulant nunca va a registrar.**
   Coagulant publica **una** barra (`blood`); la vida vive en su silueta de 6 zonas. Quien "arregle" el slot faltante duplica la vida y rompe la superficie única de la silueta. → **Hallazgo 2.11 (MEDIA)**

10. **corpus-cargo/CLAUDE.md:83 describe el fix de brazos oscuros con el mecanismo que el código documenta como fallido y revertido.**
    `SetLightingOriginEntity` no existe como call site en el repo; el fix vivo es `render.SuppressEngineLighting` + caja de luz propia. Restaurar lo que dice el doc reintroduce un bug ya pagado dos veces. → **Hallazgo 2.19 (MEDIA)**

**Además, un voto abierto que no puede resolverse sin el autor:** el **GC del cadáver looteado** está adjudicado a Cortex/Caliber en `Cargo_Trade_Arquitectura.md:249-252` y a Cargo en `:281`, con doce líneas de distancia, y **no existe código que dirima** (`corpus-cortex/` es repo semilla). → **Hallazgo 2.10, bucket B.**

---

## 2. Contradicciones, por gravedad

> Formato: afirmaciones con `archivo:línea` · ganador por jerarquía §7.1 · evidencia que decide · parche PROPUESTO al doc perdedor · bucket de triage.

---

### GRAVEDAD ALTA

---

#### 2.1 — La flecha de la arista Cargo ↔ Craving está invertida en el encabezado de Cargo
**Tema:** soft-deps · **Bucket: A (REPARABLE)** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/docs/Cargo_Architecture.md:7` — «Dependencias soft declaradas en este documento: Cortex, Coagulant, **Craving** (hambre/sed del panel de estado), **Caliber**». |
| **B** | `corpus-craving/docs/Craving_Architecture.md:33-35` — **CRV-13**: «Craving detecta a sus peers; **nadie detecta a Craving**», reforzado por **CRG-44** (`Cargo_Architecture.md:344`): la barra la registra el módulo DUEÑO. |

**Por qué chocan:** misma arista, mismo realm (client), mismo slice (Block 1 de Cargo / Block 4 de Craving, ambos cerrados), descrita con la flecha invertida. O Cargo detecta a Craving, o Craving se registra en Cargo. No las dos.

**Evidencia que decide (nivel 1 — Lua):**
- `corpus-craving/lua/corpus_craving/client/corpus_craving_bars.lua:11-18` — dentro de `Corpus.OnReady`: `local cargo = Corpus.GetModule("cargo")`, guarda con `isfunction(cargo.StatusPanel.RegisterBar)` y llama `RegisterBar("craving", {id="hunger", ...})` (:18) y `{id="hydration"}` (:24). Si Cargo falta, loguea y retorna.
- Barrido de `GetModule|HasModule` sobre **todo** `corpus-cargo/lua/`: 40 hits, 38 son auto-referencia `GetModule("cargo")`; las dos aristas salientes reales son `Corpus.GetModule("cortex")` en `server/corpus_cargo_inventory.lua:453` y `Corpus.GetModule("coagulant")` en `server/corpus_cargo_movement.lua:43`. **Cero** ocurrencias de `"craving"` o `"caliber"` como lookup de módulo.
- El header del archivo dueño lo enuncia: `corpus-cargo/lua/corpus_cargo/client/corpus_cargo_statuspanel.lua:2-5` — *"Cargo owns the panel, NOT the content: modules register bars (Craving: hambre/hidratación, Coagulant: vital/sangre, Caliber B3: protección) and absent modules simply never register"*.
- Mismo patrón entrante en el otro peer: `corpus-coagulant/lua/corpus_coagulant/client/corpus_coagulant_hud.lua:458`.

**Nivel 3-4 concordantes:** `corpus-cargo/docs/CHANGELOG.md:2305` — PARCHE 7 **[APLICADO 2026-07-14]**: «Cargo no es hoja. Consume Coagulant (`OnEncumbrance`) y Cortex (`GetFactionInfo`)» — set saliente ratificado = {Coagulant, Cortex}. Y `corpus-cargo/CLAUDE.md:9` repite ese set.

**Asimetría de git que prueba que la línea 7 es el lado viejo:** `git log -L 7,7:docs/Cargo_Architecture.md` devuelve **un solo commit**, el semilla `679ada5`. `git log -L 37,37` muestra que §1 SÍ fue reescrita el 2026-07-14 por `0ed24c3` («corrige la deriva de los docs contra el código»), cambiando "Es hoja" por "Dos aristas salen de acá". El mismo commit tocó `Cargo_Architecture.md` y `CLAUDE.md` **y se salteó el encabezado**.

**Parche PROPUESTO (no aplicado) — `corpus-cargo/docs/Cargo_Architecture.md:7`:**

> **Dependencia dura:** Corpus. **Soft-deps SALIENTES (Cargo consulta con lazy-check + `pcall`; ver §1):** Cortex (`GetFactionInfo` — facción/rango, arista anticipatoria) y Coagulant (`OnEncumbrance` — drenaje de stamina por sobrepeso, arista viva en ambos extremos). Son las únicas dos: no existe ninguna otra consulta de Cargo hacia un peer.
> **Consumidores ENTRANTES (registran CONTRA Cargo; Cargo no los detecta ni los nombra en su código — CRG-44):** Coagulant (vitales del panel de estado), Craving (hambre/sed — cita **CRV-13**, `corpus-craving/docs/Craving_Architecture.md:33`), Caliber (protección de armadura y escudos vía sub-slot Body, Block 3, aún no existe). La barra la registra siempre el **módulo dueño**; si el dueño no está montado, la barra simplemente no se registra (§11, CRG-44).

**Nota:** la línea 7 invierte la flecha en **tres** de sus cuatro entradas. Coagulant aparece mezclado: su "drenaje de stamina" SÍ es saliente real (`movement.lua:43`), sus "vitales del panel" son entrantes.

**Salvedad de un verificador (minoritario, se registra):** la línea 7 dice literalmente «dependencias soft **declaradas en este documento**», que podría leerse como índice de alcance y no como grafo de dirección. Se desestimó porque usa el término direccional "dependencias soft" (COR-11) para una lista de dirección mixta, y porque §1 del mismo doc ya fue corregida y hoy la contradice. Gravedad efectiva discutida entre ALTA y MEDIA; se deja en ALTA por el riesgo concreto de cableado.

---

#### 2.2 — «Un stackeable persiste solo un `count`» es falso: persiste `condition`, y esa condición es el anti-lavado de desgaste
**Tema:** contrato-items · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/docs/Cargo_Architecture.md:61,63-66` — la clase «determina si existe un blob de instancia»; los stackeables (incl. **placas de armadura**) persisten «solo un `count`». |
| **B** | `corpus-cargo/docs/Cargo_Trade_Arquitectura.md:146-148` — «los ítems stackeables **sin condición** usan 1.0» — la salvedad presupone stackeables **con** condición. |

**Evidencia que decide (nivel 1 — Lua):**
- `corpus-cargo/lua/corpus_cargo/shared/corpus_cargo_dev.lua:75-80` — `id = "cargo_dev_plate", class = "stackable", category = "plates", has_condition = true, material = "Ceramic IV"`. **Un stackeable con condición existe en el árbol** — y es justamente la placa que §3 lista como ejemplo de "solo un count".
- `corpus-cargo/lua/corpus_cargo/server/corpus_cargo_inventory.lua:202-222` — cabecera de `AddStack`: *"Stacks merge only when both sides carry the same condition. A worn plate returned from a sub-slot must never launder into a factory stack — that would be a free repair."* La entry escrita es `{ id = id, count = put, condition = condition }` y el merge exige `entry.condition == condition`.
- `corpus_cargo_inventory.lua:1068-1077` (`SubSlotAttach`) — *"wear travels with it, factory units start at 100 when the def declares condition"*: `if entry.condition ~= nil then mounted.condition = entry.condition elseif def.has_condition then mounted.condition = 100 end`.
- `corpus-cargo/lua/corpus_cargo/shared/corpus_cargo_trade.lua:46` — *"a stack carries its own condition field"*; `:65-69` — `RefKey` = `"s:" .. ref.id .. "|" .. ref.condition`.
- `corpus_cargo_items.lua:166` — *"`has_condition`  instance/**sub-slot entries** start with condition = 100"*: el propio contrato de def documenta condición en entries que no son instancia. `has_condition` es **ortogonal** a `class`.

**Nivel 3:** `corpus-cargo/docs/CHANGELOG.md:659` **[APLICADO]** — «merge solo con condición idéntica»; `:1275` — «`rec.equip.throwable` = entry `{id, count, condition?}`»; `:1869` (entry #22, **[APLICADO 2026-07-14]**) — «el ref de un stack es `id + condición`».

**Contra-evidencia que ACOTA el hallazgo:** `corpus_cargo_instances.lua:31` — `if def.class ~= "unique" then error("… it has no instances") end`. La cláusula de L61 («determina si existe un blob de instancia») **es correcta**: los stackeables no tienen blob ni uid. Lo falsificado es exclusivamente el «**solo** un `count`» de L65.

**Parche PROPUESTO — `Cargo_Architecture.md` §3, fila «Stackeable» (L65):**

> ANTES: `| **Stackeable** | munición, comida, componentes, placas de armadura | solo un `count` | Sí |`
> DESPUÉS: `| **Stackeable** | munición, comida, componentes, placas de armadura | entry `{id, count, condition?}` — sin blob ni uid; `condition` existe cuando el def declara `has_condition`, y **el stack se parte por condición** (mezclar desgastes sería una reparación gratis) | Sí, solo con condición idéntica |`

Y en L61: «…determina si el ítem tiene **uid y blob de instancia propios**. No determina si lleva condición: un stackeable con `has_condition` la lleva en la propia entry del stack.»

**NO tocar §4 L141** por este hallazgo (es correcto contra el Lua; su defecto es otro — ver 2.13). **NO tocar `Cargo_Trade_Arquitectura.md:146-148`**: ya describe el código tal cual.

---

#### 2.3 — «Nunca veta `PlayerCanPickupWeapon`» es un absoluto que el world gate desmiente
**Tema:** inventario · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/CLAUDE.md:68` — post-equip vía `WeaponEquip`, «**nunca vetando `PlayerCanPickupWeapon`**» (lección L4D IPS). |
| **B** | `corpus-cargo/lua/corpus_cargo/server/corpus_cargo_capture.lua:595-602` + header `:17-23` — el archivo **SÍ** veta, acotado a armas en reposo en el mundo. |

**Evidencia que decide (nivel 1):**
```
hook.Add("PlayerCanPickupWeapon", "corpus_cargo_world_gate", function(ply, wep)
    ... if wep.CargoWorldSpawned then return false end
    if ply.CargoEquipGive then return end                       -- ruta de give: intacta
    if CurTime() - wep:GetCreationTime() < 0.5 then return end   -- a give, not a pickup
    return false end)
```
Header `:17-23` — *"The WORLD GATE below (roadmap #16, author request 2026-07-11) **DOES veto** PlayerCanPickupWeapon — but only for weapons RESTING in the world … The lesson above still holds: every give flow passes untouched."*

**Nivel 3:** `corpus-cargo/docs/CHANGELOG.md:551` — entry #7 **[APLICADO 2026-07-11]**, confirmado en juego; `:571-577` describe el gate y **separa explícitamente** la ruta de give del gate de mundo.

**Origen del absoluto:** `CHANGELOG.md:176-177` (entry #4, sellada dos días DESPUÉS por confirmación del feed de pickup) repite «nunca vetar `PlayerCanPickupWeapon`». Pierde igual: el Lua es autoridad 1 y el gate corre desde el 07-11.

**Corrección de gravedad respecto de la acusación original:** `CLAUDE.md:68` es una **fila de la tabla «Mapa de archivos»**, NO el contrato #4 (`CLAUDE.md:93` = "Eyección obligatoria", CRG-9). Ningún agente que siga los "Contratos que no debes romper" sería empujado a borrar el gate. Se mantiene ALTA por el riesgo si alguien lee la fila como normativa, pero el acta deja constancia de que **no es un contrato numerado**.

**Parche PROPUESTO — `corpus-cargo/CLAUDE.md:68`:**

> **Post-equip vía `WeaponEquip`, sin vetar `PlayerCanPickupWeapon` en la ruta de give** — compat con mods de pickup (lección L4D IPS, ver header). El **world gate** del mismo archivo **sí** veta `PlayerCanPickupWeapon`, pero solo para armas **en reposo** en el mundo (edad > 0,5 s o spawneadas por nuestro drop): sin pickup por contacto, WALK+USE toma (roadmap #16, CHANGELOG #7).

**Nota de índice (no autoridad):** `corpus/docs/ids.yaml:1459` replica el absoluto en su `titulo` y su `:1465` ya lo matiza en la `nota` — el yaml se contradice a sí mismo. Alinear al título en el mismo parche.

---

#### 2.4 — CRV-7 enuncia un universal («SIEMPRE HL2 vanilla») que el código falsifica con una excepción declarada
**Tema:** assets-licencias · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-craving/CLAUDE.md:60` — CRV-7: «el último candidato de **cada lista** es **SIEMPRE** HL2 vanilla». |
| **B** | `corpus-craving/docs/Craving_Architecture.md:204-207` — el estómago (`hunger.mp3`) es **sin fallback**: sin el addon, el feedback se omite. |

**Evidencia que decide (nivel 1):**
- `corpus-craving/lua/corpus_craving/shared/corpus_craving_assets.lua:48` — `Assets.STOMACH = { "zona/stalkerrp/hunger.mp3" }  -- sin fallback (§6)`. Lista de **un** candidato, ruta ZONA.
- Mismo archivo `:27-32` — `Assets.Sound` termina en `return nil` si ningún candidato existe. `:17-23` — `Assets.Model` **sí** garantiza ruta (`if i == #candidates then return path end`). **El código separa modelo de sonido a propósito; CRV-7 los junta bajo una regla.**
- Caller: `corpus_craving_core.lua:173-174` — `if snd ~= nil then ply:EmitSound(snd) end`, con comentario `:166` *"Solo con el addon de assets (sin fallback digno en HL2, §6)"*. El `nil` **es** el contrato.

**Registro externo independiente:** `corpus-stalker/docs/ASSETS.md:55` — «`sound/zona/stalkerrp/hunger.mp3` | Craving (STOMACH, **sin fallback**)».

**Parche PROPUESTO — `corpus-craving/CLAUDE.md:60`:**

> **CRV-7 — Los assets GSC no entran a este repo.** Todo modelo/sonido STALKER se referencia por ruta vía `CRAVING.Assets`, nunca por archivo incluido. En **modelos** el último candidato de cada lista es SIEMPRE HL2 vanilla: `Assets.Model` garantiza ruta aunque nada esté montado. En **sonidos** el último candidato es el fallback del engine cuando existe, pero `Assets.Sound` devuelve `nil` si ninguno está montado — el rugido de estómago (`Assets.STOMACH = { "zona/stalkerrp/hunger.mp3" }`) es la **excepción declarada** (§6: no hay equivalente digno en HL2) y el feedback se omite sin el addon; el caller chequea `nil`. **No le agregues un fallback.** Los `.mdl` ZONA no se re-namespacean.

**Daño colateral del índice:** `corpus/docs/ids.yaml:1055` replica el universal y su `:1060` acredita `evidencia: selftest — "la resolución siempre devuelve una ruta"`, **que es falso para `Assets.Sound`**. El yaml sigue a su sede una vez corregida.

**Tercer sitio con la misma redacción:** `corpus-craving/docs/CHANGELOG.md:242-251` (PARCHE 9, [APLICADO 2026-07-14]) propagó el universal al `README.md`. El CHANGELOG **no se reescribe**; el `README.md` sí puede barrerse con entrada nueva.

---

#### 2.5 — El harness offline: un repo lo declara descartable, otro lo declara permanente y evidencia citable
**Tema:** evidencia · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/CLAUDE.md:128` — «El script vive en el **scratchpad de sesión**, se reconstruye fácil». |
| **B** | `corpus-craving/CLAUDE.md:70` — permanente, en `../dev/harness_<modulo>.py`, **no se reconstruye por sesión**; «el mismo patrón que verificó Corpus, Cargo y Coagulant». |

**Evidencia que decide (nivel 1 — el árbol):**
- `D:\…\VSCode\dev\harness_cargo.py` **EXISTE**: 121.564 bytes, mtime 2026-07-14, junto a `harness_craving.py` (21.566 bytes). **Ningún harness del ecosistema vive hoy en scratchpad.**
- Cabecera del archivo: *"offline GLua verification … LuaJIT 2.1 via lupa … loads the REAL corpus framework + cargo module in both realms"*; `:10-12` cablea `CORPUS_AUTORUN` y `CARGO_LUA` por ruta absoluta.

**Nivel 3 — la migración documentada:** `corpus-cargo/docs/CHANGELOG.md:458` (2026-07-11) dice «harness offline **reconstruido**» (régimen viejo). `CHANGELOG.md:1235` (**[APLICADO 2026-07-12]**) dice «harness offline **extendido** (`dev/harness_cargo.py`): **110 checks, 0 fallas (eran 80)**». El verbo cambia y el conteo pasa a ser acumulativo. Ratificado por `:1317`, `:1554`, `:1746` (279 checks), hasta `:2282`.
**Nivel 2:** `corpus-cargo/docs/cargo_estado.md:88` — «**355 checks verdes en ambos realms** (con gate final)». Un conteo acumulativo 80→110→229→279→310→355 es estructuralmente imposible bajo un script que se tira por sesión.

**Consecuencia normativa (por qué es ALTA):** `corpus_flujo_trabajo.txt:417` (sede de FLU-31) define el tipo de evidencia como *"harness — un check del harness offline con stubs de GMod (`dev/harness_*.py`)"* — ruta **citable**. `ids.yaml` acredita con `tipo: harness` ~20 normas CRG por esa ruta (líneas 742, 760, 769, 777, 1178, 1194, 1203, 1211, 1242, 1251, 1487, 1514…). **Obedecer A borra el referente y manda esas normas a INTENCION.**

**Parche PROPUESTO — `corpus-cargo/CLAUDE.md:128`:**

> 2. **Harness offline** (LuaJIT vía `pip install lupa` + stubs de GMod, carga el framework real de `corpus/`): mismo patrón que verificó Corpus, Craving y Coagulant. El script es **permanente**, vive fuera de los repos en [`../dev/harness_cargo.py`](../dev/harness_cargo.py) y se corre con `python dev/harness_cargo.py` desde la raíz del workspace — **no se reconstruye por sesión**: es el referente citable de la evidencia `tipo: harness` (FLU-31) que respalda las normas CRG en `ids.yaml`. Tirarlo y regenerarlo **borra esa evidencia**. Al cierre: **355 checks verdes en ambos realms**.

**⚠ NO arrastrar este parche a `corpus-coagulant/CLAUDE.md:71` sin arbitrar antes** — ver hueco H3 en §5: ese repo lleva la misma redacción, pero **`dev/harness_coagulant.py` no existe**, así que ahí la afirmación de scratchpad podría ser la correcta. Si el autor quiere unificar el régimen: primero materializar el harness, después parchear el doc. Nunca al revés.

---

#### 2.6 — §7.6 prohíbe correr el gate COMPLETO; AUD-2 lo obliga; el CHANGELOG ya levantó el bloqueo
**Tema:** evidencia · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus/docs/corpus_flujo_trabajo.txt:461-465` — «la deuda D-7 … **y es por eso que el COMPLETO no corre todavía**». |
| **B** | `corpus/docs/corpus_flujo_trabajo.txt:558` — **AUD-2**: el gate COMPLETO corre al cerrar un Block de módulo, antes de abrir el siguiente. |

**Por qué chocan:** las dos son normativas, mismo doc, mismo alcance. Una fija cadencia obligatoria, la otra la cancela sin fecha ni condición de salida operable.

**Evidencia que decide (niveles 2 y 3 — NO el yaml):**
- `corpus/docs/CHANGELOG.md:478-481` **[APLICADO 2026-07-19]** — «**109 de 125 IDs de módulo etiquetados en su sede** (CAL 22/22, COA 27/31, CRV 15/16, CRG 38/48, STK 7/8). Los 16 restantes son exactamente la deuda **D-3**. El gate COMPLETO (AUD-2) **ya puede correr sin ahogarse en `sinId` de módulo**.»
- `corpus/docs/CHANGELOG.md:589` — «El gate COMPLETO queda **sin bloqueos**.»
- `corpus/docs/corpus_estado.md:8` — «el gate COMPLETO **ya no tiene bloqueos**»; `:91-93` — «Lo que sigue: **correr el gate COMPLETO** (AUD-2, ~8-10M tokens, 29 docs)».
- Árbol: las etiquetas existen — `corpus-cargo/CLAUDE.md:97` (**CRG-24**), `corpus-coagulant/docs/Coagulant_Architecture.md:263` (**COA-35**).

**Parche PROPUESTO — `corpus_flujo_trabajo.txt` §7.6, último párrafo (ubicar por CONTENIDO: la frase «y es por eso que el COMPLETO no corre todavía»):**

> Y la advertencia que Kontrol pagó con 22 hallazgos: un gate que cruza IDs es CIEGO a un documento SIN IDs. Un "limpio" suyo sobre un doc sin IDs no es evidencia de nada — es "no auditado". La cobertura se mide en NORMAS CON ID, no en archivos leídos.
> Eso tuvo nombre y número hasta el 2026-07-19: la deuda **D-7** mantuvo el COMPLETO diferido mientras la prosa de los módulos no llevaba sus IDs. La pasada de etiquetado la **RECORTÓ** (109 de 125 + GIT-1..7 anclados a su sede), así que **AUD-2 corre sin bloqueos**. Lo que resta —16 sedes fuera de un doc de diseño (`.lua`, CHANGELOG, estado, roadmap)— es la deuda **D-3**: es un punto ciego **acotado y declarado**, no un bloqueo. Un ✅ del COMPLETO se lee "auditado salvo esas 16 sedes".

**Barrido de ratificación (FLU-28) — la premisa caduca vive en tres sitios más:**
- `corpus/docs/ids.yaml:482` (nota de AUD-2: «BLOQUEADO por la deuda D-7…») — el yaml sigue a su sede.
- `corpus/.claude/workflows/auditoria-coherencia-docs.js:166-170` — «la deuda D-7 del registro dice que los docs de MÓDULO todavía no». Es comentario, sin superficie de runtime.
- `corpus/docs/auditorias/README.md:52` — «leer las deudas D-3/D-7 antes de correr un COMPLETO».

---

### GRAVEDAD MEDIA

---

#### 2.7 — Cargo declara cuatro soft-deps salientes; el grafo sede declara «los dos»
**Tema:** soft-deps · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/docs/Cargo_Architecture.md:7` — incluye **Caliber** (protección de armadura, escudos). |
| **B** | `corpus/docs/CORPUS_Architecture.md:53-64` — «Los **DOS** edges viven en el código con lazy-check + `pcall`»; §4: «Cargo · Consume (soft): Coagulant (`OnEncumbrance`) · Cortex (`GetFactionInfo`)»; `:52` fija Caliber como **hoja**. |

**Evidencia:** el árbol de `corpus-cargo/lua/**` tiene exactamente dos lookups salientes a peers (`movement.lua:43`, `inventory.lua:453`). **Cero** `GetModule("caliber")`. Las menciones textuales de "caliber" en el Lua de Cargo son el campo de display de munición (`def.ammo.caliber`, `corpus_cargo_ammo.lua:37`) — homónimo.
La dirección real la escribe el propio doc perdedor: `Cargo_Architecture.md:365` (**CRG-47**) — «Escudos de energía de jugador vía sub-slot Body | **Dueño futuro: Caliber Block 3** | Punto de acoplamiento ya definido en este documento» → **Caliber → Cargo**.
Nivel 3: `corpus/docs/CHANGELOG.md:171` — PARCHE 1 **[APLICADO 2026-07-14]**: §2 deja de declarar hoja a Cargo, con las **dos** aristas.

**No es MOCK-FIRST:** `Cargo→Cortex` está declarada mock-first en AMBOS docs sin choque. `Cargo→Caliber` no existe en el grafo, ni en el Lua, ni como firma congelada.

**Parche PROPUESTO:** es el **mismo parche que 2.1** — la reescritura de `Cargo_Architecture.md:7` separando salientes de entrantes resuelve las dos contradicciones en una sola edición. Caliber y Craving estaban en el mismo error de dirección.

---

#### 2.8 — §1 de Cargo sigue enunciando el grid uniforme que §7 derogó el 2026-07-11
**Tema:** inventario · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/docs/Cargo_Architecture.md:42` (§1) — «grid **uniforme** … **cada ítem ocupa una celda** … (ítems **sin dimensiones**)». |
| **B** | `Cargo_Architecture.md:218-219` (§7, enmienda 2026-07-11) — «El grid deja de ser uniforme y pasa a **gradas**: cada ítem ocupa `w × h` celdas según su footprint». |

**Evidencia (nivel 1):**
- `corpus-cargo/lua/corpus_cargo/client/corpus_cargo_grid.lua:209-212` — `local fp = def and CARGO.Icons.GetFootprint(def) or {w=1,h=1}` / `cell:SetSize(fp.w * U + (fp.w-1)*GAP, fp.h * U + (fp.h-1)*GAP)`.
- Cabecera del mismo archivo `:2-6`: *"§7 (as amended by §15): tiered grid — every item paints w×h cells … **Reused by the main inventory and the container/loot column.**"* — el código ya leyó §7 y **no** leyó §1.
- `corpus_cargo_items.lua:184` — `size  { w, h } explicit cell footprint`; `:311-313` trece footprints permitidos; `:318-324` techos por categoría; `:330-333` pisos.
- `corpus_cargo_icons.lua:414` — cadena `data override → def.size → auto (projected OBB)`.
**Nivel 2-3:** `cargo_estado.md:24` — «UI fullscreen 3 columnas/3 estados **con gradas**». `CHANGELOG.md:616` — entry #8 **[APLICADO 2026-07-12]**, punto 1: «**Grid a gradas**».

**Matiz que el parche DEBE preservar:** el Lua ratifica la mitad que sobrevive — `grid.lua:4-5` dice literalmente *"Footprint is render only: the data model stays uniform (no spatial management, no rotation, auto-sort by category; carry cost is weight, not space)"*. Lo derogado es **solo** «cada ítem ocupa una celda» y el «sin dimensiones» literal.

**Parche PROPUESTO — `Cargo_Architecture.md:42`,** conservando la mitad viva y anotando la enmienda con el mismo patrón que §7 ya usa:

> Modelo de referencia: **grid estilo STALKER/GAMMA**, no Tetris estilo EFT. Los ítems se auto-ordenan por categoría, **sin gestión espacial ni rotación**; el costo de cargar más no es espacial, es de **peso**. Decisión explícita: define el modelo de datos completo del módulo (ítems sin ocupación espacial), abarata la net-sync y fija la UX de transferencia con contenedores.
>
> > **Enmienda 2026-07-11 (bloque UI fullscreen) — ver §7 y §15.** El grid deja de ser **uniforme**: «cada ítem ocupa una celda» pasa a «cada ítem pinta `w × h` celdas según su **footprint**» (`Cargo_ItemImages_Arquitectura.md` §5; set permitido y techos/pisos por categoría en `corpus_cargo_items.lua`). El footprint es solo **render**: el modelo de datos NO cambia.

**Deriva colateral (mismo enunciado, otro archivo):** `corpus-cargo/CLAUDE.md:7` sigue describiendo «grid **uniforme** estilo STALKER/GAMMA» — es el primer archivo que lee cualquiera que entre al repo. Barrerlo en la misma pasada.

---

#### 2.9 — La semilla de Coagulant congela `ApplyBandage` como firma del `onUse`; el slice 2 lo derogó
**Tema:** contrato-items · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-coagulant/docs/Coagulant_Block3_Semilla.md:30-32` — «`COAGULANT.ApplyBandage(ply) -> bool` **como firma de `onUse`**». |
| **B** | `Coagulant_Architecture.md:165` (**COA-3**) — el `onUse` devuelve **siempre `false`**; el consumo ocurre al COMPLETAR vía `TakeItem`. `:187` — `ApplyBandage` devuelve `true` si el tratamiento ARRANCÓ. |

**Por qué chocan:** si `onUse == ApplyBandage` y devuelve `true` al arrancar, Cargo descuenta la unidad al INICIO — exactamente lo que COA-3 prohíbe, dejando muertos el consumo diferido y la re-validación.

**Evidencia (nivel 1):** `corpus_coagulant_items.lua:21-27` — `UsarTratamiento(kind)` fabrica el `onUse`: llama `ApplyTreatment` y hace `return false` sin excepción («Cargo nunca consume acá: se consume al COMPLETAR»). Las 4 defs lo cablean en `:46, :56, :66, :76`. `ApplyBandage` vive en `corpus_coagulant_treatment.lua:121-125` como azúcar y **no está cableada como `onUse` de ningún def** (grep sobre las siete raíces: cero coincidencias en posición `onUse`).
**Nivel 3:** `corpus-coagulant/docs/CHANGELOG.md:202` y `:212` **[APLICADO 2026-07-13]** — «`onUse` fabricado que devuelve **false**»; «`ApplyBandage` = azúcar del contrato». Derogan `CHANGELOG.md:50-51` (el scaffold, del que la semilla copia).
**Nivel 4:** `corpus-coagulant/CLAUDE.md` contrato #5 — «Ojo desde el slice 2: el consumo es AL COMPLETAR».

**Salvedad registrada (un verificador votó falso positivo):** la semilla se autodeclara **registro histórico** en `:11-14`, y sus propias `:31-32` ya anticipaban la generalización a `ApplyTreatment(ply, kind, zone)`. El acta lo mantiene como hallazgo porque la viñeta convive en la misma lista de «Marco fijo (no se rediscute acá)» con los IDs de zona, que SÍ son contrato vivo (COA-8): el lector lee toda la lista como vigente.

**Parche PROPUESTO (anotación, no reescritura — es registro histórico):** agregar debajo de `:30-32`:

> > **DEROGADO por el slice 2** (CHANGELOG PARCHE 2 y PARCHE 3, ambos `[APLICADO 2026-07-13]`): la generalización prevista ocurrió, pero la identidad `onUse == ApplyBandage` **no** sobrevivió. Hoy `ApplyBandage` es SOLO azúcar del contrato público (`= ApplyTreatment(ply, "bandage")`, `true` si el tratamiento ARRANCÓ) y el `onUse` de cada ítem es un wrapper fabricado por `UsarTratamiento(kind)` que devuelve **SIEMPRE `false`** — el `TakeItem` corre al COMPLETAR. Sede vigente: **COA-3** (`Coagulant_Architecture.md` §7).

**Pista para el barrido:** verificar si `CORPUS_Architecture.md` §5 (el «§5 de la arquitectura de Corpus» que la semilla cita como sede de la firma congelada) todavía enuncia `ApplyBandage` como firma de `onUse`. Sería un segundo sitio del mismo rot, en el repo del framework.

---

#### 2.10 — COR-6 afirma que el boot depende del orden alfabético; el boot está diseñado para ser inmune a él
**Tema:** boot-carga / namespacing · **Bucket: A** · **Gana B** · *(Dos pares confirmados independientemente sobre el mismo defecto: contra §6 de la arquitectura y contra CAL-1. Se consolidan acá.)*

| | |
|---|---|
| **A** | `corpus/CLAUDE.md:64` — «**El nombre `corpus_registry.lua` es load-bearing**: el boot de los módulos **depende de su posición** en el merge alfabético de `lua/autorun/` — no renombrar.» |
| **B1** | `corpus/docs/CORPUS_Architecture.md:186-215` (§6) — «ningún módulo asume que Corpus ya cargó»; patrón = sonda + boot diferido a `Initialize`. |
| **B2** | `corpus-caliber/docs/Caliber_Architecture.md:60` (**CAL-1**) — el init del módulo ordena ANTES que el registro, **por eso** el boot se difiere; el orden se vuelve irrelevante. |

**Evidencia que decide (nivel 1):** `corpus-cargo/lua/autorun/corpus_cargo_init.lua:4-6` — *"the boot itself is deferred to `Initialize` **BECAUSE** gmod merges lua/autorun/ alphabetically across addons and `corpus_cargo_init.lua` sorts BEFORE `corpus_registry.lua`"*. El hecho alfabético es la **CAUSA** del patrón, no una dependencia del patrón. Estructura en `:129-147`: `if CorpusReady() then Boot() else hook.Add("Initialize", …)`. **Las dos ramas son correctas**: renombrar el registry a cualquier nombre deja el boot igualmente funcional.
Idéntico en `corpus-caliber/lua/autorun/corpus_caliber_init.lua:85-107` (el template), `corpus-coagulant/…:108-118`, `corpus-craving/…:85-95`. Cuatro de cuatro.
Grep de `corpus_registry` sobre el Lua de los cinco repos consumidores: **4 hits, todos comentarios**. Cero código ejecutable depende del nombre.
COR-9 (`CLAUDE.md:65`) prohíbe exactamente esa dependencia de orden, y se verifica en el árbol: los siete archivos del framework abren con `Corpus = Corpus or {}`.

**Trazabilidad (importante):** la cláusula **no** es vieja — la introdujo `corpus/docs/CHANGELOG.md:597-605`, PARCHE 2 **[APLICADO 2026-07-19]**, copiada del parche propuesto en `docs/auditorias/2026-07-16c_…_v3.md:190`, cuyo punto de evidencia 3 **invirtió la causalidad** del comentario de Cargo. El voto del autor ratificó los dos ejes de **alcance** de COR-6 (seis consumidores con segmento / framework con prefijo desnudo), que están BIEN; la cola causal viajó de polizón y nunca fue adjudicada. **El nivel 3 no sobrescribe al nivel 1.**

**Superficie real del daño (menor a la alegada):** la cola causal falsa vive en **un solo sitio normativo**, `corpus/CLAUDE.md:64`. `CORPUS_Architecture.md:337` (§8, el espejo real) **no** la lleva. `corpus_estado.md:90` dice solo «`corpus_registry.lua` es load-bearing», sin el porqué falso. `ids.yaml:120` dice «prefijo desnudo load-bearing», sin la premisa de orden.

**Parche PROPUESTO — `corpus/CLAUDE.md:64`, última oración del inciso 6** (el resto del inciso queda intacto):

> **El nombre `corpus_registry.lua` no se renombra por convención**, no por dependencia: su posición en el merge alfabético (después de los `corpus_<addon>_init.lua`) es el HECHO que **obliga** al patrón de sonda + boot diferido de §6 de la arquitectura — el boot es **inmune** a esa posición por construcción (COR-5, COR-9): si el registro ordena antes dispara la fast-path, si ordena después la rama diferida. Lo que sí depende del nombre es la **prosa**: la arquitectura, el CHANGELOG y los inits lo citan por escrito (`corpus_cargo_init.lua:4-6`), y los harness offline arman el frame por ese nombre (`dev/harness_cargo.py:2772`).

**Parche secundario (cita muerta, mismo origen):** `CHANGELOG.md:601-603` dice que el espejo de COR-6 vive en «`CORPUS_Architecture.md` §11» — **ese doc termina en §9** (headings en :25/:45/:80/:126/:144/:182/:286/:296/:341); el espejo real es **§8, línea 337**. Por FLU-14 el entry no se reescribe: va **entrada nueva** que consigne la reformulación y corrija la cita.

**Nota de precisión para el autor:** renombrar a `corpus_corpus_registry.lua` tampoco rompería nada por orden — la sonda + diferido absorbe el caso. El "no renombrar" es **higiene documental**, no restricción técnica de arranque.

---

#### 2.11 — Cargo reserva un slot «Health» para Coagulant que Coagulant no publica
**Tema:** ui-vgui · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/docs/Cargo_Architecture.md:467` — «Coagulant (**Health · Blood**)»; `:341` — «estado vital (overall de vida) **y** cantidad de sangre». |
| **B** | `corpus-coagulant/docs/Coagulant_Architecture.md:238` — `RegisterBar("coagulant", { id = "blood", label = "Blood", … })` — **una** barra; la vida vive en la silueta propia. |

**Evidencia (nivel 1):** `corpus-coagulant/lua/corpus_coagulant/client/corpus_coagulant_hud.lua:454-468` — **una sola** llamada a `RegisterBar`, `id = "blood"`. Grep de `RegisterBar` sobre todo `corpus-coagulant`: ese único sitio. No existe ningún `id="health"`.
**Control que refuta el «es enumeración ilustrativa»:** la misma línea de Cargo dice «Craving (Hunger · Hydration)», y `corpus_craving_bars.lua:18,24` registra **exactamente** esas dos. La enumeración es precisa ítem por ítem; Coagulant es la única entrada que no cuadra.
**Nivel 2:** `coagulant_estado.md:27` — «**Sangre**: barra en el StatusPanel de Cargo; sin Cargo, mini-barra propia bajo la silueta». La vida no figura como barra en ningún punto.

**Origen del error, que el parche debe cubrir:** la barra «Health» que hoy se ve en el panel **no es de Coagulant** — la registra el kit demo de Cargo bajo el módulo `dev` en `corpus_cargo_dev.lua:359-364` (junto a HL2 Armor, gated por `cargo_dev_bars`). `Cargo_Architecture.md:468-469` declara legacy solo la de HL2 Armor y le asigna relevo; la de Health quedó enunciada como si Coagulant fuera a relevarla, relevo que el dueño descartó.

**Parche PROPUESTO — dos anclas en `Cargo_Architecture.md`:**
- `:341` → «**Coagulant**: cantidad de sangre (`id = "blood"`) — **una sola barra**. La vida por zona no viaja al panel: la pinta la silueta de 6 zonas del HUD propio de Coagulant (`Coagulant_Architecture.md` §10, geometría única por **COA-12**), que es información por zona y no cabe en una barra lineal.»
- `:467` → «Coagulant (**Blood** — la vida la pinta su silueta propia, no el panel), Craving (Hunger · Hydration), Caliber Block 3 (armadura propia). Las dos barras demo de `corpus_cargo_dev.lua` quedan legacy: HL2 Armor sale con Caliber B3, y **Health no tiene relevo previsto**.»
- **Tercera ancla que el reporte original omitió:** `:7` dice «Coagulant (…, **vitales** del panel de estado)» — el mismo error de conteo en forma abreviada. Sin corregirlo, la deriva vuelve a crecer. (Se resuelve junto con 2.1/2.7.)

**⚠ Advertencia de citación:** NO copiar al doc de Cargo la cita «COA-8/COA-12» tal como venía en el reporte. Según `corpus-coagulant/CLAUDE.md:59`, **COA-8** son los IDs de zona; `:61`, **COA-12** es «la silueta se pinta y se clickea desde la MISMA tabla». Ninguno enuncia «la silueta es la única superficie de vida». Citar la sede correcta (`Coagulant_Architecture.md` §10) o ninguna ID.

---

#### 2.12 — El segundo argumento de `ApplyExternalCondition`: ¿condición clínica o stat?
**Tema:** dominio-medico · **Bucket: A** · **Gana A** *(único hallazgo donde gana el lado «A»; el doc perdedor es el estado de Coagulant)*

| | |
|---|---|
| **A (gana)** | `corpus-craving/docs/Craving_Architecture.md:96-103` — `ApplyExternalCondition(ply, **id**, severity)`, `id ∈ {"starvation","dehydration"}`. |
| **B (pierde)** | `corpus-coagulant/docs/coagulant_estado.md:123` — «negociar `ApplyExternalCondition(ply, **stat**, severity)` con Craving». |

**Evidencia (nivel 1):** `corpus-craving/lua/corpus_craving/server/corpus_craving_coagulant.lua:14` — `local CONDICIONES = { hunger = "starvation", hydration = "dehydration" }`; `:29` — `for stat, condicion in pairs(CONDICIONES)`; `:34` — `pcall(coag.ApplyExternalCondition, ply, **condicion**, sev)`; `:52-53` idem con `severity = 0` para el Clear. **El emisor manda la condición clínica; el stat es solo la clave del mapa y nunca cruza la frontera.** El propio bucle prueba que "stat" y "condición" son términos distintos en este ecosistema.
**Contraparte sin código:** `corpus-coagulant/lua/` tiene **0 hits** de `ApplyExternalCondition` (confirmado además por `corpus-craving/docs/CHANGELOG.md:175-177`, PARCHE 3 [APLICADO 2026-07-14]).

**Por qué NO es el falso positivo mock-first (D-5):** D-5 es que Craving congele una firma que Coagulant no ratificó — eso no se reporta. Lo reportado es que **los dos repos escriben la misma firma pendiente con dominios de valores distintos**. Y no es cosmético: la degradación es por **CAPACIDAD** (CRV-2). Si Coagulant implementa switcheando sobre `"hunger"/"hydration"`, `isfunction()` da `true`, el `pcall` **no** falla, Craving deja de tocar HP (CRV-3/CRV-4) y Coagulant descarta ids desconocidos → **la inanición se vuelve inofensiva en silencio, sin error en consola.**

**Salvedad registrada (un verificador votó falso positivo):** `coagulant_estado.md:123` enuncia un **nombre de parámetro**, no un dominio de valores; el «(hunger/hydration)» es inferencia. Se mantiene como hallazgo porque la palabra elegida es precisamente el término que el ecosistema usa para lo contrario, y porque el modo de falla es silencioso.

**Parche PROPUESTO — `corpus-coagulant/docs/coagulant_estado.md:123`:**

> …el pendiente cross-repo: ratificar `ApplyExternalCondition(ply, **id**, severity)` con **Craving**, que tiene un puente mock-first esperándolo. **Ojo con el 2.º argumento**: NO es el stat de Craving (`hunger`/`hydration`) sino el **id de condición clínica** `{"starvation", "dehydration"}` — así lo emite ya el puente (`corpus_craving_coagulant.lua:14,34`). Implementar switcheando sobre el stat pasaría el gate de CAPACIDAD sin aplicar nada: Craving delegaría y dejaría de tocar HP (CRV-4), y la inanición quedaría inofensiva **en silencio**. `severity` es float 0..1; `0` = condición limpia.

**Sitios adicionales con la misma redacción:** `corpus-coagulant/docs/coagulant_roadmap.txt:46` y `dev/HANDOFF_coagulant_slice4.md:79` (este último fuera de las siete raíces). **NO tocar** `corpus-coagulant/docs/CHANGELOG.md:692` (ya [APLICADO], no se reescribe historial).
**Al cerrar el Block 3:** ratificar la firma en `Coagulant_Architecture.md` §8 y bajar la nota «PENDIENTE DE RATIFICAR / D-5» de `ids.yaml` CRV-4.

---

#### 2.13 — «Clase «placa»» es un tercer valor de `class` que el registro rechaza con `error()`
**Tema:** contrato-items · **Bucket: A** · **Gana B** · *(gravedad nominal BAJA; se lista acá porque el modo de falla es un crash de arranque)*

| | |
|---|---|
| **A** | `corpus-cargo/docs/Cargo_Architecture.md:141` — «cada uno acepta un ítem stackeable **de clase "placa"**». |
| **B** | `corpus/docs/CORPUS_Architecture.md:161` y `Cargo_Architecture.md:75` — `class` solo admite `"stackable"` o `"unique"`. |

**Evidencia (nivel 1):** `corpus_cargo_items.lua:191` — `local ITEM_CLASSES = { stackable = true, unique = true }`; `:208-210` — `error("Cargo.Items.Register: 'class' must be \"stackable\" or \"unique\"", 2)`. El eje real es la **categoría**: `corpus_cargo_dev.lua:61-63` declara el sub-slot como `{ id = "plates", filter = "category:plates", maxItems = 2 }` y `:74-82` registra `class = "stackable", category = "plates", material = "Ceramic IV"`. `corpus_cargo_items.lua:386` hace `error()` si `spec.filter` no tiene la forma `"category:a,b"` — un filtro por clase es **estructuralmente imposible** (CRG-8). No existe el valor `"placa"` en ningún Lua de las siete raíces.

**Salvedad registrada:** un verificador leyó «stackeable de clase "placa"» como uso vernáculo («de tipo placa»), ya que el valor de `class` está en la propia frase. Se mantiene el hallazgo porque «clase» es término **definido** en el mismo doc (§3, L75) como enum de dos valores.

**Parche PROPUESTO — `Cargo_Architecture.md:141`:**

> - **Body → slots de placa**: 0–N slots según la armadura, cada uno acepta un ítem de `class = "stackable"` y **categoría `plates`** (el filtro del sub-slot es `"category:plates"`, como todo sub-slot — CRG-8) con campo `material` (tabla de materiales Caliber), y con **desgaste propio por unidad** si su def declara `has_condition`: la condición viaja con la unidad al montarla y arranca en 100 si venía de fábrica (`corpus_cargo_inventory.lua`, `SubSlotAttach`). El eje es la CATEGORÍA, no la clase (§3).

---

#### 2.14 — El roadmap #30 declara CERRADO un dedup que la entry #27 reemplazó
**Tema:** inventario · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/docs/cargo_roadmap.txt:370-379` (#30, CERRADO) — el spawnmenu marca el give como deliberate y «el dedup avisa **"You already have one."**». |
| **B** | `cargo_roadmap.txt:122-127` (#15) + CHANGELOG #27 — «la segunda arma de una clase ya poseída **YA NO se absorbe**… el dedup quedó acotado al give ANÓNIMO». |

**Evidencia (nivel 1):** `corpus_cargo_capture.lua:544-548` — `Decide(equippedCount, hasItem, deliberate)`: `if hasItem and not deliberate then return "remove" end / return "capture"`. Comentario `:541-543`: *"an ANONYMOUS give of a class already owned is dropped; a DELIBERATE one (WALK+USE take, **spawnmenu click**, a dropped Cargo instance) captures — you can carry N identical guns"*. El spawnmenu **es** deliberate: `:686-689` (`hook.Add("PlayerGiveSWEP", …)`) y `:740-743` (consumo de la marca). Cierre del handler `:793-795`: *"'remove' now only reaches ANONYMOUS gives … Nothing to say about it"*.
**La cadena `"You already have one."` NO existe en ningún `.lua`** de las siete raíces: solo en `CHANGELOG.md:1341` (relato de la entry #14, historia) y en el bloque auditado del roadmap.
**Nivel 2:** `cargo_estado.md:96-99` — «se pueden tomar N armas iguales — el dedup quedó acotado al give anónimo».

**El #30 no tiene cross-ref a la #27**: la única mención de la derogación vive 250 líneas antes, bajo el frente #15. Quien lee el #30 no recibe ninguna señal de estar leyendo historia.

**Parche PROPUESTO — `cargo_roadmap.txt:370-374`,** dejando intacta la bitácora del diagnóstico (`:375-379`):

> 30. SPAWNMENU: EL ÍCONO DE ARMA NO LLEGA AL INVENTARIO [Cargo capture].
>     [CERRADO — CHANGELOG #14, APLICADO 2026-07-13: el hook `PlayerGiveSWEP` marca el give del spawnmenu como deliberate (ventana 1 s), así que el arma clickeada llega al inventario.
>     **ENMENDADO — CHANGELOG #27 (pedido del autor 2026-07-14):** al ser DELIBERADO, el click del spawnmenu sobre una clase ya poseída **CAPTURA la N-ésima copia** (cada arma es su propia instancia; el comercio ya las vendía por separado). El dedup quedó acotado al give ANÓNIMO — ver `Capture.Decide` en `server/corpus_cargo_capture.lua:544`. El aviso "You already have one." **ya no existe en el código**: es historia, ver #15.]

**Deuda colateral detectada (decide el autor):** CHANGELOG #27 sigue `[PENDIENTE]` («En juego: pendiente», `CHANGELOG.md:2284`; harness offline 355 verdes) mientras su código está en el árbol y `cargo_estado.md` ya lo da por estado de HOY. O falta la pasada en juego, o falta el flip a `[APLICADO]`.

---

#### 2.15 — §7.8 enuncia a mano un conteo de docs que la norma de la línea de arriba prohíbe enunciar a mano
**Tema:** evidencia · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus/docs/corpus_flujo_trabajo.txt:580-581` — «El de acá **audita 4 docs y ~1.188 líneas**». |
| **B** | `corpus_flujo_trabajo.txt:545-553` — la lista se deriva del árbol (**FLU-27**) y «nunca se enuncia acá: un número escrito a mano se desincroniza del script». |

**Evidencia (nivel 1 — el árbol):** `.claude/workflows/auditoria-coherencia-docs.js:171` — `const CORPUS_PILOTO = CORPUS_COMPLETO.filter(d => d.repo === 'corpus')`, que resuelve a **cinco** entradas (`:132-136`): `CLAUDE.md` + `corpus_flujo_trabajo.txt` + `CORPUS_Architecture.md` + `corpus_convenciones_commits.txt` + `corpus_roadmap.txt` = 1.358 según la tabla, **1.393 por `wc -l` real** hoy.
**Origen del número muerto:** `docs/auditorias/2026-07-16_…PILOTO.md:803` y `README.md:67` — medición legítima de aquel día, cuando el piloto aún no incluía `CLAUDE.md` (1.188 = 611+339+138+100). El acta v3 (`2026-07-16c…:399`) ya corrigió a «5 docs» y arrastró el conteo de líneas. **§7.8 nunca se enteró de ninguna de las dos cosas.**
**Nivel 3:** `CHANGELOG.md:430-434`, PARCHE 5(a) **[APLICADO 2026-07-16]** — los `CLAUDE.md` pasan a ser «sujetos obligatorios en todo modo». Ese parche es lo que subió el SCOPED de 4 a 5, en la MISMA sesión que midió el costo.

**Matiz de encuadre:** el choque **no** es incompatibilidad mutua estricta — B tiene por objeto la LISTA del COMPLETO y A enuncia un COSTO empírico medido. Sobrevive por el criterio (b): A afirma en **presente** («audita 4 docs») un inventario vigente que el script ya resolvió distinto.

**Parche PROPUESTO — `corpus_flujo_trabajo.txt` §7.8** (ubicar por CONTENIDO: el párrafo que arranca «COSTO. El piloto de Kontrol…»):

> COSTO. Referencia de Kontrol: ~216 agentes / ~11M tokens / ~84 min para 3 docs. El SCOPED de acá se midió el 2026-07-16 en 41 agentes / 1,69M tokens / ~23 min — pero sobre el corpus de ESE día (4 docs), anterior al parche que sumó los `CLAUDE.md` como sujetos obligatorios en todo modo. **Cuántos docs entran HOY lo dice la tabla del script, no este párrafo**: mismo motivo que arriba (FLU-27). El costo se MIDE antes de la pasada completa y se anota en el acta de la corrida; no se estima, y **no se hereda de la corrida anterior**.

**Deliberadamente NO se reemplaza «4» por «5» ni «1.188» por «1.393»**: escribir el número nuevo es volver a cometer FLU-27 en el doc que la acuña. **NO tocar** `CHANGELOG.md:411-412` ni `auditorias/README.md:67` (encuadran las cifras como historia, y las actas son inmutables).
**Aviso lateral (bucket C potencial, pasada aparte):** la columna `total` de `CORPUS_COMPLETO` en el `.js` también quedó corta (declara 696/339/138/100/85 contra 702/356/139/109/87 reales).

---

#### 2.16 — `corpus-stalker` apunta como canónico un doc de commits cuya §3 lo excluye
**Tema:** proceso · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-stalker/CLAUDE.md:72-73` — «Convenciones: `../corpus/docs/corpus_convenciones_commits.txt`». |
| **B** | `corpus/docs/corpus_convenciones_commits.txt:8-13` (**GIT-6**) — cubre **SOLO** `corpus/`; enumera **cinco** repos hermanos que definen su propia tabla. `corpus-stalker` no figura. |

**Evidencia (nivel 1 — el árbol y el historial):**
- La tabla §3 del framework es: `registry, data, net, ui, ready, log, workspace, docs`. **No contiene `assets` ni `repo`.**
- `git log --all` de `corpus-stalker` — los tres únicos commits: `3d07674 docs(assets)`, `9224274 docs(docs)`, `920d0fb chore(repo)`. **Dos de tres usan alcances que no existen en esa §3.** El árbol ya ejecutó la norma y no siguió §3.
- `corpus-stalker/docs/` contiene solo `ASSETS.md` y `CHANGELOG.md`; no existe `stalker_convenciones_commits.txt`. Los cuatro módulos con código sí lo tienen.
- `grep -rn "stalker"` sobre los cinco `*_convenciones_commits.txt`: **cero ocurrencias**.

**Alcance real del choque (más angosto que lo alegado):** GIT-6 declara que las secciones **0/1/2/4/5 se copian igual** en todo repo hermano, así que Stalker citando el doc para el idioma (GIT-4) y los tipos (§2) es **legítimo**. La única sección incompatible es **§3**. El parche no debe romper la cita entera.

**Nota de cautela:** la evidencia decisoria es historial git + listado de `docs/`, no Lua. Bajo lectura estricta de §7.1 esto podría degradar a voto del autor. Se dictamina B porque los tres commits son la **ejecución real** de la norma en disputa.

**Parche PROPUESTO — dos sitios solidarios (mismo commit o ninguno):**

*(1) `corpus-stalker/CLAUDE.md:70-73`* — reemplazar la sección «## Idioma» por «## Idioma y commits»: hereda **§0/1/2/4/5** del framework, declara que **su §3 NO aplica**, y aloja su propia tabla de alcances (`assets`, `repo`, `docs`, `anomalias`, `artefactos`, `pda`, `detectores`, `npc`, `items`, `models`), señalando que los tres commits existentes ya son conformes y que la tabla se muda a `docs/stalker_convenciones_commits.txt` cuando el árbol crezca.

*(2) `corpus/docs/corpus_convenciones_commits.txt:8-13`* — GIT-6 pasa a decir que **la §3 es por repo** y que **las secciones 0/1/2/4/5 son del ecosistema**, con las **seis** raíces consumidoras (cinco módulos + `corpus-stalker`) definiendo su propia tabla; mientras un repo no tenga ese doc, su tabla vive en su `CLAUDE.md`, y **en ningún caso hereda la §3 del framework**.

*(3) índice, misma tanda por §7.4:* actualizar el `titulo` de GIT-6 en `ids.yaml:545` y el comentario de familia en `:506-509` (que hoy dice "cinco").

---

#### 2.17 — La semilla de Craving ubica el addon de contenido en `dev/`, que por regla es lo que no se versiona
**Tema:** assets-licencias · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-craving/docs/Craving_Block4_Semilla.md:138-143` — los assets ZONA viven en el «**addon opcional de `dev/`**». |
| **B** | `corpus/docs/CORPUS_Architecture.md:327,333` — `corpus-stalker` es la **séptima raíz**, repo git público MIT; `dev/` es lo que queda fuera de todo git y nunca se publica. |

**Evidencia (nivel 1):** existe `corpus-stalker/.git` con `origin https://github.com/Sepuldosky/corpus-stalker.git` y tres commits; **`dev/corpus_stalker` no existe** en disco. Comentario del propio Lua consumidor: `corpus_craving_assets.lua:2-4` — *"Los assets STALKER viven en el addon de contenido «Corpus S.T.A.L.K.E.R.» (**repo corpus-stalker/**, assets no versionados)"*.
**Nivel 3 (deroga explícitamente):** `corpus-craving/docs/CHANGELOG.md:177-179` — PARCHE 3 **[APLICADO 2026-07-14]**: «`Corpus S.T.A.L.K.E.R.` **deja de ser «addon de assets en `dev/`, no publicable»**: es la séptima raíz; lo que no se versiona son sus assets GSC, no el addon.»
**Nivel 2:** `craving_estado.md:26-27`. **Nivel 4:** `corpus-craving/CLAUDE.md:34` («los docs viejos que nombren esa ruta están desactualizados»).

**El repo hermano SÍ se enmendó en sitio:** `Craving_Architecture.md:168-173` lleva la «Enmienda 2026-07-14». La semilla es la única superficie que quedó con la ruta obsoleta — barrido incompleto del PARCHE 3.

**Salvedad registrada (un verificador votó falso positivo):** la semilla se autodeclara registro histórico y su `:142-143` delega el detalle a `Craving_Architecture.md` §5-§6, que ya trae la enmienda. Se mantiene el hallazgo porque enuncia la ruta **en presente** sin marca de obsolescencia.

**Parche PROPUESTO (mínimo, estilo del doc hermano) — agregar debajo de `:143`:**

> *Enmienda 2026-07-14: ese addon nació como `corpus_zona_assets` dentro de `dev/`, se renombró a `corpus_stalker` el 2026-07-13 y ese mismo día se promovió a **séptima raíz del workspace** (`corpus-stalker/`, git propio y público, assets GSC en `.gitignore`). La redacción de arriba quedó congelada en la ruta previa — ver `Craving_Architecture.md:168-173` y CHANGELOG PARCHE 3 [APLICADO 2026-07-14].*

---

#### 2.18 — El fix de brazos oscuros: el `CLAUDE.md` describe el intento que el código declara fallido
**Tema:** assets-licencias · **Bucket: A** · **Gana B**

| | |
|---|---|
| **A** | `corpus-cargo/CLAUDE.md:83` — fix vía «`SetLightingOriginEntity`→jugador en Deploy, suelto en Holster». |
| **B** | `corpus-cargo/lua/weapons/corpus_cargo_hands.lua:20-30` y `:383-414` — el 1.er intento **NO funcionó**; el fix vivo es `render.SuppressEngineLighting(true)` + caja de luz propia. |

**Evidencia (nivel 1):** header `:21-24` — *"The 1st attempt (SetLightingOriginEntity -> player, 2026-07-12) **did NOT work** … This attempt bypasses engine lighting entirely: PreDrawViewModel/PreDrawPlayerHands take the wheel with render.SuppressEngineLighting(true) + a lighting box we build ourselves … **CONFIRMED in-game 2026-07-12**"*. Implementación en `ApplyHandsLighting()`: `:387` (`render.GetLightColor(ply:EyePos())`), `:393`, `:394-395`, colgada de `PreDrawViewModel` `:398` y `PreDrawPlayerHands` `:408`, restaurada en los `Post` `:403/:413`.
**Grep sobre todo `corpus-cargo`: cero call sites de `SetLightingOriginEntity`** — la única ocurrencia en Lua es el comentario que lo declara fallido. Y `SWEP:Holster()` (`:363-365`) es solo `return true`: **el "suelto en Holster" no existe en ninguna forma**.
**Nivel 3:** `CHANGELOG.md:806-813` y `:863-866` (entry #9, **[APLICADO 2026-07-12]**) — enuncia los dos intentos y cierra: «El 1.er intento (`SetLightingOriginEntity`) había fallado y se revirtió. Entry cerrado.»
**Nivel 6 concordante:** `cargo_roadmap.txt:63-65`. El `CLAUDE.md` es el único doc del ecosistema que quedó describiendo el mecanismo muerto.

**Nota de encuadre:** el tema `assets-licencias` es impreciso — la mitad de créditos de la fila 83 (Apex Hands, Workshop 2792160770, `.mdl` sin recompilar) es **correcta** y no se toca. El defecto se limita a la cláusula del fix de render.

**Parche PROPUESTO — `corpus-cargo/CLAUDE.md:83`,** reemplazo quirúrgico de una cláusula:

> …con fix de brazos oscuros (2.º intento, confirmado in-game 2026-07-12: `render.SuppressEngineLighting` + caja de luz propia muestreada en `EyePos` dentro de `PreDrawViewModel`/`PreDrawPlayerHands`, restaurada en los `Post`; el 1.er intento con `SetLightingOriginEntity` **falló y se revirtió** — CHANGELOG #9); assets propios salvo el .mdl…

Dejar nombrado el intento fallido **marcado como fallido** es más seguro que borrarlo: vacuna contra la "restauración".

---

### GRAVEDAD BAJA

---

#### 2.19 — CORPUS_Architecture §7 enumera los principios de dominio de ADS sin el escudo
**Tema:** dano-limbs · **Bucket: A** · **Gana B**

**A:** `corpus/docs/CORPUS_Architecture.md:290` — «(EFT gana la jerarquía del extractor, resolver puro, armadura como pre-filtro delante de limbs) se preservaron **intactos**» — tres.
**B:** `corpus-caliber/CLAUDE.md:11` (**CAL-18**) + `Caliber_Architecture.md:33` (**CAL-13**) — **cuatro**, con el escudo como pre-filtro delante de la armadura.

**Evidencia (nivel 1):** `corpus-caliber/lua/corpus_caliber/server/corpus_caliber_core.lua:824` — *"ESCUDO: pre-filtro global delante de la armadura"*; orden de ejecución dentro de `ScaleNPCDamage`: escudo (`:831`) → armadura (`:862`) → limbs (`:956`), con corte del pipeline en `:854` si el escudo absorbe.
**Nivel 3:** `corpus-caliber/docs/CHANGELOG.md:344-346` **[APLICADO 2026-07-19]** — «**D-4 cerrada.** `Caliber_Architecture.md` §1 enuncia la cadena completa (Hit → escudo → armadura → limbs) citando CAL-13 — el escudo ya no falta en los principios de dominio.»

**Por qué no es «distinto nivel de detalle»:** el propio ecosistema ya juzgó esta omisión como **defecto** al registrarla como deuda **D-4**. PARCHE 1 la cerró en el repo de Caliber y **no alcanzó la copia gemela en el framework**.

**Salvedad registrada:** un verificador argumentó que §7 es resumen declarado («El detalle vive en `Caliber_Architecture.md`») y que cargar la cadena completa roza COR-1/COR-10. Se desestima: la frase dice «se preservaron intactos», lenguaje de conjunto completo.

**Parche PROPUESTO — `CORPUS_Architecture.md:290`,** copiando literal la redacción ya ratificada en la sede para que las gemelas queden paralelas:

> Los principios de dominio ya fijados en ADS (EFT gana la jerarquía del extractor, resolver puro, y la cadena completa del pipeline: **escudo como pre-filtro delante de la armadura — CAL-13 —, armadura delante de limbs**: Hit → escudo → armadura → limbs) se preservaron **intactos** — son de Caliber, no artefactos de nombre.

**Residuo del mismo parche (índice):** `corpus/docs/ids.yaml:658` mantiene en CAL-13 la nota «Caliber_Architecture.md §1 enuncia la cadena SIN el escudo … Drift vivo (ver deuda D-4)», que hoy **contradice** el «CERRADA 2026-07-19» de `:1722`.

---

#### 2.20 — Caliber atribuye a Cortex el primer consumo de `Corpus.OnReady`, que ya pagó Cargo
**Tema:** boot-carga · **Bucket: A** · **Gana B**

**A:** `corpus-caliber/docs/Caliber_Architecture.md:184` — «Primer consumo real: **Block de Cortex**, para wiring de soft-dep».
**B:** el Lua — Cargo (Block 1), Coagulant (Block 3) y Craving (Block 4) ya lo consumen en producción.

**Evidencia:** `corpus_cargo_arc9.lua:134` (`Corpus.OnReady` + `if ARC9 == nil then … return end` — detección de soft-dep de manual), `corpus_cargo_ammopool.lua:450`, `corpus_cargo_theme.lua:409`, `corpus_cargo_dev.lua:357`, `corpus_coagulant_items.lua:32-37`, `corpus_coagulant_hud.lua:451-454`, `corpus_craving_items.lua:23`, `corpus_craving_bars.lua:10`. Las sondas de init ya lo exigen (`corpus_cargo_init.lua:107`, `coagulant:88`, `craving:65`).
**Cortex, el supuesto primer consumidor, no tiene una sola línea:** grep de `OnReady` sobre `corpus-cortex/` → cero (repo semilla).
**La primera mitad de A es correcta y no se objeta:** grep de `OnReady` sobre `corpus-caliber/` devuelve un único hit, el propio doc.

**Salvedad registrada:** un verificador leyó la celda como módulo-scoped (sujeto continuo = Caliber, «Caliber lo tomará en el Block de Cortex»). Se mantiene por la redacción absoluta «Primer consumo real».

**Parche PROPUESTO — `Caliber_Architecture.md:184`, cuarta columna de la fila «Ready barrier»:** reemplazar «Primer consumo real: Block de Cortex» por «El primer consumo real lo pagó **Cargo en el Block 1** (`[APLICADO 2026-07-10]`) y hoy lo usan también **Coagulant** y **Craving** (`[APLICADO 2026-07-13]`); Caliber lo tomará cuando deje de ser hoja en el grafo».

---

#### 2.21 — El roadmap de Cargo lista como pendientes cruces que Craving ya entregó y verificó
**Tema:** dominio-medico · **Bucket: A** · **Gana B (con acotación importante)**

**A:** `cargo_roadmap.txt:92` («CRUCES CON OTROS MÓDULOS — cada uno espera el Block del dueño») + `:102` («9. Craving: consumibles reales + barras hambre/hidratación») + `:97-101` (ítem 8, Coagulant).
**B:** `craving_estado.md:8-22` (Block 4 CERRADO, verificado en juego) y el Lua.

**Evidencia:** `corpus_craving_config.lua:79-128` (6 consumibles), `corpus_craving_items.lua:32-53` (`RegisterCategory("food")` + registro), `corpus_craving_bars.lua:18-31` (dos barras). Coagulant: `corpus_coagulant_items.lua:40-74` (4 defs `category = "medical"`, verificadas rondas 1-4).

**⚠ Acotación que corrige la acusación original — el ítem 8 NO está enteramente cerrado:**
- «ítems médicos reales» → **SÍ entregado y verificado** (rondas 1-4).
- «barras vital/sangre» → **EN CÓDIGO pero SIN verificar**: es slice 4 (`corpus_coagulant_hud.lua:458`), `CHANGELOG.md:582` **[PENDIENTE]**, esperando la ronda 7. Y **no existe barra «vital» separada**: Coagulant registra una sola, Blood.
- «drenaje de stamina por sobrepeso» → **pendiente REAL**: `corpus_coagulant_core.lua:97-103` solo hace `st.encumbrance = fraction or 0`, sin efecto.
- El encabezado de `:92` **sigue siendo literalmente cierto** para Coagulant: su Block 3 no cerró (`coagulant_estado.md:8-12`).

**Mover los ítems 8 y 9 enteros a «cruces cerrados» introduciría un error nuevo** (daría por cerrada una barra que no pasó el gate).

**Parche PROPUESTO — `cargo_roadmap.txt:98-102`** (dejar el encabezado `:92` como está, sigue valiendo para #7 Caliber, #8 Coagulant y #10 Cortex): reescribir el ítem 8 dejando como pendiente real **solo** el drenaje de stamina, con dos sub-viñetas («YA CERRADO: los ítems médicos reales» / «EN CÓDIGO SIN VERIFICAR: la barra de sangre, slice 4, ronda 7 — ojo: barra "vital" separada NO existe»), y marcar el ítem 9 como **CERRADO, sin pendientes**, con puntero a `craving_estado.md`.

---

#### 2.22 — Los círculos sandbox: el roadmap los ubica junto a los accesorios, la arquitectura junto al cinturón
**Tema:** ui-vgui · **Bucket: A** · **Gana B**

**A:** `cargo_roadmap.txt:236-239` — «entre los quickslots y los **ACCESORIOS**».
**B:** `Cargo_Architecture.md:444-448` — «entre los quick slots y el **CINTURÓN** de munición»; orden §15.2: (1) accesorios/cabeza, (2) fila alta, (3) fila baja, (4) quick slots, (5) círculos, (6) cinturón, (7) panel de estado.

**Evidencia (nivel 1):** `corpus_cargo_ui.lua` — `BuildEquipColumn` arranca con `{accessory1, head, accessory2}` en `y = PAD` (`:794-796`, **tope** de la columna), quick slots `:832-839`, `-- sandbox tool circles (#21)` `:842-857` inmediatamente después, cinturón `:878-894`. Comentario de cabecera `:780-782`: *"…top to bottom in the §15.2 order. Returns the y cursor after the quick row: the sandbox tool circles (#21) and the ammo belt (#19) stack there"*.
**Nivel 3:** `CHANGELOG.md:616` entry #8 **[APLICADO 2026-07-12]**, `:641-645`: «Centro (orden §15.2 exacto) … quick F1–F4 / círculos sandbox / cinturón / panel de estado al fondo».

**Salvedad registrada:** un verificador señaló que el bloque del roadmap que contiene el #21 está rotulado como «material de ENTRADA para la sesión de diseño» y cierra con «→ DISEÑADO en §15», delegando. Se mantiene porque nombra un vecino incompatible y el roadmap es de lectura frecuente.

**Parche PROPUESTO — `cargo_roadmap.txt:236-239`:** sustituir «entre los quickslots y los accesorios del equipamiento» por «entre los quick slots F1-F4 y el **cinturón de munición** (orden de §15.2)» y cerrar con «→ DISEÑADO en §15 y APLICADO (CHANGELOG #8, 2026-07-12)».

---

#### 2.23 — El frente #17 difiere a un «Bloque B» la persistencia del cargador que el #18 ya cerró
**Tema:** persistencia · **Bucket: A** · **Gana B**

**A:** `cargo_roadmap.txt:183-184` — «la persistencia del cargador en el BLOB del ítem para el grid **es del Bloque B**».
**B:** `cargo_roadmap.txt:165-166` + CHANGELOG #10 — «#18 → CERRADO: el cargador persiste en el blob vía `Inventory.StoreClip`».

**Evidencia (nivel 1):** `corpus_cargo_inventory.lua:481-490` — `StoreClip(uid, wep)` escribe `blob.clip1` y persiste con `Instances.Save(uid)`; `:523-525` `RestoreClip`; llamada desde la ruta de equipar `:560`, y desde el drop `corpus_cargo_capture.lua:755` (*"harvest whatever is left in its magazine into the blob first (#18), so re-equipping from the grid does not hand back a free full clip"* — **el blob para el grid ya está implementado**). Header `:472-478`: *"Magazine persistence (roadmap #18 — prerequisite of #17)"*.
**Nivel 3:** `CHANGELOG.md:933-948` (entry #10, **[APLICADO 2026-07-12]**) — el mismo parche cerró ambos frentes.

**Salvedad registrada:** «Bloque B» **no** es un bloque futuro — `cargo_roadmap.txt:194` y `CHANGELOG.md:1058` lo dan CERRADO el mismo día (entry #11). El defecto residual es de **atribución de bloque** (la persistencia en blob aterrizó en el entry #10, no en el #11), no de vigencia. Eso baja el daño a casi nulo, pero la frase sigue diciendo «es del Bloque B» en presente.

**Parche PROPUESTO — `cargo_roadmap.txt:183-184`:** «El cargador viaja en el `Clip1` de la entidad mientras el arma está en el mundo, y se cosecha al blob de la instancia al recapturarla (persistencia a nivel entidad; **la del BLOB la cerró el #18 en la MISMA entry — CHANGELOG #10, [APLICADO 2026-07-12], vía `Inventory.StoreClip`/`RestoreClip`**).»

---

#### 2.24 — «Las otras **dos** normas duras» seguidas de una enumeración de **cuatro**
**Tema:** proceso · **Bucket: A** · **Gana B**

**A:** `corpus/CLAUDE.md:69` — «Las otras **dos** normas duras del framework tienen su sede en la arquitectura, no acá:».
**B:** `corpus/CLAUDE.md:70-73` — enumera COR-7, COR-8, COR-10 y COR-11.

**Evidencia:** es **una sola oración**: predicado único, dos puntos, y cuatro IDs colgando del mismo verbo (la segunda mitad lo elide). La enumeración es la correcta contra las sedes reales, cada una autodeclarada: `CORPUS_Architecture.md:118` (COR-7), `:120` (COR-8), `:122` (COR-10), `:66` (COR-11).
**Nivel 3:** `corpus/docs/CHANGELOG.md:245-250`, PARCHE 3 **[APLICADO 2026-07-16]** — los cuatro se acuñaron en la arquitectura **en el mismo parche**: nunca existió un estado en que solo dos tuvieran sede allí. **El «dos» nació mal.**
**Medición independiente previa:** `docs/auditorias/2026-07-16b…v2.md:41` ya contaba «4 (COR-7, COR-8, COR-10, COR-11)».

**Parche PROPUESTO — `corpus/CLAUDE.md:69`:** cambiar `dos` → `cuatro`. La enumeración no se toca.

**Caveat que requiere voto del autor (fuera del parche mínimo):** `ids.yaml:156-186` asigna **también** sede en `CORPUS_Architecture.md` §5 a COR-12, COR-13 y COR-14. Si el criterio es «toda norma COR-nn con sede en la arquitectura», el número honesto es **siete**. Si es «normas duras del framework mismo, excluyendo el contrato de ítems», «cuatro» es exacto y conviene explicitar el recorte.

**Guardia contra reincidencia (opcional):** esta clase de defecto —un número a mano que se desincroniza de la lista que cuantifica— es literalmente **FLU-27**, ya violada dos veces en este ecosistema. La alternativa que lo elimina: «Las normas duras **restantes** del framework tienen su sede en la arquitectura, no acá:».

---

### BUCKET B — VOTO DEL AUTOR (el código NO dirime)

---

#### 2.25 — ¿De quién es el GC del cadáver looteado? El mismo doc lo adjudica dos veces, a dos repos
**Tema:** inventario · **Bucket: B (VOTO DEL AUTOR)** · **Ganador: INDETERMINADO**

| | |
|---|---|
| **A** | `corpus-cargo/docs/Cargo_Trade_Arquitectura.md:249-252` (§9) — «QUÉ deja caer un NPC al morir y **CUÁNDO SE LIMPIA EL CADÁVER** es semántica de **Cortex/Caliber**». |
| **B** | `Cargo_Trade_Arquitectura.md:281` (§11) — «GC de cadáveres / instancias huérfanas \| Dueño futuro: **CARGO** \| … **cuándo se limpia un cadáver looteado**». |

**Doce líneas de distancia, mismo documento, mismo realm (server), misma pregunta.** La adjudicación de dueño es excluyente por construcción (COR-1/COR-10 existen para que un dominio tenga un solo dueño), y el flujo manda que el dueño se decida **en diseño**.

**Por qué NO se parcha — el código no puede dirimir:**
- `corpus-cortex/` contiene **solo** `LICENSE` y `README.md`: sin `lua/`, sin hook de muerte, sin loot table.
- Grep de `cadaver|corpse|ragdoll|loot|orphan|GC` sobre el `lua/` de las siete raíces: solo superficie no relacionada (`CARGO.UI.OpenLoot`, caché de íconos huérfanos, `HealOrphanDefs`). **No hay GC de ninguna clase.**
- Ninguna entrada `[APLICADO]` resolvió la propiedad. La más cercana, `CHANGELOG.md:1767` (entry #20, [APLICADO 2026-07-14]), la **difiere** explícitamente: «construir un segundo [primitivo] habría dejado al loot de cadáveres (Cortex, §9) eligiendo entre dos primitivos» — adjudica el primitivo, no el CUÁNDO.
- `cargo_roadmap.txt:122,130-131` y `cargo_estado.md:141` cubren solo el eje «instancias huérfanas», que **nadie disputa** (namespace propio de Cargo, CRG-43).

**Las dos posiciones, y de qué depende cada una:**

- **Si gana §9 (Cortex/Caliber son dueños del CUÁNDO):** el lifetime del cadáver como entidad es semántica de muerte de NPC, que es dominio de Cortex. Cargo solo **reacciona**: `corpus_cargo_containers.lua:69` ya lo hace — `ent:CallOnRemove("corpus_cargo_container", function() … end)` deregistra y derrama cuando el dueño de la entidad llama `ent:Remove()`. Bajo esta lectura, Cargo nunca decide cuándo se remueve una entidad ajena, y §11 estaría usando «cadáver» donde quiere decir «el inventario del cadáver».
- **Si gana §11 (Cargo es dueño):** el cadáver looteable **es** un contenedor, y **CRG-21** (`corpus-cargo/CLAUDE.md:100`, autoridad nivel 4) ya lo dice: «Contenedor, trader (y mañana el cadáver de Cortex) son el mismo primitivo: `Containers.Attach`». Si el cadáver es un contenedor de Cargo, su GC es parte del ciclo de vida del contenedor.

**Indicios de diseño (no arbitraje):** `Cargo_Trade_Arquitectura.md:280` —la fila inmediatamente anterior— acota la parte de Cortex a «**el contenido y la muerte**», lo que sugiere que §9 se excedió al reclamar el CUÁNDO. Y §9 no adjudica en firme: `:243-244` y `:251-252` dicen «Se declara ahora para diseñar §2 genérico, **se resuelve cuando el bloque dueño cierre**». `CORPUS_Architecture.md:132` da a Cortex solo «Táctica de combate NPC (peek) + afecto», sin lifetime de cadáver.

**Recomendación de ingeniería (no vinculante):** partir la pregunta en dos, porque son dos:
1. **«¿Cuándo desaparece el ragdoll?»** → de Cortex/Caliber. Es semántica de muerte.
2. **«¿Qué pasa con el inventario y los blobs `inst_<uid>` en ese instante?»** → de Cargo, y **ya está implementado** vía `CallOnRemove`.
Con ese corte, §9 y §11 dejan de chocar sin que nadie ceda dominio. El parche sería precisar el título de la fila §11 a «GC del **inventario** de cadáveres / instancias huérfanas» y su nota a «el CUÁNDO de la entidad lo dispara su dueño (§9); Cargo solo reacciona vía `CallOnRemove`». **Pero eso es una decisión de diseño, no una corrección de deriva: decide el autor.**

---

## 3. Patología del registro

### 3.1 — Divergencias yaml-vs-sede (1)

**GIT-6** — `sede: corpus/docs/corpus_convenciones_commits.txt (encabezado)`

| | |
|---|---|
| **Título en el yaml** | «**Cada repo** define su propia tabla de alcances en su `docs/<modulo>_convenciones_commits.txt`…» |
| **Lo que dice la sede** | NO dice «cada repo»: **enumera nominalmente cinco** — «Cada repo hermano (corpus-cortex, corpus-caliber, corpus-coagulant, corpus-craving, corpus-cargo)». |

`corpus-stalker`, séptima raíz con código y commits propios, queda **fuera** de la enumeración de la sede — y de hecho hoy no tiene ese doc. El yaml generaliza a un conjunto mayor que el que su sede enuncia. Por §7.1 el índice no litiga contra la sede: **el desactualizado es el yaml**.

**Nota para el curador:** es divergencia de **alcance de enumeración**, no de mecanismo — el mecanismo (copiar la estructura, cambiar solo §3) coincide exactamente. Es el mismo eje «cinco/seis/siete raíces» que obligó a reformular COR-6 el 2026-07-19. **Se resuelve junto con el hallazgo 2.16:** si se amplía la sede a las seis raíces consumidoras, el título del yaml pasa a ser correcto y la divergencia se cierra sola.

### 3.2 — Normativas sin ID: 844 (FLU-25)

Ochocientas cuarenta y cuatro afirmaciones normativas del corpus auditado **no citan ni definen un ID**. Es el hallazgo estructural más grande de la corrida, y explica por qué la deuda D-7 se declaró recortada y no cerrada.

Concentración observada en la muestra:
- **`corpus/docs/corpus_flujo_trabajo.txt`** aporta el grueso: prácticamente cada inciso del orden de ejecución, de la planilla y del barrido enuncia una obligación. Muchos **sí** tienen ID (`FLU-01`…`FLU-38`) pero la prosa que los rodea agrega obligaciones nuevas sin acuñar: p. ej. `:170-172` (contenido obligatorio de la Sección 0), `:234-243` (el checklist de validación contra el repo), `:248-249` (regla de deslinde planificador/ejecutor), `:255-261` (criterio de entrada al flujo y prohibición de bifurcar el doc por repo).
- **`corpus/docs/corpus_convenciones_commits.txt`**: la tabla §3 completa (`:80`, `:101-107`) y la obligatoriedad general (`:20-25`) son normativas sin ID propio, colgando de GIT-1..GIT-6.
- **`corpus/CLAUDE.md`**: `:3` (orden de lectura obligatorio), `:15-23` (jerarquía de docs), `:33` (assets de stalker no se versionan), `:35` (`dev/` fuera de git), `:37` (consulta obligatoria de `mods_workshop_mapa.md` y la distinción RECICLAR/COMPAT-RUNTIME).

**Consecuencia operativa:** una norma sin ID **va a derivar**, porque nada la ancla a una sede y el cruce no puede detectarla contradiciéndose. Y —peor— el gate no la ve: ver §5, hueco H1.

**Recomendación:** priorizar la acuñación por **riesgo de cruce**, no por volumen. Los candidatos que más rinden: (a) la tabla §3 de cada `*_convenciones_commits.txt` (un ID por tabla, ver H1); (b) la distinción RECICLAR/COMPAT-RUNTIME de `CLAUDE.md:37`, que es transversal a los seis repos consumidores y hoy es la única norma de licencias del ecosistema sin ancla; (c) los incisos del checklist de validación de §5 del flujo.

---

## 4. Ambigüedades de alcance (197)

Ciento noventa y siete afirmaciones **no declaran alcance** en al menos uno de los cuatro ejes (REALM / MÓDULO / SOFT-DEP / BLOCK). No son contradicciones, pero son **el sustrato del que salen**: casi todos los hallazgos de esta corrida nacieron de una afirmación cuyo alcance había que reconstruir a mano.

Patrones dominantes en la muestra:

1. **REALM no declarado en normas que sí lo tienen.** El caso más caro es `corpus_convenciones_commits.txt:83-99`: los alcances `registry`/`data`/`net`/`ready`/`log` son shared y `ui` es client-only, pero el doc no lo dice — hay que ir al árbol (`lua/autorun/client/corpus_ui.lua`) para saberlo.
2. **BLOCK/SLICE no declarado en afirmaciones sobre estado.** `corpus/CLAUDE.md:41` («las 6 primitivas están implementadas») y `corpus_roadmap.txt:39-43` (Caliber Block 3) no fechan ni versionan la afirmación. Es exactamente el vector de los hallazgos 2.20 y 2.21: una foto correcta en su día que nadie marcó como foto.
3. **SOFT-DEP mezclado con hard-dep en la misma frase.** `CORPUS_Architecture.md:64` describe los dos edges de Cargo sin separar «vivo en ambos extremos» (Coagulant) de «anticipatorio» (Cortex) en la misma línea — la ambigüedad que 2.1 y 2.7 convirtieron en contradicción.
4. **MÓDULO implícito en docs del framework.** Los docs de `corpus/` hablan a veces del framework y a veces del ecosistema entero sin marcarlo (`CLAUDE.md:31-37`, `corpus_flujo_trabajo.txt:8-12`).

**Recomendación de bajo costo:** al acuñar un ID nuevo (FLU-25), exigir que la línea declare **realm** y **módulo** aunque parezcan obvios. Los otros dos ejes (soft-dep, block) solo cuando apliquen. Es una línea más por norma y elimina la mayor parte de los falsos positivos que este gate tiene que descartar a mano en cada corrida.

---

## 5. Huecos de esta auditoría — qué NO quedó cubierto

**La lista de COBERTURA PERDIDA está VACÍA: ningún agente murió, ningún tramo quedó sin auditar por caída. Esta acta NO está degradada por ese motivo.**

Pero hay huecos reales, y el más grande es de ceguera, no de caída.

### H1 (BLOQUEANTE para la lectura del resultado) — **10 de los 29 docs auditados no declaran NI UN SOLO ID. Sobre esos 10 docs este gate es CIEGO, y su «limpio» significa «NO AUDITADO», no «sano».**

Son **1.828 líneas — el 35% del corpus por volumen** — sobre las que un gate que cruza IDs no tiene absolutamente nada con qué cruzar. Derivado del árbol (`grep -oE '\b(COR|FLU|CRG|CAL|COA|CRV|STK|GIT|AUD)-[0-9]+'`), no estimado:

| doc | líneas | IDs |
|---|---:|---:|
| `corpus-cargo/docs/cargo_roadmap.txt` | 546 | **0** |
| `corpus-craving/docs/Craving_Block4_Semilla.md` | 240 | **0** |
| `corpus-cargo/docs/Workbench_Arquitectura.md` | 185 | **0** |
| `corpus-cargo/docs/cargo_convenciones_commits.txt` | 180 | **0** |
| `corpus-coagulant/docs/coagulant_convenciones_commits.txt` | 165 | **0** |
| `corpus-craving/docs/craving_convenciones_commits.txt` | 153 | **0** |
| `corpus-caliber/docs/caliber_convenciones_commits.txt` | 142 | **0** |
| `corpus-caliber/docs/caliber_roadmap.txt` | 94 | **0** |
| `corpus-craving/docs/craving_roadmap.txt` | 68 | **0** |
| `corpus-coagulant/docs/coagulant_roadmap.txt` | 55 | **0** |

Al borde: `corpus/docs/corpus_roadmap.txt` (2), `Coagulant_Block3_Semilla.md` (2), `corpus-stalker/docs/ASSETS.md` (3).

**Tres agravantes concretos:**

1. **`Workbench_Arquitectura.md` — 185 líneas de diseño de un subsistema entero — produjo CERO hallazgos y es sede de CERO IDs.** No está sano: **está invisible.** Un doc de arquitectura particular sin un solo ID acuñado viola FLU-25 de punta a punta.
2. **Los cuatro `*_convenciones_commits.txt` de módulo entraron a la lista *precisamente* por el hallazgo (c) del acta v3 — y los cuatro tienen cero IDs.** Se corrigió la invisibilidad de «no está en la lista» y quedó intacta la de «está en la lista pero el gate es ciego a él». Es la lección 10.8 de Kontrol por la segunda puerta. El único hallazgo que los roza (2.16) salió del doc del **framework**, no de ellos.
3. **`cargo_roadmap.txt` es sede declarada de CRG-45 en `ids.yaml` — y el archivo no contiene la cadena «CRG-45» en ninguna parte.** Sede rota que el gate LLM no vio (y que además pone un `INVARIANTE` a vivir en un doc de nivel 6, «intención, no autoridad»). Cuatro de los 26 hallazgos salieron igual de `cargo_roadmap.txt`, pero **por lectura de prosa, no por cruce de IDs**: fue suerte del lector, no cobertura del gate.

**Antes del próximo COMPLETO:** una pasada de acuñación sobre esos 10 docs. Mínimo: un ID por tabla de alcances en los cuatro convenciones; la familia `CRG-` en Workbench; etiquetar en los roadmaps los frentes CERRADOS que ya son normativos.

### H2 (ALTA) — 15 IDs tienen su SEDE fuera del corpus auditado; 4 de ellos en docs excluidos por diseño

El gate declara `estado.md`, `CHANGELOG` y el Lua como «árbitros, no auditados» (niveles 1-3). Pero `ids.yaml` los usa como **sede** de normas vivas: `FLU-15` → `corpus_estado.md`; `CRG-42` → `cargo_estado.md`; **`COA-6` y `COA-17` → `corpus-coagulant/docs/CHANGELOG.md`**; más 11 con sede en `.lua`.

Consecuencia: la definición canónica de esas normas **nunca se contrasta contra sus citas**. Un doc auditado puede citar `COA-6` diciendo cualquier cosa y el cruce no tiene con qué comparar. Es el modo de falla que el gate existe para atrapar.
Además, **un `INVARIANTE` cuya sede es un CHANGELOG contradice FLU-14**: el CHANGELOG es historial inmutable, no sede de norma vigente.

**Opciones:** admitirlos como *lectura de referencia* (no auditables, pero cargados para que el cruce pueda leer la sede), o migrar esas 4 sedes a un doc de diseño.

### H3 (ALTA) — El defecto del hallazgo 2.5 sobrevive en un tercer doc que nadie miró, y hay un harness que no existe

El hallazgo 2.5 confrontó Cargo contra Craving. **No reportó que `corpus-coagulant/CLAUDE.md:71` dice literalmente lo mismo que Cargo** («el script se reconstruye en el scratchpad de sesión»).

Y una capa más: `corpus-craving/CLAUDE.md:70` afirma «mismo patrón que verificó Corpus, Cargo **y Coagulant**», pero el árbol tiene **solo dos harnesses**: `dev/harness_cargo.py` y `dev/harness_craving.py`. **`harness_coagulant.py` NO existe.** Craving acredita como verificada por harness una capa de Coagulant que no tiene harness.

Importa porque `ids.yaml` usa `tipo: harness` como evidencia citable (FLU-31): **si algún `COA-nn` se acredita con harness, la evidencia apunta a un archivo inexistente.** Verificar `COA-2`, `COA-4`, `COA-5`, `COA-6`, que en el registro llevan `tipo: harness` («23 checks con Cargo REAL», «escalado del move data con penalización de peso previa», «igualdad de escalado entre realms», «el piso absoluto»).

**Causa raíz del fallo del cruce: empareja de a pares.** Cuando una afirmación está triplicada, encuentra un par, lo reporta y da el tema por cerrado. El tercero queda con la versión rota.

### H4 (ALTA) — Un tema salió con CERO contradicciones y NO está limpio: `realms`. Acá está el hallazgo que se le escapó

Dos de los 14 buckets salieron vacíos: `framework-delgado` (probablemente sí limpio: 3 hits, los tres concordantes) y **`realms`, que no lo está**.

> **`corpus-coagulant/docs/Coagulant_Architecture.md:126`** afirma: *«Cargo (movecompat) **re-aplica su propio multiplicador sobre walk/run cada tick de movimiento**»*.
> El Lua dice lo contrario: `corpus-cargo/lua/corpus_cargo/shared/corpus_cargo_movecompat.lua:57` hace `mv:SetMaxSpeed(math.max(mv:GetMaxSpeed() * scale, 30))` — **no toca walk/run**. Re-estampar `SetWalkSpeed`/`SetRunSpeed` cada tick es lo que hace el mod de terceros «better movement v2» (`sh_bm_main.lua:455-457`), y **CRG-12 existe precisamente para NO hacerlo** (`Cargo_Architecture.md:170-174`).

Gravedad media-baja (la conclusión operativa —componer multiplicativamente sobre `MaxSpeed`— es correcta y COA-4 está bien), pero el doc **atribuye a un peer un mecanismo que ese peer documentó como el antipatrón que evita**. Quien lea Coagulant §6 para escribir el tercer módulo que toque velocidad copiará el mecanismo equivocado.

**Por qué se escapó:** el bucket `realms` está descrito como «defs en ambos realms, predicción de Move, autoridad del server, espejo NW2» — todo eso se verificó y está sano (COR-12 correctamente citado en los 6 sitios). **Nadie cruzó cómo un módulo describe el mecanismo interno de otro módulo.** Ese eje no está en la taxonomía (ver H6).

**Tratar `realms` y `framework-delgado` como «sin hallazgos, cobertura no demostrada»** hasta que una corrida los ataque con consigna específica.

### H5 (MEDIA) — El inventario de docs: los dos huecos reales son docs INEXISTENTES

Lo excluido por diseño y **correctamente** (son árbitros): 5× `*_estado.md`, 6× `CHANGELOG.md`, 7× `README.md`, `docs/ids.yaml`, `docs/auditorias/*`, `corpus-cargo/docs/mockups/`.

- **`corpus-stalker` tiene solo `ASSETS.md` + `CHANGELOG.md`.** Sin arquitectura, sin roadmap, sin convenciones — y el hallazgo 2.16 ya demostró el costo. Tiene 6 IDs `STK-` acuñados, 5 con sede en su `CLAUDE.md`: **el `CLAUDE.md` está haciendo de arquitectura**, justo lo que §2 del flujo dice que no debe pasar.
- **`corpus-cortex` no tiene NADA** salvo `README` + `LICENSE`. La familia `CTX` está reservada con `pendiente: true` — eso está bien manejado. Pero **Cortex es el destinatario de al menos cinco contratos congelados por otros repos** (el cadáver looteable de 2.25, la facción del header de Cargo, las defs de NPC de `corpus-stalker`, `CALIBER.Limbs.*`, la loot table). **Nadie audita si esos cinco son mutuamente consistentes, porque el repo que los recibe no tiene un doc donde contradecirlos.** El hallazgo 2.25 es la punta de ese iceberg.

**Recomendación:** (a) abrir `corpus-stalker/docs/stalker_convenciones_commits.txt` + un `STALKER_Arquitectura.md` mínimo antes de que reciba más código; (b) crear un doc de **contratos entrantes de Cortex** (aunque el Block no esté abierto) que junte en un solo lugar las N firmas que otros repos ya le congelaron. Hoy están dispersas y el único cruce posible es fortuito.

### H6 (MEDIA) — Cuatro temas transversales que la taxonomía de 14 buckets no captura

Verificado por grep sobre los 29 docs. Ninguno tiene bucket propio, así que **sus contradicciones nunca se buscaron**:

1. **`compat-terceros` — el más grande.** ARC9 / VJ Base / better movement v2 / DarkRP aparecen en **25 archivos**. `assets-licencias` cubre el eje de *licencia* (RECICLAR vs COMPAT-RUNTIME), no el de *contrato de integración runtime*: qué API se lee, quién es dueño del hook, quién gana cuando dos mods escriben la misma propiedad. CRG-23, CRG-24, el puente ARC9, el movecompat y la deuda «Front 4 — doble mult de zona ARC9» de Caliber viven ahí, sin bucket. **El hallazgo de H4 es exactamente un hallazgo de este bucket ausente.**
2. **`ciclo-de-vida-del-jugador`** — muerte / respawn / disconnect / `PlayerSpawn`: **12 archivos**. Hoy se reparte entre `persistencia`, `dominio-medico` e `inventario`, **y por eso nadie lo cruza entero**. La decisión F de Coagulant («spawn = cuerpo nuevo, sin persistencia») contra la persistencia de stats de Craving contra el inventario persistido de Cargo es un triángulo que nadie miró.
3. **`config-y-balance`** — convars, tunables, dónde viven los números: **24 archivos**. CRV-12 («balance = data») es norma dura sin bucket. El propio yaml anota en CRG-38 que el número 2.0 «solo vive en el código y en `cargo_estado.md`» — un hueco de sede que un bucket de balance habría barrido sistemáticamente.
4. **`rendimiento`** — `Think`/timers/presupuesto de red: 7 archivos. CRV-6 («un solo timer») es normativo y no tiene con qué cruzarse.

**Subir la taxonomía a 18 buckets.** `compat-terceros` y `ciclo-de-vida-del-jugador` primero: ambos son fronteras entre repos, que es donde este gate rinde.

### H7 (MEDIA) — Los `CLAUDE.md` sí entraron, pero el eje «contrato vs. árbol» quedó sin barrer

Los seis `CLAUDE.md` están en `CORPUS_COMPLETO` y **13 de los 26 hallazgos tocan uno**. Ese arreglo funcionó.

Lo que **no** se hizo es la pasada contrato-por-contrato contra el árbol. De los 53 contratos numerados de los cinco `CLAUDE.md` de módulo, produjeron hallazgo: Cargo #4, Cargo #8 (parcial), Coagulant #5, Craving #6 (CRV-7), Stalker (idioma/commits). **Quedaron sin verificar contra el Lua**, entre otros: Cargo #3 (¿*todos* los sub-slots pasan por `DeclareSubSlot`?), Cargo #12 (`Capture.WeaponTrivia` como excepción y no ruta normal), Cargo #13 (las tres validaciones de `Confirm`), Coagulant #6 (`Config.SILHOUETTE` como tabla única de pintado y clic), Coagulant #7 (contar las dos clases client-side), Craving #7 (CRV-12), Craving #8 (CRV-6, un solo timer), Caliber #7 (superficie pública mínima).

Un `CLAUDE.md` es **nivel 4**: cuando choca con el Lua, el que está mal es el `CLAUDE.md` — y es el doc que todo ejecutor lee primero. Los tres hallazgos que salieron por esa vía (2.3, 2.4, 2.18) fueron **los más accionables de toda la corrida**. Es una veta rica explotada de casualidad.

**Agregar una fase explícita al workflow: «contrato-vs-árbol»**, un agente por `CLAUDE.md`, que tome cada contrato numerado y busque su implementación en el Lua. No es doc-vs-doc, así que ninguna fase actual lo cubre.

### H8 (BAJA, pero fácil) — El `.js` del gate es prosa normativa no auditada, y ya sabemos que miente

El hallazgo 2.6 pescó de rebote que `.claude/workflows/auditoria-coherencia-docs.js:167-170` arrastra la premisa caduca de D-7. **Ese archivo no está en `CORPUS_COMPLETO`.** Pero contiene: la jerarquía de autoridad completa (duplicando §7.1), la lista de falsos positivos, la taxonomía de 14 buckets, y **conteos de líneas derivados a mano que FLU-27 prohíbe enunciar** — ya demostrados desincronizados (hallazgo 2.15, y la columna `total` corta en 5 de 5 filas del tramo corpus).

Lo mismo aplica a `.claude/check-ids/corpus_check_ids.ps1` y `.githooks/pre-commit`, que encodean normas de FLU-27/§7.7 sin que nadie los cruce contra la prosa.

**Recomendación:** que el `.js` **deje de duplicar** la jerarquía y la cite por ID (sede §7.1), en vez de meterlo al corpus. Es prosa duplicada, y este gate existe porque la prosa duplicada se desincroniza.

### H9 — Nota de método: los dos patrones de falla del cruce

1. **Empareja de a pares** (H3). Encuentra un par, lo reporta, cierra el tema. El tercer doc queda roto.
2. **No mira cómo un módulo describe el mecanismo interno de otro** (H4). Los buckets están organizados por *dominio*, y esa clase de afirmación cae entre dos dominios por construcción.

**Un «limpio» de este gate hoy significa: «ningún par de docs con IDs se contradijo dentro de los 14 dominios». No significa que los docs sean coherentes.**

---

## 6. Qué NO se auditó, y por qué

Alcance declarado de este gate, para que nadie lea de más en el resultado:

1. **Doc-vs-código NO está en el alcance.** El Lua se usó como **árbitro** (nivel 1 de §7.1) para decidir quién gana un choque doc-vs-doc, nunca como sujeto auditado. **Esta acta NO afirma que nada esté implementado ni que nada funcione.** Que un doc gane una adjudicación no dice nada sobre la calidad de su implementación.

2. **«Esto no está implementado todavía» NO es un hallazgo, y ninguno de los 26 lo es.** El ecosistema diseña por delante del código a propósito. Se rechazaron sistemáticamente: diferencias de nivel de detalle, dos docs diciendo lo mismo con otras palabras, degradación honesta por soft-dep (COR-11), y MOCK-FIRST (FLU-17) — incluida la deuda D-5 (`ApplyExternalCondition` congelada por Craving antes de que Coagulant la ratifique), que **no se reporta**. El hallazgo 2.12 sobre esa misma función **no** es D-5: es que los dos repos escriben la firma con dominios de valores distintos.

3. **Huérfanos, bicéfalos y sedes rotas no son de este gate.** Los prueba el checker determinista (`.claude/check-ids/`), que corre en cada commit. La única excepción registrada acá es la sede rota de CRG-45 (§5, H1), y se anota como evidencia de la ceguera del gate, no como hallazgo propio.

4. **Los docs excluidos del corpus son árbitros, no olvidos.** `<modulo>_estado.md` (nivel 2), `CHANGELOG.md` (nivel 3) y `README.md` quedaron fuera por diseño. Ver §5 H2: esa exclusión tiene un costo — 4 IDs vivos tienen su sede en un doc excluido, y su definición canónica nunca se contrasta.

5. **`dev/` está fuera de las siete raíces** y fuera del alcance de todo parche. Se citó como evidencia (los harness, `mods_workshop_mapa.md`, `HANDOFF_coagulant_slice4.md`), nunca como sujeto parchable.

6. **Ningún parche fue aplicado.** Modo READ-ONLY estricto: el único archivo escrito en todo el universo es esta acta. Los 25 parches del bucket A están redactados y listos; el bucket B (2.25) espera voto del autor; no hay bucket C ni CADUCO.

---

## 7. Cierre

**Recuento operativo para el autor:**

- **25 parches PROPUESTOS**, todos con ganador decidido por el árbol, el estado o el CHANGELOG. Ninguno requiere decisión de diseño.
- **1 voto abierto** (2.25, dueño del GC del cadáver), con las dos posiciones y una recomendación de corte.
- **3 parches se agrupan en una sola edición**: 2.1, 2.7 y la tercera ancla de 2.11 son todos `Cargo_Architecture.md:7`.
- **2 hallazgos comparten sede**: 2.10 consolida los dos pares confirmados sobre la cola causal de COR-6.
- **4 correcciones de índice** en `ids.yaml` (COR-6, CRV-7, CRG «nunca veta», CAL-13/D-4) que siguen a su sede.
- **3 entradas nuevas de CHANGELOG** que NO deben reescribir historia (FLU-14): la reformulación de COR-6 + la cita muerta «§11», el flip pendiente de la entry #27 de Cargo, y el barrido del `README.md` de Craving.
- **2 deudas de verificación detectadas al pasar** (decide el autor): entry #27 de Cargo `[PENDIENTE]` con código en el árbol y estado que ya lo da por vigente; slice 4 de Coagulant `[PENDIENTE]` esperando ronda 7.
- **1 harness inexistente** que respalda acreditaciones vivas (`harness_coagulant.py`, §5 H3) — verificar antes de tocar `corpus-coagulant/CLAUDE.md:71`.

**Y la advertencia que encabeza la §5, repetida acá porque es lo que más cambia cómo se lee este documento:** diez de los veintinueve docs auditados no llevan un solo ID. Sobre ellos, este gate es ciego. Su ausencia de hallazgos **no es salud: es ausencia de auditoría.**

---

*Acta cerrada 2026-07-19. Inmutable. Los parches se proponen; el autor dispone.*
