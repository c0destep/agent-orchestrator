$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$roles=Get-ChildItem -LiteralPath (Join-Path $root 'src/agents') -Filter '*.toml'
if($roles.Count -ne 16){throw "Expected 16 roles"}
foreach($r in $roles){if($r.Name -match 'fast'){throw 'Fast role forbidden'}; if(!(Select-String -Path $r.FullName -Pattern '^model_reasoning_effort = ')){throw "Effort missing $($r.Name)"}}
Write-Host 'PASS: 16 roles and no Fast variants'

$obs = Join-Path $root 'src/skills/agent-orchestrator/references/observability.md'
if(!(Test-Path -LiteralPath $obs)){throw 'Observability policy missing'}
foreach($term in @('START','DONE','FAILED','FALLBACK','unverified','configured')){
 if(!(Select-String -LiteralPath $obs -Pattern $term -SimpleMatch)){throw "Observability token missing: $term"}
}
Write-Host 'PASS: observability policy present'
