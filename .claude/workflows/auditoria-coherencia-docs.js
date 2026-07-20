export const meta = {
  name: 'auditoria-coherencia-docs',
  description: 'Auditoria doc-vs-doc del ecosistema Corpus, adjudicada contra el Lua / estado.md / CHANGELOG',
  whenToUse: 'Cuando haya que verificar que los docs de diseno de las siete raices no se contradicen entre si ni contra la realidad del arbol. args: { fecha: "2026-07-16", piloto: true|false, destino: "ruta" }',
  phases: [
    { title: 'Conteo', detail: 'Deriva del arbol el largo real de cada doc: la columna `total` es un checksum, no la fuente' },
    { title: 'Glosario', detail: 'Lee docs/ids.yaml: el indice ya existe y el checker lo valida. No se reconstruye por grep.' },
    { title: 'Lectura', detail: 'Un lector por tramo: extrae afirmaciones normativas con archivo:linea, tema, fuerza y ALCANCE' },
    { title: 'Cruce', detail: 'Un agente por tema: busca contradicciones entre docs dentro de su tema' },
    { title: 'Adjudicacion', detail: '3 verificadores adversariales por candidata; el Lua / estado.md / CHANGELOG desempatan' },
    { title: 'ContratoArbol', detail: 'Un agente por CLAUDE.md: cada contrato numerado contra el Lua real. No es doc-vs-doc' },
    { title: 'Completitud', detail: 'Critico: que quedo sin cubrir' },
    { title: 'Sintesis', detail: 'Acta en docs/auditorias/ + parches PROPUESTOS (jamas aplicados)' },
  ],
}

// ─────────────────────────────────────────────────────────────────────────────
// Parametros. args puede llegar como objeto o como string JSON segun el
// invocador: si llega string y lo tratamos como objeto, TODOS los flags dan
// undefined EN SILENCIO y el gate corre con los defaults (corpus completo).
// ─────────────────────────────────────────────────────────────────────────────
let ARGS = {}
if (typeof args === 'string') {
  try { ARGS = JSON.parse(args) } catch (e) { ARGS = {} }
} else if (args && typeof args === 'object') {
  ARGS = args
}

const FECHA = ARGS.fecha || '2026-07-16'
const PILOTO = !!ARGS.piloto
const DESTINO = ARGS.destino ||
  `corpus/docs/auditorias/${FECHA}_coherencia_docs${PILOTO ? '_PILOTO' : ''}.md`

// ─────────────────────────────────────────────────────────────────────────────
// Las tres reglas duras de Kontrol, conservadas. Van LITERALES en cada agente.
// ─────────────────────────────────────────────────────────────────────────────
const READ_ONLY = `
MODO READ-ONLY SOBRE LOS SIETE REPOS - NO NEGOCIABLE:
No modifiques, crees ni borres NINGUN archivo dentro de ninguna de las siete raices.
Ni un doc, ni el CHANGELOG, ni ids.yaml, ni Lua, ni el espejo desktop-sync. Nada.
El UNICO archivo que esta auditoria escribe es el acta final, en la ruta que se te
indique explicitamente. Los parches a docs se PROPONEN dentro del acta; JAMAS se
aplican. El gate propone, el autor dispone.
`.trim()

// H8 del COMPLETO 2026-07-19, ya reparado: este bloque DUPLICABA la jerarquia de
// seccion 7.1 en prosa. Un gate que existe porque la prosa duplicada se desincroniza
// no puede permitirse duplicar la norma que lo gobierna. Ahora la CITA por ID y manda
// a leer la sede, que es lo que FLU-26 pide de cualquier otro lugar del ecosistema.
const JERARQUIA = `
JERARQUIA DE AUTORIDAD - la rige FLU-22, y su SEDE es corpus/docs/corpus_flujo_trabajo.txt
seccion 7.1. NO la reproduzcas de memoria: ABRI ESE ARCHIVO Y LEE LA SECCION 7.1 ANTES
DE ADJUDICAR NADA. Si lo que leas ahi difiere de cualquier resumen que hayas visto,
GANA EL ARCHIVO.

Lo unico que este prompt afirma sobre ella, porque define el ALCANCE de tu tarea y no
la norma en si:
  · El codigo Lua, los <modulo>_estado.md y los docs/CHANGELOG.md son ARBITROS: se
    consultan para adjudicar, NUNCA se auditan como sujetos.
  · Los docs de DISENO (las arquitecturas y sus docs particulares) son LOS AUDITADOS.
  · Los CLAUDE.md tienen DOBLE ROL: son arbitro Y son sujeto auditado, porque son la
    sede de decenas de IDs. Se los audita como sede y se los usa como arbitro.
  · docs/ids.yaml NO integra la jerarquia: es INDICE, jamas segunda definicion. Si el
    yaml contradice la prosa de su sede, el DESACTUALIZADO ES EL YAML.
Cuando un doc de diseno choca con un arbitro: el DOC esta mal, no el repo.

FALSOS POSITIVOS QUE DEBES RECHAZAR (este ecosistema disena por delante del codigo A PROPOSITO):
  · "Esto no esta implementado todavia" NO es un hallazgo. JAMAS. El corpus es diseno futuro.
  · Dos docs diciendo LO MISMO con palabras distintas NO es una contradiccion.
  · Distinto NIVEL DE DETALLE no es contradiccion (un doc resume, otro especifica).
  · Distinto ALCANCE no es contradiccion. Verifica el alcance ANTES de declarar choque.
    En este ecosistema el alcance tiene cuatro ejes, y confundirlos es el 90% del ruido:
      - REALM: server / client / shared. Una regla de server y una de client NO chocan.
      - MODULO: cada modulo es dueno de su dominio. "El pool de limbs es de Caliber" y
        "Coagulant no toca limbs" son la MISMA regla vista de los dos lados, no un choque.
      - SOFT-DEP: "sin Cargo, la via es X" y "con Cargo, la via es Y" es DEGRADACION
        HONESTA (COR-11), no contradiccion. Es el patron de produccion del ecosistema.
      - BLOCK / SLICE: una regla de un slice cerrado y una de un slice pendiente
        conviven; el diseno va por delante.
  · MOCK-FIRST (FLU-17) NO es una contradiccion. Un doc que congela la firma de un peer
    que todavia no existe esta HACIENDO SU TRABAJO, no mintiendo. Ejemplo real: Craving
    congelo COAGULANT.ApplyExternalCondition antes de que Coagulant la ratificara. Eso es
    deuda declarada (D-5), no un choque de docs.
SOLO es hallazgo: (a) dos docs que afirman cosas mutuamente INCOMPATIBLES dentro del MISMO
alcance, o (b) un doc que afirma algo que el Lua / estado.md / CHANGELOG ya resolvieron
distinto.

${READ_ONLY}
`.trim()

