$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$roles=Get-ChildItem -LiteralPath (Join-Path $root 'src/agents') -Filter '*.toml'
if($roles.Count -ne 16){throw "Expected 16 roles"}
foreach($r in $roles){if($r.Name -match 'fast'){throw 'Fast role forbidden'}; if(!(Select-String -Path $r.FullName -Pattern '^model_reasoning_effort = ')){throw "Effort missing $($r.Name)"}}
Write-Host 'PASS: 16 roles and no Fast variants'
