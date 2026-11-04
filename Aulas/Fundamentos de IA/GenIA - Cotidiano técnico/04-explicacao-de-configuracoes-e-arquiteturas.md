# Explicação de Configurações e Arquiteturas

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | GenIA - Cotidiano técnico |
| **Aula** | 04 — Explicação de Configurações e Arquiteturas (09:44) |
| **Assunto** | Usar a IA para entender/revisar IAM, manifestos K8s e arquiteturas, e refinar por menor privilégio |
| **Data** | 04/11/2026 00:55 |
| **Tags** | iam, menor-privilegio, kubernetes, manifesto, seguranca, devsecops, revisao |

## Resumo da aula

A IA ajuda a **entender** arquiteturas/configurações existentes e a **definir** novas com mais velocidade e assertividade. Casos: IAM, security groups, Network ACLs, rede, manifestos K8s, pipelines CI/CD, Terraform.

## Conceitos principais

- Exemplo IAM: pedir para **explicar o que a policy permite e identificar riscos** → a IA aponta violações de menor privilégio (S3 total, IAM irrestrito, escalada de privilégio). Depois, **refinar**: reescrever seguindo **menor privilégio** com os acessos exatos que o usuário precisa (bucket específico, EC2 por tag `environment=dev`, pass-role só para Lambda).
- Exemplo K8s: pedir para **explicar cada campo do manifesto e destacar o que não segue boas práticas de produção** → aponta `latest`, credenciais hardcoded, réplicas, ausência de resource limits/requests, probes, security context.
- Valor em **DevSecOps / pipeline**: identificar vulnerabilidades e sugerir correção (até gerar manifesto novo + PR).

## Prompts da aula

<details>
<summary>Exemplos</summary>

```text
# IAM — análise
Explique o que esta policy IAM permite e identifique riscos de segurança.
[policy]

# IAM — refino por menor privilégio
Reescreva essa policy seguindo o princípio de menor privilégio, considerando que
o usuário é um desenvolvedor que precisa: ler/escrever num bucket S3 específico;
gerenciar instâncias EC2 apenas com tag environment=dev; passar a role
lambda-execution-role para funções Lambda.

# Kubernetes
Explique cada campo desse manifesto do Kubernetes e destaque as configurações
que não seguem boas práticas de produção.
[manifesto]
```

</details>

## Pegadinhas

- Sempre **valide** as sugestões (a IA pode errar).
- Ótimo para quem não domina a sintaxe (IAM) e para revisão por quem já domina.

## Dúvidas para revisar

- Vale colocar essa análise IAM/K8s num gate de pipeline (DevSecOps)?
- Que boas práticas eu quero que a IA sempre cheque nos meus manifestos?
