# Agent Orchestrator

**Skill de orquestração de subagentes para Codex**. Escolhe especialistas conforme a natureza da tarefa, complexidade, incerteza e risco, com **modelos e esforços predefinidos** para cada função. A prioridade é qualidade e eficiência, sem criar agentes no modo de velocidade.

**Versão:** `1.3.0` · **16 configurações** · **Modelos:** GPT-6 Luna, GPT-6.1 Sol e GPT-6.1 Terra · **Licença:** MIT

> **Importante:** instalar os arquivos não garante que todos os modelos estejam disponíveis na sua conta/cliente Codex. A Skill tem política de fallback e não finge que um agente foi executado quando não foi.

## Como funciona

```text
                         Solicitação no Codex
                                 │
                    ┌────────────▼────────────┐
                    │ Orchestrator (Skill)     │
                    │ escopo + risco + plano   │
                    └────────────┬────────────┘
                                 │
                 pontuação de complexidade 0–8
                                 │
          ┌──────────────────────┼──────────────────────┐
          ▼                      ▼                      ▼
      0–2: direta           3–5: focada            6–8: coordenada
      agente principal      até 1 especialista      2–4 se independentes
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 ▼
                   integração e quality gates
                 diff + testes + revisão + risco
                                 ▼
                       entrega com evidências
```

A pontuação soma quatro dimensões (`0`, `1` ou `2` cada): **escopo, acoplamento, incerteza e risco**. Ela orienta o *número* de agentes, não determina sozinha o esforço do raciocínio: uma mudança pequena em autenticação pode exigir revisão de segurança profunda, enquanto uma atualização mecânica grande pode continuar simples.

**Regras de trabalho:** somente paralelizar tarefas independentes, um responsável por arquivo quando houver escrita, revisão e segurança em leitura, e responsabilidade final do agente principal pelos resultados. Se a tarefa for trivial, não delegar. Segurança e regressões não são dispensadas por pressão de tempo.

## Agentes, modelos e esforços

| Agente | Modelo | Esforço | Especialidade |
| --- | --- | --- | --- |
| `code_explorer` | Luna (`gpt-6-luna`) | `high` | Inspeção localizada, rastreamento de fluxo |
| `code_explorer_deep` | Luna | `xhigh` | Dependências extensas e ambiguidade |
| `architect` | Sol (`gpt-6.1-sol`) | `medium` | Decisões e interfaces bem delimitadas |
| `architect_deep` | Sol | `high` | Arquitetura complexa e migrações |
| `implementer` | Terra (`gpt-6.1-terra`) | `medium` | Mudanças pontuais e especificadas |
| `implementer_complex` | Sol | `medium` | Implementação multiarquivo |
| `implementer_deep` | Sol | `high` | Lógica difícil e invariantes |
| `test_engineer` | Terra | `medium` | Testes e casos de borda conhecidos |
| `test_engineer_deep` | Terra | `high` | Regressões e concorrência |
| `reviewer_scoped` | Luna | `high` | Revisão objetiva de baixo risco |
| `reviewer` | Sol | `high` | Revisão aprofundada |
| `security_auditor` | Sol | `high` | Autenticação, privilégios, dados e segredos |
| `debugger` | Sol | `medium` | Falhas reproduzíveis |
| `debugger_deep` | Sol | `high` | Diagnósticos complexos |
| `docs_writer` | Terra | `low` | Atualizações simples de documentação |
| `docs_writer_advanced` | Terra | `medium` | Guias de migração e API |

**Política fechada da v1.2:** Luna usa `high`/`xhigh`; Sol usa `medium`/`high`; Terra usa `low`/`medium`/`high`. Nenhum agente utiliza modo Fast. O Codex recebe os valores através das definições TOML, por exemplo:

```toml
name = "architect"
model = "gpt-6.1-sol"
model_reasoning_effort = "medium"
```

Veja [a matriz e escalonamento](src/skills/agent-orchestrator/references/model-routing.md) para critérios completos.

## Acompanhar agentes no Codex CLI (v1.3)

