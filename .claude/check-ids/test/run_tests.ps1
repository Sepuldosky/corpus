#Requires -Version 5.1
<#
.SYNOPSIS
    Tests del checker de IDs. Un fixture por categoria de error.

.DESCRIPTION
    Existe por la leccion sec. 10.8 de Kontrol: un checker que nadie vio en ROJO no es
    evidencia de nada. Cada fixture prueba que el checker falla POR SU CATEGORIA -- no
    basta con que salga distinto de cero, porque un script roto tambien sale 1 y pareceria
    que "funciona".

    El fixture 'verde' prueba lo contrario: que el checker no inventa hallazgos.
    El fixture 'huerfano' NO define COR-1 y se apoya en el arbol REAL, donde corpus/CLAUDE.md
    lo cita: por eso el checker debe cazarlo.

    ASCII puro (ver la nota de encoding del checker).

.EXAMPLE
    .\.claude\check-ids\test\run_tests.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$TestDir  = $PSScriptRoot
$Checker  = (Resolve-Path (Join-Path $TestDir '..\corpus_check_ids.ps1')).Path
$Fixtures = Join-Path $TestDir 'fixtures'
$Tree     = (Resolve-Path (Join-Path $Fixtures 'tree')).Path   # arbol falso: tests hermeticos

# fixture -> categoria esperada ('' = debe salir limpio)
$Cases = @(
    [pscustomobject]@{ File = 'verde.yaml';                    Expect = '' }
    [pscustomobject]@{ File = 'yaml-invalido.yaml';            Expect = 'YAML_INVALIDO' }
    [pscustomobject]@{ File = 'duplicado.yaml';                Expect = 'YAML_INVALIDO' }   # clave repetida: la caza el loader
    [pscustomobject]@{ File = 'duplicado-canonico.yaml';       Expect = 'DUPLICADO' }
    [pscustomobject]@{ File = 'familia-no-registrada.yaml';    Expect = 'FAMILIA_NO_REGISTRADA' }
    [pscustomobject]@{ File = 'familia-sede-rota.yaml';        Expect = 'SEDE_ROTA' }        # sede de FAMILIA, no de ID
    [pscustomobject]@{ File = 'familia-pendiente-ok.yaml';     Expect = '' }                 # reserva legitima: pasa
    [pscustomobject]@{ File = 'prefijo-excluido.yaml';         Expect = 'PREFIJO_EXCLUIDO' }
    [pscustomobject]@{ File = 'sede-rota.yaml';                Expect = 'SEDE_ROTA' }
    [pscustomobject]@{ File = 'evidencia-rota.yaml';           Expect = 'EVIDENCIA_ROTA' }
    [pscustomobject]@{ File = 'evidencia-planilla-rota.yaml';  Expect = 'EVIDENCIA_ROTA' }
    [pscustomobject]@{ File = 'huerfano.yaml';                 Expect = 'HUERFANO_DOC' }
)

$pass = 0
$fail = 0

Write-Host ""
Write-Host "Tests del checker de IDs"
Write-Host ""

foreach ($c in $Cases) {
    $path = Join-Path $Fixtures $c.File
    # 6>&1: el checker reporta con Write-Host, que NO va al pipeline sino al stream de
    # informacion. Sin esto $out llega vacio y el test verifica el exit code contra la nada.
    $out  = (& $Checker -IdsPath $path -WorkspaceRootOverride $Tree 6>&1 | Out-String)
    $code = $LASTEXITCODE

    if ($c.Expect -eq '') {
        $ok = ($code -eq 0)
        $why = "esperaba limpio (exit 0), dio $code"
    } else {
        $ok = ($code -ne 0) -and ($out -match [regex]::Escape($c.Expect))
        $why = "esperaba exit!=0 con [$($c.Expect)]; exit=$code"
    }

    if ($ok) {
        $pass++
        Write-Host ("  OK   {0,-32} {1}" -f $c.File, $(if ($c.Expect) { $c.Expect } else { 'limpio' })) -ForegroundColor Green
    } else {
        $fail++
        Write-Host ("  FALLA {0,-31} {1}" -f $c.File, $why) -ForegroundColor Red
        Write-Host "        --- salida del checker ---"
        foreach ($l in ($out -split "`r?`n" | Where-Object { $_ -ne '' })) { Write-Host "        $l" }
    }
}

Write-Host ""
if ($fail -eq 0) {
    Write-Host "$pass/$($Cases.Count) OK - el checker se pone rojo por cada categoria, y verde cuando debe." -ForegroundColor Green
    exit 0
}
Write-Host "$fail de $($Cases.Count) fallaron." -ForegroundColor Red
exit 1
