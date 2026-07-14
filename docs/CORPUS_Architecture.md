# Corpus — Documento de Arquitectura

> **Uso de este documento:** Referencia autocontenida para sesiones futuras de planificación (Claude Opus) e implementación (Claude Code). Cada sección es independiente. No se requiere el chat de diseño original.
>
> **Estado:** Block 1 de 4 (ver §9). Cubre el framework Corpus, el grafo de dependencias entre módulos y el workspace de desarrollo. El diseño interno de cada módulo (Caliber, Cortex, Coagulant, Craving, Cargo) se documenta en bloques siguientes, como secciones nuevas de este mismo archivo — mismo patrón que ADS 2.0 usó para sus Blocks 4-8.
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

**Regla cardinal:** Corpus es un framework **delgado**. Solo aloja infraestructura demostrablemente compartida (registro, persistencia, net, UI shell). Ningún módulo sube lógica de dominio a Corpus — ni siquiera algo compartido por dos módulos, como el pool de HP de extremidades, que se queda en su dueño (Caliber) y se consume vía registro. Esa línea es lo que evita que Corpus se vuelva un god-object con el tiempo.

**Regla cardinal:** la única dependencia dura de todo el ecosistema es Corpus mismo. Todo lo demás — Caliber, Cargo, Coagulant, Craving, Cortex entre sí — es **soft-dependency**: se detecta en runtime, se enciende si el partner está, degrada honestamente si no.

---

## 2. Grafo de dependencias

```
Corpus  ← hard-dep de TODOS los módulos (se detecta, nunca se asume)
│
├─ Cortex     ─ soft→ Caliber (eventos de daño/limb, para dolor y miedo)
├─ Caliber    ─ hoja: sin deps hacia otros módulos
├─ Cargo      ─ hoja en deps, pero hub de consumo (dos módulos lo usan)
│
├─ Coagulant  ─ soft→ Caliber (enriquece hit-location con datos de armadura/zona)
│              soft→ Cargo (ítems médicos: vendas, torniquetes)
│
└─ Craving    ─ soft→ Cargo (consumibles: comida, agua)
               soft→ Coagulant (inanición/deshidratación afectan salud, opcional)
```

Ningún módulo, salvo Corpus, es un requisito duro de otro. Un usuario puede instalar solo Cargo (inventario sin combate ni supervivencia), solo Caliber (combate sin médico), o los cinco juntos. Cada combinación produce un sistema honesto, no una mitad rota.

### Tabla de resumen

| Módulo | Deps duras | Deps soft | Sin la dep soft, degrada a... |
|---|---|---|---|
| Cortex | Corpus | Caliber | comportamiento táctico sin reacción a daño por zona (dolor/miedo genérico) |
| Caliber | Corpus | — | — (no depende de nadie) |
| Cargo | Corpus | — | — (no depende de nadie) |
| Coagulant | Corpus | Caliber, Cargo | hit-location por hitgroup crudo (nativo); tratamiento por world-entity o vía mínima propia |
| Craving | Corpus | Cargo, Coagulant | fallback a entities HL2 comestibles/bebibles; sin efecto en salud, solo hambre/sed → muerte |

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

> **Invariante del registro (contrato duro):** `Corpus.RegisterModule(name, iface)` y `Corpus.GetModule(name)` guardan y devuelven la **misma tabla por referencia** — sin deep-copy, sin normalización de ningún tipo. El patrón "tabla única poblada por side-effect" con el que los módulos construyen su namespace (ver `Caliber_Architecture.md` §3 y §11) depende de que sea así; un copy defensivo acá lo rompe en silencio. Es un contrato **distinto** al de `Corpus.Data.Save/Load`, que sí normaliza en el round-trip JSON (`util.JSONToTable` puede devolver claves numéricas donde se guardaron strings) — no confundir ambos invariantes.

**Lo que Corpus NO contiene:** armor math, hitgroups, curvas de sangrado, curvas de hambre, grid de inventario. Si dos módulos comparten una pieza de dominio (limbs, por ejemplo), esa pieza no sube — se queda en su dueño y el otro la consulta por el registro (§4).

---

## 4. Fronteras de módulo

Detalle de diseño interno de cada módulo: fuera de alcance de este Block 1, aterriza en los bloques 2-4 (§9). Acá solo la frontera — qué posee, qué expone, qué consume.

