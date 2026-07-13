# Corpus — Estado de HOY

> **Foto del AHORA**, volátil. Es lo primero que se lee al retomar el proyecto —
> **antes** que el doc de arquitectura. Se actualiza **en sitio** (no se agregan
> secciones ni historial). El historial vive en `git` + [`CHANGELOG.md`](CHANGELOG.md).
> Si crece de una pantalla, está mal redactado: recortar.

**Última actualización:** 2026-07-13 (framework estable desde el 2026-07-09; Coagulant estrena scaffold pre-diseño; Craving estrena repo completo — diseño ratificado + v1 en código, pendiente de juego. Solo Cortex sigue vacío)

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
- **Workspace multi-root + metodología:** seis raíces (`corpus/` + cinco módulos) +
  `dev/` fuera de git; set de docs vivos portado de ADS/Kontrol, con el patrón doc
  general vs. particular ya formalizado en
  [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).
- **Los seis repos publicados en GitHub** (`github.com/Sepuldosky/<repo>`, públicos). Dos
  módulos ya viven sobre las primitivas: **Caliber** (Block 2, migración ADS 2.0 — cerrado y
  verificado, primer consumidor real; su boot diferido a `Initialize` es el patrón template)
  y **Cargo** (Block 1, inventario estilo STALKER — verificado y con primer commit en `main`,
  en diseño de UI fullscreen + Workbench). **Coagulant tiene su Block 3 diseñado y el slice 1 (sangre/heridas/sangrado)
  verificado en juego** (2026-07-13; solo re-test del ítem vía Cargo pendiente tras un fix de realm).
  **Craving estrenó repo el 2026-07-13** (Block 4: diseño ratificado en el día +
  v1 completo en código — decay/umbrales, puente mock-first a Coagulant, 6 consumibles
  contra Cargo, entity de mundo, barras; CHANGELOG entero `[PENDIENTE]` de juego).
  **Solo Cortex sigue vacío.** Cada
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
   NPC→agnóstico); Cargo está en diseño de UI fullscreen + Workbench (sesión de Claude
   Desktop). El detalle vive en sus roadmaps/estados, no acá.
2. **Coagulant:** Block 3 diseñado y ratificado (2026-07-13, en su repo — para mods el
   diseño ya no pasa por Desktop); slice 1 de 4 verificado en juego, sigue el slice 2
   (tratamiento con tiempo). **Craving:** v1 en código, espera la pasada en juego del autor
   (su estado/roadmap viven en su repo). **Cortex** espera su Block (§9): depende de los
   eventos daño/limb que Caliber expondrá con el pipeline de jugador — mock-first si hace
   falta antes.
3. **Framework:** sin trabajo propio pendiente. Vigilar primitivas candidatas que asoman
   desde los módulos (`Corpus.Data.Delete` y un gate de admin reutilizable que pide Cargo);
   suben solo cuando el consumo lo justifique — framework delgado (§1).

---

*Rumbo / qué sigue → [`corpus_roadmap.txt`](corpus_roadmap.txt). Diseño de referencia →
[`CORPUS_Architecture.md`](CORPUS_Architecture.md). Metodología →
[`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).*
