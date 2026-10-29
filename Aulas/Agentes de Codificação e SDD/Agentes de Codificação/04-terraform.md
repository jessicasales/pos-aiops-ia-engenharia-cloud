# Terraform — cluster EKS com OpenCode e Plan Mode

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Agentes de Codificação |
| **Aula** | 04 — Terraform (27:03) |
| **Assunto** | Infraestrutura como código (EKS na AWS) com OpenCode, usando Plan Mode para tarefas complexas |
| **Data** | 29/10/2026 19:19 |
| **Tags** | `terraform` `eks` `aws` `opencode` `plan-mode` `scratchpad` `vpc` |

## Resumo da aula

Terceira etapa: criar a infraestrutura como código (cluster **EKS** gerenciado na AWS) para rodar o EncontroStack, usando o **OpenCode** (modelo GPT-5 Plus do OpenCode Go). Diferente das etapas anteriores, aqui o professor liga o **Plan Mode** antes de construir, por ser uma tarefa com mais detalhes de implementação.

## Conceitos principais

### Por que Plan Mode aqui
Tarefas mais extensas/complexas se beneficiam do agente **não executar nada primeiro**, só pesquisar e montar um plano — é a aplicação prática do **Scratchpad** da engenharia de contexto, revisável antes de construir.

### Estrutura pedida no prompt
- Analisar a aplicação (código, Dockerfile, dependências) e **definir o perfil computacional** (tipo de instância EC2 + quantidade de nós) com justificativa de CPU/memória, **antes de gerar qualquer arquivo**.
- Provider AWS com região como variável (default `us-east-1`).
- VPC dedicada com subnets públicas e privadas em 2 AZs.
- Cluster EKS gerenciado + node pool com tipo/quantidade configuráveis por variável.
- Arquivos separados: `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`.
- Outputs: nome do cluster + comando para gerar o kubeconfig.

### Análise que o agente devolveu
- App: ~0,5 vCPU / 800 MB; Postgres: ~0,5 vCPU / 500 MB–1 GB; overhead do sistema Kubernetes: ~3 vCPU "fracionado" / 500 MB. Total estimado ≈ 1,3 vCPU / 2,3–2,8 GB.
- Recomendação: **t3.medium** (2 vCPU / 4 GB), com margem para pico; **t3.large** sugerido como alternativa para produção com mais carga.
- Mais de 1 nó por alta disponibilidade e rolling updates.

### Limitações observadas (modelo "congelado no tempo")
- O agente usou **versão antiga do provider AWS** (v5, quando a atual era 6.x) e **versão antiga do Kubernetes** (1.31, quando a AWS já oferecia 1.35) — o modelo não sabe a versão corrente sem pesquisa web, que não foi usada aqui de propósito (fica para quando o harness for calibrado).
- Mesmo desatualizado, funcionou — o Terraform aceitou as versões disponíveis no momento.

### Fluxo de execução
1. Prompt em Plan Mode → análise + plano de arquivos (sem criar nada).
2. Ajustes pedidos durante o plano: versão do Kubernetes como variável; depois, após ver os arquivos gerados, adicionar `cluster_creator_admin_permissions`.
3. `Shift+Tab` para sair do Plan Mode → "sim" para construir.
4. Conferência manual contra a **documentação oficial do provider** (registry.terraform.io) — provider desatualizado identificado, estrutura ok.
5. `terraform init` / `validate` / `apply` rodados **manualmente** (não pelo agente, por ser demorado).
6. Teste real: cluster criado na AWS, `kubectl get nodes` conectado, aplicação deployada e acessível; node group confirmado usando exatamente o t3.medium definido pela análise da IA.
7. `terraform destroy` ao final para não gerar custo.

## Prompts da aula

```text
Primeiro, analise esta aplicação (código, Dockerfile, dependências) e
defina o melhor perfil computacional para os nodes de um cluster
Kubernetes que vai rodá-la: tipo de instância EC2 e quantidade de nós,
com justificativa baseada nos requisitos de CPU e memória da app.
Me apresente essa análise antes de gerar qualquer arquivo.

Depois, crie a configuração Terraform em uma pasta chamada terraform/
para provisionar um cluster Kubernetes gerenciado na AWS (EKS).
Requisitos:
- Provider AWS, com a região vinda de uma variável (default us-east-1)
- Uma VPC dedicada com subnets públicas e privadas em 2 zonas de
disponibilidade
- Um cluster EKS gerenciado
- Um node pool gerenciado com o tipo de instância e a quantidade de nós
definidos na sua análise, ambos configuráveis por variável
- Organize em arquivos separados: providers.tf, variables.tf, main.tf e
outputs.tf
- Nos outputs, exponha pelo menos o nome do cluster e o comando para gerar
o kubeconfig
Não rode nenhum comando ainda. Só gere os arquivos para eu revisar.
```

```text
Faltou como variável a versão do Kubernetes e o valor default da versão.
Adicione.
```

```text
Adicione o campo cluster_creator_admin_permissions no cluster EKS.
```

## Pegadinhas
- Modelo não sabe a versão atual de providers/Kubernetes — **sempre confira contra a documentação oficial** antes de aplicar em produção, especialmente em projetos de infra.
- `terraform apply` rodado localmente requer AWS CLI configurado e credenciais IAM — fora do escopo desta aula.
- Testar sempre com `terraform destroy` ao final de experimentos para não deixar custo rodando.

## Dúvidas para revisar
- Adaptar o mesmo prompt para Azure/GCP/DigitalOcean, como sugerido na aula.
- Automatizar a checagem de versão atual de provider/Kubernetes via MCP/pesquisa web (temas futuros do curso).
