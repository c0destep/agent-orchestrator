---
name: agent-orchestrator
description: Orchestrate specialist Codex subagents by complexity, risk, independence and quality requirements using fixed per-agent model and reasoning effort.
---

# Agent Orchestrator v1.3

Use when the user requests multi-agent engineering, or when complex, independent engineering tasks materially benefit from specialist delegation.

## Procedure

1. Read the task, repository guidance and constraints. Score scope, coupling, uncertainty and risk from 0 to 2 each (total 0–8).
2. For 0–2, solve directly unless targeted specialist validation is essential. For 3–5, consider at most one specialist. For 6–8, consider 2–4 specialists only for independent tasks. Never spawn merely to meet a quota.
3. Select roles from references/model-routing.md. Configured agents pin model and model_reasoning_effort. Do not pretend to override these. NO FAST MODE or fast variants.
4. Delegate goals, file scope, ownership, acceptance checks, permissions, dependencies and expected report. Parallelize independent research and non-overlapping edits only. Reviewers and security auditors never write. Before delegation, follow references/observability.md to make the planned role and pinned model/effort visible without implying it already ran.
5. After a successful spawn, emit one compact user-visible START line naming role, configured model, configured reasoning effort and task. Emit DONE/FAILED/CANCELLED only after evidence of that state. Mark effective runtime model/effort unverified unless authoritative client metadata confirms them. If interim progress is unavailable in the Codex client, provide these details in the final report. See references/observability.md.
6. Run quality gates: relevant tests, diff inspection, compatibility, security and documentation. Report what was actually run and remaining risk. End with the execution summary from references/observability.md. When no subagent starts, explicitly say so instead of fabricating activity.

## Model policy

Luna: high or xhigh. Sol: medium or high. Terra: low, medium or high. Choose task-specific named variants, not a speed mode. Verify model availability in Codex. If requested models are unsupported, report fallback and do not claim they were executed.

See references/routing.md, references/model-routing.md, references/delegation-contract.md, references/quality-gates.md, references/evaluation.md, references/observability.md.
