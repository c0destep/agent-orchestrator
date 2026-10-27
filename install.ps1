#Requires -Version 5.1
[CmdletBinding()]
param([ValidateSet('User','Project')][string]$Scope='User',[string]$ProjectPath='.',[switch]$DryRun,[switch]$Force,[switch]$RetireLegacy)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
if($Scope -eq 'Project') {
 $project=(Resolve-Path -LiteralPath $ProjectPath).Path
 $skill=Join-Path $project '.agents/skills/agent-orchestrator'
 $agents=Join-Path $project '.codex/agents'
} else {
 $homeDir=[Environment]::GetFolderPath('UserProfile')
 $skill=Join-Path $homeDir '.agents/skills/agent-orchestrator'
 $codexHome=if($env:CODEX_HOME){$env:CODEX_HOME}else{Join-Path $homeDir '.codex'}
 $agents=Join-Path $codexHome 'agents'
}
$sourceSkill=Join-Path $root 'src/skills/agent-orchestrator'
$plan=@()
foreach($file in (Get-ChildItem -LiteralPath $sourceSkill -File -Recurse)) {
 $rel=$file.FullName.Substring($sourceSkill.Length).TrimStart([char[]]@('\','/'))
 $plan+=@{src=$file.FullName;dst=(Join-Path $skill $rel)}
}
foreach($file in (Get-ChildItem -LiteralPath (Join-Path $root 'src/agents') -Filter '*.toml' -File)) {
 $plan+=@{src=$file.FullName;dst=(Join-Path $agents $file.Name)}
}
function SameFile($a,$b) { if(!(Test-Path -LiteralPath $b -PathType Leaf)){return $false}; return (Get-FileHash -LiteralPath $a -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $b -Algorithm SHA256).Hash }
foreach($item in $plan) {
 if(Test-Path -LiteralPath $item.dst) {
  $target=Get-Item -LiteralPath $item.dst -Force
  if($target.PSIsContainer -or ($target.Attributes -band [IO.FileAttributes]::ReparsePoint)){throw "Unsafe destination: $($item.dst)"}
  if(!$Force -and !(SameFile $item.src $item.dst)){throw "Conflict: $($item.dst)"}
 }
}
$legacy=@()
if($RetireLegacy){foreach($name in @('implementer-fast.toml','reviewer-fast.toml')) {
 $old=Join-Path $agents $name; $back=Join-Path $agents ".agent-orchestrator-retired/v1.2.0/$name"
 if(Test-Path -LiteralPath $old) {if(Test-Path -LiteralPath $back){throw "Backup exists: $back"}; $legacy+=@{src=$old;dst=$back}}
}}
foreach($item in $plan) {
 if(SameFile $item.src $item.dst) {Write-Host "SKIP $($item.dst)"}
 elseif($DryRun){Write-Host "PLAN $($item.dst)"}
 else {$dir=Split-Path -Parent $item.dst; [void](New-Item -ItemType Directory -Path $dir -Force); Copy-Item -LiteralPath $item.src -Destination $item.dst -Force; Write-Host "WRITE $($item.dst)"}
}
foreach($item in $legacy){if($DryRun){Write-Host "PLAN-RETIRE $($item.src)"}else{[void](New-Item -ItemType Directory -Path (Split-Path -Parent $item.dst) -Force); Move-Item -LiteralPath $item.src -Destination $item.dst}}
