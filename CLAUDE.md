# CLAUDE.md

Guía para trabajar en **Corpus** — el framework (addon GLua para Garry's Mod que alojan los módulos del ecosistema). Léela antes de tocar código o docs de este repo.

## Qué es

Este repo es la raíz del ecosistema Corpus: el framework delgado del que dependen (hard-dep) Cortex, Caliber, Coagulant, Craving y Cargo, cada uno en su propio repo hermano dentro del mismo workspace VSCode. Diseño completo del framework, el grafo de dependencias y el workspace → [`docs/CORPUS_Architecture.md`](docs/CORPUS_Architecture.md).

**Regla cardinal (COR-10):** Corpus es un framework **delgado**. Solo aloja infraestructura demostrablemente compartida: registro de módulos, persistencia, net, UI shell, ready barrier, log. Ningún módulo sube lógica de dominio acá — ni siquiera algo compartido por dos módulos (ej. el pool de HP de extremidades) sube; se queda en su dueño y el resto lo consume vía registro. Sede: §3-4 de la arquitectura.

**Regla cardinal (COR-11):** la única hard-dependency de todo el ecosistema es Corpus mismo. Todo lo demás es soft-dependency: se detecta en runtime vía `Corpus.GetModule`/`Corpus.HasModule`, nunca se asume. Sede: §2 y §6 de la arquitectura.

## Docs del proyecto — jerarquía de lectura

Antes de tocar código o diseño, lee en este orden (los tres primeros son **docs vivos**):

1. **Estado de HOY** → [`docs/corpus_estado.md`](docs/corpus_estado.md). Foto del AHORA, ≤1 pantalla. **Léelo ANTES** que la arquitectura — dice qué existe hoy, qué está pendiente y qué deuda hay.
2. **Rumbo** → [`docs/corpus_roadmap.txt`](docs/corpus_roadmap.txt). Qué sigue y en qué orden (Blocks 1-4, ver §9 de la arquitectura). `estado` dice dónde estamos dentro de él.
3. **Historial de parches** → [`docs/CHANGELOG.md`](docs/CHANGELOG.md). `[PENDIENTE]`/`[APLICADO YYYY-MM-DD]`, nunca se borra ni renumera.
4. **Metodología de trabajo** → [`docs/corpus_flujo_trabajo.txt`](docs/corpus_flujo_trabajo.txt). Planificación densa por bloques, vertical slice, orden de ejecución de parches — **doc canónico para todo el ecosistema**, no solo este repo. Su **§7 arbitra los hechos**: jerarquía de autoridad (el código manda sobre el doc), la regla de que toda norma define o cita un ID, el barrido de ratificación y la conducta `DETENTE`. Léelo antes de escribir cualquier norma.
   - **Registro de IDs** → [`docs/ids.yaml`](docs/ids.yaml). Índice único del ecosistema (§7.4). **No** es autoridad: si contradice la prosa de su sede, el yaml está desactualizado. Norma nueva ⇒ entrada en el mismo parche.
5. **Arquitectura de referencia** (general, crece por bloque) → [`docs/CORPUS_Architecture.md`](docs/CORPUS_Architecture.md). Diseño estable; se consulta por sección cuando se necesita. Un Block puede desprender un doc **particular** autocontenido (`docs/<Subsistema>_Arquitectura.md`) cuando el subsistema lo amerita — la sección del general queda como resumen + link; ver §2 de [`corpus_flujo_trabajo.txt`](docs/corpus_flujo_trabajo.txt).
6. **Convenciones de commit** → [`docs/corpus_convenciones_commits.txt`](docs/corpus_convenciones_commits.txt). Alcances específicos de **este** repo (framework); cada módulo hermano define los suyos cuando su Block cierra.

## Idioma

**GIT-4 —** Comentarios y mensajes de commit en **español**; los `<tipo>` de commit van en inglés (ver convenciones). Si el código existente mezcla estilos, iguala el del archivo que estás editando — no impongas uno nuevo.

## El workspace multi-repo

Este repo (`corpus/`) es una de siete raíces del workspace `corpus.code-workspace`. Cinco son los **módulos** (`corpus-cortex/`, `corpus-caliber/`, `corpus-coagulant/`, `corpus-craving/`, `corpus-cargo/`): addons Gmod independientes con su propio git, que hard-dependen de este. Cuando el Block de diseño de un módulo cierra y empieza a recibir código, ese repo hermano recibe su **propio** `CLAUDE.md` + set de docs, siguiendo el mismo template que este archivo — ver §2 de [`corpus_flujo_trabajo.txt`](docs/corpus_flujo_trabajo.txt).

La séptima raíz, [`corpus-stalker/`](../corpus-stalker/), es de otra naturaleza: no es un módulo sino el **addon de contenido** de S.T.A.L.K.E.R. (anomalías, artefactos, PDA, detectores, defs de NPC para CortexBase, defs de ítem). El framework y los módulos son **genéricos** — no saben nada de la Zona; `corpus-stalker` es la capa que los convierte en un juego concreto. Es consumidor puro: hard-depende de Corpus, detecta los módulos en runtime, y **nada de su contenido sube al framework ni a un módulo**. Sus assets (ports de GSC Game World) no se versionan — el repo lleva solo código y docs.

Hay además una carpeta `dev/` en la raíz del workspace (fuera de todos los repos git, nunca se publica) con mods de terceros para investigar compatibilidad o reciclar ideas/assets — mismo propósito que tenía `dev/` en el ADS legacy (ver `dev/legacy/`).

**Al diseñar o discutir integración con mods ajenos** (ARC9, VJ Base, escudos Halo, NVG, etc.): consulta [`../dev/mods_workshop_mapa.md`](../dev/mods_workshop_mapa.md) — mapea cada mod instalado en `dev/other/` contra su página de Workshop y lo etiqueta **RECICLAR** (copiar código/assets → importa la licencia) vs. **COMPAT-RUNTIME** (detectar y consumir por API → la licencia no importa). Distinción clave para no confundir "integrar" con "copiar".

## Mapa de archivos

Las 6 primitivas de la API (§3 de la arquitectura) están implementadas. Cada archivo es autosuficiente — ver **COR-9** en los contratos, más abajo.

| Archivo | Realm | Rol |
|---|---|---|
| [`lua/autorun/corpus_registry.lua`](lua/autorun/corpus_registry.lua) | shared | Registro: `RegisterModule`/`HasModule`/`GetModule` — **invariante by-ref** (misma tabla por referencia, ver nota en §3 de la arquitectura) |
| [`lua/autorun/corpus_data.lua`](lua/autorun/corpus_data.lua) | shared | Persistencia: `Corpus.Data.Save/Load` → `data/corpus/<module>/<key>.json` |
| [`lua/autorun/corpus_net.lua`](lua/autorun/corpus_net.lua) | shared | Net: `Corpus.Net.Register` → `"corpus_<module>_<msgName>"` (`AddNetworkString` solo en server) |
| [`lua/autorun/corpus_ready.lua`](lua/autorun/corpus_ready.lua) | shared | Ready barrier: `Corpus.OnReady`, dispara una vez tras `InitPostEntity` |
| [`lua/autorun/corpus_log.lua`](lua/autorun/corpus_log.lua) | shared | Log: `Corpus.Log` con prefijo `[Corpus:<module>]` |
| [`lua/autorun/client/corpus_ui.lua`](lua/autorun/client/corpus_ui.lua) | client | UI shell: `Corpus.UI.RegisterTab` — categoría única "Corpus" en el menú Q (Utilities) |
| [`lua/autorun/corpus_selftest.lua`](lua/autorun/corpus_selftest.lua) | shared | Comando `corpus_selftest`: auto-test en consola de las primitivas (PASO 4 del flujo) |

## Contratos que no debes romper

Esta es la **sede** de la familia `COR-nn` (§7.4 del flujo): la definición canónica de
cada contrato vive acá y el resto del ecosistema la **cita** por su ID, nunca la
redefine. El registro [`docs/ids.yaml`](docs/ids.yaml) los indexa.

1. **COR-1 — Nada de lógica de dominio en Corpus.** Solo registro, persistencia, net, UI shell, ready barrier, log — ver la lista explícita de "lo que Corpus NO contiene" en §3 de la arquitectura (armor math, hitgroups, curvas de sangrado/hambre, grid de inventario).
2. **COR-2 — Namespace único.** Todo cuelga del global `Corpus`; los módulos se acceden vía `Corpus.GetModule(name)`, nunca como globals sueltos adicionales.
3. **COR-3 — Persistencia namespaced.** `Corpus.Data.Save/Load(module, key, tbl)` → ruta `data/corpus/<module>/<key>.json`. Un módulo no escribe fuera de su propio namespace.
4. **COR-4 — Net namespaced.** `Corpus.Net.Register(module, msgName)` devuelve `"corpus_<module>_<msgName>"` — evita colisión global de `net.Receive` entre los cinco módulos.
5. **COR-5 — Detección, nunca asunción.** Ningún módulo asume que Corpus u otro módulo ya cargó — orden de mount no garantizado en Gmod (ver §6 de la arquitectura). Lazy check (`Corpus.GetModule`) o `Corpus.OnReady` para wiring que corre una vez.
6. **COR-6 — Prefijo de archivo por addon:** los **seis addons consumidores** (los cinco módulos + `corpus-stalker`) prefijan sus archivos Lua `corpus_<addon>_*.lua` — tanto el entry point en `lua/autorun/` como el árbol propio bajo `lua/corpus_<addon>/`, `lua/entities/`, `lua/weapons/`. El **framework se reserva el prefijo `corpus_` desnudo** y nombra sus primitivas `corpus_<primitiva>.lua` en su propia `lua/autorun/`. El objetivo es evitar colisión de nombres cuando los siete addons están montados simultáneamente; el framework no colisiona consigo mismo. **El nombre `corpus_registry.lua` no se renombra por convención**, no por dependencia: su posición en el merge alfabético (después de los `corpus_<addon>_init.lua`) es el HECHO que **obliga** al patrón de sonda + boot diferido de §6 de la arquitectura — el boot es **inmune** a esa posición por construcción (COR-5, COR-9): si el registro ordena antes dispara la fast-path, si ordena después la rama diferida. Lo que sí depende del nombre es la **prosa**: la arquitectura, el CHANGELOG y los inits lo citan por escrito, y los harness offline arman el frame por ese nombre.
7. **COR-9 — Cada archivo del framework es autosuficiente.** `Corpus = Corpus or {}` al tope; ninguno asume orden de carga dentro de `lua/autorun/` — no repitas acá la fragilidad de orden alfabético que Caliber elimina con su manifest.
8. **COR-15 — UI shell vía la primitiva.** Una sola entrada por módulo en el menú Q: `Corpus.UI.RegisterTab(<module>, <label>, fn)`, bajo la categoría única "Corpus" (Utilities). Ningún módulo abre un menú propio en el spawnmenu; las ventanas adicionales (p.ej. el browser de Caliber) se abren por botón/concommand desde su tab, **y los modos de toolgun (stools) quedan fuera de esta norma: viven en la pestaña Tools bajo la categoría del módulo, no en el menú Q.**
9. **COR-16 — Log vía la primitiva.** Toda salida de consola de un módulo va por `Corpus.Log(<module>, ...)` → prefijo `[Corpus:<module>]`; nada de `print` crudo. **Dos excepciones, ambas del framework y ninguna de un módulo:** (a) el fallback ruidoso del boot cuando el framework mismo falta —no hay `Corpus.Log` que usar; **se emite con `MsgN`**—, y (b) el bloque de reporte de `corpus_selftest.lua`, que imprime con prefijo `[Corpus]` a secas porque reporta sobre el framework entero, no sobre un módulo.

Las normas duras restantes del framework tienen su sede en la arquitectura, no acá:
**COR-7** (invariante by-ref del registro) y **COR-8** (`Corpus.Data` sí normaliza en el
round-trip JSON — contrato **distinto** a COR-7, no confundirlos) viven en §3 de
[`CORPUS_Architecture.md`](docs/CORPUS_Architecture.md); **COR-10** (la regla cardinal
del framework delgado) y **COR-11** (Corpus es la única hard-dep) en §1-4 y §2/§6;
y **COR-12** (def y `onUse` en ambos realms), **COR-13** (el retorno de `onUse` gobierna
el consumo) y **COR-14** (ningún módulo de dominio necesita Cargo) en §5, el contrato de
ítems generalizado.

## Verificación

No hay test runner automatizado (es un addon GMod) — el patrón es el mismo que se usó en ADS/Kontrol: cargar el mapa, confirmar en consola/juego, no asumir. Ver [`corpus_flujo_trabajo.txt`](docs/corpus_flujo_trabajo.txt) §1 (Paso 4). El comando de consola `corpus_selftest` valida las primitivas del framework en el realm donde corre (en listen server, realm server: `lua_run Corpus._SelfTest()`); el tab de UI se confirma visual en el menú Q.

Al cerrar un cambio con superficie de runtime: refresca [`docs/corpus_estado.md`](docs/corpus_estado.md) en sitio y actualiza [`docs/CHANGELOG.md`](docs/CHANGELOG.md) (`[PENDIENTE]` → `[APLICADO YYYY-MM-DD]`, sin borrar ni renumerar).

## Git / commits

Sigue [`docs/corpus_convenciones_commits.txt`](docs/corpus_convenciones_commits.txt): `<tipo>(<alcance>): <descripción>` — tipo en inglés, descripción en español, minúscula inicial, sin punto final, imperativo.

**Este repo está publicado en GitHub** (`github.com/Sepuldosky/corpus`, público, remote `origin`). No hagas push salvo que se pida explícitamente. Los **siete** repos del ecosistema están publicados bajo `github.com/Sepuldosky/<repo>` (públicos, MIT) y todos tienen `origin/main` cableado; **Caliber, Cargo, Coagulant, Craving y `corpus-stalker` ya llevan commits** (Cortex sigue con el repo semilla: README + LICENSE, sin código). Push y commit **solo cuando se pidan explícitamente** (**GIT-7**, unificada en los siete repos el 2026-07-19) — al 2026-07-19 los siete están al día con `origin/main`, sin commits locales pendientes de push (última tanda pusheada: el ciclo anti-drift v1 completo, con autorización expresa del autor).

**GIT-5 — No agregues el trailer `Co-Authored-By: Claude` (ni ninguna atribución de co-autoría a Claude/Anthropic) en los mensajes de commit.** Esto sobreescribe el comportamiento por defecto del harness.
