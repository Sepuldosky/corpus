# Corpus — Estado de HOY

> **Foto del AHORA**, volátil. Es lo primero que se lee al retomar el proyecto —
> **antes** que el doc de arquitectura. Se actualiza **en sitio** (no se agregan
> secciones ni historial). El historial vive en `git` + [`CHANGELOG.md`](CHANGELOG.md).
> Si crece de una pantalla, está mal redactado: recortar.
> Cita **FLU-15**, cuya sede es [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt)
> §1 PASO 5 — este doc la aplica, no la define.

**Última actualización:** 2026-07-20 (framework estable desde el 2026-07-09; **Block 4 cerrado**: Craving verificó su v1 en juego, sumándose a Cargo; **Coagulant cerró sus slices 1-3 en juego (ronda 6) y tiene el slice 4 —la UI— en código, a la espera de la ronda 7, la que cierra su Block 3**. Cortex sigue sin código, pero ya no está vacío: estrenó su doc de contratos entrantes. **Nuevo: el gate SCOPED post-D13 corrió ÍNTEGRO y su tanda de reparación está APLICADA** — cinco universales que el árbol desmentía, más la fase 0 del gate; queda **D-14 abierta**, un voto del autor; **el ecosistema sigue listo para el 2.º COMPLETO**, que se corre en sesión fresca aparte)

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
- **Workspace multi-root + metodología:** **siete raíces** (`corpus/` + cinco módulos +
  `corpus-stalker/`, el addon de **contenido** de la Zona — consumidor puro, no un módulo)
  + `dev/` fuera de git; set de docs vivos portado de ADS/Kontrol, con el patrón doc
  general vs. particular ya formalizado en
  [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).
- **Anti-drift (2026-07-16, portado del SDD de Kontrol):** §7 del flujo es la
  **constitución** — jerarquía de autoridad (el código Lua manda sobre el doc), toda norma
  define o cita un ID, barrido de ratificación en el PASO 5, conducta `DETENTE`. El
  registro [`ids.yaml`](ids.yaml) indexa **207 IDs** de las siete raíces (10 familias; 27%
  INTENCION — subió porque la familia Workbench, acuñada el 2026-07-19, es intención pura
  por construcción: su bloque no está implementado). **Los votos del autor (2026-07-19) cerraron seis deudas** (D-1, D-4, D-6,
  D-9, D-10, D-11 — incluye acuñar COR-15/COR-16 para UI shell y log, y unificar la
  política git estricta en los siete repos) **y recortaron D-2/D-3** (los IDs de check
  rigen hacia adelante; quedan sedes en `.lua`/CHANGELOG por mover). El **checker** (§7.7)
  corre en `pre-commit` sobre las siete raíces (12/12 tests) y valida yaml, prefijos,
  duplicados, sedes, evidencia y huérfanos — **presencial, no semántico**. El **§8**
  formaliza la tanda como spec ejecutable. El **gate LLM** (§7.8) corrió un COMPLETO y cuatro
  SCOPED ([actas](auditorias/)); **las actas están triadas y el último SCOPED (2026-07-20) ya
  está reparado** — COR-12/13/14 anclados por etiqueta y reconocidos por el `CLAUDE.md`, más
  cuatro universales que el árbol desmentía. **El gate propone y jamás aplica (AUD-4): las
  actas son inmutables y los parches van en tanda aparte.**