| Módulo | Owns | Expone (interfaz pública) | Consume (soft) |
|---|---|---|---|
| **Cortex** | Táctica de combate NPC (peek) + afecto (dolor, miedo) | — | Caliber: eventos de daño/limb |
| **Caliber** | Armor zonal · shields · limbs · penetración · resolver puro + adapters NPC/player | `Caliber.Limbs` (API agnóstica a si la entidad es NPC o jugador) + eventos de daño/limb | — |
| **Coagulant** | Heridas por zona (jugador) · sangrado · vitales · tratamiento, estilo ACE3 | eventos de estado clínico | Caliber (`Limbs`, hit-location enriquecido) · Cargo (ítems médicos) |
| **Craving** | Hambre · hidratación (jugador) | getters (`GetHunger`/`GetHydration`/`Restore`) + evento `Craving_StatCritical` *(enmienda 2026-07-13, Block 4 — antes "—"; ver `corpus-craving/docs/Craving_Architecture.md` §8)* | Cargo (consumibles) · Coagulant (efectos de salud, opcional) |
| **Cargo** | Grid de inventario · framework de definición de ítems · contenedores · peso · UI | `Cargo.Items.Register(def)` + query/consume de inventario | — |

Nota sobre **Caliber**: internamente es *resolver puro + dos adapters* (hook NPC vía VJ/ARC9, hook jugador) — el mismo principio "resolver puro, hooking aparte" que ya rige ADS 1.x. La `Limbs API` que expone debe ser agnóstica a la entidad: Coagulant no debe saber ni importarle si la pierna sangrante es de un NPC o del jugador.

Nota sobre **Cargo**: es hoja en el grafo de dependencias (no depende de nadie), pero es un *hub de consumo* — Coagulant y Craving lo usan. Su frontera es el framework de ítems, no la lógica de qué hace cada ítem (eso es de cada módulo dueño, ver §5).

---

## 5. Contrato de ítems generalizado

Patrón que hace real el "pick and choose" en la práctica: **cada módulo de dominio posee sus propias definiciones de ítem** (qué hace, callback de uso). Cargo, si está presente, provee el contenedor (storage, grid, UI). Si no está, el módulo cae a una vía mínima propia.

```lua
-- Ejemplo: Coagulant registra un ítem propio contra el framework de Cargo
Cargo.Items.Register({
    id = "corpus_coagulant_bandage",
    name = "Bandage",
    weight = 0.1,
    onUse = function(ply)
        -- lógica de curación: dominio de Coagulant, no de Cargo
        Corpus.GetModule("coagulant").ApplyBandage(ply)
    end
})
```

- **Cargo owns**: cómo se define un ítem, cómo pesa, cómo se guarda, cómo se renderiza en la grilla.
- **Coagulant/Craving owns**: qué hace su ítem cuando se usa.
- **Sin Cargo presente**: el módulo cae a interacción con world-entity (Craving ya ship sus fallbacks HL2 comestibles/bebibles, ver bloque de Craving) o a una vía de uso mínima propia sin inventario real.

Ningún módulo de dominio **necesita** Cargo para funcionar — solo lo aprovecha si está.

---

## 6. Orden de carga y detección de dependencias

Gmod no garantiza orden de mount entre addons (server owners separan `.gma`, FastDL, orden de suscripción Workshop). Regla dura: **ningún módulo asume que Corpus, u otro módulo, ya cargó.** Se detecta en runtime.

### Init — hard-dep (Corpus)

```lua
-- corpus_caliber_init.lua (autorun/server, primera línea de carga del módulo)
if not Corpus then
    error("[Caliber] Corpus framework no encontrado. Verificar orden de carga o instalación.")
    return
end

Corpus.RegisterModule("caliber", {
    -- interfaz pública del módulo
})
```

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

**Regla derivada:** el registro de Corpus (§3) es a la vez el mecanismo de detección de presencia y la ruta de acceso al módulo — `Corpus.GetModule("cargo").Items.Register(...)` es simultáneamente el check y la llamada.

### Namespacing

Un solo global, `Corpus`. Los módulos cuelgan de él como submódulos accedidos vía el registro (`Corpus.GetModule("caliber")`), nunca como globals sueltos adicionales. Archivos y carpetas prefijados: `lua/autorun/server/corpus_caliber_*.lua`, `lua/autorun/client/corpus_cargo_*.lua`, `lua/weapons/gmod_tool/stools/corpus_caliber_config.lua`.

---

## 7. Migración ADS → Caliber

Bloque de trabajo propio, fuera del detalle de este documento — se planifica cuando Caliber entre en su bloque de diseño (§9). Se deja registrado el criterio ya cerrado:

