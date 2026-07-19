#Requires -Version 5.1
<#
.SYNOPSIS
    Checker determinista del registro de IDs normativos (docs/ids.yaml). Valida el yaml,
    los prefijos, los duplicados, las sedes y la evidencia contra las SIETE raices del
    workspace. Bloque C del plan anti-drift.

.DESCRIPTION
    Es el anillo BARATO de la coherencia (corpus_flujo_trabajo.txt sec. 7.2/7.4): caza la
    parte MECANICA del drift -- huerfanos, bicefalos, sedes rotas, evidencia rota -- que
    hasta ahora se cazaba "a grep manual antes de cerrar". La contradiccion SEMANTICA entre
    prosa NO es asunto de este script: eso es el gate LLM (sec. 7.8), que corre aparte y
    caro. Los dos anillos no se solapan a proposito: el gate no re-deriva lo que este script
    ya probo, y este script no opina sobre significado.

    LIMITE DELIBERADO, no lo estires: la evidencia es PRESENCIAL, no semantica. Este script
    prueba que el archivo EXISTE y que el check CITA el ID; jamas que el test ejerza bien el
    invariante. Eso lo cubren la curaduria humana y el autor en juego. A nadie le esta
    permitido leerle al checker mas de lo que hace.

    FALLA RUIDOSO, NUNCA EN SILENCIO: si falta python o pyyaml, sale con error y la linea de
    instalacion. Un checker que se saltea a si mismo emite un "limpio" falso, que es el peor
    resultado posible (leccion sec. 10.8 de Kontrol: un limpio sobre un doc que el gate no
    pudo ver no es evidencia de nada).

    NOTA DE ENCODING: ASCII puro a proposito, igual que sync.ps1. Windows PowerShell 5.1 lee
    los .ps1 sin BOM como ANSI: cualquier caracter no-ASCII en un string literal rompe el
    parser. Por eso este archivo no lleva acentos ni el signo de seccion.

    PYTHON: PowerShell 5.1 no parsea YAML (no trae ConvertFrom-Yaml). Se usa python UNA vez
    para convertir el yaml a JSON -- el resto es nativo (ConvertFrom-Json + Select-String).
    El loader de python ademas rechaza claves duplicadas, que yaml.safe_load aceptaria en
    silencio quedandose con la ultima: esa es la deteccion de BICEFALO exacto.

.PARAMETER Quiet
    Solo imprime errores y el veredicto. Para el hook de pre-commit.

.PARAMETER Changed
    Lista de rutas tocadas por el commit (relativas al workspace). Si se pasa y ninguna es
    superficie normativa, el script no corre. Lo usa el hook.

.PARAMETER IdsPath
    Registro alternativo. Existe para los FIXTURES de test/: un checker que nadie vio en
    rojo no es evidencia de nada. En uso normal se omite.

.EXAMPLE
    .\.claude\check-ids\corpus_check_ids.ps1

.EXAMPLE
    .\.claude\check-ids\corpus_check_ids.ps1 -Quiet