// ─────────────────────────────────────────────────────────────────────────────
// Taxonomia fija - los buckets del cruce. Un doc puede tocar varios.
// Derivada del dominio real del ecosistema, no de la de Kontrol.
// ─────────────────────────────────────────────────────────────────────────────
// El campo `sedes` NO es decorativo: es lo que distingue un CERO GANADO de un CERO
// VACIO. [Agregado 2026-07-20, Hueco 5 del acta SCOPED.] Antes, un tema cuyas sedes
// viven todas fuera del corpus auditado reportaba "0 contradicciones" igual que un
// tema que se cruzo entero y salio limpio -- indistinguibles en el reporte. Con esto,
// el gate puede decir `N/A por alcance` en vez de mentir por omision.
const TEMAS = [
  { key: 'framework-delgado', sedes: ['corpus'], desc: 'COR-10/COR-1: que sube a Corpus y que no. Logica de dominio en el framework, primitivas candidatas' },
  { key: 'soft-deps',         sedes: ['corpus'], desc: 'COR-11/COR-5: hard-dep unica, deteccion en runtime, lazy-check, degradacion honesta, direccion de las soft-deps' },
  { key: 'realms',            sedes: ['corpus', 'corpus-cargo', 'corpus-coagulant', 'corpus-craving'], desc: 'server/client/shared: defs en ambos realms (COR-12), prediccion de Move, autoridad del server, espejo NW2' },
  { key: 'namespacing',       sedes: ['corpus'], desc: 'COR-2/3/4/6/9: namespace unico, persistencia y net namespaced, prefijo de archivo, autosuficiencia' },
  { key: 'contrato-items',    sedes: ['corpus', 'corpus-cargo'], desc: 'COR-12/13/14 y CRG-*: defs, clases stackable/unique, onUse y su retorno, blob de instancia, footprint' },
  { key: 'boot-carga',        sedes: ['corpus', 'corpus-caliber'], desc: 'CAL-1..9: boot diferido, sonda, manifest explicito, orden de include, nunca invocar hacia adelante' },
  { key: 'dano-limbs',        sedes: ['corpus-caliber', 'corpus-coagulant'], desc: 'Caliber: pipeline escudo/armadura/limbs, hitgroups, zonas, la frontera con Coagulant y Cortex' },
  { key: 'dominio-medico',    sedes: ['corpus-coagulant'], desc: 'Coagulant: heridas, sangrado, tratamiento, debuffs zonales, la frontera con Caliber y Cargo' },
  { key: 'inventario',        sedes: ['corpus-cargo'], desc: 'Cargo: grid, peso, munition, cinturon, comercio, contenedores, la frontera con los modulos duenos' },
  { key: 'ui-vgui',           sedes: ['corpus', 'corpus-cargo', 'corpus-caliber', 'corpus-coagulant', 'corpus-craving'], desc: 'Menu Q, HUD, pcall en HUDPaint, trampas de VGUI, theme, quien pinta que' },
  { key: 'persistencia',      sedes: ['corpus', 'corpus-cargo'], desc: 'COR-3/COR-8: rutas namespaced, round-trip JSON y normalizacion de claves, que persiste y que no' },
  { key: 'evidencia',         sedes: ['corpus'], desc: 'FLU-05..12: la planilla, sus IDs de check, el harness, el selftest, que cuenta como verificado' },
  { key: 'proceso',           sedes: ['corpus'], desc: 'FLU-*: orden de ejecucion, jerarquia, barrido de ratificacion, el PROMPT, el registro, commits' },
  { key: 'assets-licencias',  sedes: ['corpus-stalker'], desc: 'STK-*: consumidor puro, assets fuera de git, rutas verbatim, RECICLAR vs COMPAT-RUNTIME' },

  // ── Los cuatro de la v2 (sumados 2026-07-19, hueco H6 del COMPLETO) ────────
  // Ninguno tenia bucket, asi que sus contradicciones NUNCA SE BUSCARON. Van
  // primero los dos que son FRONTERA ENTRE REPOS, que es donde este gate rinde.
  // El hallazgo de H4 (Coagulant describiendo mal el mecanismo interno de Cargo)
  // es exactamente un hallazgo de `compat-terceros`, y salio de casualidad.
  { key: 'compat-terceros',   sedes: ['corpus-cargo', 'corpus-caliber', 'corpus-coagulant', 'corpus-craving', 'corpus-stalker'], desc: 'EL MAS GRANDE: ARC9 / VJ Base / better movement v2 / DarkRP aparecen en 25 archivos. NO es el eje de LICENCIA (eso es assets-licencias) sino el de CONTRATO DE INTEGRACION RUNTIME: que API se lee, quien es dueno del hook, quien gana cuando dos mods escriben la misma propiedad. CRG-23, CRG-24, el puente ARC9, el movecompat, la deuda Front-4 de Caliber. INCLUYE el eje que H4 destapo: COMO UN MODULO DESCRIBE EL MECANISMO INTERNO DE OTRO -- si el doc de A explica que hace B, verificalo contra el Lua de B, no contra el doc de B' },
  { key: 'ciclo-de-vida-del-jugador', sedes: ['corpus-cargo', 'corpus-coagulant', 'corpus-craving'], desc: 'muerte / respawn / disconnect / PlayerSpawn / PlayerInitialSpawn: 12 archivos. Hoy se repartia entre persistencia, dominio-medico e inventario, y POR ESO NADIE LO CRUZABA ENTERO. El triangulo a mirar: la decision F de Coagulant (spawn = cuerpo nuevo, sin persistencia) contra la persistencia de stats de Craving contra el inventario persistido de Cargo. Tres politicas distintas sobre el mismo evento' },
  { key: 'config-y-balance',  sedes: ['corpus-cargo', 'corpus-caliber', 'corpus-coagulant', 'corpus-craving'], desc: 'convars, tunables, DONDE VIVEN LOS NUMEROS: 24 archivos. CRV-12 (balance = data) y COA-35 (un check jamas hardcodea un numero tunable) son normas duras sin bucket. Ojo al numero que vive en dos lados: el propio yaml anota en CRG-38 que el 2.0 solo vive en el codigo y en un estado.md' },
  { key: 'rendimiento',       sedes: ['corpus-coagulant', 'corpus-craving'], desc: 'Think / timers / presupuesto de red: 7 archivos. CRV-6 (un solo timer) y COA-15 (timer unico de 1s, nunca Think) son normativos y no tenian con que cruzarse. Incluye el costo de replicacion: COA-17 (un NW2 se replica a TODOS los clientes en cada escritura) y COA-16 (snapshot on-change, no por tick)' },
]

// ─────────────────────────────────────────────────────────────────────────────
// Corpus AUDITADO. El Lua, los estado.md y los CHANGELOG NO estan aca: son los
// ARBITROS (jerarquia 1-3). Auditamos DISENO (5) y roadmap (6).
//
// LOS CLAUDE.md SI ENTRAN, y son OBLIGATORIOS en todo modo (piloto incluido).
// [Corregido tras el piloto 2026-07-16, hallazgo 5.2 de su acta.] Un CLAUDE.md es
// arbitro (nivel 4) Y ADEMAS es la SEDE de 32 IDs del ecosistema (corpus 11,
// coagulant 10, cargo 9, stalker 5, craving 4, caliber 3). El valor unico de este
// gate frente al checker es contrastar el `titulo` del yaml contra la PROSA de su
// sede -- y dejarlos fuera nos hizo saltear exactamente los archivos que mas lo
// necesitan. Los dos roles conviven: se AUDITA su prosa como sede, y se lo sigue
// usando como arbitro al adjudicar. Kontrol los excluye y tiene el mismo punto ciego.
// El piloto que los omitio no vio, entre otras, que COR-6 declara un alcance
// ("en lua/autorun/...") que el arbol abandono: 70 de 74 archivos Lua de los modulos
// viven FUERA de autorun.
// ─────────────────────────────────────────────────────────────────────────────
// Conteos DERIVADOS del arbol con wc -l, no estimados a ojo: una norma que enumera se
// deriva del codigo, no de la prosa (FLU-27). Si un doc crece mucho, re-derivar y subir
// su `chunks` -- el tramo apunta a ~1400 lineas, el mismo grano que usa Kontrol.
//
// RE-DERIVADO 2026-07-19 (hallazgo (c) del acta v3, y era grave): la lista tenia 25
// entradas contra 29 docs normativos reales. Faltaban los cuatro convenciones_commits
// de modulo -- que SON normativos: GIT-6 los declara sede de los alcances de cada repo.
// Un COMPLETO contra una lista corta arranca con docs INVISIBLES y su limpio no
// significa nada (es la seccion 10.8 por la puerta de atras). El comando que la deriva:
//   for r in corpus corpus-*; do ls $r/CLAUDE.md $r/docs/*.{md,txt}; done
//   ... excluyendo CHANGELOG (historial), *_estado (foto volatil) y auditorias/ (actas).
// RE-DERIVADO 2026-07-19 (segunda vez, H8 del COMPLETO). La columna `total` estaba
// desincronizada EN LAS 29 FILAS, no en 5: la derivacion anterior habia contado sin
// las lineas vacias. Un `total` corto no rompe la corrida -- rompe algo peor: los
// TRAMOS se calculan con el, asi que la COLA de cada doc quedaba fuera del rango
// leido y nadie lo notaba. Es el modo de falla de la seccion 10.8 (limpio por
// omision) escondido en una constante.
//
// RE-DERIVADO 2026-07-20 (tercera vez, seccion 3.C del PROMPT de reparacion post-gate).
// Desincronizada de nuevo, y en UNA sola fila: corpus_flujo_trabajo.txt decia 720 y el
// arbol tenia 737. Causa: dentro de la MISMA tanda D-13, el PARCHE 9 reescribio la
// seccion 7.8 DESPUES de que el PARCHE 10 derivara los conteos. Las ultimas 17 lineas
// del doc mas normativo del ecosistema quedaron fuera del rango de tramos, y entre ellas
// la seccion 7.8 -- el gate se auditó a si mismo con la cola cortada.
//
// TRES VECES ES UNA CLASE, NO UNA INSTANCIA. Por eso esta columna YA NO ES LA FUENTE:
// la fase 0 (Conteo) deriva el largo real del arbol en cada corrida y los TRAMOS se
// arman con ESE valor. Lo que queda aca es un CHECKSUM -- util para ver el desfase de un
// vistazo y para que la corrida lo reporte, pero ya no puede cortar la cola de nadie.
// Mantenela al dia igual: un desfase grande es señal de que un doc crecio y quizas
// necesita mas `chunks`.
//
// El comando que la deriva (PowerShell), y el detalle que lo hace correcto:
//   @(Get-Content $f).Count      <- SI cuenta las lineas vacias
//   NO: Get-Content $f | Measure-Object -Line   <- las SALTEA, y por eso mentia
// La lista de archivos:
//   for r in corpus corpus-*; do ls $r/CLAUDE.md $r/docs/*.{md,txt}; done
//   ... excluyendo CHANGELOG (historial), *_estado (foto volatil) y auditorias/ (actas).
//
// 32 docs al 2026-07-19 (eran 29): la tanda de D-13 sumo los tres que faltaban --
// stalker gano su arquitectura y sus convenciones (su CLAUDE.md estaba haciendo de
// arquitectura), y Cortex gano el doc de CONTRATOS ENTRANTES, que es el unico lugar
// donde las firmas que otros repos le congelaron se pueden cruzar entre si.
const CORPUS_COMPLETO = [
  // Framework
  { file: 'corpus/CLAUDE.md',                                           total:  90, chunks: 1, repo: 'corpus' },
  { file: 'corpus/docs/corpus_flujo_trabajo.txt',                       total: 737, chunks: 1, repo: 'corpus' },
  { file: 'corpus/docs/CORPUS_Architecture.md',                         total: 356, chunks: 1, repo: 'corpus' },
  { file: 'corpus/docs/corpus_convenciones_commits.txt',                total: 140, chunks: 1, repo: 'corpus' },
  { file: 'corpus/docs/corpus_roadmap.txt',                             total: 112, chunks: 1, repo: 'corpus' },
  // Modulos - el CLAUDE.md primero: es la sede de sus contratos
  { file: 'corpus-cargo/CLAUDE.md',                                     total: 140, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-caliber/CLAUDE.md',                                   total:  86, chunks: 1, repo: 'corpus-caliber' },
  { file: 'corpus-coagulant/CLAUDE.md',                                 total:  83, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-craving/CLAUDE.md',                                   total:  82, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-stalker/CLAUDE.md',                                   total:  98, chunks: 1, repo: 'corpus-stalker' },
  { file: 'corpus-cargo/docs/Cargo_Architecture.md',                    total: 925, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-cargo/docs/cargo_roadmap.txt',                        total: 573, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-cargo/docs/Cargo_Trade_Arquitectura.md',              total: 338, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-cargo/docs/Cargo_ItemImages_Arquitectura.md',         total: 320, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-cargo/docs/Workbench_Arquitectura.md',                total: 185, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-coagulant/docs/Coagulant_Architecture.md',            total: 341, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-coagulant/docs/Coagulant_Block3_Semilla.md',          total: 155, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-coagulant/docs/coagulant_roadmap.txt',                total:  70, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-caliber/docs/Caliber_Architecture.md',                total: 300, chunks: 1, repo: 'corpus-caliber' },
  { file: 'corpus-caliber/docs/Caliber_EnergyShields_Arquitectura.md',  total: 292, chunks: 1, repo: 'corpus-caliber' },
  { file: 'corpus-caliber/docs/caliber_roadmap.txt',                    total: 105, chunks: 1, repo: 'corpus-caliber' },
  { file: 'corpus-craving/docs/Craving_Architecture.md',                total: 404, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-craving/docs/Craving_Block4_Semilla.md',              total: 263, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-craving/docs/craving_roadmap.txt',                    total:  79, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-stalker/docs/ASSETS.md',                              total: 116, chunks: 1, repo: 'corpus-stalker' },
  // Los convenciones_commits de modulo: normativos por GIT-6 (cada repo define su propia
  // tabla de alcances). Faltaban en la v1 de esta lista -- eran cuatro docs invisibles.
  // Desde la tanda D-13 cada uno acuna el ID de su tabla (CAL-23, COA-36, CRV-19, CRG-55),
  // asi que ya no son ciegos al cruce de IDs.
  { file: 'corpus-cargo/docs/cargo_convenciones_commits.txt',           total: 182, chunks: 1, repo: 'corpus-cargo' },
  { file: 'corpus-coagulant/docs/coagulant_convenciones_commits.txt',   total: 167, chunks: 1, repo: 'corpus-coagulant' },
  { file: 'corpus-craving/docs/craving_convenciones_commits.txt',       total: 155, chunks: 1, repo: 'corpus-craving' },
  { file: 'corpus-caliber/docs/caliber_convenciones_commits.txt',       total: 144, chunks: 1, repo: 'corpus-caliber' },
  // Nacidos en la tanda D-13 (2026-07-19), hueco H5 del COMPLETO.
  { file: 'corpus-stalker/docs/STALKER_Arquitectura.md',                total: 112, chunks: 1, repo: 'corpus-stalker' },
  { file: 'corpus-stalker/docs/stalker_convenciones_commits.txt',       total: 172, chunks: 1, repo: 'corpus-stalker' },
  // Cortex: doc de RECEPCION, no de diseno. Su repo no tiene CLAUDE.md todavia.
  { file: 'corpus-cortex/docs/Cortex_ContratosEntrantes.md',            total: 129, chunks: 1, repo: 'corpus-cortex' },
]

// PILOTO: solo el framework. Modo acotado historico: nacio cuando solo la prosa del
// framework llevaba IDs (la deuda D-7 mantuvo fuera a los modulos hasta que la pasada
// de etiquetado del 2026-07-19 la recorto — hoy los modulos tambien llevan los suyos).
// Un gate que cruza IDs es CIEGO a un doc sin IDs: un "limpio" ahi seria "no
// auditado", no "sano" (leccion 10.8 de Kontrol, que alla costo 22 hallazgos).
const CORPUS_PILOTO = CORPUS_COMPLETO.filter(d => d.repo === 'corpus')

const CORPUS = PILOTO ? CORPUS_PILOTO : CORPUS_COMPLETO

// ─────────────────────────────────────────────────────────────────────────────
// FASE 0 - CONTEO. La reparacion de CLASE del defecto que el gate SCOPED del
// 2026-07-20 encontro en si mismo (seccion 3.C del PROMPT de reparacion).
//
// EL DEFECTO, dos veces en dos tandas: `total` es una constante escrita a mano y
// los TRAMOS se calculan con ella, asi que un `total` corto deja la COLA del doc
// fuera del rango leido y NADIE LO NOTA. El 2026-07-20 el doc afectado era
// corpus_flujo_trabajo.txt (script 720, real 737): las ultimas 17 lineas del doc
// MAS NORMATIVO del ecosistema quedaron sin auditar, y entre ellas su propia
// seccion 7.8 -- el gate se auditó a si mismo con la cola cortada. Un limpio con
// la cola cortada es un FALSO-LIMPIO, el unico modo de falla que este gate no
// puede permitirse (seccion 10.8 de Kontrol, escondida en una constante).
//
// POR QUE NO SE DERIVA EN JS: el runtime de estos scripts NO tiene filesystem ni
// APIs de Node. No hay readFileSync. Se delega en un agente, que si tiene Bash.
//
// LA INVERSION DE AUTORIDAD: a partir de aca la fuente del largo es EL ARBOL, y
// la columna `total` es un CHECKSUM. Si discrepan, gana el arbol (no se aborta:
// abortar dejaria al autor sin gate justo despues de editar un doc, que es
// exactamente cuando mas lo necesita) y el desfase VIAJA HASTA EL ACTA. Ruidoso,
// no silencioso: FLU-27 pide que todo numero se derive del arbol, y ahora se
// deriva en cada corrida en vez de a mano cada tantas tandas.
// ─────────────────────────────────────────────────────────────────────────────
phase('Conteo')

const CONTEO_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['conteos'],
  properties: {
    conteos: {
      type: 'array',
      description: 'Una entrada por archivo pedido, en el mismo orden. Ninguno salteado.',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['file', 'lineas'],
        properties: {
          file:   { type: 'string', description: 'La ruta EXACTA tal como se te dio' },
          lineas: { type: 'number', description: 'Largo real en lineas, contando las VACIAS' },
        },
      },
    },
  },
}

