# Corpus — Documento de Arquitectura

> **Uso de este documento:** Referencia autocontenida para sesiones futuras de planificación (Claude Opus) e implementación (Claude Code). Cada sección es independiente. No se requiere el chat de diseño original.
>
> **Estado:** Block 1 (framework) cerrado y bajado a código; los Blocks 2-4 ya se ejecutaron en los repos de módulo (ver §9). Cubre el framework Corpus, el grafo de dependencias entre módulos y el workspace de desarrollo. El diseño interno de cada módulo **no** vive acá: cada uno desprendió su **doc particular** autocontenido en su propio repo (`corpus-<modulo>/docs/<Modulo>_Architecture.md`), según el patrón doc general vs. particular que formaliza [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt) §2. Este documento conserva el resumen y el link (§9).
>
> **Estado vigente (foto de HOY, volátil)** → [`corpus_estado.md`](corpus_estado.md) — léelo antes que este documento. **Metodología de trabajo** → [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt). Índice operativo → [`../CLAUDE.md`](../CLAUDE.md).

---

## Índice

1. [Visión general](#1-visión-general)
2. [Grafo de dependencias](#2-grafo-de-dependencias)
3. [Superficie de Corpus — la API del framework](#3-superficie-de-corpus--la-api-del-framework)
4. [Fronteras de módulo](#4-fronteras-de-módulo)
5. [Contrato de ítems generalizado](#5-contrato-de-ítems-generalizado)
6. [Orden de carga y detección de dependencias](#6-orden-de-carga-y-detección-de-dependencias)
7. [Migración ADS → Caliber](#7-migración-ads--caliber)
8. [Workspace multi-root](#8-workspace-multi-root)
9. [Estado de este documento y próximos bloques](#9-estado-de-este-documento-y-próximos-bloques)

---

## 1. Visión general

**Corpus** es un framework para Garry's Mod que aloja un ecosistema de módulos de mejora realista/de gameplay para el Sandbox. Cada módulo es un addon Workshop independiente que declara a Corpus como dependencia; el usuario instala solo los módulos que quiere, o todos.

Analogía de referencia en el mismo stack: **VJ Base + SNPCs** y **ARC9 + weapon packs**. Base delgada, packs que la consumen. Corpus sigue el mismo patrón.

| Módulo | Dominio (una línea) |
|---|---|
| **Cortex** | IA/comportamiento de NPC: táctica de combate + afecto (dolor, miedo) |
| **Caliber** | Combate: armadura zonal, escudos de energía, HP de extremidades, penetración balística — NPC y jugador |
| **Coagulant** | Médico de jugador, estilo ACE3: heridas por zona, sangrado, vitales, tratamiento |
| **Craving** | Supervivencia de jugador: hambre e hidratación |
| **Cargo** | Inventario tipo EFT/STALKER: grid, framework de ítems, contenedores |

**Regla cardinal (COR-10):** Corpus es un framework **delgado**. Solo aloja infraestructura demostrablemente compartida: las **seis primitivas** de §3 (registro, persistencia, net, UI shell, ready barrier, log) — la lista canónica está ahí y en el `CLAUDE.md`, no acá. Ningún módulo sube lógica de dominio a Corpus — ni siquiera algo compartido por dos módulos, como el pool de HP de extremidades, que se queda en su dueño (Caliber) y se consume vía registro. Esa línea es lo que evita que Corpus se vuelva un god-object con el tiempo.

**Regla cardinal:** la única dependencia dura de todo el ecosistema es Corpus mismo. Todo lo demás — Caliber, Cargo, Coagulant, Craving, Cortex entre sí — es **soft-dependency**: se detecta en runtime, se enciende si el partner está, degrada honestamente si no.

---

## 2. Grafo de dependencias

```
Corpus  ← hard-dep de TODOS los módulos (se detecta, nunca se asume)
│
├─ Cortex     ─ soft→ Caliber (eventos de daño/limb, para dolor y miedo)
├─ Caliber    ─ hoja: sin deps hacia otros módulos
│
├─ Cargo      ─ soft→ Coagulant (encumbrance → stamina; contrato en producción)
│              soft→ Cortex    (facción/rango en el panel de estado; mock-first)
│              …y además es el HUB de consumo: Coagulant y Craving lo usan
│
├─ Coagulant  ─ soft→ Caliber (enriquece hit-location con datos de armadura/zona)
│              soft→ Cargo (ítems médicos: vendas, torniquetes)
│
└─ Craving    ─ soft→ Cargo (consumibles: comida, agua)
               soft→ Coagulant (inanición/deshidratación afectan salud, opcional)
```

**Cargo no es hoja** (lo fue en el diseño original, dejó de serlo al construirse): consume Coagulant para volcarle el encumbrance y Cortex para pintar la facción en su panel de estado. Los dos edges viven en el código con lazy-check + `pcall` y degradación honesta — el de Coagulant está vivo en ambos extremos, el de Cortex es anticipatorio (Cortex todavía no tiene código).

**COR-11 (ésta es su sede):** ningún módulo, salvo Corpus, es un requisito duro de otro. La única hard-dep del ecosistema es Corpus mismo; todo lo demás es soft-dep, se detecta en runtime vía `Corpus.GetModule`/`Corpus.HasModule` y nunca se asume (el mecanismo, en §6). Un usuario puede instalar solo Cargo (inventario sin combate ni supervivencia), solo Caliber (combate sin médico), o los cinco juntos. Cada combinación produce un sistema honesto, no una mitad rota.

### Tabla de resumen

| Módulo | Deps duras | Deps soft | Sin la dep soft, degrada a... |
|---|---|---|---|
| Cortex | Corpus | Caliber | comportamiento táctico sin reacción a daño por zona (dolor/miedo genérico) |
| Caliber | Corpus | — | — (no depende de nadie) |
| Cargo | Corpus | Coagulant, Cortex | sin línea de facción en el panel de estado; sin volcado de encumbrance — el penalty nativo de velocidad por peso es toda la consecuencia del sobrepeso |
| Coagulant | Corpus | Caliber, Cargo | hit-location por hitgroup crudo (nativo); tratamiento por world-entity o vía mínima propia |
| Craving | Corpus | Cargo, Coagulant | vía de mundo con entity propia (`corpus_craving_food`, gate WALK+USE); sin Coagulant, el daño por inanición/sed lo aplica Craving sobre el HP nativo y mata |

---

## 3. Superficie de Corpus — la API del framework

Seis primitivas. Nada de lógica de dominio.

| Primitiva | Contrato | Por qué vive en Corpus |
|---|---|---|
| **Registro** | `Corpus.RegisterModule(name, iface)` · `Corpus.HasModule(name) → bool` · `Corpus.GetModule(name) → iface \| nil` | Es el linchpin: sin esto no hay soft-deps ni namespacing |
| **Persistencia** | `Corpus.Data.Save(module, key, tbl)` · `Corpus.Data.Load(module, key) → tbl \| nil` | Los cinco módulos persisten estado; una sola convención de ruta evita colisiones |
| **Net** | `Corpus.Net.Register(module, msgName) → fullName` | El namespace de `net.Receive` es global en Gmod; cinco módulos sin convención chocan nombres |
| **UI shell** | `Corpus.UI.RegisterTab(module, label, buildFn)` | Reusa el patrón de layout manual (`DPanel`+`DLabel`+`DSlider`+`DTextEntry`) ya validado en ADS; una sección "Corpus" en vez de cinco menús Q sueltos |
| **Ready barrier** | `Corpus.OnReady(fn)` | Dispara tras `InitPostEntity` con todos los módulos presentes ya registrados — punto seguro para wiring de soft-deps |
| **Log** | `Corpus.Log(module, ...)` | Prefija `[Corpus:<module>]` — identifica el origen de un error sin adivinar |

### Firmas ilustrativas

```lua
-- Registro
function Corpus.RegisterModule(name, iface)   -- iface: tabla de funciones públicas del módulo
function Corpus.HasModule(name)               -- bool
function Corpus.GetModule(name)               -- iface o nil

-- Persistencia — ruta resultante: data/corpus/<module>/<key>.json
function Corpus.Data.Save(module, key, tbl)
function Corpus.Data.Load(module, key)        -- tbl o nil si no existe

-- Net — evita colisión de nombres entre AddNetworkString de distintos módulos
function Corpus.Net.Register(module, msgName) -- retorna "corpus_<module>_<msgName>"

-- UI shell — una entrada por módulo bajo una sola categoría Q
function Corpus.UI.RegisterTab(module, label, buildFn)

-- Ready barrier
function Corpus.OnReady(fn)                   -- fn corre una vez, tras InitPostEntity

-- Log
function Corpus.Log(module, ...)              -- print("[Corpus:"..module.."] ", ...)
```

> **COR-7 — Invariante del registro (contrato duro; ésta es su sede):** `Corpus.RegisterModule(name, iface)` y `Corpus.GetModule(name)` guardan y devuelven la **misma tabla por referencia** — sin deep-copy, sin normalización de ningún tipo. El patrón "tabla única poblada por side-effect" con el que los módulos construyen su namespace (ver `Caliber_Architecture.md` §3 y §11) depende de que sea así; un copy defensivo acá lo rompe en silencio. Es un contrato **distinto** al de **COR-8** (`Corpus.Data.Save/Load` sí normaliza en el round-trip JSON: `util.JSONToTable` puede devolver claves numéricas donde se guardaron strings) — no confundir ambos invariantes.

> **COR-8 — Normalización en el round-trip de `Corpus.Data` (ésta es su sede):** lo que sale de `Corpus.Data.Load` **no** es garantizadamente idéntico a lo que entró en `Save`: el viaje por JSON puede cambiar el tipo de las claves. Un módulo que persiste una tabla con claves string no debe asumir que las recupera como string. Es el contrario exacto de COR-7, y por eso conviven: el registro **no** toca la tabla; la persistencia **sí**.

**Lo que Corpus NO contiene (COR-10, la regla cardinal del framework delgado — ésta es su sede, junto con §4):** armor math, hitgroups, curvas de sangrado, curvas de hambre, grid de inventario. Si dos módulos comparten una pieza de dominio (limbs, por ejemplo), esa pieza no sube — se queda en su dueño y el otro la consulta por el registro (§4).

---

## 4. Fronteras de módulo

Detalle de diseño interno de cada módulo: fuera de alcance de este Block 1, aterriza en los bloques 2-4 (§9). Acá solo la frontera — qué posee, qué expone, qué consume.

| Módulo | Owns | Expone (interfaz pública) | Consume (soft) |
|---|---|---|---|
| **Cortex** | Táctica de combate NPC (peek) + afecto (dolor, miedo) | — | Caliber: eventos de daño/limb |
| **Caliber** | Armor zonal · shields · limbs · penetración · resolver puro + adapters NPC/player | `CALIBER.HealLimbs(npc, amount, target)` — lo único bajo contrato hoy. La `Limbs` API agnóstica (NPC o jugador) y los eventos de daño/limb son **alcance de su Block 3** (pipeline de jugador): el `hook.Run("Caliber_LimbsUpdated", npc, reason)` que ya existe es un aviso de refresh heredado de ADS, off-contract y sin consumidor *(precisión 2026-07-14, Block 2 — antes se listaba como si ya existiera)* | — |
| **Coagulant** | Heridas por zona (jugador) · sangrado · vitales · tratamiento, estilo ACE3 | `ApplyTreatment(ply, kind, zone)` · `ApplyBandage` · `GetBlood` · `IsBleeding` · `GetZoneScore` · `OnEncumbrance(ply, fraction)` (contrato congelado que Cargo ya invoca) · `Zones.*` + eventos (`Coagulant_WoundAdded`/`WoundClosed`/`BloodCritical`/`TreatmentStart`/`TreatmentComplete`/`TreatmentCancel`) + estado replicado por NW2 (`coagulant_blood`, `coagulant_speed_mult`) *(enmienda 2026-07-14, Block 3 — antes "eventos de estado clínico"; ver `corpus-coagulant/docs/Coagulant_Architecture.md` §8)* | Caliber (`Limbs`, hit-location enriquecido) · Cargo (ítems médicos) |
| **Craving** | Hambre · hidratación (jugador) | getters (`GetHunger`/`GetHydration`/`Restore`) + evento `Craving_StatCritical` *(enmienda 2026-07-13, Block 4 — antes "—"; ver `corpus-craving/docs/Craving_Architecture.md` §8)* | Cargo (consumibles) · Coagulant (efectos de salud, opcional) |
| **Cargo** | Grid de inventario · framework de definición de ítems · contenedores · peso · UI · economía · comercio | `Items.Register/DeclareSubSlot/Get/RegisterCategory` · `Inventory.GiveItem/TakeItem/CountItem/HasItem/GetEquipped` · `Money.RegisterProvider` + `Get/Add/Take/Format` · `Containers.Attach` · `Trade.AttachTrader/OpenFor` · `StatusPanel.RegisterBar` (client) · `Icons.Get/GetFootprint` (client) · el campo `def.value` como contrato de precio *(enmienda 2026-07-14 — antes solo `Items.Register` + query/consume; el contrato completo vive en el bloque CARGO PUBLIC CONTRACT de `corpus_cargo_init.lua`)* | Coagulant (`OnEncumbrance` — contrato congelado, en producción) · Cortex (`GetFactionInfo` — mock-first, su Block sigue pendiente) |

Nota sobre **Caliber**: internamente es *resolver puro + dos adapters* (hook NPC vía VJ/ARC9, hook jugador) — el mismo principio "resolver puro, hooking aparte" que ya rige ADS 1.x. La `Limbs API` que expone debe ser agnóstica a la entidad: Coagulant no debe saber ni importarle si la pierna sangrante es de un NPC o del jugador.

Nota sobre **Cargo**: es sobre todo un *hub de consumo* — Coagulant y Craving lo usan — pero **no es hoja**: consume Coagulant (`OnEncumbrance`, contrato congelado y ya implementado en ambos extremos) y Cortex (`GetFactionInfo`, mock-first a la espera de su Block), los dos con lazy-check + `pcall` y degradación honesta. Su frontera de *dominio* sigue siendo el framework de ítems, no la lógica de qué hace cada ítem (eso es de cada módulo dueño, ver §5); además provee panel de estado, economía, contenedores y comercio como **servicios de infraestructura** al resto del ecosistema.

---

## 5. Contrato de ítems generalizado

Patrón que hace real el "pick and choose" en la práctica: **cada módulo de dominio posee sus propias definiciones de ítem** (qué hace, callback de uso). Cargo, si está presente, provee el contenedor (storage, grid, UI). Si no está, el módulo cae a una vía mínima propia.

```lua
-- corpus_coagulant_items.lua — SHARED (ver la nota de realm abajo)
Corpus.OnReady(function()
    local cargo = Corpus.GetModule("cargo")   -- soft-dep: se detecta, no se asume (§6)
    if cargo == nil then
        Corpus.Log("coagulant", "Cargo no presente: ítems médicos apagados (degradación honesta)")
        return
    end

    cargo.Items.Register({
        id       = "corpus_coagulant_bandage",
        name     = "Bandage",
        weight   = 0.1,
        class    = "stackable",   -- OBLIGATORIO: "stackable" | "unique" (Register hace error() si falta)
        category = "medical",     -- decide la tab de la UI (default "misc")
        onUse    = function(ply)
            -- semántica: dominio de Coagulant, no de Cargo. Corre solo en server.
            Corpus.GetModule("coagulant").ApplyTreatment(ply, "bandage")
            return false          -- Cargo NO descuenta acá: se consume al COMPLETAR
        end,
    })
end)
```

- **Cargo owns**: cómo se define un ítem, cómo pesa, cómo se guarda, cómo se renderiza en la grilla.
- **Coagulant/Craving owns**: qué hace su ítem cuando se usa.
- **COR-12 — Realm: la def y el `onUse` se registran en AMBOS realms (shared).** El snapshot de Cargo solo transporta las defs `autogen`/`icon_override`, así que una def registrada solo en server no existe en el cliente y el grid no la renderiza; y la UI exige `isfunction(def.onUse)` client-side para habilitar «Use» y el quick bind — un `onUse` solo-server deja el ítem visible pero inusable. El `onUse` solo *corre* en server. Lección pagada en juego el 2026-07-13, por Craving y por Coagulant.
  **Por qué esta norma vive en el framework y no en Cargo** (voto del autor, 2026-07-20 — deuda D-14, cerrada): porque **no gobierna ítems**. Gobierna el **protocolo de registro entre módulos** —dónde se registra una def y desde qué realm es invocable su callback—, del mismo linaje que COR-3 (persistencia namespaced) y COR-4 (net namespaced): las tres nacieron para evitar colisión entre consumidores, y a ninguna se la llama dominio. Bajarla a Cargo la convertiría en **norma de un módulo sobre otros módulos**, que es justo lo que COR-11 evita.
  **El precio, que es parte del voto y no una glosa:** COR-12 enuncia solo la **FORMA** del contrato, **jamás la SEMÁNTICA** del ítem. El día que mencione stacks, peso o slots, bajó dominio al framework y **el voto se reabre**. Esa cláusula es lo que hace **falsable** la decisión — sin ella, «es protocolo y no dominio» sería inauditable. No contradice a COR-1 ni a COR-10: los **delimita**. Lo que no sube es la semántica.
- **COR-13 — El retorno de `onUse` gobierna el consumo:** Cargo descuenta una unidad solo si devuelve `true`. Devolver `false` habilita el consumo diferido (Coagulant descuenta al completar el tratamiento) y el rechazo (Craving no consume si la barra ya está llena).
- **Sin Cargo presente**: el módulo cae a interacción con world-entity — esa *es* la vía de uso mínima propia sin inventario real. Craving ship su propia entity (`corpus_craving_food`, una sola clase; el def concreto viaja en el keyvalue `craving_item`): con Cargo, `E` (WALK+USE) la manda al inventario; sin Cargo, `E` la consume in situ. Lo que cae a candidatos CS:S/HL2 son los *modelos y sonidos* cuando el addon de assets de la Zona no está montado, no la entity.

**COR-14 —** Ningún módulo de dominio **necesita** Cargo para funcionar: solo lo aprovecha si está.

---

## 6. Orden de carga y detección de dependencias

Gmod no garantiza orden de mount entre addons (server owners separan `.gma`, FastDL, orden de suscripción Workshop). Regla dura: **ningún módulo asume que Corpus, u otro módulo, ya cargó.** Se detecta en runtime.

### Init — hard-dep (Corpus): sonda + boot diferido

El init es el **único** archivo del módulo en `lua/autorun/` (**shared**, no `autorun/server`), y lleva el manifest de carga explícito; el resto vive en `lua/corpus_<modulo>/<realm>/` y entra por `include()`.

La trampa está en el orden: Gmod fusiona `lua/autorun/` de **todos** los addons y lo ejecuta en orden alfabético del nombre de archivo. `corpus_caliber_init.lua` ordena **antes** que `corpus_data.lua` y `corpus_registry.lua`, así que en una carga de mapa normal **`Corpus` todavía no existe** cuando corre el init del módulo. Un `error()` en file-scope no protege de nada: lo único que consigue es que el módulo **no se registre nunca** — falla silenciosa de módulo, no crash del server.

De ahí el patrón real, verificado en juego y hoy template de los cuatro módulos con código: **sonda + boot diferido al hook `Initialize`** (corre en ambos realms después de todo `autorun` y antes de `InitPostEntity`, así que conserva las garantías: tabs de UI antes de `PopulateToolMenu`, net strings antes de que conecte un cliente).

```lua
-- corpus_caliber_init.lua — único archivo en lua/autorun/ (SHARED)

-- AddCSLuaFile NO depende de Corpus: corre siempre, aunque el boot quede diferido.
if SERVER then
    for _, f in ipairs(CLIENT_FILES) do AddCSLuaFile("corpus_caliber/" .. f) end
end

-- La sonda cubre TODAS las primitivas que los sub-archivos usan en file-scope,
-- no solo el registro.
local function CorpusListo()
    return Corpus ~= nil and Corpus.RegisterModule ~= nil and Corpus.Data ~= nil
        and Corpus.Net ~= nil and Corpus.Log ~= nil and (SERVER or Corpus.UI ~= nil)
end

local function Boot()
    Corpus.RegisterModule("caliber", {})   -- tabla VACÍA: se puebla by-ref (§3)
    for _, f in ipairs(MANIFEST) do include("corpus_caliber/" .. f) end
    Corpus.Log("caliber", "cargado (" .. (SERVER and "server" or "client") .. ")")
end

if CorpusListo() then
    Boot()                                  -- lua refresh / carga tardía: ya está
else
    hook.Add("Initialize", "corpus_caliber_boot", function()
        hook.Remove("Initialize", "corpus_caliber_boot")
        if CorpusListo() then
            Boot()
        else
            -- Falla RUIDOSA, no silenciosa. No se usa Corpus.Log: Corpus no existe.
            MsgN("[Caliber] Corpus framework no encontrado. Verificar que el addon corpus/ esté montado.")
        end
    end)
end
```

Dos detalles que el patrón exige y son fáciles de romper:

- **La iface se registra vacía y se puebla por side-effect.** `RegisterModule(name, {})` primero, `include()` después: cada sub-archivo cachea `local CALIBER = Corpus.GetModule("caliber")` y cuelga lo suyo de esa misma tabla. Esto se apoya en el **invariante by-ref** del registro (§3) — si Corpus copiara la tabla, el patrón se rompería en silencio. La interfaz **nunca** va inline en el `RegisterModule`.
- **`AddCSLuaFile` queda en file-scope**, fuera del `Boot()`: el cliente tiene que recibir los archivos aunque el boot se difiera.

### Uso — soft-dep (otro módulo)

Dos mecanismos, se combinan:

**a) Lazy check** (preferido para la mayoría de los casos) — se consulta en el momento del uso, no en init, porque el partner puede no haber cargado aún cuando este módulo inicializa:

```lua
-- dentro de Coagulant, al momento de resolver una herida
local caliber = Corpus.GetModule("caliber")
if caliber then
    -- enriquecer con datos de zona/armadura
else
    -- degradar: hit-location por hitgroup nativo crudo
end
```

**b) Ready barrier** — para wiring que debe correr una sola vez, después de que todos los módulos presentes ya se registraron:

```lua
Corpus.OnReady(function()
    -- ejemplo: cablear una integración fija entre dos módulos presentes
end)
```

**Regla derivada (COR-11):** el registro de Corpus (§3) cumple los dos roles a la vez — es el mecanismo de detección de presencia y la ruta de acceso al módulo: una sola llamada a `Corpus.GetModule` entrega el veredicto y la interfaz. Pero el acceso **nunca** se encadena sobre el resultado: `GetModule` devuelve `nil` cuando el módulo no está registrado (`lua/autorun/corpus_registry.lua`), así que indexar sin nil-check produce un error de Lua en vez de la degradación honesta que exige COR-11. La forma canónica es captura local + rama (el lazy check de arriba):

```lua
local cargo = Corpus.GetModule("cargo")
if cargo then
    cargo.Items.Register(...)
else
    -- degradar: sin Cargo, los ítems no se registran
end
```

Cuando solo se necesita una sub-tabla y `nil` es un valor de trabajo aceptable, la forma corta equivalente ya en producción (`corpus-coagulant/lua/corpus_coagulant/shared/corpus_coagulant_dev.lua`) es:

```lua
local cargoInv = Corpus.HasModule("cargo") and Corpus.GetModule("cargo").Inventory or nil
```

— acá el encadenamiento es legal porque `HasModule` lo precede.

### Namespacing

Un solo global, `Corpus`. Los módulos cuelgan de él como submódulos accedidos vía el registro (`Corpus.GetModule("caliber")`), nunca como globals sueltos adicionales.

Archivos y carpetas prefijados por módulo. La disposición **no es libre**, la impone el manifest: el init es el único archivo en `lua/autorun/` (`lua/autorun/corpus_caliber_init.lua`, shared) y los sub-archivos viven **fuera** de `autorun/`, en `lua/corpus_<modulo>/<realm>/` (`lua/corpus_caliber/server/corpus_caliber_armor.lua`, `lua/corpus_cargo/client/corpus_cargo_ui.lua`, …). Si estuvieran en `autorun/server|client` se **auto-ejecutarían** y duplicarían la carga, rompiendo el orden determinista del manifest. Lo que carga el engine por su cuenta queda donde el engine lo busca: `lua/weapons/gmod_tool/stools/corpus_caliber_config.lua`, `lua/entities/corpus_craving_food.lua`.

---

## 7. Migración ADS → Caliber

**Ejecutada** — fue el Block 2 de Caliber, cerrado y verificado en juego el 2026-07-09. El detalle vive en [`corpus-caliber/docs/Caliber_Architecture.md`](../../corpus-caliber/docs/Caliber_Architecture.md); acá queda el criterio con el que se hizo:

- **Fue una migración, no una reescritura.** Los 10 archivos de ADS 2.0 (`ads_core.lua`, `ads_armor.lua`, `ads_limbs.lua`, etc.) se convirtieron en Caliber por rename mecánico + adaptación de namespace (`ADS.*` → módulo registrado como `caliber` en Corpus) + prefijo de carpeta (`corpus_caliber_*`) + wiring sobre las 6 primitivas. Los principios de dominio ya fijados en ADS (EFT gana la jerarquía del extractor, resolver puro, y la cadena completa del pipeline: **escudo como pre-filtro delante de la armadura — CAL-13 —, armadura delante de limbs**: Hit → escudo → armadura → limbs) se preservaron **intactos** — son de Caliber, no artefactos de nombre. El criterio de aceptación fue **paridad de comportamiento**, no mejora.
- **El legacy ADS quedó congelado** en `dev/legacy/AdvancedDamageSystem 2.0/` — carpeta fuera de todos los repos git del workspace (§8), con su nombre y namespace original (`ADS`), tag `v1.0`. No comparte código con Caliber: cualquier fix futuro se hace en Caliber, nunca se retro-porta al legacy.
- **Queda pendiente el alcance nuevo** que ADS no cubría: el pipeline de armadura de **jugador** (backend nuevo, no una pestaña — es el Block 3 de Caliber) y la integración formal con Coagulant/Cortex vía el registro. Es ese pipeline el que vuelve agnóstica la `Limbs` API y expone los eventos de daño/limb que Cortex espera (§4).

---

## 8. Workspace multi-root

Un `.code-workspace` de VSCode con **ocho raíces**: siete repos git independientes (el framework, los cinco módulos y el addon de contenido) más `dev/`, carpeta de trabajo que queda fuera de todo git. Cada una de las siete primeras es un addon Gmod standalone:

```
corpus/            → framework (este documento vive en corpus/docs/CORPUS_Architecture.md)
corpus-cortex/
corpus-caliber/
corpus-coagulant/
corpus-craving/
corpus-cargo/
corpus-stalker/    → addon de CONTENIDO (no es un módulo, ver abajo)
dev/               → fuera de git, nunca se publica
```

```jsonc
// corpus.code-workspace
{
  "folders": [
    { "path": "corpus" },
    { "path": "corpus-cortex" },
    { "path": "corpus-caliber" },
    { "path": "corpus-coagulant" },
    { "path": "corpus-craving" },
    { "path": "corpus-cargo" },
    { "path": "corpus-stalker" },
    { "name": "dev (no publicado)", "path": "dev" }
  ]
}
```

**`corpus-stalker/` es de otra naturaleza.** No es un módulo: es el addon de **contenido** de S.T.A.L.K.E.R. — anomalías, artefactos, PDA, detectores, defs de NPC para CortexBase, defs de ítem. El framework y los cinco módulos son **genéricos**: no saben nada de la Zona. `corpus-stalker` es la capa que los convierte en un juego concreto, y es **consumidor puro**: hard-depende de Corpus, detecta los módulos en runtime, y **nada de su contenido sube al framework ni a un módulo**. Sus assets (ports de GSC Game World) no se versionan — el repo lleva solo código y docs.

**`dev/` no es un repo.** Carpeta de trabajo fuera de todos los git del workspace, nunca se publica: mods de terceros para investigar compatibilidad o reciclar ideas, y el legacy ADS congelado (§7).

Reglas del workspace:

- **Un git público por repo (MIT).** Los siete versionan, taguean y releasean de forma independiente entre sí — publicados en `github.com/Sepuldosky/<repo>` bajo licencia MIT desde el 2026-07-13. `dev/` no se versiona.
- **Cada raíz-repo es un addon Gmod completo**, con su propio `addon.json` en la raíz de la carpeta y su propia estructura `lua/`. Esto permite testear cada módulo por separado copiando su carpeta a `garrysmod/addons/`, o todos juntos para probar integración. (`dev/` queda excluida: no es un addon.)
- **La infraestructura compartida vive SOLO en `corpus/`** (COR-10, sede en §3-4). Ningún módulo copia-pega infraestructura de otro — dado el patrón de drift ya observado en este proyecto (ver §16 del doc de ADS 2.0, el fix de `DNumSlider` documentado como final cuando era intermedio), esta es la regla que más protege contra divergencia silenciosa entre módulos. **El dominio compartido entre dos módulos NO sube**: se queda en su dueño y el resto lo consume vía registro (COR-10, §1 y §3) — el pool de HP de extremidades vive en Caliber (`corpus_caliber_limbs.lua`) y Coagulant lo detecta con `Corpus.HasModule("caliber")`, no hay copia en el framework.
- **"Quiero todo"**: una Workshop Collection que bundlea los addons, con metadata de `required items` en cada `addon.json` (informativa para el usuario — Gmod no la impone a nivel de carga real, ver §6).
- Prefijo de archivo por **addon**: los seis consumidores (cinco módulos + `corpus_stalker_*`) usan `corpus_<addon>_*.lua` en todo su árbol Lua; el framework se reserva `corpus_<primitiva>.lua` (`corpus_registry`, `corpus_data`, `corpus_net`, `corpus_ready`, `corpus_log`, `corpus_selftest`, `client/corpus_ui`). Evita colisión de nombres en `lua/autorun/` con los siete montados a la vez en el mismo cliente/servidor. Sede: **COR-6** en `CLAUDE.md`.

---

## 9. Estado de este documento y próximos bloques

Este es el **Block 1** del diseño de Corpus: framework, grafo de dependencias, superficie de API, contrato de ítems, orden de carga y workspace. Cerrado y validado en sesión de diseño (Opus) — ratificado por el autor antes de este volcado a documento (Sonnet).

Los bloques de módulo, en la práctica, **no** se agregaron como secciones de este archivo: cada módulo desprendió su **doc particular** autocontenido en su propio repo (el patrón que formaliza [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt) §2). Acá queda el resumen y el link:

| Bloque | Contenido | Estado |
|---|---|---|
| **Block 1** | Corpus (framework) + grafo + workspace | **Cerrado — este documento**, bajado a código y verificado en juego el 2026-07-09 |
| **Block 2** | Caliber (migración desde ADS + alcance nuevo) + Cortex (táctica + afecto NPC) | **Caliber: CERRADO — verificado en juego el 2026-07-09** (primer consumidor real de las 6 primitivas; su boot diferido a `Initialize` es hoy el patrón template del ecosistema, §6; doc particular: `corpus-caliber/docs/Caliber_Architecture.md`. El alcance nuevo —armadura de jugador— es su Block 3, ver §7) · **Cortex: pendiente** — sin código todavía (repo semilla); gated por la superficie de eventos daño/limb que Caliber expondrá con el pipeline de jugador |
| **Block 3** | Coagulant (médico jugador, estilo ACE3 — heridas por zona, sangrado, vitales, tratamiento, debuffs zonales y UI) | **Cerrado (2026-07-20).** Los 4 slices verificados en juego (rondas 1-7; la 7 pasó 13/13 e incluyó el modo degradado sin Cargo) y los fixes post-cierre confirmados (mini-ronda 8 y check N1). Restan dos decisiones de diseño abiertas y el tramo de zonas `chest`/`stomach` en curso (enmienda de COA-8/COA-7 ratificada el 2026-07-21; bajada a código pendiente). Doc particular: `corpus-coagulant/docs/Coagulant_Architecture.md`; foto en su `coagulant_estado.md` |
| **Block 4** | Craving (hambre/hidratación + fallback HL2) + Cargo (grid de inventario + framework de ítems) | **CERRADO — ambos verificados en juego.** Cargo (construido temprano como hub, ver nota del roadmap; diseño en `corpus-cargo/docs/`) · Craving v1 (2026-07-14, tres rondas de checklist — doc particular: `corpus-craving/docs/Craving_Architecture.md`, foto en su `craving_estado.md`) |

**El orden real de ejecución divergió de esta numeración:** Cargo, planeado para el Block 4, se construyó temprano por ser el **hub de consumo** del que dependen Coagulant y Craving — tenerlo antes los desbloquea. Divergencia legítima: manda la dependencia real, no el plan.

Al cerrar cada bloque: resumen + link acá (la fila de esta tabla y, si corresponde, la §7), registro en el `CHANGELOG.md` del repo correspondiente, y refresco de los docs vivos del framework, siguiendo el orden de parches de [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt) §1 (verificación de contexto → verificación de estado real → aplicación → verificación en juego → actualizar changelog/estado).
