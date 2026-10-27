# Agent run visibility (Codex CLI and chat)

## Goal and limitations

For every delegation, make role, **configured** model, **configured** reasoning effort, task and lifecycle status visible in the parent conversation when the Codex client exposes assistant messages. Do not modify or promise control of the native `/agents` panel or the CLI status bar: rendering and availability are client-owned.

This skill is an instruction protocol, not an instrumentation or telemetry API. It cannot independently observe the backend-served model, actual reasoning effort, rate-limit pool or token consumption. The TOML configuration is **intent**, not proof of the effective runtime configuration. Never suggest that a child self-report or a copied role name proves its serving model.

## Status lifecycle

Default is **compact**. Communicate only meaningful transitions, no per-tool chatter. For each selected agent:

1. **PLAN** before spawning (optional if spawning immediately): announce selection without implying execution.
2. **START** only when the orchestration tool confirms successful creation, with exact role used, configured model/effort read from the matching TOML, task and known child ID if supplied.
3. **DONE** / **FAILED** / **CANCELLED** only after receiving the corresponding tool outcome. Include a one-line result or blocker.
4. **FALLBACK** when requested role/model is unavailable or the execution changes: show requested and fallback choices, or `unknown` where runtime metadata is absent. Never relabel an inherited parent thread as the requested specialist.
5. **DIRECT** when no subagents were invoked: show complexity score and explicitly say none were started.

Example user-visible message *after a successful spawn*:

```text
[orchestrator] START | code_explorer_deep | configured: gpt-6-luna / xhigh | effective: unverified | task: map billing dependencies
```

Example after conclusion:

```text
[orchestrator] DONE  | code_explorer_deep | configured: gpt-6-luna / xhigh | effective: unverified | result: dependency map delivered
```

If the client does not surface interim assistant commentary, include the same facts in the final recap. Do not run shell `echo` solely to simulate a Codex UI notice; terminal tool output is not equivalent to a native agent label.

## Source-of-truth and evidence

- `configured`: the exact `model` and `model_reasoning_effort` fields from the selected role's current TOML (or `unspecified` if absent). Do not guess from names.
- `effective`: mark `unverified` by default; promote to `confirmed by client` **only** if supported runtime metadata explicitly identifies the child model and effort. Attribute this to client metadata; if only model is available, confirm model alone and mark effort unverified.
- `fallback`: separately describe what was requested, what was actually launched (if known) and the limits of runtime verification.
- Never claim actual model usage based only on a subagent's textual statement, the parent model, a static file, or a pre-spawn plan.
- Do not ask agents to reveal hidden reasoning. Status lines convey operational activity only.

## Final execution summary

When delegating, always show a concise summary (Portuguese if the user's request is in Portuguese):

| Agent | Configured model | Configured effort | Runtime confirmation | Status |
|---|---|---|---|---|
| code_explorer_deep | gpt-6-luna | xhigh | not verifiable | completed |
| reviewer | gpt-6.1-sol | high | not verifiable | failed |

These are examples, not observations. Only list agents actually selected; mark planned-but-not-launched separately or omit them with a note. Mention tests actually run. Never omit a failed/fallback agent from the recap.

Users may request a detailed report with the assignment, child IDs (if available), milestones and evidence. Keep the default compact to minimize noise and cost.