const conteo = await agent(
  `Deriva del arbol el largo REAL, en lineas, de cada uno de estos ${CORPUS.length} archivos.

${CORPUS.map(d => d.file).join('\n')}

Las rutas son relativas a la raiz del workspace (la carpeta que contiene corpus/, corpus-cargo/,
corpus-caliber/, corpus-coagulant/, corpus-craving/, corpus-stalker/ y corpus-cortex/).

EL DETALLE QUE HACE O ROMPE ESTA FASE -- las lineas VACIAS CUENTAN:
  · PowerShell:  @(Get-Content $f).Count          <- SI las cuenta
    NO uses:     Get-Content $f | Measure-Object -Line   <- las SALTEA, y ya corrompio
                 esta misma tabla una vez (H8 del COMPLETO 2026-07-19)
  · Bash:        wc -l < "$f"                     <- sirve

Corre UN SOLO comando que los recorra todos; no abras los archivos con Read (son miles de
lineas y no necesitas su contenido, solo su largo).

Devolve una entrada por archivo, con la ruta EXACTA tal como te la di. Si alguno no existe,
devolvelo igual con lineas=0: que un doc del corpus haya desaparecido es informacion, no un
error que debas resolver por tu cuenta.`,
  { label: 'conteo:32-docs', phase: 'Conteo', schema: CONTEO_SCHEMA }
)

// Si la fase 0 muere, el gate NO cae de vuelta a la constante en silencio: eso seria
// reintroducir el defecto. Cae a la constante DECLARANDOLO, y el aviso llega al acta.
const DERIVADO = new Map(
  ((conteo && conteo.conteos) || []).filter(c => c && c.lineas > 0).map(c => [c.file, c.lineas])
)

const DESFASES = []
for (const d of CORPUS) {
  const real = DERIVADO.get(d.file)
  if (real === undefined) {
    DESFASES.push(`${d.file}: NO DERIVADO (la fase de conteo no lo devolvio) - se usa la constante ${d.total}, que puede estar corta`)
    continue
  }
  if (real !== d.total) {
    DESFASES.push(`${d.file}: la constante dice ${d.total} y el arbol tiene ${real} (${real > d.total ? `${real - d.total} linea(s) habrian quedado SIN AUDITAR` : 'la constante sobra'}) - se audita por el arbol`)
  }
  d.total = real          // el arbol manda
}

if (DESFASES.length) {
  log(`DESFASE en la columna \`total\` (${DESFASES.length} doc(s)) - se corrigio en caliente, va al acta:`)
  for (const d of DESFASES) log(`  · ${d}`)
} else {
  log(`Conteo: las ${CORPUS.length} filas de \`total\` coinciden con el arbol`)
}

