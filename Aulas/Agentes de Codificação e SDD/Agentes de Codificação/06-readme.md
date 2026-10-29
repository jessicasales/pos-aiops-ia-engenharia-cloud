# Readme — documentação do projeto com Antigravity

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Agentes de Codificação |
| **Aula** | 06 — Readme (06:38) |
| **Assunto** | Gerar README.md fiel ao repositório (sem alucinar) com Antigravity CLI |
| **Data** | 29/10/2026 19:19 |
| **Tags** | `readme` `documentação` `antigravity` `chain-of-thought` `anti-alucinação` |

## Resumo da aula

Quinta e última etapa: documentar tudo o que foi construído (Docker, Compose, manifests, Terraform, script de seed, endpoints de health/ready) num **README.md**, usando o **Antigravity CLI** do Google (`agy`), com um prompt estruturado em etapas para **evitar alucinação**.

## Conceitos principais

### Técnica: raciocínio em etapas numeradas, só documentar o comprovado
1. **Etapa 1** — ler o repositório inteiro e listar o que encontrou, **citando o arquivo de origem** de cada item (stack, containerização, deploy, testes/seed, infraestrutura, endpoints de saúde, variáveis de ambiente).
2. **Etapa 2** — listar o que **não** encontrou (versões, portas, comandos sem origem) — tudo isso vira **"A confirmar"**, nunca é preenchido por suposição.
3. **Etapa 3** — só então gerar o `README.md`, baseado exclusivamente no confirmado na Etapa 1.

Regra geral: **toda afirmação precisa ter origem em um arquivo do repositório**; o que não tiver vira "A confirmar".

### Seções pedidas
Visão geral · Stack (com versões declaradas) · Pré-requisitos · Como rodar local · Como rodar testes e popular o banco · Como provisionar infraestrutura (Terraform) · Como fazer deploy no Kubernetes · Endpoints de saúde (liveness vs readiness) · Variáveis de ambiente.

### Antigravity CLI
- Comando: `agy`.
- Interface mostra não só a execução das ferramentas, mas também o **raciocínio** (tempo gasto pensando, pode expandir com Ctrl+O).
- Resultado elogiado: "melhor que muito README que você já viu por aí" — vantagem não é só a investigação, mas a **padronização da escrita**.

## Prompt da aula

```text
Você vai gerar o README.md do projeto encontros-tech. Antes de escrever
qualquer coisa, raciocine em voz alta, em etapas numeradas, e só produza o
arquivo na última etapa:

ETAPA 1 — Leia o repositório INTEIRO e me mostre o que encontrou, citando o
arquivo de origem de cada item:
- stack e arquitetura (linguagem, framework, banco)
- containerização (Dockerfile) e deploy no Kubernetes (manifests)
- testes e população de dados (scripts de seed)
- provisionamento da infraestrutura (arquivos Terraform)
- endpoints de saúde (/health, /ready) e variáveis de ambiente que a app lê

ETAPA 2 — Liste o que você NÃO encontrou no repositório (versões, portas,
comandos sem origem). Tudo que cair aqui será marcado como "A confirmar", não
preenchido por suposição.

ETAPA 3 — Só agora crie o README.md na raiz, baseado EXCLUSIVAMENTE no que
você confirmou na Etapa 1, com estas seções:
- Visão geral (o que é o encontros-tech)
- Stack (com as versões declaradas no projeto)
- Pré-requisitos
- Como rodar local (passo a passo real, com os comandos e o Dockerfile/compose existentes)
- Como rodar os testes e popular o banco com dados de exemplo
- Como provisionar a infraestrutura com Terraform (o que o .tf cria e os comandos)
- Como fazer o deploy no cluster Kubernetes (manifests e ordem de aplicação)
- Endpoints de saúde (/health e /ready: o que cada um responde, liveness vs readiness)
- Variáveis de ambiente (cada uma com descrição curta)

Regra que vale para o arquivo todo: toda afirmação tem que ter origem em um
arquivo do repositório. O que não tiver, marque como "A confirmar".
```

## Pegadinhas
- Essa técnica (ler → listar o que faltou → só então escrever) é reaproveitável para qualquer documentação gerada por IA, não só README.

## Dúvidas para revisar
- Reaproveitar este prompt de documentação "anti-alucinação" nos meus próprios projetos/runbooks.
- Relacionar com a skill de design docs (TRD) vista no capítulo Skills — mesmo princípio de "não inventar, marcar premissa".
