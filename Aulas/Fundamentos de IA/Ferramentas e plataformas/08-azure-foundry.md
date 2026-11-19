# Azure Foundry

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | Ferramentas e plataformas |
| **Aula** | 08 — Azure Foundry (09:05) |
| **Assunto** | Serviço de modelos/agentes da Microsoft no Azure: criar projeto, implantar modelo, comparar e apagar recursos |
| **Data** | 04/11/2026 00:45 |
| **Tags** | azure, microsoft-foundry, modelos, playground, resource-group, custo |

## Resumo da aula

O **Microsoft Foundry** (Azure) disponibiliza modelos e permite criar agentes. Foco: usar/testar/comparar modelos.

## Conceitos principais

- **Criar projeto** no Foundry vincula a uma assinatura e cria os recursos num **Resource Group** no Azure.
- **Catálogo** amplo: GPT, Claude Opus, Qwen, Grok, DeepSeek, open source, etc. **Implantar** o modelo e usar no **playground** (chat), com system prompt, max tokens, reasoning, API key/endpoint.
- **Comparar** modelos lado a lado (ex.: GPT mini vs. nano).

### Custo e limpeza

Recursos ativos **geram cobrança**. Para parar: no portal do Azure, **Delete Resource Group** — apaga tudo do Foundry e zera a cobrança. (Cadastro novo costuma dar ~US$200 de crédito.)

## Pegadinhas

- Deixar o serviço ativo cobra — delete o resource group ao terminar.
- Para flows/agentes a pós usa n8n (agnóstico), não o flow nativo.

## Dúvidas para revisar

- Preciso integrar modelos de IA aos serviços do Azure? → Foundry.