const TRAMOS = []
for (const d of CORPUS) {
  const span = Math.ceil(d.total / d.chunks)
  for (let i = 0; i < d.chunks; i++) {
    const desde = i * span + 1
    const hasta = Math.min((i + 1) * span, d.total)
    const nombre = d.file.split('/').pop().replace(/\.(md|txt)$/, '')
    TRAMOS.push({
      file: d.file,
      desde,
      hasta,
      label: d.chunks > 1 ? `${nombre}#${i + 1}/${d.chunks}` : nombre,
    })
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schemas de salida estructurada
// ─────────────────────────────────────────────────────────────────────────────
const GLOSARIO_SCHEMA = {
  type: 'object',
  required: ['entradas', 'divergencias'],
  properties: {
    entradas: {
      type: 'array',
      description: 'Una por ID del registro: su titulo y su sede, tal como el yaml los declara',
      items: {
        type: 'object',
        required: ['id', 'sede', 'titulo'],
        properties: {
          id:     { type: 'string' },
          sede:   { type: 'string' },
          titulo: { type: 'string' },
        },
      },
    },
    divergencias: {
      type: 'array',
      description: 'IDs cuyo titulo en el yaml NO coincide con lo que dice la prosa de su sede. El yaml es INDICE: si diverge, el yaml esta desactualizado. Es un hallazgo.',
      items: {
        type: 'object',
        required: ['id', 'sede', 'tituloYaml', 'diceLaSede'],
        properties: {
          id:         { type: 'string' },
          sede:       { type: 'string' },
          tituloYaml: { type: 'string' },
          diceLaSede: { type: 'string' },
        },
      },
    },
  },
}

const LECTURA_SCHEMA = {
  type: 'object',
  required: ['afirmaciones'],
  properties: {
    afirmaciones: {
      type: 'array',
      description: 'Toda afirmacion NORMATIVA del tramo. Exhaustivo: si dudas, incluila.',
      items: {
        type: 'object',
        required: ['ref', 'tema', 'afirmacion', 'fuerza', 'alcance'],
        properties: {
          ref:        { type: 'string', description: 'archivo:linea exacto' },
          tema:       { type: 'string', enum: TEMAS.map(t => t.key) },
          ids:        { type: 'array', items: { type: 'string' }, description: 'IDs (COR-nn, FLU-nn, CAL-nn...) que la afirmacion define o cita' },
          afirmacion: { type: 'string', description: 'AUTOCONTENIDA: legible sin abrir el doc. 1-3 frases. Sin pronombres colgando.' },
          fuerza:     { type: 'string', enum: ['NORMATIVA', 'DESCRIPTIVA', 'EJEMPLO'], description: 'NORMATIVA = debe/nunca/siempre/jamas. Solo las NORMATIVAS pueden contradecirse.' },
          alcance:    { type: 'string', description: 'Los cuatro ejes: REALM (server/client/shared), MODULO, SOFT-DEP (con/sin), BLOCK/SLICE. CRITICO para no inventar choques. Si el doc no lo dice: "no especificado".' },
          sinId:      { type: 'boolean', description: 'true si es NORMATIVA (siempre/nunca/debe/jamas) y NO define ni cita ningun ID. Viola FLU-25 y es un hallazgo por si mismo.' },
        },
      },
    },
  },
}

const CRUCE_SCHEMA = {
  type: 'object',
  required: ['candidatas'],
  properties: {
    candidatas: {
      type: 'array',
      items: {
        type: 'object',
        required: ['refA', 'afirmacionA', 'refB', 'afirmacionB', 'porQueChocan', 'gravedad'],
        properties: {
          refA:         { type: 'string' },
          afirmacionA:  { type: 'string' },
          refB:         { type: 'string' },
          afirmacionB:  { type: 'string' },
          porQueChocan: { type: 'string', description: 'Por que son MUTUAMENTE INCOMPATIBLES dentro del MISMO alcance, no solo distintas' },
          gravedad:     { type: 'string', enum: ['BLOQUEANTE', 'ALTA', 'MEDIA', 'BAJA'] },
        },
      },
    },
  },
}

const VEREDICTO_SCHEMA = {
  type: 'object',
  required: ['esContradiccionReal', 'ganador', 'evidencia'],
  properties: {
    esContradiccionReal: { type: 'boolean' },
    ganador:             { type: 'string', enum: ['A', 'B', 'NINGUNO', 'INDETERMINADO'], description: 'Cual afirmacion sobrevive segun la jerarquia de autoridad' },
    evidencia:           { type: 'string', description: 'Cita con archivo:linea del Lua / estado.md / CHANGELOG que lo decide. Sin evidencia -> INDETERMINADO.' },
    correccion:          { type: 'string', description: 'Parche PROPUESTO al doc perdedor (texto concreto). Vacio si INDETERMINADO.' },
  },
}

// ─────────────────────────────────────────────────────────────────────────────
// FASE 1 - Glosario desde el REGISTRO.
//
// Divergencia deliberada con Kontrol: alla la fase 1 reconstruye el indice de IDs
// a grep, porque su gate se escribio ANTES que su registro. Aca el registro ya
// existe (docs/ids.yaml, 184 IDs) y el CHECKER determinista (seccion 7.7) ya valida
// mecanicamente lo que esa fase buscaba: huerfanos, bicefalos, sedes rotas. Pagarle
// a tres agentes por re-derivar lo que un script prueba en un segundo seria caro y
// PEOR (el script es exhaustivo; el agente, probabilistico).
//
// Es el P-19 de Kontrol -- "cablear el gate al yaml curado" -- hecho desde el dia uno.
// Lo que el gate SI hace, y el checker no puede: verificar que el titulo del yaml
// coincida con la PROSA de su sede. El checker prueba que la sede EXISTE; solo un
// lector puede ver que dice otra cosa.
// ─────────────────────────────────────────────────────────────────────────────
phase('Glosario')
log(`Corpus: ${CORPUS.length} docs - ${TRAMOS.length} tramos${PILOTO ? ' (PILOTO: solo el framework)' : ''}`)

const glos = await agent(
  `Lee el registro de IDs normativos del ecosistema Corpus: corpus/docs/ids.yaml

${JERARQUIA}

TU TRABAJO, en dos partes:

1. GLOSARIO. Devolve una entrada por cada ID del bloque \`ids:\` con su \`titulo\` y su \`sede\`.
   Este glosario viaja a todos los lectores de la fase siguiente para que normalicen
   vocabulario y no inventen significados. Se exhaustivo: son ~184 IDs.
   ${PILOTO ? 'MODO PILOTO: alcanza con las familias COR, FLU y GIT (el piloto solo audita los docs del framework).' : ''}

2. DIVERGENCIAS. Para las entradas de las familias ${PILOTO ? 'COR y FLU' : 'COR, FLU y GIT'}, ABRI la sede y compara:
   ¿el \`titulo\` del yaml dice lo MISMO que la prosa de su sede?
   - El yaml es INDICE, jamas segunda definicion. Si divergen, el YAML esta desactualizado
     (no se litiga contra el doc): es un hallazgo, y va en \`divergencias\`.
   - No reportes diferencias de redaccion: solo divergencias de SIGNIFICADO.
   - NO es tu trabajo buscar huerfanos, bicefalos ni sedes rotas: eso ya lo prueba el
     checker determinista (.claude/check-ids/), que corre en cada commit y esta en verde.
     No lo repitas.`,
  { label: 'glosario:ids.yaml', phase: 'Glosario', schema: GLOSARIO_SCHEMA }
)

const ENTRADAS = (glos && glos.entradas) || []
const DIVERGENCIAS = (glos && glos.divergencias) || []
log(`Glosario: ${ENTRADAS.length} IDs leidos del registro - ${DIVERGENCIAS.length} divergencia(s) yaml-vs-sede`)

const GLOSARIO = ENTRADAS
  .map(d => `${d.id} (${d.sede}): ${d.titulo}`)
  .join('\n')
  .slice(0, 14000)

// ─────────────────────────────────────────────────────────────────────────────
// DOCS SIN IDS PROPIOS - Hueco 4 del acta SCOPED 2026-07-20.
//
// Este gate cruza IDs. Sobre un doc que no es sede de NINGUNO, es CIEGO: su
// "limpio" significa "no auditado", no "sano". Al 2026-07-20 el caso es
// corpus_roadmap.txt, y el Hueco 3 de esa misma acta probo el costo: su etiqueta
// "NO-AUDITABLE POR DISEÑO" se leyo como permiso para NO MIRAR EL DOC, y adentro
// habia un hecho falso (linea 81: Cortex "sin codigo ni docs", cuando
// Cortex_ContratosEntrantes.md existe y tiene 129 lineas).
//
// Intencion pura en el nivel 6 de la jerarquia NO es lo mismo que inauditable: un
// roadmap carga HECHOS VERIFICABLES contra el arbol. Asi que estos docs reciben
// `N/A - sin IDs propios` en vez de `limpio`, Y un pase de VALOR contra el arbol.
// ─────────────────────────────────────────────────────────────────────────────
const SEDES_CON_IDS = ENTRADAS.map(e => e.sede || '')
const DOCS_SIN_IDS = CORPUS
  .map(d => d.file)
  .filter(f => !SEDES_CON_IDS.some(s => s.includes(f)))

if (DOCS_SIN_IDS.length) {
  log(`${DOCS_SIN_IDS.length} doc(s) sin IDs propios - el cruce es CIEGO sobre ellos, van a pase de VALOR: ${DOCS_SIN_IDS.join(', ')}`)
}

// ─────────────────────────────────────────────────────────────────────────────
// FASE 2 - Lectura: un agente por tramo.
// BARRERA REAL: el cruce necesita todas las afirmaciones juntas para agruparlas.
// ─────────────────────────────────────────────────────────────────────────────
phase('Lectura')

const lecturas = await parallel(TRAMOS.map(t => () => agent(
  `Lee ${t.file} lineas ${t.desde}-${t.hasta} y extrae TODA afirmacion normativa, con archivo:linea.

${JERARQUIA}

GLOSARIO DE IDS DEL REGISTRO (usa este vocabulario; no inventes significados):
${GLOSARIO || '(vacio)'}

QUE ES UNA AFIRMACION NORMATIVA:
  Una regla que el sistema DEBE cumplir. "Ningun modulo asume que Corpus ya cargo".
  "Las defs y su onUse van en shared". "Coagulant nunca pisa SetWalkSpeed".
  NO son normativas: la prosa de motivacion, los ejemplos, la historia de por que se
  decidio algo. Marcalas igual pero con fuerza=DESCRIPTIVA o EJEMPLO.

REGLAS DE EXTRACCION (las dos que hacen o rompen esta auditoria):
  · AUTOCONTENIDA. Otro agente leera tu afirmacion SIN abrir el doc. Nada de "esto",
    "dicho modulo", "como se vio arriba". Nombra los sujetos completos.
  · ALCANCE EXPLICITO, siempre, en los cuatro ejes: REALM (server/client/shared),
    MODULO, SOFT-DEP (con o sin el peer), BLOCK/SLICE. El 90% de los falsos positivos
    de esta auditoria nacen de comparar dos afirmaciones de ALCANCE DISTINTO. Si el doc
    no declara el alcance, escribi "no especificado" - eso EN SI MISMO es un hallazgo.

Y marca \`sinId\`: si la afirmacion es NORMATIVA (siempre/nunca/debe/jamas) y no define ni
cita ningun ID del glosario, viola FLU-25 ("una norma sin ID es una norma que va a derivar")
y es un hallazgo por si mismo, aunque no choque con nada.

Se exhaustivo: es preferible una afirmacion de mas que una regla perdida.`,
  { label: `lee:${t.label}`, phase: 'Lectura', schema: LECTURA_SCHEMA }
)))

// COBERTURA PERDIDA - no se descarta en silencio. [Agregado tras el piloto 2026-07-16.]
// Un agente puede morir (error de API, clasificador, timeout) y `filter(Boolean)` lo
// tira sin dejar rastro: el acta despues reporta "auditamos 4 docs" y nadie sabe que
// uno volvio vacio. Eso es un falso-limpio por omision -- el modo de falla exacto de
// la seccion 10.8, cometido por el gate que existe para prevenirlo. Se cuenta y viaja
// hasta el acta.
const TRAMOS_CAIDOS = TRAMOS.filter((_, i) => !lecturas[i])
if (TRAMOS_CAIDOS.length) {
  log(`AVISO: ${TRAMOS_CAIDOS.length} tramo(s) NO se leyeron (agente caido): ${TRAMOS_CAIDOS.map(t => t.label).join(', ')} - su "limpio" no vale`)
}

const AFIRMACIONES = lecturas.filter(Boolean).flatMap(l => l.afirmaciones || [])
const NORMATIVAS = AFIRMACIONES.filter(a => a.fuerza === 'NORMATIVA')
const SIN_ID = NORMATIVAS.filter(a => a.sinId)
log(`Lectura: ${AFIRMACIONES.length} afirmaciones - ${NORMATIVAS.length} normativas - ${SIN_ID.length} normativas SIN ID (violan FLU-25)`)

// ─────────────────────────────────────────────────────────────────────────────
// FASE 3+4 - Cruce por tema -> Adjudicacion, en PIPELINE.
// Cada tema adjudica apenas termina su cruce; no espera a los otros.
// ─────────────────────────────────────────────────────────────────────────────
phase('Cruce')

const porTema = await pipeline(
  TEMAS,

  // Etapa A - cruce dentro del tema.
  // `sinClaims: true` distingue "el tema no tenia nada que cruzar" de "el agente murio":
  // sin eso, los dos casos son un objeto vacio y el tema caido pasa por tema limpio.
  (tema) => {
    const claims = NORMATIVAS.filter(a => a.tema === tema.key)
    if (claims.length < 2) return { candidatas: [], sinClaims: true }
    return agent(
      `Busca CONTRADICCIONES entre docs en el tema "${tema.key}" (${tema.desc}).

${JERARQUIA}

Estas son TODAS las afirmaciones normativas que los ${CORPUS.length} docs auditados hacen
sobre este tema, cada una con su archivo:linea y su alcance declarado:

${JSON.stringify(claims, null, 1)}

TU TRABAJO: encontrar pares MUTUAMENTE INCOMPATIBLES.

Antes de emitir cada par, aplica este filtro y descarta si falla ALGUNO:
  1. ¿Coincide el ALCANCE de ambas, en los cuatro ejes (realm, modulo, soft-dep, slice)?
     Si difieren, NO es contradiccion - es especializacion. Descarta.
  2. ¿Son realmente incompatibles, o es la misma regla redactada distinto? Descarta redacciones.
  3. ¿Podrian ser ambas verdaderas a la vez? Si si, no es contradiccion. Descarta.
  4. ¿Una es solo mas detallada que la otra? Eso es refinamiento, no choque. Descarta.
  5. ¿Una describe el camino CON un soft-dep y la otra SIN el? Eso es degradacion honesta
     (COR-11), el patron de produccion del ecosistema. Descarta.

Prefiero 3 contradicciones reales que 30 candidatas de las cuales 27 son ruido.
Si el tema esta limpio, devolve lista vacia - es un resultado perfectamente valido.

GRAVEDAD: BLOQUEANTE = construir siguiendo un doc rompe lo que el otro exige (romper un
contrato COR-nn, un invariante de datos, o la degradacion honesta de un soft-dep).
BAJA = inconsistencia cosmetica o de nombres.`,
      { label: `cruce:${tema.key}`, phase: 'Cruce', schema: CRUCE_SCHEMA }
    )
  },

  // Etapa B - adjudicacion adversarial de cada candidata (3 lentes distintas)
  (cruce, tema) => {
    // El agente de cruce murio: el tema NO se cruzo. No es un tema limpio -- es un
    // tema no auditado, y tiene que llegar al acta como tal.
    if (!cruce) return [{ __temaCaido: tema.key }]
    const cands = cruce.candidatas || []
    if (!cands.length) return []
    return parallel(cands.map(c => () => {
      const CASO = `
CONTRADICCION CANDIDATA (tema: ${tema.key}, gravedad alegada: ${c.gravedad})

  AFIRMACION A - ${c.refA}
    "${c.afirmacionA}"

  AFIRMACION B - ${c.refB}
    "${c.afirmacionB}"

  Por que se alega que chocan: ${c.porQueChocan}
`.trim()

      const LENTES = [
        {
          key: 'refutador',
          prompt: `Tu trabajo es REFUTAR esta contradiccion. Empezas asumiendo que es FALSA y que el
otro agente se equivoco.

${CASO}

${JERARQUIA}

ABRI LOS DOS DOCS y lee cada pasaje EN SU CONTEXTO (mas o menos 40 lineas alrededor). Casi
siempre la "contradiccion" se disuelve al leer el parrafo completo: alcances distintos, una
es un ejemplo, una fue derogada y el doc lo dice tres lineas mas abajo, una habla del camino
sin el soft-dep, o son sinonimos.

Solo si tras leer ambos contextos completos siguen siendo MUTUAMENTE IMPOSIBLES, admiti
esContradiccionReal=true. Ante la duda: FALSE.`,
        },
        {
          key: 'arbitro-codigo',
          prompt: `Sos el arbitro que consulta la VERDAD FINAL: el codigo Lua.

${CASO}

${JERARQUIA}

Anda al arbol y averigua cual de las dos afirmaciones describe la realidad. Busca en el
lua/ de las siete raices, en los defs, y en los CLAUDE.md. Usa Grep/Glob/Read con generosidad.

DOS SALIDAS POSIBLES Y SOLO DOS:
  · Encontras Lua que decide -> ganador=A o B, y evidencia CON archivo:linea del codigo.
  · El codigo aun no existe (mucho de este diseno va por delante, y Cortex esta vacio)
    -> ganador=INDETERMINADO. Eso NO es un fracaso: es informacion.

NUNCA inventes evidencia. Si no citas archivo:linea real, tu ganador es INDETERMINADO.
Ojo: que el codigo no exista NO convierte la contradiccion en falsa. Dos docs pueden
contradecirse perfectamente sobre algo que aun no se construyo - sigue siendo un hallazgo
(esContradiccionReal puede ser true con ganador INDETERMINADO). En este ecosistema eso es
FRECUENTE y tiene nombre: es el corolario de la seccion 7.1 (una afirmacion sobre algo NO
CONSTRUIDO no tiene arbitro) y va a VOTO del autor, no a parche.`,
        },
        {
          key: 'arbitro-historia',
          prompt: `Sos el arbitro que consulta la HISTORIA: ¿una de las dos ya fue derogada?

${CASO}

${JERARQUIA}

Busca en los docs/CHANGELOG.md de las siete raices, en los <modulo>_estado.md, y en
corpus/docs/auditorias/. Pregunta clave: ¿hubo una entrada [APLICADO] que resolvio esto y
uno de los dos docs simplemente no se actualizo? Ese es el patron de deriva mas comun de
este ecosistema - la pasada de veracidad del 2026-07-14 tuvo que limpiar exactamente eso.

Busca por los IDs implicados, por las palabras clave del tema, y por fecha: la afirmacion
MAS NUEVA que haya sido aplicada gana sobre la mas vieja que nadie toco. Ojo tambien con
los reportes de planilla: un check en FALLA que se arreglo deroga lo que el doc prometia.

Si encontras la ratificacion -> ganador = el lado que coincide, evidencia = CHANGELOG:linea.
Si no hay rastro -> INDETERMINADO.`,
        },
      ]

      return parallel(LENTES.map(l => () => agent(l.prompt, {
        label: `${l.key}:${c.refA.split('/').pop()}`,
        phase: 'Adjudicacion',
        schema: VEREDICTO_SCHEMA,
      }))).then(veredictos => {
        const vs = veredictos.filter(Boolean)
        const votosReal = vs.filter(v => v.esContradiccionReal).length
        // Sobrevive por MAYORIA (>=2 de 3). El refutador solo no puede matarla,
        // pero si los tres dudan, muere.
        const confirmada = votosReal >= 2
        const decisivo = vs.find(v => v.ganador === 'A' || v.ganador === 'B')
        return {
          ...c,
          tema: tema.key,
          confirmada,
          votosReal,
          ganador: decisivo ? decisivo.ganador : 'INDETERMINADO',
          evidencia: decisivo ? decisivo.evidencia : vs.map(v => v.evidencia).filter(Boolean).join(' | '),
          correccion: decisivo ? decisivo.correccion : '',
          veredictos: vs,
        }
      })
    }))
  }
)

// La deteccion va POR INDICE contra TEMAS, y ANTES de filtrar. [Corregido 2026-07-16,
// corrida _v3.] El detector anterior vivia en la etapa B del pipeline y no servia para
// nada: un agente BLOQUEADO hace throw, un stage que throwea tira el item entero a null
// y SALTEA los stages siguientes -- asi que la etapa B jamas corria, y el filter(Boolean)
// de abajo borraba la evidencia antes de mirarla. La _v3 reporto `degradada: false` con
// DOS temas sin cruzar: el detector de falsos-limpios emitiendo un falso-limpio.
// Se cubren los dos caminos: el item tirado a null (throw) y el marcador de la etapa B
// (por si agent() devuelve null sin throwear).
const TEMAS_CAIDOS = [
  ...TEMAS.filter((_, i) => !porTema[i]).map(t => t.key),
  ...porTema.filter(Boolean).flat().filter(f => f && f.__temaCaido).map(f => f.__temaCaido),
]
const CRUDO = porTema.filter(Boolean).flat()
const TODAS = CRUDO.filter(f => f && !f.__temaCaido)
const CONFIRMADAS = TODAS.filter(f => f.confirmada)
log(`Adjudicacion: ${TODAS.length} candidatas -> ${CONFIRMADAS.length} confirmadas (${TODAS.length - CONFIRMADAS.length} refutadas)`)
if (TEMAS_CAIDOS.length) {
  log(`AVISO: ${TEMAS_CAIDOS.length} tema(s) NO se cruzaron (agente caido): ${TEMAS_CAIDOS.join(', ')} - no estan limpios, estan sin auditar`)
}

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO POR BUCKET - Hueco 5 del acta SCOPED 2026-07-20.
//
// EL DEFECTO: un cero de contradicciones se reportaba igual viniera de donde
// viniera. "0" en `dominio-medico` durante un PILOTO no significa que Coagulant
// este limpio: significa que sus sedes no estaban en el corpus y NO HABIA DOS
// TEXTOS QUE CRUZAR. Y "0" en `rendimiento` no significa limpio tampoco:
// significa que el tema tiene superficie real y CERO NORMAS que la gobiernen --
// un tema donde el gate no puede fallar y tampoco puede servir.
//
// Colapsar los tres casos en un cero es la mentira por omision que este gate
// existe para no cometer. Ahora cada bucket declara CUAL de los cinco estados
// tiene, y el acta los reporta sin colapsar.
// ─────────────────────────────────────────────────────────────────────────────
const REPOS_EN_CORPUS = new Set(CORPUS.map(d => d.repo))

const TEMAS_ESTADO = TEMAS.map(t => {
  const claims = NORMATIVAS.filter(a => a.tema === t.key).length
  const hallazgos = CONFIRMADAS.filter(f => f.tema === t.key).length
  const enAlcance = (t.sedes || []).filter(r => REPOS_EN_CORPUS.has(r))

  let estado, porQue
  if (TEMAS_CAIDOS.includes(t.key)) {
    estado = 'NO CRUZADO'
    porQue = 'el agente de cruce murio: no esta limpio, esta sin auditar'
  } else if (!enAlcance.length) {
    estado = 'N/A por alcance'
    porQue = `todas las sedes de este tema (${(t.sedes || []).join(', ') || 'sin sedes declaradas'}) quedaron FUERA del corpus auditado: su cero es vacio por construccion`
  } else if (claims === 0) {
    estado = 'sin normas que cruzar'
    porQue = 'el tema esta en alcance y no se extrajo ni UNA afirmacion normativa: tema con superficie y sin norma, donde el gate no puede fallar ni servir'
  } else if (claims === 1) {
    estado = 'sin normas que cruzar'
    porQue = 'una sola afirmacion normativa en todo el corpus: no hay par posible'
  } else if (hallazgos > 0) {
    estado = `${hallazgos} hallazgo(s)`
    porQue = `${claims} normativas cruzadas`
  } else {
    estado = 'limpio'
    porQue = `${claims} normativas cruzadas entre si, ninguna contradiccion sobrevivio a la adjudicacion`
  }
  return { tema: t.key, estado, porQue, normativas: claims, hallazgos }
})

const N_A_ALCANCE = TEMAS_ESTADO.filter(t => t.estado === 'N/A por alcance').length
const SIN_NORMAS = TEMAS_ESTADO.filter(t => t.estado === 'sin normas que cruzar').length
log(`Buckets: ${TEMAS_ESTADO.filter(t => t.estado === 'limpio').length} limpio(s) - ${N_A_ALCANCE} N/A por alcance - ${SIN_NORMAS} sin normas que cruzar - ${TEMAS_CAIDOS.length} NO cruzado(s)`)

// La cobertura perdida viaja al acta. Si esto queda vacio, la cobertura fue completa;
// si no, el acta tiene que DECIRLO en su seccion de huecos, no maquillarlo.
const COBERTURA_PERDIDA = [
  ...TRAMOS_CAIDOS.map(t => `tramo NO leido: ${t.file} lineas ${t.desde}-${t.hasta}`),
  ...TEMAS_CAIDOS.map(t => `tema NO cruzado: ${t}`),
]

// ─────────────────────────────────────────────────────────────────────────────
// FASE 5 - CONTRATO-VS-ARBOL. Un agente por CLAUDE.md.
//
// H7 del COMPLETO 2026-07-19. Los CLAUDE.md YA entraban al corpus y 13 de los 26
// hallazgos tocaron uno -- ese arreglo funciono. Lo que NO se hacia es la pasada
// contrato-por-contrato CONTRA EL LUA: de los 53 contratos numerados de los cinco
// CLAUDE.md de modulo, solo cinco produjeron hallazgo, y los tres mas accionables de
// toda la corrida (2.3, 2.4, 2.18) salieron por esa via DE CASUALIDAD.
//
// Por que merece fase propia: NO es doc-vs-doc, asi que ninguna fase anterior lo
// cubre. El cruce compara afirmaciones entre si; esto compara UNA afirmacion contra
// el arbol. Y el asimetria de autoridad lo hace barato de adjudicar: un CLAUDE.md es
// nivel 4 y el Lua es nivel 1, asi que cuando chocan NO HAY QUE DELIBERAR -- el
// CLAUDE.md esta mal. Es, ademas, el doc que todo ejecutor lee primero.
//
// Sin adjudicacion adversarial a proposito: el veredicto lo da el archivo:linea del
// Lua, no una mayoria de opiniones. Lo que si se exige es la CITA.
// ─────────────────────────────────────────────────────────────────────────────
phase('ContratoArbol')

const CONTRATO_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['repo', 'contratos'],
  properties: {
    repo: { type: 'string' },
    contratos: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['numero', 'enunciado', 'veredicto', 'evidencia'],
        properties: {
          numero:    { type: 'string', description: 'Numero o titulo del contrato tal como lo lista el CLAUDE.md' },
          enunciado: { type: 'string', description: 'Que afirma el contrato, autocontenido' },
          idsCitados:{ type: 'array', items: { type: 'string' }, description: 'IDs que el contrato define o cita' },
          veredicto: {
            type: 'string',
            enum: ['CUMPLIDO', 'INCUMPLIDO', 'PARCIAL', 'NO_VERIFICABLE'],
            description: 'CUMPLIDO = el Lua lo ejerce y lo citas. INCUMPLIDO = el Lua hace otra cosa (el CLAUDE.md esta mal). PARCIAL = se cumple en unos call sites y no en otros. NO_VERIFICABLE = no hay codigo todavia (diseno por delante) o es una norma de proceso sin superficie en el arbol.',
          },
          evidencia: { type: 'string', description: 'archivo:linea del Lua. OBLIGATORIO salvo NO_VERIFICABLE.' },
          detalle:   { type: 'string', description: 'Solo si INCUMPLIDO o PARCIAL: que dice el arbol y como habria que corregir el CLAUDE.md' },
        },
      },
    },
  },
}