#>
[CmdletBinding()]
param(
    [switch]$Quiet,
    [string[]]$Changed,
    [string]$IdsPath,
    [string]$WorkspaceRootOverride
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$sec = [char]0x00A7   # el signo de seccion, emitido por codigo (ver nota de encoding)

# --- Rutas: el script vive en <workspace>/corpus/.claude/check-ids/ ---
$ScriptDir     = $PSScriptRoot
$RepoRoot      = (Resolve-Path (Join-Path $ScriptDir '..\..')).Path
$WorkspaceRoot = (Resolve-Path (Join-Path $RepoRoot '..')).Path
if (-not $IdsPath) { $IdsPath = Join-Path $RepoRoot 'docs\ids.yaml' }
# Los fixtures traen su propio arbol: sin esto, un registro de test convierte cada cita
# REAL del ecosistema en un huerfano y el ruido tapa lo que el fixture prueba.
if ($WorkspaceRootOverride) { $WorkspaceRoot = (Resolve-Path $WorkspaceRootOverride).Path }

# --- Las siete raices (misma tabla que sync.ps1) ---
$Repos = @('corpus','corpus-cortex','corpus-caliber','corpus-coagulant','corpus-craving','corpus-cargo','corpus-stalker')

# Superficie normativa: si un commit no toca nada de esto, el hook no dispara.
$NormativeGlobs = @('docs/', 'CLAUDE.md', 'ids.yaml')

function Write-Info { param([string]$m) if (-not $Quiet) { Write-Host $m } }

# El CORPUS ESCANEADO de una raiz: CLAUDE.md + docs/**/*.{md,txt} + lua/**/*.lua.
# Quedan FUERA a proposito:
#   - ids.yaml            es el REGISTRO, no el corpus: se indexa a si mismo si entra.
#   - .claude/desktop-sync/  es un ESPEJO del ecosistema: contarlo duplicaria cada cita.
#   - docs/auditorias/    son ACTAS: PROPONEN, no normalizan. Un acta nombra IDs
#     hipoteticos ("esperando a que alguien acune CTX-1") y IDs de hallazgo propios;
#     leerlas como corpus normativo convierte cada propuesta en un huerfano. Kontrol
#     las excluye por lo mismo -- ahi nacieron sus 11 bicefalos. [Agregado 2026-07-19:
#     el acta del piloto v3 puso al checker en rojo por citar CTX-1 en prosa.]
# El filtro de extension va por Where-Object y no por -Include: en PS 5.1, -Include con
# -LiteralPath + -Recurse devuelve archivos que no matchean (colo ids.yaml en la primera
# corrida, y el registro se auditaba a si mismo).
function Get-CorpusFiles {
    param([string]$Root)
    $out = @()
    $claude = Join-Path $Root 'CLAUDE.md'
    if (Test-Path -LiteralPath $claude) { $out += (Get-Item -LiteralPath $claude) }
    foreach ($sub in @('docs','lua')) {
        $p = Join-Path $Root $sub
        if (-not (Test-Path -LiteralPath $p)) { continue }
        $out += @(Get-ChildItem -LiteralPath $p -Recurse -File -ErrorAction SilentlyContinue |
                  Where-Object {
                      $_.Extension -eq '.lua' -or $_.Extension -eq '.md' -or $_.Extension -eq '.txt'
                  } |
                  Where-Object { $_.Name -ne 'ids.yaml' } |
                  Where-Object { $_.FullName -notlike '*\desktop-sync\*' } |
                  Where-Object { $_.FullName -notlike '*\auditorias\*' })
    }
    return $out
}

# =====================================================================
# Gate del hook: correr solo si el commit toca superficie normativa
# =====================================================================
if ($PSBoundParameters.ContainsKey('Changed') -and $Changed) {
    $touches = $false
    foreach ($f in $Changed) {
        $n = $f.Replace('\','/')
        foreach ($g in $NormativeGlobs) {
            if ($n -like "*$g*") { $touches = $true; break }
        }
        if ($touches) { break }
    }
    if (-not $touches) {
        Write-Info "check-ids: el commit no toca superficie normativa, no corre."
        exit 0
    }
}

# =====================================================================
# Dependencia: python + pyyaml. Falla RUIDOSO.
# =====================================================================
$py = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $py) {
    Write-Host ""
    Write-Host "check-ids FALLA: no se encontro 'python' en el PATH." -ForegroundColor Red
    Write-Host "  PowerShell 5.1 no parsea YAML; el checker usa python solo para eso."
    Write-Host "  Instalar python, o correr el checker a mano y revisar ids.yaml."
    Write-Host "  (No se saltea el check: un 'limpio' que no corrio no es un limpio.)"
    exit 1
}

if (-not (Test-Path -LiteralPath $IdsPath)) {
    Write-Host "check-ids FALLA: no existe $IdsPath" -ForegroundColor Red
    exit 1
}

# Loader que RECHAZA claves duplicadas (yaml.safe_load se quedaria con la ultima en
# silencio; una clave repetida en `ids:` es un BICEFALO exacto y tiene que ser rojo).
#
# TODO va por STDOUT como envelope JSON, y python sale SIEMPRE con 0. Motivo: en PS 5.1,
# un ejecutable nativo que escribe en stderr dispara NativeCommandError y, con
# ErrorActionPreference='Stop', vuela la sesion aunque el redirect sea a archivo. El
# envelope esquiva la trampa entera. ensure_ascii queda en su default (True): la salida
# es ASCII pura y PowerShell no la mangla.
$PyScript = @'
import sys, json

def out(obj):
    print(json.dumps(obj, default=str))
    sys.exit(0)

try:
    import yaml
except ImportError:
    out({"ok": False, "cat": "NO_PYYAML", "error": "falta el modulo pyyaml"})

class DupKeyLoader(yaml.SafeLoader):
    pass

def _no_dups(loader, node, deep=False):
    mapping = {}
    dups = []
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in mapping:
            dups.append(str(key))
        mapping[key] = loader.construct_object(value_node, deep=deep)
    if dups:
        raise yaml.YAMLError("claves duplicadas: " + ", ".join(dups))
    return mapping

DupKeyLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, _no_dups)

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        data = yaml.load(f, Loader=DupKeyLoader)
except Exception as e:
    out({"ok": False, "cat": "YAML_INVALIDO", "error": str(e).replace("\n", " ")})

