# TRD — gerando o baseline técnico por engenharia reversa

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 07 — TRD (11:28) |
| **Assunto** | Gerar o TRD inicial de um projeto já existente lendo o repositório como fonte de verdade |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `trd` `baseline-técnico` `engenharia-reversa` `anti-alucinação` `brownfield` |

## Resumo da aula

Com os PRDs prontos (health/ready, seed), falta a parte técnica: tecnologias, framework, arquitetura — isso é o **TRD**. Diferente de um projeto do zero (greenfield), aqui o projeto **já existe** (brownfield), então o TRD é gerado por **engenharia reversa**: o agente lê o repositório inteiro e documenta "como ele é hoje".

## Conceitos principais

### Por que centralizar num TRD
Sem um documento técnico central, a IA teria que varrer o código toda vez para entender a stack. O TRD vira a fonte única que o agente carrega para ter esse contexto.

### Regra central do TRD inicial
Descreve **o que o sistema é** (snapshot do estado atual) — **nunca** o que deveria virar. Nada de recomendações/melhorias/refactors aqui. Decisões de "por que X em vez de Y" ficam em **ADR**; mudança de comportamento fica em **PRD**.

### Anti-alucinação (igual à técnica usada no README, no capítulo Agentes de Codificação)
- Antes de escrever qualquer afirmação, o agente deve confirmá-la num arquivo real.
- Se nenhum arquivo sustenta, **não escreve** — nunca infere ou completa a lacuna.
- Onde o código não define um valor, escreve "Não definido"/"Não aplicável" — **nunca omite a linha**.
- O que for relevante mas não confirmável é levantado **na conversa**, fora do documento, para decisão humana.
- Essa verificação é raciocínio interno — o documento final não leva coluna de fonte nem citação `arquivo:linha`.

### Template do TRD (seções fixas, chain-of-thought)
`Stack` → `Arquitetura` (padrão arquitetural, estrutura de pastas, módulos/camadas, rotas, modelo de dados) → `Requisitos Não-Funcionais` (sempre: Performance, Disponibilidade/SLA, Escalabilidade, Segurança, Observabilidade — mesmo que "Não definido") → `Dependências Externas` → `Padrões` (testes, estilo de código, error handling, logging, auth) → `Decisões Globais (ADRs)` (tabela, inicialmente vazia: `*(nenhum ADR registrado)*`).

### O que saiu no exemplo (EncontroStack)
- Linguagem: Python; runtime: Gunicorn; framework: Flask 3.0.0; banco: Postgres.
- Padrão: camadas (router com Blueprints Flask + validação Pydantic → service com regra de negócio → model SQLAlchemy).
- Modelo de dados: só a tabela `Events`.
- Observabilidade: Prometheus com exporter.
- Pontos não confirmáveis: versão exata do Python, endpoint de métricas, como o Gunicorn é executado — o agente perguntou antes de assumir.

### Fechando pendências
Para a versão do Python não confirmada, o professor pediu: *"Verifique a versão atual do Python localmente e defina essa versão"* — o agente checou o ambiente e atualizou o documento. **O TRD é um documento vivo**: vai sendo refinado com o tempo, não sai perfeito de primeira.

## Prompt da aula

<details>
<summary>Prompt — Geração do TRD inicial (baseline técnico)</summary>