const CLAUDES = CORPUS.filter(d => d.file.endsWith('CLAUDE.md'))

const contratos = await parallel(CLAUDES.map(d => () => agent(
  `Verifica CONTRATO POR CONTRATO el archivo ${d.file} contra el ARBOL DE CODIGO REAL de ${d.repo}.

${JERARQUIA}

GLOSARIO DE IDS DEL REGISTRO:
${GLOSARIO || '(vacio)'}

TU TRABAJO: abri ${d.file}, tomá su seccion de contratos (los "Contratos que no debes
romper" -- estan numerados) y, UNO POR UNO, andá a buscar su implementacion en el Lua de
${d.repo}/lua/**. No opines desde el doc: ABRI LOS ARCHIVOS.

Esto NO es doc-vs-doc. Es doc-vs-ARBOL, y la asimetria de autoridad hace el veredicto
barato: un CLAUDE.md es nivel 4 y el Lua es nivel 1. Cuando chocan, EL CLAUDE.md ESTA MAL
-- no hay nada que deliberar. Y es el doc que todo ejecutor lee primero, asi que un
contrato que miente se propaga a todo lo que se escriba despues.

Para cada contrato devolve un veredicto CON archivo:linea del Lua. Reglas:
  · CUMPLIDO exige CITA. Sin archivo:linea no hay CUMPLIDO -- eso es NO_VERIFICABLE.
  · Un contrato que dice "TODOS los X pasan por Y" se verifica buscando los X que NO
    pasan por Y. Encontrar un solo call site que cumple NO prueba el "todos": si el
    contrato es universal, buscá el contraejemplo. Si no lo buscaste, es PARCIAL.
  · NO_VERIFICABLE es un veredicto legitimo y frecuente: este ecosistema disena por
    delante del codigo A PROPOSITO. "Todavia no esta implementado" NUNCA es INCUMPLIDO.
    Tampoco lo son las normas de proceso (idioma, commits, que doc leer): no tienen
    superficie en el arbol.
  · PARCIAL es el veredicto mas valioso y el que mas se pierde: el contrato se cumple en
    la ruta principal y se lo saltea en una rama. Buscá activamente esa rama.

Se exhaustivo: TODOS los contratos numerados, ninguno salteado. Si el archivo lista 13,
devolve 13 entradas.`,
  { label: `contrato:${d.repo}`, phase: 'ContratoArbol', schema: CONTRATO_SCHEMA }
)))

