# Corpus — Estado de HOY

> **Foto del AHORA**, volátil. Es lo primero que se lee al retomar el proyecto —
> **antes** que el doc de arquitectura. Se actualiza **en sitio** (no se agregan
> secciones ni historial). El historial vive en `git` + [`CHANGELOG.md`](CHANGELOG.md).
> Si crece de una pantalla, está mal redactado: recortar.

**Última actualización:** 2026-07-09 (6 primitivas implementadas, falta verificación en juego)

---

## Qué existe hoy

- **Block 1 cerrado (diseño) y bajado a código:** las 6 primitivas de la API
  ([`CORPUS_Architecture.md`](CORPUS_Architecture.md) §3) implementadas en
  `lua/autorun/` — registro (con invariante by-ref, anotado en §3), persistencia,
  net, UI shell, ready barrier, log + comando `corpus_selftest`. Mapa archivo → rol
  en [`CLAUDE.md`](../CLAUDE.md). Todo shared salvo la UI (client). Pasaron un
  harness offline con stubs de GMod (46 checks, ambos realms); la verificación en
  juego sigue pendiente (abajo). Una vez verificadas, quedan listas para que Caliber
  las consuma (CC Prompt #2 depende de ese cierre).
- **Workspace multi-root + metodología:** seis raíces (`corpus/` + cinco módulos) +
  `dev/` fuera de git; set de docs vivos portado de ADS/Kontrol, con el patrón doc
  general vs. particular ya formalizado en
  [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).
- **Los seis repos publicados en GitHub** (`github.com/Sepuldosky/<repo>`, públicos).
  `corpus/` con commits pusheados a `main`; los cinco hermanos vacíos, esperando su
  Block de diseño. Legacy ADS 2.0 en `dev/legacy/` como referencia para la migración
  a Caliber (§7 de la arquitectura).

## Pendiente de verificar

- **PASO 4 en juego** (parches 1-7 del CHANGELOG, hoy `[PENDIENTE]`): mapa con
  `corpus/` como único addon → `corpus_selftest` en consola (en listen server, realm
  server: `lua_run Corpus._SelfTest()`) debe dar "todo OK" — cubre by-ref del
  registro, ruta de Data, namespacing de Net, disparo único de OnReady y prefijo de
  Log. La UI se confirma visual: menú Q → Utilities → categoría "Corpus" (requiere un
  tab dummy vía `Corpus.UI.RegisterTab`, o esperar al primer módulo real). Al
  confirmar: flipear los parches a `[APLICADO]`.

## Remanentes / deuda conocida

- **Sin `addon.json` todavía** — el repo aún no se puede empaquetar para Workshop
  (§8 de la arquitectura pide uno por raíz). No bloquea el testeo local en
  `garrysmod/addons/`.
- **`docs/Caliber_Architecture.md` está en este repo, sin commitear** — es el diseño
  del Block 2 de Caliber; decidir si vive acá o en `corpus-caliber/docs/` cuando
  arranque CC Prompt #2.

## Próximo paso

1. El autor verifica en juego (checklist de arriba) y flipea el CHANGELOG.
2. **CC Prompt #2:** migración ADS→Caliber consumiendo las primitivas
   (`Caliber_Architecture.md` §3-§7 + checklist §12).

---

*Rumbo / qué sigue → [`corpus_roadmap.txt`](corpus_roadmap.txt). Diseño de referencia →
[`CORPUS_Architecture.md`](CORPUS_Architecture.md). Metodología →
[`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).*
