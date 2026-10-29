# Docker K8s — Dockerfile, Compose e manifests com Claude Code

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Agentes de Codificação |
| **Aula** | 02 — Docker K8s (31:25) |
| **Assunto** | Containerizar o EncontroStack e gerar manifests Kubernetes com Claude Code, do zero (sem harness) |
| **Data** | 29/10/2026 19:19 |
| **Tags** | `claude-code` `dockerfile` `docker-compose` `kubernetes` `kind` `chain-of-thought` `liveness` `readiness` |

## Resumo da aula

Primeira etapa prática: usar o Claude Code, **sem nenhuma configuração/harness adicional** ("modo freestyle"), para analisar o projeto, criar Dockerfile + docker-compose, validar com execução real, depois gerar os manifests Kubernetes e validar num cluster **kind**.

## Conceitos principais

### Fluxo em 4 prompts
1. **Exploratório (só leitura)** — pede um panorama do projeto (stack, porta, deploy, dependências, variáveis de ambiente) **sem escrever nada**. Serve de onboarding.
2. **Criação de Dockerfile + docker-compose** — prompt estruturado com Chain of Thought: analisar antes de escrever (stack, porta, dependências) → só então decidir a containerização.
3. **Verificação** — pedir explicitamente para executar comandos Docker e validar que a aplicação sobe (não basta criar o arquivo).
4. **Manifests Kubernetes** — mesma lógica: analisar o docker-compose, separar variáveis sensíveis de não sensíveis, criar Deployment + Service + ConfigMap + Secret + probes, testar com **kind**, e por fim consolidar tudo num único YAML.

Importante: o professor **não deixou o Claude Code criar direto** a partir da análise exploratória — preferiu um prompt de criação próprio, mais reutilizável (parametrizável), em vez de popular o contexto com a exploração e pedir "cria".

### Requisitos de design passados no prompt (reaproveitáveis)
- Imagem base **slim** (sem amarrar à linguagem no nome, para reaproveitar o prompt em outros projetos).
- Instalar dependências via gerenciador de pacotes do projeto.
- Servir com **servidor de produção** — nunca o servidor de desenvolvimento (ex. não usar `flask run`/`fastapi run dev`; aqui usou **Gunicorn**).
- Rodar como **usuário não-root**.
- Expor a porta da aplicação.
- Dockerfile dentro de `src/`; docker-compose na raiz; nome da imagem como parâmetro (`namespace/repositório`).

### Execução e correções observadas
- O Claude Code detectou sozinho que o Docker Desktop não estava rodando, orientou a ligar e **retentou**.
- Ao pedir validação, encontrou e **corrigiu um bug real** da aplicação (dois workers do Gunicorn chamando `create_all` simultaneamente) — sem que isso tivesse sido pedido explicitamente. Lição: se você não restringe o escopo ("não mexe em código"), o agente resolve tudo que julgar necessário para o objetivo.
- No manifest gerado, usou **NodePort** (adaptado ao `kind`) em vez do `LoadBalancer` esperado — ajuste manual necessário depois.
- `Shift+Tab` duas vezes ativa o **auto mode** (o agente avalia a criticidade e decide pedir permissão ou não).

## Prompts da aula

```text
# 1. Reconhecimento (sem escrita)
Antes de qualquer coisa, leia a estrutura deste projeto e me dê um panorama
detalhado:
- a aplicação: o que ela é, qual a stack e o framework, como ela sobe, em qual
porta escuta e como funciona o deploy dela hoje
- os requisitos básicos do projeto
- as dependências externas: banco de dados, serviços ou APIs de que ela depende
- as configurações de variáveis de ambiente: quais ela espera e pra que serve
cada uma
- o que precisa estar instalado numa máquina pra executar essa aplicação

Não escreva em nenhum arquivo. Só me dê o panorama.
```

```text
# 2. Dockerfile + docker-compose
Crie um Dockerfile e um docker-compose.yml para containerizar esta aplicação.
Antes de escrever qualquer coisa, analise o projeto passo a passo:
1. Identifique a stack, o framework e as principais bibliotecas
2. Descubra como a aplicação é executada e em qual porta ela escuta
3. Mapeie as dependências externas (banco de dados, serviços) de que ela
precisa para funcionar
4. Com base nessa análise, decida a melhor forma de containerizar

Depois da análise, crie os arquivos cumprindo estes requisitos:

Dockerfile:
- Imagem base slim
- Instalar as dependências a partir do gerenciador de pacotes
- Servir com o servidor de produção adequado que você detectou no projeto
(NÃO usar o servidor de desenvolvimento)
- Rodar como usuário não-root
- Expor a porta da aplicação

Criar o Dockerfile dentro da pasta src junto com o fonte do projeto

docker-compose.yml:
- O objetivo é a aplicação rodar 100% em containers num ambiente local de
desenvolvimento
- A imagem da aplicação deve ser buildada com o nome
fabricioveronez/encontros-tech-pos (namespace/repositório)
- Toda dependência externa que a aplicação precisar deve subir como serviço
do compose, em container
- Configure as variáveis de ambiente necessárias para os serviços se
conectarem entre si

Crie o docker compose na raiz do projeto.
```

```text
# 3. Verificação
Execute as etapas de verificação para garantir que a aplicação funciona utilizando o Dockerfile e o docker compose.
Execute os comandos com Docker para levantar a aplicação e garantir que está funcionando.
```

```text
# 4. Manifests Kubernetes
Crie os manifests de Kubernetes para fazer o deploy desta aplicação num
cluster. Antes de escrever qualquer coisa, analise o projeto passo a passo:
1. Identifique a stack, como a aplicação executa e em qual porta ela escuta
2. Leia o docker-compose.yml e identifique a imagem da aplicação e as
dependências externas de que ela precisa
3. Mapeie as variáveis de ambiente e separe as sensíveis (credenciais) das
não sensíveis
4. Com base nessa análise, decida como estruturar o deploy

Depois da análise, crie os manifests cumprindo estes requisitos:
- Deployment da aplicação, usando a imagem definida no docker-compose
- Service para expor a aplicação externamente
- ConfigMap para as variáveis de ambiente NÃO sensíveis
- Secret para as variáveis sensíveis
- liveness e readiness probes no Deployment, usando o path padrão (/) na
porta utilizada pela aplicação

Organize os manifests numa pasta k8s/.

Execute as etapas de verificação para garantir que a aplicação funciona utilizando o ambiente Kubernetes.
Execute os comandos com necessários para levantar a aplicação e garantir que está funcionando.
Execute a criação do cluster Kubernetes para esse ambiente de teste utilizando o kind. Ele já está instalado na máquina. Depois de verificar a qualidade e ter feito todos os testes você pode destruir o cluster utilizando também o comando kind.
```

```text
# 5. Consolidar
Edite os arquivos e utilize apenas um arquivo YAML. Utilize o nome encontros-tech.yaml
```

## Pegadinhas
- Se não restringir o escopo no prompt, o agente pode corrigir código de produção "por conta própria" ao perseguir o objetivo — bom e perigoso ao mesmo tempo.
- Manifests testados com `kind` tendem a vir ajustados para `kind` (ex. `NodePort`) — revise antes de levar para um cluster real.
- Cuidado com portas: `hostPort` × `containerPort` diferentes causaram erro de acesso na aula — sempre confira o manifest/compose linha a linha.

## Dúvidas para revisar
- Repetir esse fluxo com o `kind` localmente para treinar a leitura de erros do agente.