const CONTRATOS_OK = contratos.filter(Boolean)
const CLAUDES_CAIDOS = CLAUDES.filter((_, i) => !contratos[i]).map(d => d.file)
const CONTRATOS_TODOS = CONTRATOS_OK.flatMap(c =>
  (c.contratos || []).map(x => ({ ...x, repo: c.repo })))
const CONTRATOS_ROTOS = CONTRATOS_TODOS.filter(
  c => c.veredicto === 'INCUMPLIDO' || c.veredicto === 'PARCIAL')

log(`Contrato-vs-arbol: ${CONTRATOS_TODOS.length} contratos verificados en ${CONTRATOS_OK.length}/${CLAUDES.length} CLAUDE.md - ${CONTRATOS_ROTOS.length} incumplido(s)/parcial(es)`)
if (CLAUDES_CAIDOS.length) {
  log(`AVISO: ${CLAUDES_CAIDOS.length} CLAUDE.md NO se verificaron contra el arbol (agente caido): ${CLAUDES_CAIDOS.join(', ')}`)
  COBERTURA_PERDIDA.push(...CLAUDES_CAIDOS.map(f => `contratos NO verificados contra el arbol: ${f}`))
}

// ─────────────────────────────────────────────────────────────────────────────
// FASE 6 - Critico de completitud. Lo que encuentre se convierte en trabajo.
// ─────────────────────────────────────────────────────────────────────────────
phase('Completitud')

