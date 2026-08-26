<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/corpus_lockup_dark.svg">
    <img src="assets/corpus_lockup_light.svg" width="220" alt="Corpus">
  </picture>
</p>

<p align="center"><sub><b>M O D U L E S</b></sub></p>

<p align="center">
  <a href="https://github.com/Sepuldosky/corpus-caliber"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/caliber_logo_dark.svg"><img src="assets/caliber_logo_light.svg" width="60" alt="Caliber"></picture></a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://github.com/Sepuldosky/corpus-cargo"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/cargo_logo_dark.svg"><img src="assets/cargo_logo_light.svg" width="60" alt="Cargo"></picture></a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://github.com/Sepuldosky/corpus-coagulant"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/coagulant_logo_dark.svg"><img src="assets/coagulant_logo_light.svg" width="60" alt="Coagulant"></picture></a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://github.com/Sepuldosky/corpus-craving"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/craving_logo_dark.svg"><img src="assets/craving_logo_light.svg" width="60" alt="Craving"></picture></a>
  &nbsp;&nbsp;&nbsp;
  <a href="https://github.com/Sepuldosky/corpus-cortex"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/cortex_logo_dark.svg"><img src="assets/cortex_logo_light.svg" width="60" alt="Cortex"></picture></a>
</p>

<p align="center"><sub>C A L I B E R &nbsp;·&nbsp; C A R G O &nbsp;·&nbsp; C O A G U L A N T &nbsp;·&nbsp; C R A V I N G &nbsp;·&nbsp; C O R T E X</sub></p>

<p align="center"><sub><b>A D D O N S</b></sub></p>

<p align="center">
  <a href="https://github.com/Sepuldosky/corpus-stalker"><picture><source media="(prefers-color-scheme: dark)" srcset="assets/stalker_logo_dark.svg"><img src="assets/stalker_logo_light.svg" width="60" alt="Corpus S.T.A.L.K.E.R."></picture></a>
</p>

<p align="center"><sub>S T A L K E R</sub></p>

# Corpus

**Thin** framework for **Garry's Mod** that hosts an ecosystem of realistic gameplay modules
for Sandbox. Each module is an independent addon that declares Corpus as its only hard
dependency; the user installs only the modules they want, or all of them, and every
combination produces an honest system — never a broken half. Analogy in the same stack:
**VJ Base + SNPCs**, **ARC9 + weapon packs**.

## The ecosystem

| Module | Domain | Status |
|---|---|---|
| [**Caliber**](https://github.com/Sepuldosky/corpus-caliber) | Combat: EFT-style zonal armor, energy shields, per-limb HP, ballistic penetration | In code, verified |
| [**Cargo**](https://github.com/Sepuldosky/corpus-cargo) | STALKER/GAMMA-style inventory: grid, item framework, equipment, containers, trade | In code, verified |
| [**Coagulant**](https://github.com/Sepuldosky/corpus-coagulant) | ACE3-style player medic: zonal wounds, bleeding, vitals, treatment, zonal debuffs | In code, verified |
| [**Craving**](https://github.com/Sepuldosky/corpus-craving) | Player survival: hunger and hydration | In code, verified |
| [**Cortex**](https://github.com/Sepuldosky/corpus-cortex) | NPC AI: combat tactics + affect (pain, fear) | In code, unverified |

Besides the five modules, [**Corpus S.T.A.L.K.E.R.**](https://github.com/Sepuldosky/corpus-stalker)
is the Zone's **content** addon (anomalies, artifacts, PDA, detectors, NPC and item defs). It's
not a module: the framework and the modules are **generic** — they know nothing about the Zone —
and the content addon is what turns them into a concrete game, consuming them without pushing
anything back up.

Two cardinal rules hold the design together:

- **Corpus stays thin.** It only hosts demonstrably shared infrastructure; no domain logic
  (armor math, bleed curves, inventory grid) goes up into the framework — it lives in its
  owning module, and everything else consumes it through the registry.
- **The only hard dependency is Corpus.** Every cross-module link is a soft dependency:
  detected at runtime (`Corpus.GetModule`/`Corpus.HasModule`), never assumed, and it degrades
  gracefully if the partner isn't present.

## The API — 7 primitives

| Primitive | Contract |
|---|---|
| **Registry** | `Corpus.RegisterModule(name, iface)` · `Corpus.HasModule(name)` · `Corpus.GetModule(name)` |
| **Persistence** | `Corpus.Data.Save/Load(module, key, tbl)` → `data/corpus/<module>/<key>.json` |
| **Net** | `Corpus.Net.Register(module, msgName)` → `"corpus_<module>_<msgName>"` |
| **UI shell** | `Corpus.UI.RegisterTab(module, label, buildFn)` — single "Corpus" category in the Q menu (Utilities) |
| **Ready barrier** | `Corpus.OnReady(fn)` — runs once after `InitPostEntity`, with every module registered |
| **Log** | `Corpus.Log(module, ...)` — prefix `[Corpus:<module>]` |
| **Interact** | `Corpus.Interact.Register(module, ...)` / `Resolve` / `Enabled` — the protocol a module uses to hang a contextual action; today it's data only, no rendering or execution yet |

Full detail (signatures, the registry's by-ref invariant, module boundaries) →
[`docs/CORPUS_Architecture.md`](docs/CORPUS_Architecture.md) §3.

## Installation

Clone into `garrysmod/addons/` (no Workshop release yet):

```
garrysmod/addons/corpus/            ← this repo (required by every module)
garrysmod/addons/corpus-<module>/   ← whichever modules you want
```

Quick check: the console command `corpus_selftest` self-tests the primitives on
whichever realm it runs on (on a listen server, server realm: `lua_run Corpus._SelfTest()`).

## Documentation

- [`docs/CORPUS_Architecture.md`](docs/CORPUS_Architecture.md) — framework design, dependency graph, workspace.
- [`docs/corpus_estado.md`](docs/corpus_estado.md) · [`docs/corpus_roadmap.txt`](docs/corpus_roadmap.txt) · [`docs/CHANGELOG.md`](docs/CHANGELOG.md) — living docs.
- [`docs/corpus_flujo_trabajo.txt`](docs/corpus_flujo_trabajo.txt) — work methodology, canonical for the ecosystem's seven repos.
- [`docs/Corpus_Identidad.md`](docs/Corpus_Identidad.md) — visual identity: parent brand, glyph family, accent palette, asset usage.
- [`CLAUDE.md`](CLAUDE.md) — guide for assistance with Claude Code.
