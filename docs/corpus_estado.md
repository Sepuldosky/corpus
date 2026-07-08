# Corpus — Estado de HOY

> **Foto del AHORA**, volátil. Es lo primero que se lee al retomar el proyecto —
> **antes** que el doc de arquitectura. Se actualiza **en sitio** (no se agregan
> secciones ni historial). El historial vive en `git` + [`CHANGELOG.md`](CHANGELOG.md).
> Si crece de una pantalla, está mal redactado: recortar.

**Última actualización:** 2026-07-08 (publicado en GitHub)

---

## Qué existe hoy

- **Block 1 cerrado (diseño):** framework Corpus, grafo de dependencias, superficie de
  API (6 primitivas), contrato de ítems generalizado, orden de carga y workspace —
  todo en [`CORPUS_Architecture.md`](CORPUS_Architecture.md) §1-§9.
- **Workspace multi-root creado:** `corpus.code-workspace` con seis carpetas raíz
  (`corpus/`, `corpus-cortex/`, `corpus-caliber/`, `corpus-coagulant/`,
  `corpus-craving/`, `corpus-cargo/`) + carpeta `dev/` fuera de todo repo git (código
  de referencia, no se publica).
- **Metodología portada:** este set de docs (CLAUDE.md + `corpus_flujo_trabajo.txt` +
  `corpus_convenciones_commits.txt` + `corpus_estado.md` + `corpus_roadmap.txt` +
  `CHANGELOG.md`) adaptado desde el equivalente de ADS 2.0, que a su vez lo portó de
  Kontrol. `corpus_flujo_trabajo.txt` ya formaliza el patrón de doc de arquitectura
  GENERAL (`<modulo>_Architecture.md`, crece por Block) vs. PARTICULAR
  (`<Subsistema>_Arquitectura.md`, autocontenido, se desprende cuando un subsistema lo
  amerita) — patrón que ADS usó en la práctica pero nunca escribió como regla.
- **Legacy ADS 2.0 + VMT Editor** movidos a `dev/legacy/` como material de referencia:
  mod antiguo que se va a revisar y mejorar dentro de Corpus (principalmente su
  migración a Caliber, ver §7 de la arquitectura). Los mods de terceros que traía el
  propio `dev/` de ADS (VJ Base, ARC9 EFT, zbase, drgbase, halo energy shield,
  visceral dynamic blood, etc.) se subieron un nivel a `dev/other/`, junto al resto
  del workspace, para investigación de compatibilidad.
- **Los seis repos publicados en GitHub** (`github.com/Sepuldosky/<repo>`, públicos).
  `corpus/` tiene remote `origin` y sus dos commits pusheados a `main`. Los cinco
  repos hermanos existen en GitHub y tienen `origin` cableado localmente, pero siguen
  vacíos, sin commits ni push, esperando su Block de diseño.

**Cero código Lua todavía.** Ninguna de las 6 primitivas de la API de Corpus
(registro, persistencia, net, UI shell, ready barrier, log) está implementada. Los
cinco repos hermanos (cortex/caliber/coagulant/craving/cargo) están vacíos, esperando
el Block 2/3/4 de diseño.

## Pendiente de verificar

- N/A — no hay código en juego que verificar todavía.

## Remanentes / deuda conocida

- N/A — proyecto recién arrancado.

## Próximo paso (abierto, a decidir)

Dos rutas válidas, sin decidir aún:
1. Implementar las 6 primitivas de Corpus ahora (bajar Block 1 a código) antes de
   diseñar Block 2.
2. Cerrar el diseño de Block 2 (Caliber + Cortex) primero, y recién ahí bajar a
   código (Corpus + Caliber + Cortex juntos, ya que Caliber consumirá las primitivas
   desde el primer commit).

Ver [`corpus_roadmap.txt`](corpus_roadmap.txt) §1.

---

*Rumbo / qué sigue → [`corpus_roadmap.txt`](corpus_roadmap.txt). Diseño de referencia →
[`CORPUS_Architecture.md`](CORPUS_Architecture.md). Metodología →
[`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt).*