# default=str: pyyaml devuelve `fecha: 2026-07-16` como objeto date, que json no
# serializa. No nos importa el tipo: el checker solo lee texto.
out({"ok": True, "data": data})
'@

$raw = ($PyScript | & python - "$IdsPath" | Out-String)
if ([string]::IsNullOrWhiteSpace($raw)) {
    Write-Host ""
    Write-Host "check-ids FALLA: python no devolvio nada al parsear el registro." -ForegroundColor Red
    Write-Host "  No se saltea el check: un 'limpio' que no corrio no es un limpio."
    exit 1
}

$env = $raw | ConvertFrom-Json
if (-not $env.ok) {
    Write-Host ""
    if ($env.cat -eq 'NO_PYYAML') {
        Write-Host "check-ids FALLA: falta el modulo pyyaml." -ForegroundColor Red
        Write-Host "  Instalar con:  pip install pyyaml"
        Write-Host "  (Es la unica dependencia del checker. No se saltea el check.)"
    } else {
        Write-Host "check-ids FALLA - $($env.cat) en $IdsPath" -ForegroundColor Red
        Write-Host "  $($env.error)"
    }
    exit 1
}

$Reg = $env.data

# =====================================================================
# Modelo: familias, excluidas, ids
# =====================================================================
function Get-Props { param($obj) if ($null -eq $obj) { return @() } return @($obj.PSObject.Properties) }

$Familias  = @(Get-Props $Reg.familias | ForEach-Object { $_.Name })
$Excluidas = @()
if ($Reg.PSObject.Properties.Name -contains 'familias_excluidas') {
    $Excluidas = @(Get-Props $Reg.familias_excluidas | ForEach-Object { $_.Name })
}
$IdEntries = @(Get-Props $Reg.ids)

$Errors = New-Object System.Collections.Generic.List[object]
function Add-Err {
    param([string]$Cat, [string]$Id, [string]$Detalle)
    $Errors.Add([pscustomobject]@{ Cat = $Cat; Id = $Id; Detalle = $Detalle })
}

# Forma canonica: COR-1 y COR-01 son EL MISMO ID (comparacion canonica, igual que Kontrol).
function Get-Canon {
    param([string]$Id)
    if ($Id -match '^([A-Z]+)-0*([0-9]+)$') { return "$($Matches[1])-$([int]$Matches[2])" }
    return $Id
}

# =====================================================================
# CHECK 1 - FAMILIA_NO_REGISTRADA / PREFIJO_EXCLUIDO / DUPLICADO
# =====================================================================
$canonSeen = @{}
foreach ($e in $IdEntries) {
    $id = $e.Name
    if ($id -notmatch '^([A-Z]+)-([0-9]+)$') {
        Add-Err 'ID_MALFORMADO' $id "no tiene forma PREFIJO-numero"
        continue
    }
    $prefix = $Matches[1]

    if ($Excluidas -contains $prefix) {
        Add-Err 'PREFIJO_EXCLUIDO' $id "el prefijo '$prefix' esta en familias_excluidas: no puede acunar normas (sec. 7.4)"
    } elseif ($Familias -notcontains $prefix) {
        Add-Err 'FAMILIA_NO_REGISTRADA' $id "el prefijo '$prefix' no esta en la tabla familias. Registrarlo ANTES de acunar su primer ID (FLU-30)"
    }

    $canon = Get-Canon $id
    if ($canonSeen.ContainsKey($canon)) {
        Add-Err 'DUPLICADO' $id "colisiona con '$($canonSeen[$canon])' en forma canonica ($canon) - BICEFALO"
    } else {
        $canonSeen[$canon] = $id
    }
}