// PASE DE VALOR sobre los docs ciegos al cruce de IDs (Hueco 4). No cruza prosa
// contra prosa: cruza cada HECHO VERIFICABLE del doc contra el arbol. Es el unico
// eje por el que un doc sin IDs puede auditarse, y el que habria cazado el falso
// de corpus_roadmap.txt:81 en la corrida que lo dejo pasar.
const VALOR_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['hechos'],
  properties: {
    hechos: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['ref', 'afirma', 'veredicto', 'evidencia'],
        properties: {
          ref:       { type: 'string', description: 'archivo:linea exacto' },
          afirma:    { type: 'string', description: 'El hecho verificable, autocontenido' },
          veredicto: { type: 'string', enum: ['VERDADERO', 'FALSO', 'NO_VERIFICABLE'] },
          evidencia: { type: 'string', description: 'Que hay en el arbol. OBLIGATORIO salvo NO_VERIFICABLE: ruta, comando corrido o archivo:linea.' },
          parche:    { type: 'string', description: 'Solo si FALSO: el texto concreto que deberia decir' },
        },
      },
    },
  },
}

const valorados = DOCS_SIN_IDS.length ? await parallel(DOCS_SIN_IDS.map(f => () => agent(
  `Audita ${f} por VALOR contra el arbol real. Este doc no es sede de NINGUN ID, asi que el
cruce de IDs de este gate es CIEGO sobre el: un "limpio" ahi significaria "no auditado".
Vos sos el unico eje que lo mira.

${JERARQUIA}

TU TRABAJO: abri ${f} y extrae cada AFIRMACION DE HECHO VERIFICABLE CONTRA EL ARBOL --
que existe y que no, cuantos hay, que estado tiene cada cosa, que archivo contiene que.
Despues ANDA AL ARBOL Y COMPROBALA, una por una, con Glob/Grep/Read/Bash.

Ejemplos del tipo de afirmacion que buscas (son los que ya fallaron en este ecosistema):
  · "el repo X es semilla, sin codigo ni docs"      -> lista el repo. ¿Es cierto HOY?
  · "el workspace tiene N raices"                    -> contalas.
  · "el slice K esta cerrado / pendiente"            -> cruzalo contra el estado.md y el CHANGELOG.
  · "el archivo Y define Z"                          -> abrilo.

LO QUE NO ES HALLAZGO, y descartarlo es parte del trabajo:
  · La INTENCION y la PRIORIZACION. Un roadmap dice que quiere hacer; eso no se audita.
  · "Todavia no esta implementado" JAMAS es un hallazgo: este ecosistema disena por
    delante del codigo a proposito. Un doc que dice "esto viene despues" esta bien.
  · Solo marcas FALSO cuando el doc afirma un HECHO SOBRE EL PRESENTE y el arbol lo
    desmiente. Ante la duda, NO_VERIFICABLE.

Para cada FALSO, proponé el texto concreto que deberia decir. No lo apliques: este gate
es READ-ONLY y el unico archivo que se escribe es el acta.`,
  { label: `valor:${f.split('/').pop()}`, phase: 'Completitud', schema: VALOR_SCHEMA }
))) : []

const HECHOS_FALSOS = valorados.filter(Boolean).flatMap(v => (v.hechos || []).filter(h => h.veredicto === 'FALSO'))
const DOCS_VALOR_CAIDOS = DOCS_SIN_IDS.filter((_, i) => !valorados[i])
if (DOCS_SIN_IDS.length) {
  log(`Pase de VALOR: ${HECHOS_FALSOS.length} hecho(s) FALSO(s) en ${DOCS_SIN_IDS.length} doc(s) sin IDs propios`)
}
if (DOCS_VALOR_CAIDOS.length) {
  COBERTURA_PERDIDA.push(...DOCS_VALOR_CAIDOS.map(f => `pase de VALOR NO corrido (agente caido): ${f}`))
}

const SIN_ALCANCE = AFIRMACIONES.filter(a => /no especificado/i.test(a.alcance || ''))

const critica = await agent(
  `Sos el critico de completitud de esta auditoria. Tu trabajo NO es revisar los hallazgos:
es encontrar QUE SE NOS ESCAPO.

Lo que se cubrio:
  · Docs auditados (${CORPUS.length}): ${CORPUS.map(d => d.file).join(', ')}
  · Temas cruzados (${TEMAS.length}): ${TEMAS.map(t => t.key).join(', ')}
  · ${AFIRMACIONES.length} afirmaciones extraidas, ${NORMATIVAS.length} normativas
  · ${TODAS.length} contradicciones candidatas, ${CONFIRMADAS.length} confirmadas
  · ${SIN_ID.length} normativas SIN ID (violan FLU-25)
  · ${DIVERGENCIAS.length} divergencias entre el titulo del yaml y la prosa de su sede
  · ${SIN_ALCANCE.length} afirmaciones cuyo ALCANCE el doc nunca declara
  · ${CONTRATOS_TODOS.length} contratos de CLAUDE.md verificados contra el arbol Lua (fase ContratoArbol), ${CONTRATOS_ROTOS.length} incumplido(s)/parcial(es)
${PILOTO ? '  · MODO PILOTO: solo se auditaron los docs del FRAMEWORK. Los de modulo quedaron fuera a proposito (alcance acotado del modo piloto).' : ''}

Contradicciones confirmadas:
${JSON.stringify(CONFIRMADAS.map(f => ({ tema: f.tema, refA: f.refA, refB: f.refB, resumen: f.porQueChocan })), null, 1)}

Contratos que el arbol NO respalda:
${JSON.stringify(CONTRATOS_ROTOS.map(c => ({ repo: c.repo, contrato: c.numero, veredicto: c.veredicto, evidencia: c.evidencia })), null, 1)}

PREGUNTAS QUE DEBES RESPONDER, yendo al arbol a mirar:
  1. ¿Algun doc de diseno de las siete raices quedo FUERA del corpus y deberia estar?
     (lista los docs/ de cada raiz y compara contra la lista de arriba)
  2. ¿Hay algun tema transversal que la taxonomia de ${TEMAS.length} buckets no captura, y por
     tanto sus contradicciones nunca se buscaron? Nombralo.
  3. Un tema con CERO contradicciones, ¿esta limpio de verdad o nadie lo miro bien?
     Señala los sospechosos.
  4. ¿Hay docs que se contradicen con un CLAUDE.md (los contratos no negociables) y que este
     cruce, al comparar solo doc-vs-doc, no podia ver? OJO: la fase ContratoArbol ya barrio
     cada contrato contra el LUA -- no repitas ese trabajo. Lo tuyo es el angulo que ella no
     cubre: contrato-vs-DOC (un doc de arquitectura que promete algo que el CLAUDE.md
     prohibe), y los contratos que volvieron NO_VERIFICABLE, que son puntos ciegos.
  5. LA PREGUNTA DE LA SECCION 10.8: ¿cuantos de los docs auditados NO declaran ningun ID
     propio? Para un gate que cruza IDs, un doc sin IDs es un punto ciego perfecto: un
     "limpio" sobre el no es evidencia de nada - es "no auditado". Contalos y nombralos,
     y decilo con todas las letras en tu respuesta.

Devolve prosa: los huecos concretos, priorizados, cada uno con que habria que hacer para taparlo.`,
  { label: 'critico', phase: 'Completitud' }
)

// ─────────────────────────────────────────────────────────────────────────────
// FASE 6 - Sintesis
// ─────────────────────────────────────────────────────────────────────────────
phase('Sintesis')