- **Es una migración, no una reescritura.** El código de ADS 2.0 (`ads_core.lua`, `ads_armor.lua`, `ads_limbs.lua`, etc.) se convierte en Caliber mediante rename mecánico de archivos + adaptación de namespace (`ADS.*` → módulo registrado como `caliber` en Corpus) + prefijo de carpeta (`corpus_caliber_*`). Los principios de dominio ya fijados en ADS (EFT gana la jerarquía del extractor, resolver puro, armadura como pre-filtro delante de limbs) se preservan intactos — son de Caliber, no artefactos de nombre.
- **El legacy ADS queda congelado.** Snapshot publicado con su nombre y namespace original (`ADS`), tag `v1.0`, repo separado y privado por ahora (ver conversación de Releases/licencia). No comparte código con Caliber después de la migración — cualquier fix futuro se hace en Caliber, no en el legacy.
- **Caliber además adquiere alcance nuevo** fuera de lo que ADS cubría: el pipeline de armadura de jugador (backend nuevo, no una pestaña — ya identificado como trabajo grande aparte) y la integración formal con Coagulant/Cortex vía el registro de Corpus.

---

## 8. Workspace multi-root

Un `.code-workspace` de VSCode con **seis raíces**, una carpeta por addon/repo. Cada raíz es un addon Gmod standalone e independiente:

```
corpus/            → framework (este documento vive en corpus/docs/CORPUS_Architecture.md)
corpus-cortex/
corpus-caliber/
corpus-coagulant/
corpus-craving/
corpus-cargo/
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
    { "path": "corpus-cargo" }
  ]
}
```

Reglas del workspace:

- **Un git privado por repo.** Los seis versionan, taguean y releasean de forma independiente entre sí — igual que el legacy ADS, que queda en su propio repo aparte.
- **Cada raíz es un addon Gmod completo**, con su propio `addon.json` en la raíz de la carpeta y su propia estructura `lua/autorun/...`. Esto permite testear cada módulo por separado copiando su carpeta a `garrysmod/addons/`, o los seis juntos para probar integración.
- **Código compartido vive SOLO en `corpus/`.** Ningún módulo copia-pega infraestructura de otro — dado el patrón de drift ya observado en este proyecto (ver §16 del doc de ADS 2.0, el fix de `DNumSlider` documentado como final cuando era intermedio), esta es la regla que más protege contra divergencia silenciosa entre módulos.
- **"Quiero todo"**: una Workshop Collection que bundlea los seis, con metadata de `required items` en cada `addon.json` (informativa para el usuario — Gmod no la impone a nivel de carga real, ver §6).
- Prefijo de archivo por módulo (`corpus_<modulo>_*.lua`) evita colisión de nombres en `lua/autorun/` cuando los seis addons están montados simultáneamente en el mismo cliente/servidor.

---

## 9. Estado de este documento y próximos bloques

Este es el **Block 1** del diseño de Corpus: framework, grafo de dependencias, superficie de API, contrato de ítems, orden de carga y workspace. Cerrado y validado en sesión de diseño (Opus) — ratificado por el autor antes de este volcado a documento (Sonnet).

Bloques planificados, cada uno se agrega como sección nueva a este mismo archivo cuando cierre su propio diseño — mismo patrón que ADS 2.0 usó para sus Blocks 4 a 8:

| Bloque | Contenido | Estado |
|---|---|---|
| **Block 1** | Corpus (framework) + grafo + workspace | **Cerrado — este documento** |
| **Block 2** | Caliber (migración desde ADS + alcance nuevo) + Cortex (táctica + afecto NPC) | Pendiente |
| **Block 3** | Coagulant (médico jugador, estilo ACE3 — sustrato v1: heridas por zona, sangrado, vitales, vendaje/torniquete) | Pendiente |
| **Block 4** | Craving (hambre/hidratación + fallback HL2) + Cargo (grid de inventario + framework de ítems) | **CERRADO — ambos verificados en juego.** Cargo (construido temprano como hub, ver nota del roadmap; diseño en `corpus-cargo/docs/`) · Craving v1 (2026-07-14, tres rondas de checklist — doc particular: `corpus-craving/docs/Craving_Architecture.md`, foto en su `craving_estado.md`) |

Al cerrar cada bloque: sección nueva acá, y registro en el `CHANGELOG.md` de cada repo correspondiente, siguiendo el mismo flujo de trabajo ya establecido para ADS (`ads_flujo_trabajo.txt`: verificación de contexto → verificación de estado real → aplicación → verificación en juego → actualizar changelog/estado).
