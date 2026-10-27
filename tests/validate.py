import pathlib, tomllib
root = pathlib.Path(__file__).resolve().parents[1]
roles = sorted((root / "src/agents").glob("*.toml"))
assert len(roles) == 16, len(roles)
allowed = {"gpt-6-luna": {"high", "xhigh"}, "gpt-6.1-sol": {"medium", "high"}, "gpt-6.1-terra": {"low", "medium", "high"}}
for role in roles:
    d = tomllib.loads(role.read_text())
    assert d["model_reasoning_effort"] in allowed[d["model"]], role
    assert "fast" not in role.name.lower()
assert (root / "src/skills/agent-orchestrator/SKILL.md").exists()
print("PASS: 16 valid roles, efforts, skill and no Fast variants")

obs = (root / "src/skills/agent-orchestrator/references/observability.md").read_text()
skill = (root / "src/skills/agent-orchestrator/SKILL.md").read_text()
readme = (root / "README.md").read_text()
for term in ("START", "DONE", "FAILED", "FALLBACK", "unverified", "configured"):
    assert term in obs, term
assert "references/observability.md" in skill
assert "not" in obs.lower() and "/agents" in obs
assert "1.3.0" in readme
print("PASS: reporting policy documents configured vs effective runtime settings")