# =====================================================================
# CHECK 2 - SEDE_ROTA. La sede arranca con una ruta relativa al workspace.
# =====================================================================
function Get-SedePath {
    param([string]$Sede)
    if ([string]::IsNullOrWhiteSpace($Sede)) { return $null }
    $tok = ($Sede -split '\s+')[0]
    $tok = $tok -replace ':[0-9]+(-[0-9]+)?$', ''    # corpus_x.lua:6-18 -> corpus_x.lua
    if ($tok -notmatch '\.(md|txt|lua|yaml|ps1|py)$') { return $null }
    return $tok
}

# CHECK 2a - la sede de cada FAMILIA. [Agregado 2026-07-19, hallazgo (b) del acta v3.]
# La familia CTX declaraba sede en corpus-cortex/CLAUDE.md, que NO EXISTE, y se salvaba del
# rojo porque el checker solo miraba la sede de los IDs. Una familia con sede rota es una
# trampa cargada: el dia que alguien acune CTX-1 la escribe contra un archivo fantasma.
# EXCEPCION: una familia puede declararse `pendiente: true` -- reserva el prefijo (FLU-30
# exige registrarlo ANTES de acunar el primer ID) sin exigir que la sede exista todavia.
# Pero si tiene entradas, la sede TIENE que existir: reservar no es acunar.
foreach ($f in (Get-Props $Reg.familias)) {
    $fam = $f.Name
    $tieneIds = @($IdEntries | Where-Object { $_.Name -match "^$fam-[0-9]+$" }).Count -gt 0
    $pendiente = $false
    if ($f.Value.PSObject.Properties.Name -contains 'pendiente') { $pendiente = [bool]$f.Value.pendiente }

    $sedeF = ''
    if ($f.Value.PSObject.Properties.Name -contains 'sede') { $sedeF = [string]$f.Value.sede }
    if (-not $sedeF) { Add-Err 'SEDE_VACIA' "familia:$fam" "la familia no declara sede"; continue }

    $relF = Get-SedePath $sedeF
    if ($null -eq $relF) { continue }
    $fullF = Join-Path $WorkspaceRoot ($relF -replace '/', '\')
    if (Test-Path -LiteralPath $fullF) { continue }

    if ($pendiente -and -not $tieneIds) { continue }   # reserva legitima
    if ($pendiente -and $tieneIds) {
        Add-Err 'SEDE_ROTA' "familia:$fam" "declarada `pendiente` pero YA tiene IDs acunados, y su sede '$relF' no existe"
    } else {
        Add-Err 'SEDE_ROTA' "familia:$fam" "la sede de la familia apunta a un archivo que no existe: '$relF'"
    }
}

foreach ($e in $IdEntries) {
    $sede = $null
    if ($e.Value.PSObject.Properties.Name -contains 'sede') { $sede = [string]$e.Value.sede }
    if ([string]::IsNullOrWhiteSpace($sede)) {
        Add-Err 'SEDE_VACIA' $e.Name "la entrada no declara sede"
        continue
    }
    $rel = Get-SedePath $sede
    if ($null -eq $rel) {
        Add-Err 'SEDE_ROTA' $e.Name "no se pudo extraer una ruta de la sede: '$sede'"
        continue
    }
    $full = Join-Path $WorkspaceRoot ($rel -replace '/', '\')
    if (-not (Test-Path -LiteralPath $full)) {
        Add-Err 'SEDE_ROTA' $e.Name "la sede apunta a un archivo que no existe: '$rel'"
    }
}

# =====================================================================
# CHECK 3 - EVIDENCIA_ROTA + metrica INTENCION
#   - INTENCION: literal, valido, cuenta para la metrica de salud.
#   - tipo planilla: el ref trae un ID de check (ej "Coagulant G4"). PRESENCIAL: se exige
#     que ese ID de check este CITADO en algun doc/codigo del repo del modulo.
#   - otros tipos: si el ref contiene algo con forma de ruta, el archivo debe existir.
# =====================================================================
$ModuloRepo = @{
    'corpus' = 'corpus'; 'cortex' = 'corpus-cortex'; 'caliber' = 'corpus-caliber'
    'coagulant' = 'corpus-coagulant'; 'craving' = 'corpus-craving'
    'cargo' = 'corpus-cargo'; 'stalker' = 'corpus-stalker'
}

# Cache de texto por repo, para no releer siete arboles por cada evidencia.
$RepoText = @{}
function Get-RepoText {
    param([string]$Repo)
    if ($RepoText.ContainsKey($Repo)) { return $RepoText[$Repo] }
    $root = Join-Path $WorkspaceRoot $Repo
    $sb = New-Object System.Text.StringBuilder
    if (Test-Path -LiteralPath $root) {
        $files = @(Get-CorpusFiles -Root $root)
        foreach ($f in $files) {
            [void]$sb.AppendLine([System.IO.File]::ReadAllText($f.FullName))
        }
    }
    $RepoText[$Repo] = $sb.ToString()
    return $RepoText[$Repo]
}

$intencion = 0
foreach ($e in $IdEntries) {
    $ev = $null
    if ($e.Value.PSObject.Properties.Name -contains 'evidencia') { $ev = $e.Value.evidencia }

    if ($null -eq $ev) {
        Add-Err 'EVIDENCIA_AUSENTE' $e.Name "no declara evidencia ni el literal INTENCION (FLU-31)"
        continue
    }
    if ($ev -is [string]) {
        if ($ev -eq 'INTENCION') { $intencion++ }
        else { Add-Err 'EVIDENCIA_ROTA' $e.Name "evidencia escalar '$ev' no es el literal INTENCION" }
        continue
    }

    foreach ($item in @($ev)) {
        $tipo = ''; $ref = ''
        if ($item.PSObject.Properties.Name -contains 'tipo') { $tipo = [string]$item.tipo }
        if ($item.PSObject.Properties.Name -contains 'ref')  { $ref  = [string]$item.ref }
        if (-not $tipo) { Add-Err 'EVIDENCIA_ROTA' $e.Name "una entrada de evidencia no declara tipo"; continue }

        if ($tipo -eq 'planilla') {
            # "Coagulant G4 - ronda 3..." / "Coagulant A-D y F" / "Caliber J4"
            if ($ref -match '^\s*([A-Za-z]+)\s+([A-Z][0-9]+)\b') {
                $mod  = $Matches[1].ToLower()
                $chk  = $Matches[2]
                if (-not $ModuloRepo.ContainsKey($mod)) {
                    Add-Err 'EVIDENCIA_ROTA' $e.Name "evidencia planilla cita un modulo desconocido: '$mod'"
                } else {
                    $txt = Get-RepoText $ModuloRepo[$mod]
                    if ($txt -notmatch "\b$chk\b") {
                        Add-Err 'EVIDENCIA_ROTA' $e.Name "el check '$chk' no esta citado en ningun doc ni codigo de $($ModuloRepo[$mod]) - la planilla no dejo rastro citable (deuda D-2)"
                    }
                }
            }
            continue
        }

        # Otros tipos: validar SOLO los refs con forma de ruta real desde el workspace.
        # Se exige raiz conocida + separador: 'corpus-cargo/lua/x.lua' se valida, pero
        # 'dev.lua:22' o 'corpus_caliber_init.lua:52' NO -- esos son menciones en prosa,
        # y tratarlos como rutas daba diez falsos positivos en la primera corrida.
        # El resto del ref es prosa a proposito: el checker valida lo que es checkeable
        # y no inventa. La calidad de la cita la cubre la curaduria (sec. 7.4).
        if ($ref -match '(?<p>(?:dev|corpus(?:-[a-z]+)?)/[\w\-./ ]*[\w\-.]+\.(?:lua|py|ps1|md|txt|yaml))(?::[0-9]+(?:-[0-9]+)?)?') {
            $p = $Matches['p']
            $full = Join-Path $WorkspaceRoot ($p -replace '/', '\')
            if (-not (Test-Path -LiteralPath $full)) {
                Add-Err 'EVIDENCIA_ROTA' $e.Name "la evidencia ($tipo) apunta a un archivo que no existe: '$p'"
            }
        }
    }
}

# =====================================================================
# CHECK 4 - HUERFANOS. Un ID citado en el corpus que el registro no define.
#   El regex se DERIVA de la tabla familias (FLU-27: enumerar desde un doc es
#   como se hereda un error). Los prefijos de familias_excluidas quedan fuera
#   por construccion: el checker es ciego a ellos por diseno.
#   Corpus escaneado: CLAUDE.md + docs/ + lua/ de las siete raices.
#   FUERA: ids.yaml (es el registro, no el corpus) y .claude/desktop-sync/ (es
#   un ESPEJO: contarlo duplicaria cada cita del ecosistema).
# =====================================================================
if ($Familias.Count -eq 0) {
    Add-Err 'YAML_INVALIDO' 'familias' "la tabla familias esta vacia: sin ella el checker no puede buscar huerfanos"
}
$idRegex = '\b(' + (($Familias | Sort-Object) -join '|') + ')-[0-9]+\b'
$defined = @{}
foreach ($e in $IdEntries) { $defined[(Get-Canon $e.Name)] = $true }

$scanned = 0
foreach ($repo in $Repos) {
    $root = Join-Path $WorkspaceRoot $repo
    if (-not (Test-Path -LiteralPath $root)) { continue }

    foreach ($f in (Get-CorpusFiles -Root $root)) {
        $scanned++
        $isCode = ($f.Extension -eq '.lua')
        $lineNo = 0
        foreach ($line in [System.IO.File]::ReadAllLines($f.FullName)) {
            $lineNo++
            foreach ($m in [regex]::Matches($line, $idRegex)) {
                $cited = Get-Canon $m.Value
                if (-not $defined.ContainsKey($cited)) {
                    $rel = $f.FullName.Substring($WorkspaceRoot.Length + 1).Replace('\','/')
                    $cat = if ($isCode) { 'HUERFANO_CODIGO' } else { 'HUERFANO_DOC' }
                    Add-Err $cat $m.Value "citado en ${rel}:${lineNo} y no definido en el registro (FLU-30: alta en el mismo parche)"
                }
            }
        }
    }
}

# =====================================================================
# Reporte
# =====================================================================
$total = $IdEntries.Count
$pct = 0
if ($total -gt 0) { $pct = [math]::Round(100 * $intencion / $total) }

Write-Info ""
Write-Info "check-ids - registro de IDs normativos del ecosistema Corpus"
Write-Info "  Registro : docs/ids.yaml"
Write-Info "  IDs      : $total en $($Familias.Count) familia(s); $($Excluidas.Count) prefijo(s) excluido(s)"
Write-Info "  Corpus   : $scanned archivo(s) escaneados en las siete raices"
Write-Info ("  Salud    : {0} INTENCION de {1} ({2}%) - la metrica a bajar ({3}7.4)" -f $intencion, $total, $pct, $sec)

if ($Errors.Count -eq 0) {
    Write-Info ""
    Write-Host "check-ids OK: el registro esta limpio." -ForegroundColor Green
    Write-Info ""
    Write-Info "Recordatorio del limite: esto es coherencia MECANICA. La contradiccion"
    Write-Info "semantica entre prosa no la ve este script: eso es el gate LLM (sec. 7.8,"
    Write-Info ".claude/workflows/auditoria-coherencia-docs.js), que se dispara aparte."
    exit 0
}

Write-Host ""
Write-Host "check-ids FALLA: $($Errors.Count) hallazgo(s)" -ForegroundColor Red
foreach ($g in ($Errors | Group-Object Cat | Sort-Object Name)) {
    Write-Host ""
    Write-Host "  [$($g.Name)] x$($g.Count)" -ForegroundColor Yellow
    foreach ($err in $g.Group) {
        Write-Host "    $($err.Id): $($err.Detalle)"
    }
}
Write-Host ""
exit 1
