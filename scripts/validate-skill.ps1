param([string]$SkillRoot=(Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference="Stop"
$required=@("SKILL.md","agents\openai.yaml","references\planning.md","references\review-integration.md","references\recovery.md","references\governance.md","references\dispatch.md","assets\task-contract.template.yaml","assets\project-policy.default.yaml")
foreach($f in $required){if(-not(Test-Path(Join-Path $SkillRoot $f))){throw "Missing: $f"}}
$skill=Get-Content -Raw (Join-Path $SkillRoot "SKILL.md")
foreach($c in @("PROJECT_ORCHESTRATION_AUTHORIZATION","heavy_task_executor=zcode","禁止预加载全部 references/assets","Owner != Independent Reviewer","AWAITING_EXTERNAL_DISPATCH","FAST_RECOVERY","ORCHESTRATOR_FAILOVER","primary_at_safe_boundary")){if($skill -notmatch [regex]::Escape($c)){throw "Missing concept: $c"}}
if($skill.Length -gt 7000){throw "SKILL.md too long: $($skill.Length) chars (limit 7000)"}
if($skill -match "Codex.*(大 Token|High-Token).*优先"){throw "Possible old Codex-heavy rule"}
$task=Get-Content -Raw (Join-Path $SkillRoot "assets\task-contract.template.yaml")
if($task -match "integrator:\s*codex"){throw "Integrator is hard-coded to codex"}
Write-Host "Lean failover skill validation PASS ($($skill.Length) chars)"
