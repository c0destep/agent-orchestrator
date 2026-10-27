# Fixed model/effort routing

| Role | Model | Effort |
|---|---|---|
| code_explorer | gpt-6-luna | high |
| code_explorer_deep | gpt-6-luna | xhigh |
| architect | gpt-6.1-sol | medium |
| architect_deep | gpt-6.1-sol | high |
| implementer | gpt-6.1-terra | medium |
| implementer_complex | gpt-6.1-sol | medium |
| implementer_deep | gpt-6.1-sol | high |
| test_engineer | gpt-6.1-terra | medium |
| test_engineer_deep | gpt-6.1-terra | high |
| reviewer_scoped | gpt-6-luna | high |
| reviewer | gpt-6.1-sol | high |
| security_auditor | gpt-6.1-sol | high |
| debugger | gpt-6.1-sol | medium |
| debugger_deep | gpt-6.1-sol | high |
| docs_writer | gpt-6.1-terra | low |
| docs_writer_advanced | gpt-6.1-terra | medium |

Luna may use high/xhigh, Sol medium/high, Terra low/medium/high. Never use Fast mode. Select the named deep variant for high-uncertainty tasks. Models might not be available in every Codex release: report fallback explicitly and do not fabricate execution.
