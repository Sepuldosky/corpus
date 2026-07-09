# Corpus — Estado de HOY

> **Foto del AHORA**, volátil. Es lo primero que se lee al retomar el proyecto —
> **antes** que el doc de arquitectura. Se actualiza **en sitio** (no se agregan
> secciones ni historial). El historial vive en `git` + [`CHANGELOG.md`](CHANGELOG.md).
> Si crece de una pantalla, está mal redactado: recortar.

**Última actualización:** 2026-07-09 (las 6 primitivas verificadas en juego, UI incluida — Caliber Block 2 verificado como primer consumidor real; CHANGELOG todo en `[APLICADO]`)

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
- **Los seis repos publicados en GitHub** (`github.com/Sepuldosky/<repo>`, públicos).
  `corpus/` con commits pusheados a `main`; los cinco hermanos vacíos, esperando su
  Block de diseño. Legacy ADS 2.0 en `dev/legacy/` como referencia para la migración
  a Caliber (§7 de la arquitectura).

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

1. **Caliber Block 2: CERRADO y verificado en juego (2026-07-09)** — incluyó un fix de
   arranque (boot diferido a `Initialize`; autorun alfabético fusionado corre el init
   del módulo antes que el framework) que es el **patrón template** para los otros
   cuatro módulos. Falta el primer commit del repo (cuando el autor lo pida). Foto del
   módulo → `../../corpus-caliber/docs/caliber_estado.md`.
2. **Próximo grande de Caliber:** pipeline de armadura de jugador (alcance nuevo, no
   cubierto por ADS). Después, Bloques 3/4 del ecosistema (Coagulant/Craving/Cargo, §9);
   Cortex espera la superficie de eventos daño/limb que Caliber expondrá.

---

*Rumbo / qué sigue → [`corpus_roadmap.txt`](corpus_roadmap.txt). Diseño de referencia →
[`CORPUS_Architecture.md`](CORPUS_Architecture.md). Metodología →
[`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).*