- **Los siete repos publicados en GitHub** (`github.com/Sepuldosky/<repo>`, públicos, MIT). Dos
  módulos ya viven sobre las primitivas: **Caliber** (Block 2, migración ADS 2.0 — cerrado y
  verificado, primer consumidor real; su boot diferido a `Initialize` es el patrón template)
  y **Cargo** (Block 1, inventario estilo STALKER — hoy el módulo más grande del ecosistema:
  UI fullscreen, munición, wheel, captura de armas y el slice 1 del comercio, todo en juego).
  **Coagulant tiene su Block 3 diseñado y los slices 1-3 verificados en juego** (2026-07-14,
  seis rondas de checklist: sangre/heridas/sangrado + tratamiento con tiempo y 4 ítems contra
  Cargo + debuffs zonales —cojera, sway, visión—); su **slice 4 (UI)** —silueta, menú médico,
  barra de tratamiento, StatusPanel y tab Q— está en código y verificado offline, pendiente de
  la ronda 7.
  **Craving estrenó repo y cerró su Block 4 en dos días** (2026-07-13/14: diseño
  ratificado + código + tres rondas de verificación en juego — decay/umbrales, puente
  mock-first a Coagulant, 6 consumibles contra Cargo, entity de mundo con WALK+USE,
  barras; los 12 entries de su CHANGELOG en `[APLICADO]`, ya commiteados y pusheados).
  **Cortex sigue sin código**, pero desde el 2026-07-19 tiene
  [`docs/Cortex_ContratosEntrantes.md`](../../corpus-cortex/docs/Cortex_ContratosEntrantes.md):
  las **seis** firmas que otros repos ya le congelaron, juntas y cruzadas entre sí por primera
  vez (no se contradicen). Es doc de RECEPCIÓN, no su diseño. Cada
  módulo con docs lleva su propia foto en `<repo>/docs/<modulo>_estado.md`; legacy ADS 2.0 en
  `dev/legacy/` (tag `v1.0`, congelado) ya migrado a Caliber (§7 de la arquitectura).

## Pendiente de verificar

- Nada — el CHANGELOG está todo en `[APLICADO]`.

## Remanentes / deuda conocida

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
2. **Coagulant:** Block 3 diseñado y ratificado (2026-07-13, en su repo — para mods el
   diseño ya no pasa por Desktop); slices 1-3 verificados en juego (ronda 6). El **slice 4
   (UI)** y el sway retuneado esperan la **ronda 7**, que cierra el bloque.
   **Craving:** Block 4 cerrado, verificado, commiteado y pusheado.
   **Cortex** espera su Block (§9): depende de los eventos daño/limb que Caliber expondrá
   con el pipeline de jugador — mock-first si hace falta antes.
3. **Framework:** sin trabajo propio pendiente. Vigilar primitivas candidatas que asoman
   desde los módulos (`Corpus.Data.Delete` y un gate de admin reutilizable que pide Cargo);
   suben solo cuando el consumo lo justifique — framework delgado (§1).
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
   Registro: **207 IDs**, 27 % INTENCION. **D-3** quedó recortada a **once sedes en `.lua`**
   —cero en CHANGELOG, estado o roadmap—, y varias de esas once son legítimas.
   El **SCOPED del 2026-07-20** (AUD-1) cerró el ciclo: reparado, y el gate estrena **fase 0
   «Conteo»** —`total` pasó de constante a **checksum derivado del árbol**, el defecto que
   bloqueaba el COMPLETO— más cinco estados por bucket y un pase de VALOR.
   **Lo que sigue: correr el 2.º COMPLETO** (sesión fresca, Opus 4.8, su propio PROMPT —
   AUD-3; editar el `.js` invalidó el caché de resume, es esperable). **`D-14` CERRADA por
   voto del autor: COR-12 SE QUEDA** — no gobierna ítems sino el protocolo de registro entre
   módulos, del linaje de COR-3/COR-4; enuncia la FORMA, jamás la SEMÁNTICA, y si algún día
   menciona stacks, peso o slots el voto se reabre. Deudas de verificación **en juego, del
   autor**: la entry #27 de Cargo (`[PENDIENTE]` con código en árbol) y la ronda 7 de Coagulant.

---

*Rumbo / qué sigue → [`corpus_roadmap.txt`](corpus_roadmap.txt). Diseño de referencia →
[`CORPUS_Architecture.md`](CORPUS_Architecture.md). Metodología →
[`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).*