Ao usar `$agent-orchestrator`, o agente principal é instruído a informar **agente, modelo configurado, esforço configurado e status** na conversa, quando o cliente permitir mensagens de progresso. Isso **não altera o painel nativo `/agents`** nem garante que a saída apareça em tempo real em todas as versões do CLI.

Exemplo ilustrativo após uma criação confirmada:

```text
[orchestrator] START | reviewer | configured: gpt-6.1-sol / high | effective: unverified | task: review authentication diff
[orchestrator] DONE  | reviewer | configured: gpt-6.1-sol / high | effective: unverified | result: review finished
```

No encerramento, a Skill apresenta uma tabela com os agentes selecionados, modelo/esforço *configurados*, confirmação do runtime quando disponível e resultado. Se não houver delegação, informa a execução direta. Se o Codex não mostrar avisos intermediários, a tabela final funciona como alternativa.

**Configurado não significa efetivamente executado:** os valores vêm dos arquivos TOML e não comprovam qual modelo foi servido pelo backend. A Skill marca `unverified` quando não existe metadata confiável; mudança de agente ou fallback deve ser declarada. Nenhum status deve ser inventado. Para o protocolo completo, consulte [observability.md](src/skills/agent-orchestrator/references/observability.md).

Para testar no Codex:

```text
$agent-orchestrator Analise este projeto usando especialistas somente se necessário. Informe na conversa cada subagente iniciado, seu modelo e esforço configurados; mostre status e um resumo ao final.
```

## Requisitos

- **Codex** (CLI ou ambiente que suporte Skills locais e agentes personalizados).
- **Git** para clonar o repositório; ou baixe o código como ZIP.
- **Linux/macOS:** Bash e ferramentas padrão (`find`, `sort`, `cp`, `cmp`, `mv`).
- **Windows:** PowerShell 5.1+; comandos abaixo também funcionam no PowerShell 7+.
- **Python 3.11+** somente para executar o validador estático, não é necessário para instalar.
- Acesso aos modelos depende da versão do Codex e dos modelos habilitados na conta.

## Instalar no Linux (inclui Fedora)

Clone este repositório para uma pasta local:

```bash
git clone https://github.com/c0destep/agent-orchestrator.git
cd agent-orchestrator
```

### Global, para todos os seus projetos

```bash
bash install.sh --user --dry-run
bash install.sh --user
```

Arquivos instalados:

- Skill: `~/.agents/skills/agent-orchestrator/`
- Subagentes: `${CODEX_HOME:-~/.codex}/agents/`

### Apenas no projeto atual

```bash
bash install.sh --project /caminho/do/projeto --dry-run
bash install.sh --project /caminho/do/projeto
```

A Skill ficará em `.agents/skills/agent-orchestrator/` e os agentes em `.codex/agents/` do projeto informado. Reinicie a sessão do Codex, se necessário.

## Instalar no Windows (PowerShell)

```powershell
git clone https://github.com/c0destep/agent-orchestrator.git
Set-Location agent-orchestrator
```

### Global, para todos os seus projetos

```powershell
.\install.ps1 -Scope User -DryRun
.\install.ps1 -Scope User
```