```text
Você é um engenheiro documentando o BASELINE TÉCNICO deste projeto. Sua fonte de verdade é o REPOSITÓRIO INTEIRO já aberto — leia o código, os arquivos de configuração e a estrutura de pastas. Documente ESTE projeto como ele É hoje.

TAREFA: gerar o TRD inicial (Technical Requirements Document) do projeto em `docs/trd.md`.

REGRA CENTRAL: o TRD inicial descreve O QUE O SISTEMA É (o estado atual, o baseline), não o que ele deveria virar. Nada de recomendações, melhorias ou refactors. Decisões (por que X em vez de Y) ficam em ADRs; comportamento que muda fica em PRDs.

VERIFICAÇÃO INTERNA (anti-alucinação — NÃO vai pro documento): antes de escrever cada afirmação, confirme-a num arquivo real do repositório. Isso é raciocínio seu, não conteúdo: o documento final NÃO leva coluna de fonte, nem citações de `arquivo:linha`, nem marcações de premissa. Regras:
- Não suponha, não use conhecimento externo sobre "como projetos Flask costumam ser".
- Se nenhum arquivo sustenta uma afirmação, NÃO a escreva — não infira, não complete a lacuna.
- Onde o código não definir um valor esperado pelo template, escreva "Não definido" / "Não aplicável".
- O que for relevante mas você não conseguiu confirmar, me levante NA REVISÃO (na conversa, fora do arquivo) para eu decidir.

O documento final deve seguir EXATAMENTE este template — mesmos headings, mesma ordem, mesmas colunas. Não numere nem coloque os títulos em caixa-alta.

# TRD — <Projeto>

> Documento técnico global do projeto. Granularidade baixa: cobre o que é global e estável.
> Regras finas ficam em ADRs.

## Stack
Tabela com colunas: | Dimensão | Valor |
Dimensões: Linguagem principal, Runtime/plataforma, Framework principal, Banco de dados, Ferramentas de build, Gerenciador de pacotes.

## Arquitetura
### Padrão arquitetural
O padrão em camadas (router → service) em 1-2 linhas, e por que.
### Estrutura de pastas dominante
Árvore de 2 níveis em bloco de código, com 1 linha de responsabilidade por pasta.
### Módulos / camadas principais
Tabela com colunas: | Módulo | Responsabilidade |
### Rotas
Tabela com colunas: | Método | Rota | Handler | (separe API e páginas se existirem os dois).
### Modelo de dados
Uma tabela por entidade/tabela, com colunas: | Coluna | Tipo | Constraints/Default |.

## Requisitos Não-Funcionais
Tabela com colunas: | Dimensão | Requisito |
Inclua SEMPRE estas dimensões, nesta ordem: Performance, Disponibilidade/SLA, Escalabilidade, Segurança, Observabilidade. Onde o código não sustenta um valor, escreva "Não definido" — NÃO omita a linha.

## Dependências Externas
Tabela com colunas: | Serviço / Sistema | Tipo | Constraint relevante | Dono |
Só serviços/sistemas que impõem contrato (ex.: PostgreSQL). Não liste libs de build do lockfile. Se não houver, escreva "Nenhuma".

## Padrões
### Testes
Tabela com colunas: | Item | Valor | — linhas: Framework, Comando completo, Cobertura mínima, Estratégia.
### Estilo de código
Bullets: Linter, Formatter, Convenções de nomenclatura. O que não existir: "Não aplicável".
### Error handling
Prosa curta do padrão real.
### Logging
Bullets: Formato, Nível padrão, Biblioteca.
### Autenticação / autorização
Prosa curta — ou "Não aplicável".

## Decisões Globais (ADRs)
Tabela com colunas: | # | Título | Data | Status | Link |
Ainda não há ADR: deixe uma linha com *(nenhum ADR registrado)*. Os ADRs virão depois e serão indexados aqui.

Ao terminar, me mostre o TRD seção por seção para revisão ANTES de gravar o arquivo — e liste à parte (fora do documento) o que você NÃO conseguiu confirmar no código, pra eu decidir.
```
</details>

## Pegadinhas
- Não executar o prompt completo de uma vez e aceitar sem revisão — o ideal é revisar seção por seção e só depois mandar gravar.
- Esse TRD ainda **não** reflete Docker/Kubernetes (que ainda serão implementados) — ele é um raio-x do estado atual, não do destino. As próximas aulas tratam disso via **ADR**, não editando o TRD diretamente.

## Dúvidas para revisar
- Rodar esse prompt de TRD contra um repositório real do trabalho para ver o que ele identifica/deixa como "Não definido".