await agent(
  `Escribe el acta final de la auditoria de coherencia documental en:
    ${DESTINO}
(ruta EXACTA).

${JERARQUIA}

Las actas son INMUTABLES: son la foto del estado AL MOMENTO DE AUDITAR, no la foto de hoy.
No se editan despues. Toda afirmacion con evidencia archivo:linea. Cero adjetivos sin respaldo.

MATERIAL:

## Contradicciones CONFIRMADAS (${CONFIRMADAS.length}) - sobrevivieron a 3 verificadores adversariales
${JSON.stringify(CONFIRMADAS, null, 1)}

## Divergencias yaml-vs-sede (${DIVERGENCIAS.length}) - el registro dice una cosa y su sede otra
${JSON.stringify(DIVERGENCIAS, null, 1)}

## Normativas SIN ID (${SIN_ID.length}) - violan FLU-25: una norma sin ID va a derivar
${JSON.stringify(SIN_ID.slice(0, 60), null, 1)}

## Afirmaciones sin alcance declarado (${SIN_ALCANCE.length}) - ambiguedad latente
${JSON.stringify(SIN_ALCANCE.slice(0, 40), null, 1)}

## CONTRATO-VS-ARBOL - ${CONTRATOS_TODOS.length} contratos de ${CONTRATOS_OK.length} CLAUDE.md verificados contra el Lua
Esta fase NO es doc-vs-doc: compara cada contrato numerado contra el arbol real. Cuando un
CLAUDE.md (nivel 4) choca con el Lua (nivel 1) NO hay deliberacion -- el CLAUDE.md esta mal,
y es el doc que todo ejecutor lee primero.

Incumplidos y parciales (${CONTRATOS_ROTOS.length}):
${CONTRATOS_ROTOS.length ? JSON.stringify(CONTRATOS_ROTOS, null, 1) : '(ninguno: todos los contratos verificables tienen respaldo en el arbol)'}

Resumen por veredicto:
${JSON.stringify(['CUMPLIDO', 'INCUMPLIDO', 'PARCIAL', 'NO_VERIFICABLE'].map(v =>
  ({ veredicto: v, n: CONTRATOS_TODOS.filter(c => c.veredicto === v).length })), null, 1)}

## ESTADO POR BUCKET - NUNCA colapses estos estados en un conteo de cero
Un cero de contradicciones significa cosas DISTINTAS segun el estado del bucket, y
reportarlos igual es mentir por omision. Los estados son: \`limpio\` (se cruzo y salio
sano), \`N/A por alcance\` (las sedes del tema quedaron fuera del corpus: cero vacio por
construccion), \`sin normas que cruzar\` (el tema esta en alcance y no tiene normas: tema
con superficie y sin norma), \`NO CRUZADO\` (el agente murio: no auditado), o N hallazgos.
${JSON.stringify(TEMAS_ESTADO, null, 1)}

## DOCS SIN IDS PROPIOS (${DOCS_SIN_IDS.length}) - el cruce de IDs es CIEGO sobre ellos
${DOCS_SIN_IDS.length ? JSON.stringify(DOCS_SIN_IDS, null, 1) : '(ninguno: los ${CORPUS.length} docs son sede de al menos un ID)'}
Para estos docs el reporte dice \`N/A - sin IDs propios\`, JAMAS \`limpio\`. En su lugar se
les corrio un PASE DE VALOR contra el arbol, que es el unico eje por el que se los puede
auditar. Sus resultados:

## HECHOS FALSOS hallados por el pase de VALOR (${HECHOS_FALSOS.length})
Afirmaciones sobre el PRESENTE que el arbol desmiente. Son hallazgos de pleno derecho,
triage A por construccion (el arbol es arbitro de nivel 1): van en la seccion 2 con su
parche propuesto, no escondidos en los huecos.
${HECHOS_FALSOS.length ? JSON.stringify(HECHOS_FALSOS, null, 1) : '(ninguno)'}

## DESFASE DE LA COLUMNA \`total\` (${DESFASES.length}) - la fase de Conteo lo corrigio en caliente
${DESFASES.length ? JSON.stringify(DESFASES, null, 1) : '(ninguno: las filas de `total` coincidian con el arbol)'}
Si esta lista NO esta vacia, DECILO en la seccion de huecos: la constante del script estaba
desincronizada con el arbol. La corrida NO quedo degradada por eso (el conteo real se derivo
en la fase 0 y los tramos se armaron con el), pero es deuda de mantenimiento del gate y la
tercera vez que pasa. Si algun doc dice "NO DERIVADO", ESO SI degrada: ese doc se auditó por
una constante sin verificar.

## COBERTURA PERDIDA (${COBERTURA_PERDIDA.length}) - agentes que murieron y NO auditaron su parte
${COBERTURA_PERDIDA.length ? JSON.stringify(COBERTURA_PERDIDA, null, 1) : '(ninguna: la cobertura fue completa)'}

## Critica de completitud
${critica || '(sin critica)'}

ESTRUCTURA DEL ACTA:
  1. Resumen ejecutivo: los hallazgos que CAMBIAN EL PLAN primero. Si construir segun el doc X
     rompe un contrato del doc Y, eso va arriba de todo, con nombre y apellido.
  2. Contradicciones por gravedad (BLOQUEANTE -> BAJA). Cada una: las dos afirmaciones con su
     archivo:linea, quien gana segun la jerarquia de autoridad, la evidencia que lo decide,
     y el parche PROPUESTO al doc perdedor.
     TRIAGE, marca cada hallazgo con su bucket:
       A - REPARABLE: el ganador esta decidido por el Lua, el estado o el CHANGELOG. Se parcha.
       B - VOTO DEL AUTOR: los docs chocan y el codigo NO dirime (seccion 7.1, corolario).
           NO se parcha: se consolida como voto abierto, con las dos posiciones, que depende
           de cada una, y una recomendacion de ingenieria.
       C - BUG DE CODIGO: el doc tiene razon y el Lua esta mal. Va a pasada aparte.
       CADUCO: la frase citada ya no existe.
  3. Patologia del registro: divergencias yaml-vs-sede, y normativas sin ID.
  4. Ambiguedades de alcance.
  4.bis CONTRATO-VS-ARBOL: seccion propia, con la tabla por repo y el detalle de cada
     INCUMPLIDO/PARCIAL. Un contrato INCUMPLIDO es bucket A por construccion (el Lua es el
     arbitro de nivel 1 y ya dirimio: se parcha el CLAUDE.md), asi que no lo mandes a voto.
     Un PARCIAL es el hallazgo mas util de esta fase: el contrato se cumple en la ruta
     principal y se saltea en una rama -- decila con archivo:linea. Y reporta cuantos
     volvieron NO_VERIFICABLE: son el punto ciego de la fase, no su exito.
  4.ter ESTADO POR BUCKET: la tabla de los ${TEMAS.length} temas con su estado, tal como te
     llego arriba. UNA FILA POR TEMA, con su estado y su por que. PROHIBIDO reportar un
     bucket \`N/A por alcance\` o \`sin normas que cruzar\` como "0 contradicciones" o como
     "limpio": son cosas distintas y el lector tiene que poder distinguirlas de un vistazo.
     Y para los docs sin IDs propios, la etiqueta es \`N/A - sin IDs propios\`, nunca \`limpio\`.
  5. Huecos de esta auditoria (de la critica de completitud) - honestidad sobre lo NO cubierto.
     Si algun doc auditado no tiene IDs propios, DECILO ACA con todas las letras: sobre ese
     doc este gate es ciego por el eje de IDs, y su "limpio" significaria "no auditado". Deci
     tambien que se le corrio el PASE DE VALOR y que encontro, porque eso es lo que hoy tapa
     ese hueco parcialmente.
     Si la lista de DESFASE DE LA COLUMNA \`total\` no esta vacia, va aca tambien.
     Y si la lista de COBERTURA PERDIDA de arriba NO esta vacia, ABRI esta seccion con eso,
     en negrita: hubo tramos o temas que ningun agente audito porque su agente murio. Ese
     resultado NO es un limpio parcial: es un no-auditado, y el acta entera debe declararse
     DEGRADADA en su encabezado. Nunca lo maquilles ni lo omitas.
  6. Que NO se auditó y por que: doc-vs-codigo queda fuera del alcance; este acta NO afirma
     que nada este implementado. Los huerfanos, bicefalos y sedes rotas tampoco son de este
     gate: los prueba el checker determinista (.claude/check-ids/), que corre en cada commit.
${PILOTO ? '  7. MODO PILOTO: declara que solo se audito el framework y por que (alcance acotado del piloto).' : ''}

REGLA DURA: el UNICO archivo que escribis en todo el universo es ${DESTINO}.
Ningun doc de arquitectura, ningun README, ningun ids.yaml, ningun archivo de los siete repos.
Los parches se PROPONEN dentro del acta, no se aplican.

Devolve un resumen de 10 lineas de lo que encontraste.`,
  { label: 'acta', phase: 'Sintesis' }
)

return {
  destino: DESTINO,
  piloto: PILOTO,
  // degradada: hubo cobertura perdida. Un acta degradada es una HIPOTESIS, no un cierre.
  degradada: COBERTURA_PERDIDA.length > 0,
  coberturaPerdida: COBERTURA_PERDIDA,
  docsAuditados: CORPUS.length,
  tramos: TRAMOS.length,
  afirmaciones: AFIRMACIONES.length,
  normativas: NORMATIVAS.length,
  sinId: SIN_ID.length,
  divergenciasRegistro: DIVERGENCIAS.length,
  candidatas: TODAS.length,
  confirmadas: CONFIRMADAS.length,
  bloqueantes: CONFIRMADAS.filter(f => f.gravedad === 'BLOQUEANTE').length,
  // Los cuatro que estrena la tanda del 2026-07-20: sin ellos, un cero de este
  // reporte no se distingue de un no-auditado.
  desfaseTotal: DESFASES,
  bucketsPorEstado: {
    limpio:                 TEMAS_ESTADO.filter(t => t.estado === 'limpio').length,
    'N/A por alcance':      N_A_ALCANCE,
    'sin normas que cruzar': SIN_NORMAS,
    'NO CRUZADO':           TEMAS_CAIDOS.length,
    'con hallazgos':        TEMAS_ESTADO.filter(t => /hallazgo/.test(t.estado)).length,
  },
  docsSinIdsPropios: DOCS_SIN_IDS,
  hechosFalsosPorValor: HECHOS_FALSOS.length,
}