Instala em `%USERPROFILE%\.agents\skills\agent-orchestrator\` e `%USERPROFILE%\.codex\agents\`, ou em `%CODEX_HOME%\agents\` se a variável estiver definida.

### Apenas no projeto atual

```powershell
.\install.ps1 -Scope Project -ProjectPath 'C:\Projetos\MinhaAPI' -DryRun
.\install.ps1 -Scope Project -ProjectPath 'C:\Projetos\MinhaAPI'
```

> Se o PowerShell bloquear scripts, verifique a política de execução. Não é necessário desabilitar proteções globalmente. Você pode rodar em uma nova sessão temporária com `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Scope User`, caso a política da sua organização permita.

## Atualizar da v1.1 para v1.2

**Revise personalizações antes de sobrescrever configurações.** Os instaladores fazem pré-verificação de conflitos e não alteram `config.toml`, permissões do sandbox ou `AGENTS.md`. `--force`/`-Force` autoriza substituir arquivos existentes com conteúdo diferente.

Linux:

```bash
bash install.sh --user --dry-run --force --retire-legacy
bash install.sh --user --force --retire-legacy
```

Windows:

```powershell
.\install.ps1 -Scope User -DryRun -Force -RetireLegacy
.\install.ps1 -Scope User -Force -RetireLegacy
```

A opção de migração arquiva duas antigas definições substituídas na pasta `.codex/agents/.agent-orchestrator-retired/v1.2.0/` e não sobrescreve backups anteriores. Instalação nova não precisa dessa opção. Para atualização por projeto, altere o escopo correspondente.

## Usar no Codex

Abra o Codex **no repositório que deseja trabalhar**. Invoque explicitamente a Skill:

```text
$agent-orchestrator Analise esta API PHP. Classifique a complexidade, delegue apenas investigações independentes e entregue um diagnóstico com evidências. Não modifique arquivos.
```

Ou peça implementação com validação:

```text
$agent-orchestrator Implemente validação de CPF/CNPJ nesta API PHP. Avalie o risco, selecione especialistas apenas se necessário, escreva testes Pest e revise o diff antes de entregar.
```

Diagnóstico difícil:

```text
$agent-orchestrator Investigue o bug intermitente de concorrência. Procure uma reprodução mínima, avalie o uso do debugger_deep e apresente hipóteses com testes para confirmá-las. Não altere produção.
```

Revisão de segurança:

```text
$agent-orchestrator Revise as alterações de autenticação desta branch. Use auditoria de segurança independente se disponível, reporte achados por severidade com arquivos/linhas e não faça modificações.
```

É possível também pedir explicitamente um papel, mas o orquestrador deve justificar o uso e pode executar diretamente quando for mais adequado. Você pode acompanhar o uso de agentes na interface do Codex, conforme recursos do cliente.

### Se os subagentes não aparecerem

1. Confirme `SKILL.md` no caminho de escopo correto e 16 TOMLs em `agents/`.
2. Reinicie a sessão do Codex e confira se a Skill aparece no seletor.
3. Confira se os subagentes estão habilitados (`[agents] enabled = true` no `config.toml` quando houver configuração explícita de desativação). O padrão atual é habilitado.
4. Confirme os modelos disponíveis no seu Codex. Sem suporte ao modelo configurado, escolha uma alternativa disponível ou execute a etapa no agente principal.

**Não configure um modelo só em um prompt esperando que ele sobrescreva o TOML**: os valores definidos no arquivo do agente têm prioridade.

## Estrutura do repositório

```text
agent-orchestrator/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── PUBLISH.md               # como criar o repositório remoto
├── install.sh                 # Linux e macOS
├── install.ps1                # Windows PowerShell
├── src/
│   ├── agents/               # 16 papéis Codex (*.toml)
│   └── skills/
│       └── agent-orchestrator/
│           ├── SKILL.md
│           ├── agents/openai.yaml
│           └── references/    # routing, qualidade, modelos, avaliação
├── tests/
│   ├── validate.py
│   └── validate-windows.ps1
└── .github/workflows/validate.yml
```

## Publicar ou fazer fork

Para criar um repositório remoto a partir deste pacote, veja [PUBLISH.md](PUBLISH.md) (via GitHub CLI ou site).

## Validação e contribuição

Validação estática (Python 3.11+):

```bash
python3 tests/validate.py
```

Validação do instalador Windows:

```powershell
.\tests\validate-windows.ps1
```

O CI do GitHub executa verificações em Ubuntu e Windows a cada push ou pull request. Essas verificações **não comprovam a execução real dos agentes nem o acesso aos modelos**.

Contribuições devem manter o contrato de delegação, a política de modelos e os quality gates. Antes de propor uma mudança, acrescente um caso mensurável em [evaluation.md](src/skills/agent-orchestrator/references/evaluation.md); rode os testes; explique o benefício e qualquer regressão.

## Documentação oficial

- [Criando Skills no Codex](https://learn.chatgpt.com/docs/build-skills)
- [Subagentes e precedência de configuração](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Catálogo de modelos OpenAI](https://developers.openai.com/api/docs/models)

---

Projeto independente, não oficial, construído para o Codex. Licenciado sob MIT.