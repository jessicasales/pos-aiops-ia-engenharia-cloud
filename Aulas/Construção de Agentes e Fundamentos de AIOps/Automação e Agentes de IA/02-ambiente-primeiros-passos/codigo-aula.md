# Código da Aula — 02 Ambiente primeiros passos

Conteúdo extraído literalmente do painel "Material Complementar" (Links Úteis + Código da Aula) da plataforma, aula **Ambiente de Trabalho e Primeira Execução**.

## Links úteis

- **Repositório**: `exemplos-langchain-devops`

## Código da Aula

> Os comandos abaixo podem ser copiados direto e reproduzidos no seu próprio ambiente, na ordem em que apareceram na gravação.

### Sincronização de dependências com `uv sync`

Primeiro comando executado ao preparar o ambiente, antes de rodar o projeto pela primeira vez — sincroniza as dependências travadas no `uv.lock` sem expor nenhuma credencial.

```bash
uv sync
```

### Primeira execução com resposta integral

Comando usado para a primeira execução do projeto, invocando a função de resposta completa (modo `invoke`, sem streaming). O retorno inclui o objeto `AIMessage` com o texto de resposta e os metadados de uso (`usage_metadata`) — tokens de entrada, saída e total.

```bash
uv run src/app.py
```
