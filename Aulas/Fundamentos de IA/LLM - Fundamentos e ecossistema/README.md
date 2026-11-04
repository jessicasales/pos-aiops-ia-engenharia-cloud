# LLM - Fundamentos e ecossistema — Fundamentos de IA

Anotações do capítulo **LLM - Fundamentos e ecossistema** do módulo **Fundamentos de IA** (curso Pós AIOps e IA na Engenharia de Cloud).

Como os LLMs funcionam por dentro (token, janela, Transformer, parâmetros) e o ecossistema de providers — a base para escolher e usar modelos com assertividade.

| # | Conteúdo | Duração | Tema |
|---|---|---|---|
| 00 | [Material Complementar](00-material-complementar.md) | — | Projetos de apoio do capítulo |
| 01 | [Introdução aos LLMs](01-introducao.md) | 12:07 | O que é LLM, parâmetros, modelo vs. ferramenta |
| 02 | [Tokens e Tokenização](02-tokens-e-tokenizacao.md) | 19:44 | Token, custo input/output, idioma |
| 03 | [Janela de Contexto](03-janela-de-contexto.md) | 15:41 | Limite de tokens, qualidade, gerenciamento |
| 04 | [Transformer](04-transformer.md) | 07:37 | Geração token a token |
| 05 | [Temperatura, Top-p e Top-k](05-temperatura-top-p-top-k.md) | 14:34 | Controle da geração |
| 06 | [Providers, modelos e critérios](06-providers-modelos-criterios.md) | 06:11 | Panorama e escolha (LLM vs. SLM) |

## Resumo rápido

- **LLM** guarda **parâmetros** (vetores), não texto; prevê a próxima palavra por probabilidade.
- **Token** é a menor unidade e a **base de cobrança** (PT gasta mais que EN).
- **Janela de contexto** é a memória da sessão; acima de ~60% degrada; gerencie com RAG/chunking/compactação.
- **Transformer** gera **token a token** → por isso alucina (sempre dá o próximo token mais provável).
- **Temperatura/top-p/top-k** controlam criatividade × determinismo (mexa na temperatura).
- **Escolha de modelo**: custo, latência, qualidade, privacidade; LLM para complexo, SLM para simples/local.
